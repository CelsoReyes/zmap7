classdef ZmapCatalog < handle
    % ZmapCatalog represents an event catalog
    %
    % ZmapCatalog properties:
    %   Name - name of catalog, used when labeling plots
    %   Date - catalog event times
    %
    %   Longitude - Longitude (Deg) of each event
    %   Latitude - Latitude (Deg) of each event
    %   Depth -  Depth (km) of events 
    %
    %   Magnitude - Magnitude of each event
    %   MagnitudeType - Magnitude[unit of each event
    % 
    %    Dip         - unused?
    %    DipDirection - unused?
    %    Rake - unused?
    %
    %   MomentTensor - as mrr, mtt, mff, mrt, mrf, mtf
    %
    %   DecimalYear - date as a decimal year (for backward compatibility, not recommended)
    %   DayOfYear - day of the year for each event
    %   Count - number of events in catalog
    %   DateSpan - duration between first and last events in catalog
    %
    % ZmapCatalog methods:
    %   
    %   ZmapCatalog -  create an empty ZmapCatalog, or from an array
    %
    %   isempty - returns true if catalog contains no events
    %
    %   cat - concatenate catalogs
    %   removeDuplicates - remove duplicate events, based on tolerance values
    %   subset - get a subset of the catalog, based on an index (numeric, or logical)
    %
    %   Range methods:
    %
    %   DateRange - get the min and max date for this catalog
    %   DepthRange - get the min and max depth for this catalog
    %   MagnitudeRange - get the min and max magnitude for this catalog
    %
    %   Output Methods:
    %
    %   disp - display simple details for catalog
    %   summary - get text that describe this catalog
    %   plot - plot the catalog
    %   plotm - plot the catalog on a map
    %   plotFocalMechanisms - plot the focal mechanisms
    %
    %   Export Methods:
    %
    %   ZmapArray - get an array in the style of older Zmap versions
    %
    %   Filtering Methods:
    %
    %   * Filtering methods have been outsourced into the ZmapCatalogView class.
    %
    %   addFilter - add a filter associated with a single property
    %   clearFilter - resets the filter
    %   invertFilter - swap which events meet filter criteria
    %   setFilterToAxesLimits - set Longitude and Latitude filters to current X- and Y-axis limits
    %   cropToFilter - apply filters to this ZmapCatalog, resulting in smaller catalog
    %   getCropped - apply filters to get a NEW smaller ZmapCatalog
    % 
    %   Sorting Methods:
    %
    %   sort - sort the catalog according to a field, either ascending or descending
    %   sortedByDistanceTo - sort catalog according to event distance to a point
    %
    %   Spatial Methods:
    %
    %   epicentralDistanceTo - get distance (km) to a point, considering only Lat/Lon. 
    %   hypocentralDistanceTo - get distance (km) to a point, taking depth into consideration
    %   selectClosestEvents - return a catalog containing only N closest events
    %   selectRadius - return a catalog containing only events within a radius
    
    % TODO consider using matlab.mixin.CustomDisplay
    properties
        Name   % name of this catalog. Used when labeling plots
        Date        % datetime
        % Nanosecond  % additional precision, if needed
        Longitude   % Longitude (Deg) of each event
        Latitude    % Latitude (Deg) of each event
        Depth       % Depth (km) of events 
        Magnitude   % Magnitude of each event
        MagnitudeType % Magnitude units, such as M, ML, MW, etc. 
        Filter      % logical Filter used for getting a subset of events
        Dip         % unused?
        DipDirection % unused?
        Rake % unused?
        MomentTensor=table([],[],[],[],[],[],'VariableNames', {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'})
        % additions to this table need to be also added to a bunch of functions: 
        %    summary (?), cropToFilter, getCropped, addFilter(?), sort, subset, 
    end
    
    properties(Dependent)
        DecimalYear % read-only
        DayOfYear % read-only
        Count % read-only number of events in catalog
        DateSpan % read-only duration 
    end
    
    methods
        function propval = get.Count(obj)
            % number of events
            propval = numel(obj.Longitude);
        end
        %function set.Name(obj,value)
        %    obj.Name=value; %only here for debugging
        %end
        
        function out = get.DateSpan(obj)
            % dspan = obj.DateSpan  returns difference between min & max dates
            out=max(obj.Date) - min(obj.Date);
            if days(out)>5
                out.Format = 'd';
            end
        end
        function propval = get.DecimalYear(obj)
            propval = decyear(obj.Date);
        end
        
        function propval = get.DayOfYear(obj)
            propval = fix(datenum(obj)) - datenum(obj.Date.Year - 1, 12 , 31);
        end
        
        function set.MomentTensor(obj, value)
            if istable(value)
                assert(isequal(value.Properties.VariableNames,{'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'}));
                obj.MomentTensor=value;
            elseif isnumeric(value)
                assert(size(value,2)==6,'expect moment tensors to have 6 columns: mrr, mtt, mff, mrt, mrf, mtf');
                % assert(size(value,1)==obj.Count,'# of moment tensors must match catalog size.');
                obj.MomentTensor=array2table(value,'VariableNames',{'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'});
            end
        end
        
        function [a, b] = DateRange(obj)
            % get min and max dates from catalog
            % A = obj.DateRange() will return a 1x2 vector [minDate, maxDate]
            % [minDate, maxDate] = obj.DateRange()
            switch nargout
                case 2
                    a = min(obj.Date);
                    b = max(obj.Date);
                otherwise
                    a = [min(obj.Date), max(obj.Date)];
            end
        end
        
        function [a, b] = MagnitudeRange(obj)
            % get min and max magnitudes from catalog
            % A = obj.MagnitudeRange() will return a 1x2 vector [minMag, maxMag]
            % [minmag, maxmag] obj.MagnitudeRange()
            switch nargout
                case 2
                    a = min(obj.Magnitude);
                    b = max(obj.Magnitude);
                otherwise
                    a = [min(obj.Magnitude), max(obj.Magnitude)];
            end
        end
        function obj = ZmapCatalog(varargin)
            % ZmapCatalog create a ZmapCatalog object
            obj.Name = '';
            if nargin==0
                %donothing
                return
            end
            if nargin==1 && ischar(varargin{1})
                obj.Name=varargin{1};
                return;
            end
            if isnumeric(varargin{1})
                % import Catalog from Array
                obj.Longitude = varargin{1}(:,1);
                obj.Latitude = varargin{1}(:,2);
                if all(varargin{1}(:,3) < 100)
                    varargin{1}(:,3) = varargin{1}(:,3)+1900;
                    errdisp =  'The catalog dates appear to have 2 digits years. Action taken: added 1900 for Y2K compliance';
                    warndlg(errdisp)
                end
                obj.Date = datetime([floor(varargin{1}(:,3)), varargin{1}(:,[4,5,8,9,10])]);
                obj.Depth = varargin{1}(:,7);
                obj.Magnitude = varargin{1}(:,6);
                
                obj.MagnitudeType = cell(size(obj.Magnitude));
                obj.Dip = nan(obj.Count,1);
                obj.DipDirection = nan(obj.Count,1);
                obj.Rake = nan(obj.Count,1);
                
                for i=1:numel(obj.MagnitudeType)
                    if isempty(obj.MagnitudeType{i})
                        obj.MagnitudeType(i)={''};
                    end
                end
                
                
                if nargin==2 && ischar(varargin{2})
                    obj.Name = varargin{2};
                end
                
            elseif (nargin==0)
                obj = ZmapCatalog;
            elseif isa(varargin{1},'ZmapCatalog')
                obj = varargin{1};
            end
            
        end
        
        function TF=isempty(obj)
            % isempty is true when there are no events in the catalog
            TF = obj.Count == 0;
        end
        
        function outval = ZmapArray(obj)
            % create a zmap array from this catalog
            outval = [obj.Longitude, ...
                obj.Latitude, ...
                obj.DecimalYear, ...
                obj.Date.Month, ...
                obj.Date.Day,...
                obj.Depth, ...
                obj.Magnitude, ...
                obj.Date.Hour,...
                obj.Date.Minute, ...
                obj.Date.Second]; % position 10 of 10
            
            % ZmapArry that had 12 values is like above, except...
            % obj.Dip % position 10 of 12
            % obj.DipDirection % position 11 of 12
            % obj.Rake % position 12 of 12
        end
        
        function s =  summary(obj, verbosity,useTex)
            % return a summary of this catalog
            % valid verbosity values: 'simple', 'stats'
            % if useTex is given, then format is wrapped in tex-style markup (not implemented)
            
            % add additional ways to look at catalog if it makes sense
            if ~exist('verbosity','var')
                verbosity='';
            end
            if numel(obj) > 1
                s = sprintf('%d Catalogs',numel(obj));
                return
            end
            
            if obj.Count==0
                s = sprintf('Empty Catalog, named "%s"',obj.Name);
                return
            end
            
            switch verbosity
                case 'simple'
                    minti = min( obj.Date );
                    maxti  = max( obj.Date );
                    minma = min(obj.Magnitude);
                    maxma = max(obj.Magnitude);
                    mindep = min(obj.Depth);
                    maxdep = max(obj.Depth);
                    %{
                    if exist('useTex','var') && useTex
                        fmtstr = [...
                        '{\\bf Catalog} "%s" with %d events\n',...
                        '{\\bf Start Date:} %s\n',...
                        '{\\bf End Date:}   %s\n',...
                        '{\\bf Depths:}     %4.2f km <= Z <= %4.2f km\n',...
                        '{\\bf Magnitudes:} %2.1f <= M <= %2.1f'];
                    nm=strrep(obj.Name,'_','\_');
                    s = sprintf(fmtstr, nm, obj.Count, ...
                        char(minti,'uuuu-MM-dd HH:mm:ss'),...
                        char(maxti,'uuuu-MM-dd HH:mm:ss'),...
                        mindep, maxdep,...
                        minma, maxma);
                    else
                    %}
                    mtypes=cat2mtypestring();
                    fmtstr = [...
                        'Catalog "%s" with %d events\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        'Depths:     %4.2f km <= Z <= %4.2f km\n',...
                        'Magnitudes: %2.1f <= M <= %2.1f\n',...
                        'MagnitudeTypes: %s'];
                    s = sprintf(fmtstr, obj.Name, obj.Count, ...
                        char(minti,'uuuu-MM-dd HH:mm:ss'),...
                        char(maxti,'uuuu-MM-dd HH:mm:ss'),...
                        mindep, maxdep,...
                        minma, maxma,mtypes);
                    %end %useTex
                case 'stats'
                    minti = min( obj.Date );
                    maxti  = max( obj.Date );
                    minma = min(obj.Magnitude);
                    maxma = max(obj.Magnitude);
                    mindep = min(obj.Depth);
                    maxdep = max(obj.Depth);
                    
                    fmtstr = [...
                        'Catalog "%s"\nNumber of events: %d\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        '  %s\n',...
                        'Depths:     %4.2f km <= Z <= %4.2f km\n',...
                        '  %s\n',...
                        'Magnitudes: %2.1f <= M <= %2.1f\n',...
                        '  %s\n',...
                        'Magnitude Types: %s'];
                    
                    mean_int = mean(diff(obj.Date));
                    median_int = median(diff(obj.Date));
                    std_int = std(diff(obj.Date));
                    mean_int.Format = 'd';
                    median_int.Format = 'd';
                    std_int.Format = 'd';
                    if std_int < 10
                        std_int.Format = 'hh:mm:ss';
                    end
                    if mean_int < 10
                        mean_int.Format = 'hh:mm:ss';
                    end
                    if median_int < 10
                        median_int.Format = 'hh:mm:ss';
                    end
                    s = sprintf(fmtstr, obj.Name, obj.Count, ...
                        char(minti,'uuuu-MM-dd HH:mm:ss'),...
                        char(maxti,'uuuu-MM-dd HH:mm:ss'),...
                        sprintf('mean interval: %s ±std %s , median int: %s',mean_int, std_int, median_int),...
                        mindep, maxdep,...
                        sprintf('mean: %.3f ±std %.3f , median: %.3f',mean(obj.Depth), std(obj.Depth), median(obj.Depth)),...
                        minma, maxma,...
                        sprintf('mean: %.2f ±std %.2f , median: %.2f',mean(obj.Magnitude), std(obj.Magnitude), median(obj.Magnitude)),...
                        cat2mtypestring());
                    
                otherwise
                    s = sprintf('Catalog "%s", containing %d events', obj.Name, obj.Count);
            end
            function mtypes=cat2mtypestring()
                mtypes=strcat(unique(obj.MagnitudeType)',',');
                mtypes=strcat(mtypes{:});
                mtypes(end)=[];
                if isempty(mtypes)
                    mtypes='-none-';
                end
            end
        end
        
        function clearFilter(obj)
            % clearFilter sets all items in Filter to true
            obj.Filter = true(size(obj.Longitude));
        end
        
        function invertFilter(obj)
            % invertFilter flips all true to false and vice-versa
            obj.Filter = ~obj.Filter;
        end
        
        function setFilterToAxesLimits(obj, ax)
            if ~isvalid(ax)
                return
            end
            obj.addFilter('Longitude','>=',min(ax.XLim));
            obj.addFilter('Latitude','>=',min(ax.YLim));
            obj.addFilter('Longitude','<=',max(ax.XLim));
            obj.addFilter('Latitude','<=',max(ax.YLim));
        end
        
        function cropToFilter(obj)
            % applies the Filter to this ZmapCatalog
            %
            % see also addFilter, clearFilter
            
            if isempty(obj.Filter)
                return
            end
            
            obj.Date = obj.Date(obj.Filter);       % datetime
            % Nanosecond  % additional precision, if needed
            obj.Longitude = obj.Longitude(obj.Filter) ;
            obj.Latitude = obj.Latitude(obj.Filter);
            obj.Depth =  obj.Depth(obj.Filter) ;      % km
            obj.Magnitude = obj.Magnitude(obj.Filter) ;
            obj.MagnitudeType = obj.MagnitudeType(obj.Filter) ;
            obj.Filter = obj.Filter(obj.Filter);
            obj.Dip = obj.Dip(obj.Filter);
            obj.DipDirection = obj.DipDirection(obj.Filter);
            obj.Rake = obj.Rake(obj.Filter);
            if ~isempty(obj.MomentTensor)
                obj.MomentTensor = obj.MomentTensor(obj.Filter,:);
            end
        end
        
        function obj = getCropped(existobj)
            % get a new, cropped ZmapCatalog from this one
            % reasoning: requires less memory
            
            if isempty(existobj.Filter)
                obj = existobj;
                return
            end
            % get a subset of an existing catalog
            obj = ZmapCatalog();
            obj.Longitude = existobj.Longitude(existobj.Filter);
            obj.Latitude = existobj.Latitude(existobj.Filter);
            obj.Date = existobj.Date(existobj.Filter);
            obj.Depth = existobj.Depth(existobj.Filter);
            obj.Magnitude = existobj.Magnitude(existobj.Filter);
            obj.MagnitudeType = existobj.MagnitudeType(existobj.Filter);
            obj.Dip = existobj.Dip(existobj.Filter);
            obj.DipDirection = existobj.DipDirection(existobj.Filter);
            obj.Rake = existobj.Rake(existobj.Filter);
            obj.Filter=existobj.Filter(existobj.Filter);
            if ~isempty(obj.MomentTensor)
                obj.MomentTensor=existobj.MomentTensor(existobj.Filter,:);
            end
            
        end
        
        function addFilter(obj, field, operation, value, varargin)
            % addFilter allows subsets of data to be specified
            %
            % addFilter(mask) AND's the mask with the existing Filter
            %     where mask is a logical array of same length as ZmapCatalog.Count
            %
            %
            % addFilter(field, operation, value) compares the data from the field to the value using
            %     the specified operation.
            %     FIELD is a string containing the name of a valid ZmapCatalog field
            %     OPERATION is either a function handle or one of the following:
            %          '<','>','<=','<=','>=','>=','==','~='
            %     VALUE is what the field will be compared against.
            %
            % Example 1
            %     obj.addFilter('Depth','>=',3) % sets Filter to true wherever depth >= 3
            %     obj.addFilter('Depth','<', 23) % now Filter is true only where depth >=3 AND depth < 23
            %
            % Example 2
            %     odd_dates = @(x,~) mod(datenum(x),2) == 1;
            %     obj.addFilter('Date',@odd_dates,[]); %true where datenum is odd
            %
            %
            % see also clearFilter
            %
            if ~exist('operation','var') && islogical(field) && all(size(field)==size(obj.Longitude))
                obj.Filter = field;
                return
            end
            
            if ischar(operation)
                switch operation
                    case '<'
                        operation=@lt;
                    case '>'
                        operation=@gt;
                    case {'<='}
                        operation = @le;
                    case {'>='}
                        operation = @ge;
                    case '=='
                        operation = @eq;
                    case '~='
                        operation = @ne;
                    otherwise
                        operation = str2func(operation);
                end
            end
            if ~isprop(obj, field)
                error('%s is not a valid property of a ZmapCatalog',field);
            end
            if isa(operation,'function_handle')
                if isempty(obj.Filter)
                    obj.clearFilter();
                end
                obj.Filter = obj.Filter & operation(obj.(field), value);
                if ~isempty(varargin)
                    obj.addFilter(varargin{:});
                end
                
            else
                error('don''t know how to handle a %s',class(operation));
            end
            %
        end
        
        function sort(obj, field, direction)
            % sort this object by the field specified (IN PLACE)
            % obj.sort(field), where field is a valid ZmapCatalog property
            %
            % obj.sort(field, direction), where direction is 'ascend' or 'descend'
            % ex.
            % obj.sort('Date')
            % sortBy (fieldname)
            %
            % modifies original
            if ~isprop(obj, field)
                error('%s is not a valid property of a ZmapCatalog',field);
            end
            if ~exist('direction','var')
                direction = 'ascend';
            end
            [~,idx] = sort(obj.(field),direction);
            
            obj.Date = obj.Date(idx);       % datetime
            obj.Longitude = obj.Longitude(idx) ;
            obj.Latitude = obj.Latitude(idx);
            obj.Depth =  obj.Depth(idx) ;      % km
            obj.Magnitude = obj.Magnitude(idx) ;
            obj.MagnitudeType = obj.MagnitudeType(idx) ;
            obj.Dip=obj.Dip(idx);
            obj.DipDirection=obj.DipDirection(idx);
            obj.Rake=obj.Rake(idx);
            if ~isempty(obj.MomentTensor)
                obj.MomentTensor=obj.MomentTensor(idx,:);
            end
            if isempty(obj.Filter)
                obj.clearFilter();
            end
            obj.Filter = obj.Filter(idx) ;
        end
        
        function other=sortedByDistanceTo(obj, lat, lon, depth)
            % ans=obj.sortedByDistanceTo(lat, lon) % epicentral sort
            % ans=obj.sortedBYDistanceTo(lat, lon) % hypocentral sort to surface
            %
            % does NOT modify original
            if ~exist('depth','var')
                dists= obj.epicentralDistanceTo(lat, lon);
            else
                dists= obj.hypocentralDistanceTo(lat, lon, depth);
            end
            [~,idx]=sort(dists);
            other=obj.subset(idx);
        end
        
        function [other, max_km] = selectClosestEvents(obj, lat, lon, depth, n)
            % selectClosestEvents determine which N events are closest to a point (lat,lon, depth).
            % [otherCat, max_km] = obj.selectClosestEvents(lat,lon, depth, nEvents)
            % for hypocentral distance, leave depth empty.
            %  ex.  selectClosestEvents(mycatalog, 82, -120, [], 20);
            % the distance to the nth closest event
            %
            % see also selectCircle, selectRadius
            if isempty(depth) || isnan(depth)
                dists_km = obj.epicentralDistanceTo(lat, lon);
            else
                dists_km = obj.hypocentralDistanceTo(lat, lon, depth);
            end
            
            % find nth closest by grabbing from the sorted distances
            sorted_dists = sort(dists_km);
            n = min(n, numel(sorted_dists));
            if n>0
                max_km = sorted_dists(n);
            else
                max_km=0;
            end
            mask = dists_km <= max_km;
            other = obj.subset(mask);
        end
        
        function [other,max_km] = selectRadius(obj, lat, lon, radius_km)
            %selectRadius  select subset catalog to an epicentral radius from a point. sortorder is preserved
            % [catalog,max_km] = obj.selectRadius(lat, lon, dist_km)
            %
            % see also selectClosestEvents, selectCircle
            dists_km = obj.epicentralDistanceTo(lat, lon);
            mask = dists_km <= radius_km;
            % furthest_event_km = max(dists_km(mask));
            other = obj.subset(mask);
            if ~any(mask)
                max_km=0;
            else
                max_km= max(dists_km(mask));
            end
        end
        
        function [ minicat, max_km ] = selectCircle(obj, selcrit, x,y,z )
            %selectCircle Select events in a circle defined by either distance or number of events or both
            % [ minicat, maxd ] = catalog.selectCircle(selcrit);
            % [ minicat, maxd ] = catalog.selectCircle(selcrit, x,y,z ) %specify th
            %
            %  SELCRIT is a structure containing one of the following set of fields:
            %    * numNearbyEvents (by itself) : runs function against this many closest events.
            %    * radius_km  (by itself) : runs function against all events in this radius
            %    * useNumNearbyEvents, useEventsInRadius, numNearbyEvents, radius_km (ALL of the above):
            %      uses the useNumNearbyEvents and useEventsInRadius to determine its behavior.  If
            %      both of these fields are true, then the closest events are evaluated up to the distance
            %      radius_km.
            %    * maxRadiusKm
            %   X, Y, Z : coordinates of a point.  Z may be empty [].
            %   if X,Y not provided, then they should be fields of selcrit as X0, Y0
            %               
            %
            % see also selectClosestEvents, selectRadius
            assert(isstruct(selcrit),'SELCRIT should be a structure');
            
            % make sure the required selection fields exist
            if ~isfield(selcrit,'useNumNearbyEvents')
                selcrit.useNumNearbyEvents=isfield(selcrit,'numNearbyEvents');
            end
            if ~isfield(selcrit,'useEventsInRadius')
                selcrit.useEventsInRadius=isfield(selcrit,'radius_km');
            end
            if selcrit.useEventsInRadius
                assert(isfield(selcrit,'radius_km'),'Error: useEventsInRadius was true, but no radius [radius_km] was specified');
            end
            if selcrit.useNumNearbyEvents
                assert(isfield(selcrit,'numNearbyEvents'),'Error: useNumNearbyEvents was true, but no number [numNearbyEvents] was specified');
            end
            
            assert(selcrit.useNumNearbyEvents ~= selcrit.useEventsInRadius,...
                'Error. Cannot select both numnearby and events in radius.');
            
            if ~isfield(selcrit,'minNumEvents')
                selcrit.minNumEvents=0;
            end
            if selcrit.useNumNearbyEvents && ~isfield(selcrit,'maxRadiusKm')
                selcrit.maxRadiusKm=inf;
            end
            
            if ~exist('x','var')||isempty('x')
                x = selcrit.X0;
            end
            if ~exist('y','var')||isempty('y')
                y = selcrit.Y0;
            end
            if ~exist('z','var') || isempty('z')
                z = []; % not a member of selcrit.
            end
                
            assert( selcrit.useEventsInRadius || selcrit.useNumNearbyEvents,'Error: No selection criteria was chosen. Results would be one value (based on entire catalog) repeated');
            
            if selcrit.useEventsInRadius
                [minicat,max_km]=obj.selectRadius(y,x, selcrit.radius_km);
            elseif selcrit.useNumNearbyEvents
                [minicat,max_km]=obj.selectClosestEvents(y,x,z, selcrit.numNearbyEvents);
                if max_km > selcrit.maxRadiusKm
                    [minicat, max_km]=obj.selectRadius(y,x, selcrit.maxRadiusKm);
                end
            end
        end
        
        function obj = subset(existobj, range)
            % subset get a subset of this object
            % newobj = obj.subset(mask) where mask is a t/f array matching obj.Count
            %    will keep all "true" events
            % newobj = obj.subset(range), where range evaluates to an integer array
            %    will retrieve the specified events.
            %    this option can be used to change the order of the catalog too
            
            obj = ZmapCatalog();
            obj.Date = existobj.Date(range);       % datetime
            obj.Longitude = existobj.Longitude(range) ;
            obj.Latitude = existobj.Latitude(range);
            obj.Depth =  existobj.Depth(range) ;      % km
            obj.Magnitude = existobj.Magnitude(range) ;
            obj.MagnitudeType = existobj.MagnitudeType(range) ;
            if ~isempty(obj.Filter)
                obj.Filter = existobj.Filter(range) ;
            end
            obj.Dip = existobj.Dip(range);
            obj.DipDirection=existobj.DipDirection(range);
            obj.Rake=existobj.Rake(range);
            if ~isempty(existobj.MomentTensor)
                obj.MomentTensor=existobj.MomentTensor(range,:);
            end
        end
        
        function obj = cat(objA, objB)
            % cat combines two catalogs
            % duplicates are not looked for
            obj = objA;
            objA.Date = [objA.Date; objB.Date];
            objA.Longitude = [objA.Longitude; objB.Longitude];
            objA.Latitude = [objA.Latitude; objB.Latitude];
            objA.Depth = [objA.Depth; objB.Depth];
            objA.Magnitude = [objA.Magnitude; objB.Magnitude];
            objA.MagnitudeType = [objA.MagnitudeType; objB.MagnitudeType];
            objA.Dip = [objA.Dip; objB.Dip];
            objA.DipDirection = [objA.DipDirection; objB.DipDirection];
            objA.Rake = [objA.Rake; objB.Rake];
            objA.MomentTensor=[objA.MomentTensor;objB.MomentTensor];
            ...
                %add additional fields here!
            ...
                objA.clearFilter();
        end
        
        function obj = removeDuplicates(obj, tolLat, tolLon, tolDepth_m, tolTime_sec, tolMag)
            % removeDuplicates removes events from catalog that are similar within tolerances
            % catalog = catalog.removeDuplicates(tolLat, tolLon, tolDepth_m, tolTime_sec, tolMag)
            
            obj.sort('Date');
            orig_size = obj.Count;
            if ~exist('tolLat','var') || isempty(tolLat), tolLat = 0.0001; end
            if ~exist('tolLon','var') || isempty(tolLon), tolLon = 0.0001; end
            if ~exist('tolDepth_m','var') || isempty(tolDepth_m), tolDepth_m = 0.5; end
            if ~exist('tolTime_sec','var') || isempty(tolTime_sec), tolTime_sec = 0.01; end
            if ~exist('tolMag','var') || isempty(tolMag), tolMag = 0.001; end
            fprintf('Removing duplicates with the following tolerances:\n');
            fprintf('  Time (s): %.2f\nLat: %f\nLon: %f\nDepth (m): %f\nMag:%.3f\n',...
                tolTime_sec, tolLat, tolLon, tolDepth_m, tolMag);
            
            % Dip, DipDirection, Rake, MomentTensor are not included in calculation
            isSame = abs(diff(obj.Date)) <= seconds(tolTime_sec) & ...
                abs(diff(obj.Latitude)) <= tolLat & ...
                abs(diff(obj.Longitude)) <= tolLon & ...
                abs(diff(obj.Depth)) <= (tolDepth_m / 1000) & ...
                abs(diff(obj.Magnitude)) <= tolMag;
            sameidx = [false; isSame];
            obj = obj.subset(~sameidx);
            fprintf('Removed %d duplicates\n', orig_size - obj.Count);
        end
        
        function disp(obj)
            if obj.Count > 0
                fprintf('ZmapCatalog "%s" with %d events\n',obj.Name,obj.Count());
            else
                disp('empty ZmapCatalog');
            end
            % disp(obj.summary('stats'));
        end
        function h=plot(obj,varargin)
            error('use a ZmapCatalogView instead');
        end
        %{
        function h=plot(obj, ax, varargin)
            % plot this catalog. It will plot on
            %
            % see also refreshPlot

            if has_toolbox('Mapping Toolbox') && ismap(ax)
                h=obj.plotm(ax,varargin{:});
                return
            end
            
            hastag=find(strcmp('Tag',varargin),1,'last');
            
            if ~isempty(hastag)
                mytag=varargin{hastag+1};
            else
                mytag=['catalog_',obj.Name];
                varargin(end+1:end+2)={'Tag',mytag};
            end
            
            % fprintf('plotting catalog with %d events and tag:%s\n',obj.Count,mytag);
            % clear the existing layer
            h = findobj(ax,'Tag',mytag);
            if ~isempty(h)
                delete(h);
            end
            
            holdstatus = ishold(ax); 
            hold(ax,'on');
            
            % val = obj.getTrimmedData();
            h=plot(ax,nan,nan,'x');
            set(h,'XData',obj.Longitude,'YData', obj.Latitude, 'ZData',obj.Depth);
            set(h,varargin{:}); % if Tag is in varargin, it will override default tag
            %h.ZData = obj.Depth;
            
            if ~holdstatus; hold(ax,'off'); end
            
        end
        %}
        function h=plotm(obj,varargin)
            error('use a ZmapCatalogView instead');
        end
        %{
        function h=plotm(obj,ax, varargin)
            % plot this layer onto a map (Requires mapping toolbox)
            % will delete layer if it exists
            % note features will only plot the subset of features within the
            % currently visible axes
            %
            % see also refreshPlot
            
            
            if isempty(ax) || ~isvalid(ax) || ~ismap(ax)
                error('Feature "%s" ->plot has no associated axis or is not a map',obj.Name);
            end
            
            hastag=find(strcmp('Tag',varargin));
            if ~isempty(hastag)
                mytag=varargin{hastag}+1;
            else
                mytag=['catalog_',obj.Name];
                varargin(end+1:end+2)={'Tag',mytag};
            end
            
            h = findobj(ax,'Tag',mytag);
            if ~isempty(h)
                delete(h);
            end
            
            holdstatus = ishold(ax); hold(ax,'on');
            h=plotm(obj.Latitude, obj.Longitude, '.',varargin{:});
            set(h, 'ZData',obj.Depth);
            set(ax,'ZDir','reverse');
            daspectm('km');
            if ~holdstatus; hold(ax,'off'); end
            
        end
       %}
        function plotFocalMechanisms(obj,ax,color)
            % plot the focal mechanisms of a catalog (if they exist)
            
            pbar=pbaspect(ax);
            pbar=daspect(ax);
            asp=pbar(1)/pbar(2);
            if isempty(obj.MomentTensor)
                warning('no moment tensors to plot');
            end
            axes(ax)
            hold on;
            set(findobj(gcf,'Type','Legend'),'AutoUpdate','off'); %
            for i=1:obj.Count
                mt = obj.MomentTensor{i,:};
                if istable(mt)
                    mt=mt{:,:};
                end
                
                if ~any(isnan(mt))
                    h(i)=focalmech(mt,obj.Longitude(i),obj.Latitude(i),.05*obj.Magnitude(i),asp,color);
                    set([h(i).circle(:);h(i).fill(:);h(i).text],'Tag','focalmech_');
                    drawnow
                    %TODO set the tag
                else
                    disp('nan present in moment tensor')
                end
            end
            set(findobj(gcf,'Type','Legend'),'AutoUpdate','on')
        end
        
        function dists_km = epicentralDistanceTo(obj, to_lat, to_lon)
            % get epicentral (lat-lon) distance to another point
            dists_km=deg2km(distance(obj.Latitude, obj.Longitude, to_lat, to_lon));
        end
        function dists_km = hypocentralDistanceTo(obj, to_lat, to_lon, to_depth_km)
            % get epicentral (lat-lon) distance to another point
            dists_km=deg2km(distance(obj.Latitude, obj.Longitude, to_lat, to_lon));
            delta_dep = (obj.Depth - to_depth_km);
            dists_km = sqrt( dists_km^2 + delta_dep ^2);
        end
        
        function rt = relativeTimes(obj, other)
            % relativeTimes
            % rt = obj.relativeTimes() get times relative to start
            % rt = obj.relativeTimes(other) get times relative to another time
        
            if ~exist('other','var')
                rt = obj.Date - min(obj.Date);
                return
            end
            switch class(other)
                case 'datetime'
                    rt = obj.Date - datetime;
                otherwise
                    error('do not know how to compare to a .. try giving a specific date');
            end
        end
    end
    
end

