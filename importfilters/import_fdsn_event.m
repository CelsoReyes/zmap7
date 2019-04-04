function [uOutput, ok] = import_fdsn_event(nFunction, code, varargin)
    % Import or fetch FDSN event data
    %
    % to get basic help string:
    %   [helpstr] = import_fdsn_event(0);
    
    % to import from file:
    %   [uOutput] = import_fdsn_event(1, filename);
    %   The file should be a text-formatted (not xml) response from an FDSN webservice.
    %   and will have a single line header and the following fields, using a pipe as separator:
    %
    % EventID|Time|Latitude|Longitude|Depth/km|Author|Catalog|Contributor|ContributorID|MagType|Magnitude|MagAuthor|EventLocationName
    %
    % to fetch from web:
    %   [uOutput] = import_fdsn_event(1, code, [param1, val1, [...]]);
    %   code: data center code, as listed by: 'http://service.iris.edu/irisws/fedcatalog/1/datacenters'
    %
    %   additional arguments: param-value pairs for query to fdsn services.  These must be
    %   lower-case, and are listed by each center. For more details, see http://www.fdsn.org/webservices/
    %
    
    % eg.
    % data = import_fdsn_event(true, 'SED', 'minmagnitude', 4.0,'minlatitude',45,'maxlatitude', 60)
    
    
    % get list of data providers that support the FDSN Event query
    persistent datacenter_details
    
    % Filter function switchyard
    if nFunction == FilterOp.getDescription
        uOutput = 'FDSNWS Events (text) - import ascii data downloaded from one of the FDSN webservice datacenters';
        return
    end
    if nFunction == FilterOp.getWebpage
        uOutput = 'fdsntext.html'; % location of fdsn format documentation
        return
    end
    
    hf = matlab.net.http.HeaderField('Content-Encoding','gzip');
    options = weboptions('timeout',120,'HeaderFields',hf); %seconds
    ZG=ZmapGlobal.Data;
    
    % make sure that this program identified during requests to datacenter
    options.UserAgent=[options.UserAgent,' ZMAP/',ZG.zmap_version];
    
    if isempty(datacenter_details) && ~exist(code,'file')
        datacenter_details = webread('http://service.iris.edu/irisws/fedcatalog/1/datacenters',options);
        
        %dump datacenters with no event catalog access
        i=1;
        while i <= numel(datacenter_details)
            fldnm = fieldnames(datacenter_details(i).serviceURLs);
            if ~ismember('eventService',fldnm)
                datacenter_details(i)=[];
            else
                i=i+1;
            end
        end
        if exist('fdsnservices.json','file')
            try
                % this is the datacenter_details structure, saved as a json file in the resrc directory
                jj=jsondecode(fileread('fdsnservices.json')); % get additional services
                for i=1:numel(jj)
                    % only include datacenters that are not already retrieved by the querying fedcatalog
                    if ~ismember(jj(i).name,{datacenter_details.name})
                        datacenter_details(end+1)=jj(i);
                    end
                end
            catch ME
                disp(['unable to access additional datacenter information: ', ME.message]);
            end
        end
    end
    
    % load FDSN text details that had been saved to a files
    if exist(code,'file')
        [uOutput,ok] = convert_from_fdsn_text(fileread(code));
        if ok
            [~, uOutput.Name] = fileparts(code);
            if mean(uOutput.Depth >= 1000)
                warning('ZMAP:unexpectedUnit','depths look like they are in m instead of km! scaling')
                uOutput.Depth= uOutput.Depth ./ 1000;
            end
        end
        return;
    end
    
    
    % check to see if program merely requests a summary of this type of import
    if nFunction == FilterOp.getDescription
        uOutput=sprintf('Available Datacenters: %s',strcat({datacenter_details(:).name,','}));
        for n=1:numel(datacenter_details)
            disp(datacenter_details(n))
        end
        return
    end
    
    valid_fields = {...
        'minlatitude','maxlatitude','minlongitude','maxlongitude',...bounding rectangle (degrees)
        'latitude','longitude','minradius','maxradius',... bounding circle (degrees)
        'mindepth', 'maxdepth',... in kilometers (+ down)
        'starttime','endtime',... yyyy-MM-DDThh:mm:ss[.sssssss]
        'minmagnitude','maxmagnitude', ...
        'magnitudetype',... can be 'all' or your preferred mag
        'catalog', 'contributor', ... text
        'limit','offset', ... affect which and how many quakes retrieved
        'updatedafter',...
        'includeallmagnitudes',...
        'orderby', ... either 'time' or 'magnitude'
        'eventid',... specify an event by id
        'format' ... 'xml' or 'text'.  Don't use this. we'll automatically get text
        };
    
    for n=1:2:numel(varargin)
        if ~ismember(varargin{n},valid_fields)
            disp(valid_fields);
            error('import_fdsn_event:unrecognized_field',...
                'Unrecognized field: %s', varargin{n});
        end
    end
    
    %the fields seem to be valid FDSN fields.
    provider = datacenter_details(strcmp({datacenter_details.name},code));
    
    baseurl = provider.serviceURLs.eventService;
    
    disp(['sending request to:' baseurl 'query  with options'])
    disp(varargin)
    
    % hasParallel=license('test','Distrib_Computing_Toolbox') && ZG.ParallelProcessingOpts.Enable;
    myuri=[baseurl, 'query?', sprintf('%s=%s&',string(varargin)), 'format=text'];
    resp = get_low_level_fdsn_query(myuri);
    switch resp.StatusCode
        case "OK"
            ok=true;
        case "NoContent"
            warning("No Data was found");
            uOutput=[];
            ok=false;
        case "BadRequest"
            disp(resp.Body.Data)
            numbers= double(regexp(extractBefore(resp.Body.Data,'Request:'),'\d\d\d+','match'));
            % first number is the error, so ignore it.
            numbers(1)=[];
            % second number is 
            % as of 2018-12-14, USGS returns this result when limit is exceeded. these depend on the error message wording
            maxSearchLimit = min(numbers);
            nFound =  max(numbers);
            if ~ismissing(maxSearchLimit)
                warning("maximum number of events [%d] exceeded. attempting to limit results", maxSearchLimit);
                % try again, in chunks of maxSearchLimit
                disp('* trying again while limiting results')
                [resp, ok] = get_in_chunks(myuri, maxSearchLimit, nFound);
            else
                uOutput=[];
                ok=false;
            end
            
        case "PayloadTooLarge"
            disp(resp.Body.Data)
            
            % as of 2018-12-14, INGV returns this result when limit is exceeded. these depend on the error message wording
            nFound = double(extractBefore(extractAfter(resp.Body.Data,'the number of requested events is "'),'";'));
            maxSearchLimit = double(extractBefore(extractAfter(resp.Body.Data,'your request must be less then "'),'" events.'));
            if ~ismissing(maxSearchLimit)
                warning("maximum number of events [%d] exceeded. atttempting to limit results", maxSearchLimit);
                % try again, in chunks of maxSearchLimit
                disp('* trying again while limiting results')
                [resp, ok] = get_in_chunks(myuri, maxSearchLimit, nFound);
            else
                uOutput=[];
                ok=false;
            end
            
        otherwise
            warning("there was some sort of problem. The response follows")
            disp(resp)
            warning(resp.Body.Data)
            uOutput=[];
            ok=false;
    end     
    if ok
        data = char(resp.Body.Data);  
    else
        return
    end
    
    
    %data = webread([baseurl 'query'], varargin{:},'format','xml',options);
    [uOutput, ok] = convert_from_fdsn_text(data);
    
    function [uOutput,ok] = convert_from_fdsn_text(data)
        % the FDSN text format is something like:
        % EventID|Time|Latitude|Longitude|Depth/km|
        % Author|Catalog|Contributor|ContributorID|
        % MagType|Magnitude|MagAuthor|EventLocationName
        %
        % remarks start with #, so the first line is actually #EventID|time, etc..
        % spacing in header line is not guaranteed
        
        if isempty(data)
            uOutput = ZmapCatalog('Name','nodata');
            ok=false;
            return
        end
        ok=true;
        % scan only the relevant fields
        
        %This version makes no assumptions other than the field titles it expects.
        % various FDSN services tend to disagree on formats.. time, spellings, capitalization, etc.
        newlines = find(data==newline,2);
        headerline =data(1:newlines(1)-1);
        hdrs=lower(strip(split(headerline,'|')));
        firstrow = data(newlines(1)+1:newlines(2)-1);
        
        mappings = determine_field_mappings(hdrs, firstrow);
        
        midx = containers.Map;
        fmtstr=[];
        next_idx = 1;
        for ij=1:numel(hdrs)
            
            field = hdrs{ij};
            if field == "longtitude" % SCEDC mispelling
                hdrs{ij} = 'longitude';
                field = hdrs{ij};
            end
            if mappings.isKey(field)
                fmtstr=[fmtstr, mappings(field)]; %field of interest
                midx(field) = next_idx;
                next_idx = next_idx + 1;
            else
                fmtstr=[fmtstr,'%*s']; % ignore field
            end
        end
        try
            mData = textscan(data,fmtstr,'Delimiter','|','Headerlines',1,'MultipleDelimsAsOne',false);
        catch ME
            disp('unable to scan data');
            disp(ME)
            ok=false;
        end
        
        conversionDetails = {... midxVal, type, TableVarName
            'longitude', 'double', 'Longitude';...
            'latitude',  'double', 'Latitude';...
            'time', 'datetime', 'Date';...
            'magnitude', 'double', 'Magnitude';...
            'depth/km', 'double', 'Depth';...
            'magtype', 'categorical', 'MagnitudeType'};
            
        tb=table('Size', [numel(mData{1}), 6], ...
            'VariableTypes', conversionDetails(:,2),...
            'VariableNames', conversionDetails(:,3));
        for j=1:length(conversionDetails)
            tb.(conversionDetails{j,3}) = mData{midx(conversionDetails{j,1})};
        end
        uOutput = ZmapCatalog.from(tb);
           
        %%
        
    end
    
end

function  mappings = determine_field_mappings(hdrs, firstrow)
    vals=strip(split(firstrow,'|'));
    
    
    mappings = containers.Map;
    
    mappings('latitude')='%f';
    mappings('longitude')='%f';
    mappings('depth/km')='%f';
    mappings('magnitude')='%f';
    mappings('magtype')='%s';
    
    % the TIME could be in one of several different formats. Figure out which one.
    time_pos = find(hdrs == "time");
    
    % look at format for the date
    if ismember('/',vals{time_pos})
        date_format = 'yyyy/MM/dd';
    else
        date_format = 'yyyy-MM-dd'; %FDSN date standard
    end
    
    % look at format for time
    if ismember('.',vals{time_pos})
        time_format = 'HH:mm:ss.SSSSSS';
    else
        time_format ='HH:mm:ss';
    end
    
    if endsWith(vals{2},'Z')
        time_format = [time_format, '''Z'''];
    end
    
    % look at separator between date & time fields
    if ismember('T', vals{time_pos}) % FDSN date standard
        mappings('time')=['%{', date_format, '''T''', time_format, '}D'];
    else
        mappings('time')=['%{', date_format, ' ', time_format, '}D'];
    end
    
end

function [resp,ok] = get_in_chunks(myuri, maxAllowed, expected)
    % try again, in chunks of maxSearchLimit
    starts=1:maxAllowed:expected;
    uOutput='';
    for n=starts
        fprintf(' ** retrieving events %d to %d\n', n, min(n+maxAllowed-1, expected));
        resp = get_low_level_fdsn_query(myuri + "&offset=" + n + "&limit="+ maxAllowed);
        if resp.StatusCode == "OK"
            if isempty(uOutput)
                uOutput=string(resp.Body.Data);
            else
                uOutput=uOutput + newline + extractAfter(resp.Body.Data, newline);
            end
            ok=true;
        else
            ok=false;
            break
        end
    end
    if ok
        resp.Body.Data=uOutput;
    end
end

function resp = get_low_level_fdsn_query(uri)
    U = matlab.net.URI(uri);
    method = matlab.net.http.RequestMethod.GET;
    type1 = matlab.net.http.MediaType('text/*');
    acceptField = matlab.net.http.field.AcceptField(type1);
    uafield=matlab.net.http.HeaderField('UserAgent','MATLAB 9.4.0.949201 (R2018a) Update 6 ZMAP/7.1');
    contentTypeField = matlab.net.http.field.ContentTypeField('text/plain');
    header = [acceptField contentTypeField uafield];
    request = matlab.net.http.RequestMessage(method,header);
    
    consumer=matlab.net.http.io.StringConsumer;
    options=matlab.net.http.HTTPOptions(...'SavePayload',true ...
        'ProgressMonitorFcn',@MyProgressMonitorNew ...
        ,'UseProgressMonitor',true ...
        ,'ConnectTimeout',30 ... % in seconds
        );
    [resp,req,hist] = request.send(U,options,consumer);
    
end

