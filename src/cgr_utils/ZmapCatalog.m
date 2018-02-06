classdef ZmapCatalog < matlab.mixin.Copyable
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
    %   getRange - get the min and max range for specified field
    %   DateRange - get the min and max date for this catalog
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
        Date        % datetime
        % Nanosecond  % additional precision, if needed
        Longitude   % Longitude (Deg) of each event
        Latitude    % Latitude (Deg) of each event
        Depth       % Depth (km) of events 
        Magnitude   % Magnitude of each event
        MagnitudeType % Magnitude units, such as M, ML, MW, etc. 
        Dip         % unused?
        DipDirection % unused?
        Rake % unused?
        MomentTensor=table([],[],[],[],[],[],'VariableNames', {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'})
        % additions to this table need to be also added to a bunch of functions: 
        %    summary (?), getCropped, sort, subset, 
    end
    
    properties(SetObservable)
        Name        % name of this catalog. Used when labeling plots
        Filter      % logical Filter used for getting a subset of events
        IsSortedBy=''; % describes sort order
        SortDirection=''; %describes sorting direction
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
        
        function [a, b] = getRange(obj,fieldname)
            switch nargout
                case 2
                    a = min(obj.(fieldname));
                    b = max(obj.(fieldname));
                otherwise
                    a = [min(obj.(fieldname)), max(obj.(fieldname))];
            end
        end
        function [a, b] = DateRange(obj)
            % DATERANGE get min and max dates from catalog
            % A = catalog.DATERANGE() will return a 1x2 vector [minDate, maxDate]
            % [minDate, maxDate] = catalog.DATERANGE()
            switch nargout
                case 2
                    a = min(obj.Date);
                    b = max(obj.Date);
                otherwise
                    a = [min(obj.Date), max(obj.Date)];
            end
        end
        
        function [a, b] = MagnitudeRange(obj)
            % MAGNITUDERANGE get min and max magnitudes from catalog
            % A = catalog.MAGNITUDERANGE() will return a 1x2 vector [minMag, maxMag]
            % [minmag, maxmag] obj.MAGNITUDERANGE()
            switch nargout
                case 2
                    a = min(obj.Magnitude);
                    b = max(obj.Magnitude);
                otherwise
                    a = [min(obj.Magnitude), max(obj.Magnitude)];
            end
        end
        
        function obj = ZmapCatalog(varargin)
            % ZMAPCATALOG create a ZmapCatalog object
            %
            % catalog = ZMAPCATALOG() get an empty catalog
            % catalog = ZMAPCATALOG(name) get an empty catalog, but set the name
            % catalog = ZMAPCATALOG(otherCatalog) get a copy of a catalog
            % catalog = ZMAPCATALOG(zmaparray) create a catalog from a ZmapArray with columns:
            %   [longitude, latitude, decyear, month, day, magnitude, depth, hour, minute, second]
            
            
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
                nCols = size(varargin{1},2);
                fprintf(['importing from old catalog array with %d columns and %d events:\n'...
                    '[ lon lat decyr month day mag dep hr min sec ]\n'],nCols, size(varargin{1},1));
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
                
            elseif isa(varargin{1},'ZmapCatalog')
                % force a copy
                idx=true(varargin{1}.Count,1);
                obj = varargin{1}.subset(idx);
                obj.Name=varargin{1}.Name;
            end
            obj.Filter=true(size(obj.Longitude));
            
        end
        
        function TF=isempty(obj)
            % ISEMPTY is true when there are no events in the catalog
            % tf = ISEMPTY(catalog)
            TF = obj.Count == 0;
        end
        
        function outval = ZmapArray(obj)
            % ZMAPARRAY create a zmap array from this catalog
            % zmarr = catalog.ZMAPARRAY()
            outval = [...
                obj.Longitude, ...   % 1
                obj.Latitude, ...    % 2
                obj.DecimalYear, ... % 3
                obj.Date.Month, ...  % 4
                obj.Date.Day,...     % 5
                obj.Magnitude, ...   % 6
                obj.Depth, ...       % 7
                obj.Date.Hour,...    % 8
                obj.Date.Minute, ... % 9
                obj.Date.Second]; % position 10 of 10
            
            % ZmapArry that had 12 values is like above, except...
            % obj.Dip % position 10 of 12
            % obj.DipDirection % position 11 of 12
            % obj.Rake % position 12 of 12
        end
        
        function tbl = table(obj)
            % TABLE write catalog as a table.
            %
            st=struct(obj);
            flds=fieldnames(st);
            % to  convert to a table, all fields must be of same length
            % but some fields aren't individual to events.
            todelete=structfun(@(x)numel(x)~=st.Count , st);
            st=rmfield(st,flds(todelete));
            tbl = struct2table(st);
        end
        
        function s =  summary(obj, verbosity)
            % SUMMARY return a summary of this catalog
            % valid verbosity values: 'simple', 'stats'
            
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
                case 'list'
                    fprintf('Catalog "%s" with %d events\n',obj.Name, obj.Count);
                    fprintf('Date                      Lat       Lon   Dep(km)    Mag  MagType\n');
                    for n=1:obj.Count
                        fmtstr = '%s  %8.4f  %9.4f   %6.2f   %4.1f   %s\n';
                        mt =obj.MagnitudeType{n};
                        if isempty(mt), mt='-'; end
                        fprintf( fmtstr, char(obj.Date(n),'uuuu-MM-dd HH:mm:ss'),...
                            obj.Latitude(n), obj.Longitude(n),...
                            obj.Depth(n), obj.Magnitude(n), mt);
                    end
                otherwise
                    s = sprintf('Catalog "%s", containing %d events', obj.Name, obj.Count);
            end
            function mtypes=cat2mtypestring()
                % CAT2MTYPESTRING returns a string representation of the catalog type
                % mtypes = CAT2MTYPESTRING()
                mtypes=strcat(unique(obj.MagnitudeType)',',');
                mtypes=strcat(mtypes{:});
                mtypes(end)=[];
                if isempty(mtypes)
                    mtypes='-none-';
                end
            end
        end
        
        function clearFilter(obj)
            % CLEARFILTER sets all items in Filter to true
            % catalog.CLEARFILTER
            obj.Filter = true(size(obj.Longitude));
        end
        
        function obj = getCropped(existobj)
            % GETCROPPED get a new, cropped ZmapCatalog from this one
            
            if isempty(existobj.Filter)
                obj = existobj;
            else
                obj = existobj.subset(existobj.Filter);
            end
        end
        
        
        function sort(obj, field, direction)
            % SORT this catalog by the specified field (IN PLACE)
            % catalog.SORT(field), where field is a valid ZmapCatalog property
            %
            % catalog.SORT(field, direction), where direction is 'ascend' or 'descend'
            % ex.
            % catalog.sort('Date','ascend')
            %
            % NOTE: modifies original
            % see also catalog.sortedByDistanceTo
            if ~isprop(obj, field)
                error('%s is not a valid property of a ZmapCatalog',field);
            end
            if ~exist('direction','var')
                direction = 'ascend';
            end
            [~,idx] = sort(obj.(field),direction);
            obj.subset_in_place(idx);
            if isempty(obj.Filter)
                obj.clearFilter();
            end
            obj.IsSortedBy=field;
            obj.SortDirection=direction;
        end
        
        function other=sortedByDistanceTo(obj, lat, lon, depth)
            % SORTEDBYDISTANCE returns a catalog that has been sorted by distance to a point
            % ans=catalog.SORTEDBYDISTANCE(lat, lon) % epicentral sort
            % ans=catalog.SORTEDBYDISTANCE(lat, lon, depth) % hypocentral sort to surface
            %
            % does NOT modify original
            if ~exist('depth','var')
                dists= obj.epicentralDistanceTo(lat, lon);
            else
                dists= obj.hypocentralDistanceTo(lat, lon, depth);
            end
            [~,idx]=sort(dists);
            other=obj.subset(idx);
            other.IsSortedBy='distance';
            other.SortDirection='ascending';
        end
        
        function [other, max_km] = selectClosestEvents(obj, lat, lon, depth, n)
            % SELECTCLOSESTEVENTS determine which N events are closest to a point (lat,lon, depth).
            % [otherCat, max_km] = catalog.SELECTCLOSESTEVENTS(lat,lon, depth, nEvents)
            % for epicentral distance, leave depth empty.
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
        
        function [other,max_km] = selectRadius(obj, lat, lon, depth, radius_km)
            %SELECTRADIUS  select subset catalog to a radius from a point 
            % [catalog,max_km] = catalog.SELECTRADIUS(lat, lon, dist_km) epicentral radius from a point. sortorder is preserved
            % [catalog,max_km] = catalog.SELECTRADIUS(lat, lon, depth, dist_km) hypocentral radius from a point. sortorder is preserved
            %
            % see also selectClosestEvents, selectCircle
            if ~exist('radius_km','var')
                radius_km=depth;
                depth=[];
            end
            if isempty(depth)
                dists_km = obj.epicentralDistanceTo(lat, lon);
            else
                dists_km = obj.hypocentralDistanceTo(lat, lon, depth);
            end
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
            % [ minicat, maxd ] = catalog.SELECTCIRCLE(selcrit);
            % [ minicat, maxd ] = catalog.SELECTCIRCLE(selcrit, x,y,z ) %specify th
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
                [minicat,max_km]=obj.selectRadius(y,x, z, selcrit.radius_km);
            elseif selcrit.useNumNearbyEvents
                [minicat,max_km]=obj.selectClosestEvents(y,x,z, selcrit.numNearbyEvents); %works with sphere
                if max_km > selcrit.maxRadiusKm
                    [minicat, max_km]=obj.selectRadius(y,x, z, selcrit.maxRadiusKm);
                end
            end
        end
        
        function obj = blank(obj2)
            % allows subclass-aware use of empty objects
            obj=ZmapCatalog();
        end
        
        function subset_in_place(obj,range)
            %SUBSET_IN_PLACE modifies this object, not a copy of it.
            obj.Date = obj.Date(range);
            
            obj.Longitude = obj.Longitude(range) ;
            obj.Latitude = obj.Latitude(range);
            obj.Depth =  obj.Depth(range) ;
            
            obj.Magnitude = obj.Magnitude(range) ;
            obj.MagnitudeType = obj.MagnitudeType(range) ;
            
            if ~isempty(obj.Filter)
                obj.Filter = obj.Filter(range) ;
            end
            
            obj.Dip = obj.Dip(range);
            obj.DipDirection=obj.DipDirection(range);
            obj.Rake=obj.Rake(range);
            
            if ~isempty(obj.MomentTensor)
                obj.MomentTensor=obj.MomentTensor(range,:);
            end
        end
        function obj = subset(existobj, range)
            % SUBSET get a subset of this object
            % newcatalog = catalog.SUBSET(mask) where mask is a t/f array matching obj.Count
            %    will keep all "true" events
            % newcatalog = catalog.SUBSET(range), where range evaluates to an integer array
            %    will retrieve the specified events.
            %    this option can be used to change the order of the catalog too
            
            % changed this to make subset usable by subclassed catalogs. 
            obj = existobj.blank(); 
            obj.Name = existobj.Name;
            
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
            % CAT combines two catalogs
            % combinedCatalog = cat(catalogA, catalogB)
            % duplicates are not removed
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
            % REMOVEDUPLICATES removes events from catalog that are similar within tolerances
            % catalog = catalog.REMOVEDUPLICATES(tolLat, tolLon, tolDepth_m, tolTime_sec, tolMag)
            
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
        
        function s= blurb(obj)
            % BLURB get simple statement about catalog
            % s = catalog.blurb();
            if obj.Count > 0
                s=sprintf('ZmapCatalog "%s" with %d events\n',obj.Name,obj.Count());
            else
                s='empty ZmapCatalog';
            end
        end
        
        function disp(obj)
            disp(obj.blurb);
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
            % PLOTFOCALMECHANISMS plot the focal mechanisms of a catalog (if they exist)
            % plotFocalMechanisms(catalog, ax, color)
            
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
            % dists_km = catalog.EPICENTRALDISTANCETO(to_lat, to_lon)
            dists_km=deg2km(distance(obj.Latitude, obj.Longitude, to_lat, to_lon));
        end
        function dists_km = hypocentralDistanceTo(obj, to_lat, to_lon, to_depth_km)
            % get HYPOCENTRALDISTANCETO (lat,lon,z) distance to another point
            % dists_km = catalog.HYPOCENTRALDISTANCETO(to_lat, to_lon, to_depth_km)
            dists_km=deg2km(distance(obj.Latitude, obj.Longitude, to_lat, to_lon));
            delta_dep = (obj.Depth - to_depth_km);
            dists_km = sqrt( dists_km^2 + delta_dep ^2);
        end
        
        function rt = relativeTimes(obj, other)
            % relativeTimes
            % rt = catalog.RELATIVETIMES() get times relative to start
            % rt = catalog.RELATIVETIMES(other) get times relative to another time
        
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
    
    methods (Static)
        
    end
    
end

