function [uOutput] = import_fdsn_event(nFunction, code, varargin)
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
    if isempty(datacenter_details)
        datacenter_details = webread('http://service.iris.edu/irisws/fedcatalog/1/datacenters');

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
    end
    
    % Filter function switchyard
    if nFunction == 0     % Return info about filter
        uOutput = 'FDSN Events webservice text - import data from one of the webservice datacenters';
        return
    end
    
    if exist(code,'file')
        fid = fopen(code,'r');
        uOutput = convert_from_fdsn_text(fid);
        fclose(fid);
        return;
    end
    
    
    % check to see if program merely requests a summary of this type of import
    if nFunction==0
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
        'eventid',... specify a specific event by id
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
    options = weboptions('timeout',120); %seconds
    disp(['sending request to:' baseurl 'query  with options'])
    disp(varargin)
    data = webread([baseurl 'query'], varargin{:},'format','text',options)
    uOutput = convert_from_fdsn_text(data);
    
    function uOutput = convert_from_fdsn_text(data)
        % the FDSN text format is as follows:
        % EventID|Time|Latitude|Longitude|Depth/km|
        % Author|Catalog|Contributor|ContributorID|
        % MagType|Magnitude|MagAuthor|EventLocationName
        %
        % remarks start with #, so the first line is actually #EventID|time, etc..
        % spacing in header line is not guaranteed
        
        % scan only the relevant fields
        nanoformat= 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS';
        milliformat='yyyy-MM-dd''T''HH:mm:ss.SSS';
        flatformat ='yyyy-MM-dd''T''HH:mm:ss';
        try
        mData = textscan(...
            ... xx|Time|Latitude|Longitude|Depth/km|
            ... xx|xx|xx|xx|
            ... MagType|Magnitude|xx|xx
            data,'%*s%{yyyy-MM-dd''T''HH:mm:ss.SSSSSS}D%f%f%f%*s%*s%*s%*s%s%f%*s%*s',...
            'Delimiter','|','Headerlines',1,'MultipleDelimsAsOne',false);
        catch
            disp('unable to scan. trying again, with simple seconds');
            % yes, this is a brute approach to a most-likely scenario
            % where datacenters use differing details in seconds
            
        mData = textscan(...
            ... xx|Time|Latitude|Longitude|Depth/km|
            ... xx|xx|xx|xx|
            ... MagType|Magnitude|xx|xx
            data,'%*s%{yyyy-MM-dd''T''HH:mm:ss}D%f%f%f%*s%*s%*s%*s%s%f%*s%*s',...
            'Delimiter','|','Headerlines',1,'MultipleDelimsAsOne',false);
        end
            
        
        uOutput=zeros(numel(mData{1}),10);
        uOutput(:,1)=mData{3}; % Longitude
        uOutput(:,2)=mData{2}; % Latitude
        uOutput(:,3)=decyear(mData{1});% decimal year.
        uOutput(:,4)=mData{1}.Month;
        uOutput(:,5)=mData{1}.Day;
        uOutput(:,6)=mData{6}; % Magnitude
        uOutput(:,7)=mData{4}; % depth (km)
        uOutput(:,8)=mData{1}.Hour;
        uOutput(:,9)=mData{1}.Minute;
        uOutput(:,10)=mData{1}.Second;
        
        %% 
        
    end
    
end


