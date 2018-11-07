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
        Date datetime        % date and time of event (capable of storing data to microseconds)
        Longitude double   % Longitude (Deg) of each event
        Latitude  double   % Latitude (Deg) of each event
        Depth double      % Depth (km) of events
        Magnitude double  % Magnitude of each event
        MagnitudeType categorical % Magnitude units, such as M, ML, MW, etc.
        Dip         % unused?
        DipDirection % unused?
        Rake % unused?
        MomentTensor table = table([],[],[],[],[],[],'VariableNames', {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'})
        RefEllipsoid referenceEllipsoid = referenceEllipsoid('wgs84','kilometer'); % reference ellipsoid for Longitude and Latitude as specified in QuakeML
        % additions to this table need to be also added to a bunch of functions:
        %    summary (?), getCropped, sort, subset,
    end
    
    properties(SetObservable,AbortSet)
        Name (1,:) char     = ''  % name of this catalog. Used when labeling plots
        Filter logical     % logical Filter used for getting a subset of events
        IsSortedBy char     = '' % describes sort order
        SortDirection char  = '' %describes sorting direction
    end
    
    properties(Dependent)
        DecimalYear % read-only
        DayOfYear % read-only
        Count % read-only number of events in catalog
        DateSpan % read-only duration
    end
    
    properties(Constant)
        Type = 'zmapcatalog'
    end
    
    events
        ValueChange
    end
    
    
    methods
        
        function obj = ZmapCatalog(varargin)
            % ZMAPCATALOG create a ZmapCatalog object
            %
            % catalog = ZMAPCATALOG() get an empty catalog
            % catalog = ZMAPCATALOG(name) get an empty catalog, but set the name
            % catalog = ZMAPCATALOG(otherCatalog) get a copy of a catalog
            % catalog = ZMAPCATALOG(zmaparray) create a catalog from a ZmapArray with columns:
            %   [longitude, latitude, decyear, month, day, magnitude, depth, hour, minute, second]
            
            
            if nargin==0
                return
            elseif nargin==1 && ischar(varargin{1})
                obj.Name = varargin{1};
            elseif istable(varargin{1})
                vn = varargin{1}.Properties.VariableNames;
                if any(vn == "Date")
                    vn(vn == "DecimalYear") = [];
                    vn(vn == "DayOfYear")   = [];
                end
                for i=1:numel(vn)
                    try
                        obj.(vn{i}) = varargin{1}.(vn{i});
                    catch ME
                        fprintf('Error interpreting field: %s\n',vn{i});
                        warning(ME.message);
                    end
                end
                if isempty(obj.MagnitudeType)
                    obj.MagnitudeType = repmat(categorical({''}),size(obj.Magnitude));
                end
                obj.Name    = varargin{1}.Properties.Description;
                pu          = varargin{1}.Properties.VariableUnits;
                
                % automatically convert depth units
                if ~isempty(pu) && ~isempty(pu(vn=="Depth"))
                    units       = validateLengthUnit(pu{vn=="Depth"});
                    obj.Depth   = unitsratio('kilometer',units) * obj.Depth;
                end
                
                
            elseif isnumeric(varargin{1})
                % import Catalog from Array
                nCols = size(varargin{1},2);
                fprintf(['importing from old catalog array with %d columns and %d events:\n'...
                    '[ lon lat decyr month day mag dep hr min sec ]\n'],nCols, size(varargin{1},1));
                obj.Longitude   = varargin{1}(:,1);
                obj.Latitude    = varargin{1}(:,2);
                if all(varargin{1}(:,3) < 100)
                    varargin{1}(:,3) = varargin{1}(:,3)+1900;
                    errdisp =  'The catalog dates appear to have 2 digits years. Action taken: added 1900 for Y2K compliance';
                    warndlg(errdisp)
                end
                if nCols==9
                    nRows=size(varargin{1},1);
                    obj.Date = datetime([floor(varargin{1}(:,3)),...
                        varargin{1}(:,[4,5,8,9]),...
                        zeros(nRows,1)]);
                else
                    obj.Date        = datetime([floor(varargin{1}(:,3)), varargin{1}(:,[4,5,8,9,10])]);
                end
                obj.Depth           = varargin{1}(:,7);
                obj.Magnitude       = varargin{1}(:,6);
                
                obj.MagnitudeType   = repmat(categorical({''}),size(obj.Magnitude));
                obj.Dip             = nan(obj.Count,1);
                obj.DipDirection    = nan(obj.Count,1);
                obj.Rake            = nan(obj.Count,1);
                
                if nargin==2 && ischar(varargin{2})
                    obj.Name        = varargin{2};
                end
                
            elseif isa(varargin{1},'ZmapCatalog')
                % force a copy
                idx      = true(varargin{1}.Count,1);
                obj      = varargin{1}.subset(idx);
                obj.Name = varargin{1}.Name;
            end
            obj.Filter=true(size(obj.Longitude));
        end
        
        function propval = get.Count(obj)
            % number of events
            if numel(obj)==0
                propval = 0;
            else
                propval = numel(obj.Longitude);
            end
        end
        %function set.Name(obj,value)
        %    obj.Name=value; %only here for debugging
        %end
        
        function out = get.DateSpan(obj)
            % dspan = obj.DateSpan  returns difference between min & max dates
            out = range(obj.Date);
            if days(out)>5
                out.Format = 'd';
            end
        end
        function propval = get.DecimalYear(obj)
            propval = decyear(obj.Date);
        end
        
        function propval = get.DayOfYear(obj)
            propval = fix(datenum(obj.Date)) - datenum(obj.Date.Year - 1, 12 , 31);
        end
        
        function set.RefEllipsoid(obj, value)
            % change reference ellipsoid associated with data WITHOUT updating lat & lon positions.
            % Reference ellipsoid is always of length unit 'kilometer'
            if ischar(value)||isstring(value)
                obj.RefEllipsoid = referenceEllipsoid(value,'kilometer');
            elseif isa(value,'referenceEllipsoid')
                obj.RefEllipsoid = value;
                obj.RefEllipsoid.LengthUnit='kilometer';
            else
                error('Trying to set the reference ellipsoid with unknown value. use a name (ex. ''wgs84'') or provide a referenceEllipsoid');
            end
        end
        
        function set.MomentTensor(obj, value)
            MomentTensorColumns = {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'};
            if istable(value)
                assert(isequal(value.Properties.VariableNames,MomentTensorColumns));
                obj.MomentTensor = value;
            elseif isnumeric(value)
                assert(size(value,2) == 6,...
                    'expect moment tensors to have 6 columns %s:', strjoin(MomentTensorColumns,', '));
                obj.MomentTensor     = array2table(value, 'VariableNames', MomentTensorColumns);
            end
        end
        
        function TF = isempty(obj)
            % ISEMPTY is true when there are no events in the catalog
            % tf = ISEMPTY(catalog)
            TF = numel(obj)==0 || isempty(obj.Latitude);
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
            warnState=warning('off', 'MATLAB:structOnObject');
            st       = struct(obj);
            warning(warnState.state, warnState.identifier); %restore

            flds     = fieldnames(st);
            % to  convert to a table, all fields must be of same length
            % but some fields aren't individual to events.
            todelete = structfun(@(x)numel(x)~=st.Count , st);
            st       = rmfield(st,flds(todelete));
            tbl      = struct2table(st);
            tbl.Properties.Description = obj.Name;
        end
        
        function s = summary(obj, verbosity)
            % SUMMARY return a summary of this catalog
            % valid verbosity values: 'simple', 'stats'
            
            tFmt = 'uuuu-MM-dd HH:mm:ss';
            
            % add additional ways to look at catalog if it makes sense
            if ~exist('verbosity','var')
                verbosity = '';
            end
            if numel(obj) > 1
                s = sprintf('%d Catalogs',numel(obj));
                return
            end
            
            if isempty(obj) || obj.Count==0
                s = sprintf('Empty Catalog, named "%s"',obj.Name);
                return
            end
            leq = char(8804); %pretty version of <= , because a typed representation doesn't work across all platforms.
            switch verbosity
                case 'simple'
                    minti   = min( obj.Date );
                    maxti   = max( obj.Date );
                    minma   = min(obj.Magnitude);
                    maxma   = max(obj.Magnitude);
                    mindep  = min(obj.Depth);
                    maxdep  = max(obj.Depth);
                    mtypes  = cat2mtypestring();
                    fmtstr  = [...
                        'Catalog "%s" with %d events\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        'Depths:     %4.2f km ',leq,' Z ',leq,' %4.2f km\n',...
                        'Magnitudes: %2.1f ',leq,' M ',leq,' %2.1f\n',...
                        'MagnitudeTypes: %s'];
                    s = sprintf(fmtstr, obj.Name, obj.Count, ...
                        char(minti,tFmt),...
                        char(maxti,tFmt),...
                        mindep, maxdep,...
                        minma, maxma,mtypes);
                case 'stats'
                    minti   = min( obj.Date );
                    maxti   = max( obj.Date );
                    minma   = min(obj.Magnitude);
                    maxma   = max(obj.Magnitude);
                    mindep  = min(obj.Depth);
                    maxdep  = max(obj.Depth);
                    
                    fmtstr = [...
                        'Catalog "%s"\nNumber of events: %d\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        '  %s\n',...
                        'Depths:     %4.2f km ',leq,' Z ',leq,' %4.2f km\n',...
                        '  %s\n',...
                        'Magnitudes: %2.1f ',leq,' M ',leq,' %2.1f\n',...
                        '  %s\n',...
                        'Magnitude Types: %s'];
                    
                    mean_int    = mean(diff(obj.Date));
                    median_int  = median(diff(obj.Date));
                    std_int     = std(diff(obj.Date));
                    mean_int.Format     = 'd';
                    median_int.Format   = 'd';
                    std_int.Format      = 'd';
                    if std_int < 10
                        std_int.Format      = 'hh:mm:ss';
                    end
                    if mean_int < 10
                        mean_int.Format     = 'hh:mm:ss';
                    end
                    if median_int < 10
                        median_int.Format   = 'hh:mm:ss';
                    end
                    s = sprintf(fmtstr, obj.Name, obj.Count, ...
                        char(minti, tFmt),...
                        char(maxti, tFmt),...
                        sprintf('mean interval: %s ±std %s , median int: %s', mean_int, std_int, median_int),...
                        mindep, maxdep,...
                        sprintf('mean: %.3f ±std %.3f , median: %.3f', mean(obj.Depth), std(obj.Depth), median(obj.Depth)),...
                        minma, maxma,...
                        sprintf('mean: %.2f ±std %.2f , median: %.2f', mean(obj.Magnitude), std(obj.Magnitude), median(obj.Magnitude)),...
                        cat2mtypestring());
                case 'list'
                    fprintf('Catalog "%s" with %d events\n', obj.Name, obj.Count);
                    fprintf('Date                      Lat       Lon   Dep(km)    Mag  MagType\n');
                    for n=1:obj.Count
                        fmtstr  = '%s  %8.4f  %9.4f   %6.2f   %4.1f   %s\n';
                        mt      = obj.MagnitudeType(n);
                        fprintf( fmtstr, char(obj.Date(n),'uuuu-MM-dd HH:mm:ss'),...
                            obj.Latitude(n), obj.Longitude(n), obj.Depth(n), obj.Magnitude(n), mt);
                    end
                otherwise
                    s = sprintf('Catalog "%s", containing %d events', obj.Name, obj.Count);
            end
            function mtypes = cat2mtypestring()
                % CAT2MTYPESTRING returns a string representation of the catalog type
                % mtypes = CAT2MTYPESTRING()
                mtypes = strjoin(categories(unique(obj.MagnitudeType)), ',');
                if isempty(mtypes)
                    mtypes = '-none-';
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
            obj.IsSortedBy      = field;
            obj.SortDirection   = direction;
        end
        
        function other = sortedByDistanceTo(obj, lat, lon, varargin)
            % SORTEDBYDISTANCE returns a catalog that has been sorted by distance to a point
            % ans=catalog.SORTEDBYDISTANCE(lat, lon) % epicentral sort
            % ans=catalog.SORTEDBYDISTANCE(lat, lon, depth) % hypocentral sort to surface
            %
            % does NOT modify original
            dists = obj.DistanceTo(lat, lon, varargin{:});
            [~,idx]   = sort(dists);
            other     = obj.subset(idx);
            other.IsSortedBy    = 'distance';
            other.SortDirection = 'ascending';
        end
        
        function [other, max_km] = selectClosestEvents(obj, lat, lon, depth, n)
            % SELECTCLOSESTEVENTS determine which N events are closest to a point (lat,lon, depth).
            % [otherCat, max_km] = catalog.SELECTCLOSESTEVENTS(lat,lon, depth, nEvents)
            % for epicentral distance, leave depth empty.
            %  ex.  selectClosestEvents(mycatalog, 82, -120, [], 20);
            % the distance to the nth closest event
            %
            % see also selectCircle, selectRadius
            
            dists_km = obj.DistanceTo(lat, lon, depth);
            esp = EventSelectionParameters('NumClosestEvents', n);
            mask = esp.SelectionFromDistances(dists_km,'kilometer');
            other       = obj.subset(mask);
            max_km = max(dists_km(mask));
        end
        
        function [other,max_km] = selectRadius(obj, lat, lon, depth, RadiusKm)
            %SELECTRADIUS  select subset catalog to a radius from a point
            % [catalog,max_km] = catalog.SELECTRADIUS(lat, lon, dist_km) epicentral radius from a point. sortorder is preserved
            % [catalog,max_km] = catalog.SELECTRADIUS(lat, lon, depth, dist_km) hypocentral radius from a point. sortorder is preserved
            %
            % see also selectClosestEvents, selectCircle
            if ~exist('RadiusKm','var')
                RadiusKm = depth;
                depth    = [];
            end
            
            dists_km = obj.DistanceTo(lat, lon, depth);
            
            mask = dists_km <= RadiusKm;
            % furthest_event_km = max(dists_km(mask));
            other = obj.subset(mask);
            if ~any(mask)
                max_km = 0;
            else
                max_km = max(dists_km(mask));
            end
        end
        
        function [ minicat, max_km ] = selectCircle(obj, esp, x,y,z )
            %selectCircle Select events in a circle defined by either distance or number of events or both
            % [ minicat, maxd ] = catalog.SELECTCIRCLE( SELCRIT, x,y,z ) where selcrit is an 
            % EventSelectionParameters object. The comparison point is x,y,z, where 
            % x, y are in degrees, and z is in km or is empty [].
            % returns a catalog containing selected events, along with the maximum distance of the
            % catalog from the chosen point
            %
            % see also selectClosestEvents, selectRadius, EventSelectionParameters
            if ~(esp.UseEventsInRadius || esp.UseNumClosestEvents)
                error('Error: No selection criteria was chosen. Results would be one value (based on entire catalog) repeated');
            end
            dists_km = obj.DistanceTo(y,x,z);
            
            mask = esp.SelectionFromDistances(dists_km,'kilometer');
            minicat = obj.subset(mask);
            max_km = max(dists_km(mask));
        end
        
        function obj = blank(~)
            % allows subclass-aware use of empty objects
            obj = ZmapCatalog();
        end
        
        function subset_in_place(obj,range)
            %SUBSET_IN_PLACE modifies this object, not a copy of it.
            obj.Date = obj.Date(range);
            
            obj.Longitude       = obj.Longitude(range) ;
            obj.Latitude        = obj.Latitude(range);
            obj.Depth           = obj.Depth(range);
            obj.Magnitude       = obj.Magnitude(range) ;
            obj.MagnitudeType   = obj.MagnitudeType(range) ;
            
            if ~isempty(obj.Filter)
                obj.Filter      = obj.Filter(range) ;
            end
            if ~isempty(obj.Dip)
                obj.Dip         = obj.Dip(range);
            end
            if ~isempty(obj.DipDirection)
                obj.DipDirection = obj.DipDirection(range);
            end
            if ~isempty(obj.Rake)
                obj.Rake        = obj.Rake(range);
            end
            if ~isempty(obj.MomentTensor)
                obj.MomentTensor = obj.MomentTensor(range,:);
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
            
            obj             = existobj.blank();
            obj.Name        = existobj.Name;
            
            obj.Date             = existobj.Date(range);       % datetime
            obj.Longitude        = existobj.Longitude(range) ;
            obj.Latitude         = existobj.Latitude(range);
            obj.Depth            = existobj.Depth(range) ;      % km
            obj.Magnitude        = existobj.Magnitude(range);
            obj.MagnitudeType    = existobj.MagnitudeType(range) ;
            if ~isempty(obj.Filter)
                obj.Filter       = existobj.Filter(range) ;
            end
            if ~isempty(existobj.Dip)
                obj.Dip          = existobj.Dip(range);
            end
            if ~isempty(existobj.DipDirection)
                obj.DipDirection = existobj.DipDirection(range);
            end
            if ~isempty(existobj.Rake)
                obj.Rake         = existobj.Rake(range);
            end
            if ~isempty(existobj.MomentTensor)
                obj.MomentTensor = existobj.MomentTensor(range,:);
            end
        end
        
        function obj = cat(objA, objB)
            % CAT combines two catalogs
            % combinedCatalog = cat(catalogA, catalogB)
            % duplicates are not removed
            initialCount = objA.Count + objB.Count;
            obj = copy(objA);
            obj.Date           = [objA.Date;           objB.Date];
            obj.Longitude      = [objA.Longitude;      objB.Longitude];
            obj.Latitude       = [objA.Latitude;       objB.Latitude];
            obj.Depth          = [objA.Depth;      	objB.Depth];
            obj.Magnitude      = [objA.Magnitude;      objB.Magnitude];
            obj.MagnitudeType  = [objA.MagnitudeType;  objB.MagnitudeType];
            
            if isempty(objA.Dip) && ~isempty(objB.Dip)
                obj.Dip        = [nan(objA.Count,1);            objB.Dip];
            elseif isempty(objB.Dip) && ~isempty(objA.Dip)
                obj.Dip        = [objA.Dip;            nan(objB.Count,1)];
            else
                obj.Dip        = [objA.Dip;            objB.Dip];
            end
            
            if isempty(objA.DipDirection) && ~isempty(objB.DipDirection)
                obj.DipDirection        = [nan(objA.Count,1);            objB.DipDirection];
            elseif isempty(objB.DipDirection) && ~isempty(objA.DipDirection)
                obj.DipDirection        = [objA.DipDirection;            nan(objB.Count,1)];
            else
                obj.DipDirection        = [objA.DipDirection;            objB.DipDirection];
            end
            
            if isempty(objA.Rake) && ~isempty(objB.Rake)
                obj.Rake        = [nan(objA.Count,1);            objB.Rake];
            elseif isempty(objB.Rake) && ~isempty(objA.Rake)
                obj.Rake        = [objA.Rake;            nan(objB.Count,1)];
            else
                obj.Rake        = [objA.Rake;            objB.Rake];
            end
            
            obj.MomentTensor   = [objA.MomentTensor;   objB.MomentTensor];
            ...
                %add additional fields here!
            ...
            obj.clearFilter();
            assert(obj.Count == initialCount);
        end
        
        function [C, IA] = setdiff(A, B)
            % returns values that are in A but not in B with no repetitions. NO tolerance.
            % based solely on Date, Longitude, Latitude, Depth, and Magnitude
            dateFmt='uuuu-MM-dd''T''HH:mm:ss.SSSSS';
            compstrA = string(A.Date,dateFmt)+" "+string(A.Longitude)+","+string(A.Latitude)+" "+string(A.Depth)+" "+string(A.Magnitude);
            compstrB = string(B.Date,dateFmt)+" "+ string(B.Longitude)+","+string(B.Latitude)+" "+string(B.Depth)+" "+string(B.Magnitude);
            IA=ismember(compstrA,compstrB);
            C=A.subset(~IA);
        end
        
        function E = setxor(A,B)
            % return combination of values that are either in A or B, but not in both. no tolerance
            % based solely on Date, Longitude, Latitude, Depth, and Magnitude
            C=setdiff(A,B); % in A, not in B
            D=setdiff(B,A); % in B, not in A
            E = C.cat(D);
        end
        
        function [C,IA,IB] = intersect(A,B)
            % return values common to both events, no repetitions. no tolerance
            % based solely on Date, Longitude, Latitude, Depth, and Magnitude
            dateFmt='uuuu-MM-dd''T''HH:mm:ss.SSSSS';
            compstrA = string(A.Date,dateFmt)+" "+string(A.Longitude)+","+string(A.Latitude)+" "+string(A.Depth)+" "+string(A.Magnitude);
            compstrB = string(B.Date,dateFmt)+" "+ string(B.Longitude)+","+string(B.Latitude)+" "+string(B.Depth)+" "+string(B.Magnitude);
            IA=ismember(compstrA,compstrB);
            if nargout==3
                IB=ismember(compstrB,compstrA);
            end
            C=A.subset(IA);
        end
        
        
        function [obj, sameidx] = removeDuplicates(obj, varargin)
            % REMOVEDUPLICATES removes events from catalog that are similar within tolerances
            %
            % catalog = catalog.REMOVEDUPLICATES() removes the duplicates according to default
            % tolerances. To specify tolerances, add them as NAME - VALUE pairs.
            %
            % Valid Tolerances names are:
            %   'tolDist_m'  : Horizontal distance tolerance, in meters
            %   'tolDepth_m' : Depth Tolorance, in meters 
            %   'tolTime'    : Time tolerance (in seconds) OR a duration
            %   'tolMag'     : Magnitude Tolerance
            %
            % For example:
            %   c = mycat.removeDuplicates('tolDepth_m', 20 , 'tolTime', milliseconds(50))
            %
            % this only compares events adjacent in the catalog (sorted by time).
            %
            % catalog is returned in DateOrder

            
            obj.sort('Date');
            orig_size = obj.Count;
            p=inputParser();
            p.addOptional('tolDist_m'   , 10            , @(x)isscalar(x) && x>=0 );
            p.addOptional('tolDepth_m'  , 0.5           , @(x)isscalar(x) && x>=0 );
            p.addOptional('tolTime'     ,seconds(0.01)  , @(x)isscalar(x) && x>=0 );
            p.addOptional('tolMag'      , 0.001         , @(x)isscalar(x) && x>=0 );
            p.parse(varargin{:})
            
            tols = p.Results;
            if ~isduration(tols.tolTime)
                tols.tolTime = seconds(tols.tolTime);
            end
            msg.dbfprintf(['Removing duplicates\n Using Tolerances:\n'...
            	'     Time : %10s\n Distance : %6g m\n    Depth : %6g m\n      Mag : %6.3f\n'],...
                tols.tolTime, tols.tolDist_m, tols.tolDepth_m, tols.tolMag);
            % Dip, DipDirection, Rake, MomentTensor are not included in calculation
            
            dist_km = distance(obj.Latitude(1:end-1),obj.Longitude(1:end-1),...
                obj.Latitude(2:end),obj.Longitude(2:end), obj.RefEllipsoid);
            
            isSame = abs(diff(obj.Date)) <= tols.tolTime & ...
                dist_km <= (tols.tolDist_m / 1000) & ...
                abs(diff(obj.Depth))     <= (tols.tolDepth_m / 1000) & ...
                abs(diff(obj.Magnitude)) <= tols.tolMag;
            sameidx = [false; isSame];
            obj = obj.subset(~sameidx);
            msg.dbfprintf('Removed %d duplicates\n', orig_size - obj.Count);
        end
        
        function s = blurb(obj)
            % BLURB get simple statement about catalog
            if numel(obj)>0 && obj.Count > 0
                s = sprintf('ZmapCatalog "%s" with %d events\n',obj.Name,obj.Count);
            else
                s = 'empty ZmapCatalog';
            end
        end
        
        function disp(obj)
            disp(obj.blurb)
            disp('with properties:');
            p=properties(obj);
            for i=1:numel(p)
                pn = p{i};
                switch class(obj.(pn))
                    case 'categorical'
                        c=categories(obj.(pn));
                        s = strjoin(c,', ');
                        if numel(s) > 80
                            commas = find(s==',');
                            break1=max(commas(commas<25));
                            break2=min(commas(commas>(length(s)-25)));
                            
                            s=[s(1:break1),'...',s(break2:end)];
                        end
                        fprintf('\t%20s : %d categories [ %s ]\n', pn, numel(c), s);
                    case 'logical'
                        fprintf('\t%20s : <logical> [%d of %d are true] \n',pn,sum(obj.(pn)),numel(obj.(pn)));
                        
                    case 'cell'
                        fprintf('\t%20s : <%s cell> \n',pn,strjoin(num2str(size(obj.(pn))),'x'));
                    case {'char','string'}
                        fprintf('\t%20s : ''%s''\n',pn,obj.(pn));
                    case {'datetime','duration'}
                        if numel(obj.(pn))==1
                            fprintf('\t%20s : %s\n',pn, obj.(pn));
                        else
                            fprintf('\t%20s : [ %s  to  %s ]\n',pn, min(obj.(pn)), max(obj.(pn)));
                        end
                        
                    case 'referenceEllipsoid'
                        fprintf('\t%20s : %s [Units:%s]',pn,obj.(pn).Name,obj.(pn).LengthUnit);
                        
                    otherwise
                        try
                            
                            if numel(obj.(pn))==1
                                fprintf('\t%20s : %g\n', pn, obj.(pn));
                            else
                                fprintf('\t%20s : [ %g  to  %g ]\n', pn, min(obj.(pn)), max(obj.(pn)));
                            end
                        catch
                            if isempty(obj.(pn))
                                fprintf('\t%20s : empty <%s>\n',pn,class(obj.(pn)))
                            else
                                fprintf('\t%20s : <%s>\n',pn,class(obj.(pn)));
                            end
                        end
                end
                
            end
        end
        
        function plotFocalMechanisms(obj,ax,color)
            % PLOTFOCALMECHANISMS plot the focal mechanisms of a catalog (if they exist)
            % plotFocalMechanisms(catalog, ax, color)
            if ~exist(ax,'var') || ~isprop(ax,'type') || ax ~= "axes"
                ax=gca;
            end
            
            
            %pbar    = pbaspect(ax);
            pbar    = daspect(ax);
            asp     = pbar(1)/pbar(2);
            if isempty(obj.MomentTensor)
                warning('no moment tensors to plot');
            end
            axes(ax)
            set(gca, 'NextPlot', 'add');
            set(findobj(gcf,'Type','Legend'), 'AutoUpdate', 'off'); %
            h=gobjects(obj.Count,1);
            for i=1:obj.Count
                mt = obj.MomentTensor{i,:};
                if istable(mt)
                    mt = mt{:,:};
                end
                
                if ~any(isnan(mt))
                    h(i) = focalmech(mt,obj.Longitude(i),obj.Latitude(i),.05*obj.Magnitude(i),asp,color);
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
            dists_km    = distance(obj.Latitude, obj.Longitude, to_lat, to_lon, obj.RefEllipsoid);
        end
        
        function dists_km = hypocentralDistanceTo(obj, to_lat, to_lon, to_depth_km)
            % get HYPOCENTRALDISTANCETO (lat,lon,z) distance to another point
            % dists_km = catalog.HYPOCENTRALDISTANCETO(to_lat, to_lon, to_depth_km)
            dists_km    = distance(obj.Latitude, obj.Longitude, to_lat, to_lon, obj.RefEllipsoid);
            delta_dep   = (obj.Depth - to_depth_km);
            dists_km    = sqrt( dists_km .^ 2 + delta_dep .^ 2);
        end
        
        function dists_km = DistanceTo(obj, to_lat, to_lon, to_depth_km)
            if ~exist('to_depth_km','var') || isempty(to_depth_km)
                dists_km = obj.epicentralDistanceTo(to_lat, to_lon);
            else
                dists_km = obj.hypocentralDistanceTo(lat, lon, to_depth_km);
            end
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

