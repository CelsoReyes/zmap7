classdef ZmapCatalog < ZmapBaseCatalog
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
    %   epicentralDistanceTo - get distance to a point, considering only Lat/Lon. default units are specified by this Catalog's RefEllipsoid
    %   hypocentralDistanceTo - get distance to a point, taking depth into consideration. default units are specified by this Catalog's RefEllipsoid
    %   selectClosestEvents - return a catalog containing only N closest events
    %   selectRadius - return a catalog containing only events within a radius
    
    % TODO consider using matlab.mixin.CustomDisplay
    properties
        Dip
        DipDirection
        Rake 
        MomentTensor    table               = get_empty_moment_tensor()
        RefEllipsoid    referenceEllipsoid  = referenceEllipsoid('wgs84','kilometer'); % reference ellipsoid for Longitude and Latitude as specified in QuakeML
        % additions to this table need to be also added to a bunch of functions:
        %    summary (?), getCropped, sort, subset
    end
    
    properties(Dependent)
        Depth           double                          % Depth of events (in kilometers)
        Longitude       double                          % Longitude (Deg) of each event
        Latitude        double                          % Latitude (Deg) of each event
    end
    
    properties(Constant)
        Type           = 'zmapcatalog'
        DepthUnits     = 'kilometer'
    end
    
    events
        ValueChange
    end
    
    
    methods

        function obj = ZmapCatalog(other, varargin)
            % ZMAPCATALOG create a ZmapCatalog object
            %
            % catalog = ZMAPCATALOG() get an empty catalog
            % catalog = ZMAPCATALOG(name) get an empty catalog, but set the name
            % catalog = ZMAPCATALOG(otherCatalog) get a copy of a catalog
            % catalog = ZMAPCATALOG(table) create a catalog from a table
            % catalog = ZMAPCATALOG(zmaparray) create a catalog from a ZmapArray with columns:
            %   [longitude, latitude, decyear, month, day, magnitude, depth_km, hour, minute, second]
            
            
            if nargin==0                                        % ZMAPCATALOG()
                return
                
            elseif nargin==1 && ischar(other)                   % ZMAPCATALOG(name)
                obj.Name = other;
                
            elseif istable(other)                               % ZMAPCATALOG(table)
                
                other = table2zmapcatalogtable(other);
                
                vn = other.Properties.VariableNames;
                for i=1:numel(vn)
                    fieldname = vn{i};
                    try
                        obj.(fieldname) = other.(fieldname);
                    catch ME
                        fprintf('Error interpreting field: %s\n',fieldname);
                        warning(ME.message);
                    end
                end
                
                if isempty(obj.MagnitudeType)
                    obj.MagnitudeType = repmat(categorical({''}),size(obj.Magnitude));
                end
                
                obj.Name    = other.Properties.Description;
                pu          = other.Properties.VariableUnits;
                
                % automatically convert depth units
                if ~isempty(pu) && ~isempty(pu(vn=="Depth"))
                    units       = validateLengthUnit(pu{vn=="Depth"});
                    obj.Depth   = unitsratio(obj.DepthUnits,units) * obj.Depth;
                end
                
                
            elseif isnumeric(other)                             % ZMAPCATALOG(zmaparray)
                % import Catalog from Array
                nCols = size(other,2);
                fprintf(['importing from old catalog array with %d columns and %d events:\n'...
                    '[ lon lat decyr month day mag dep hr min sec ]\n'],nCols, size(other,1));
                obj.Longitude   = other(:,1);
                obj.Latitude    = other(:,2);
                if all(other(:,3) < 100)
                    other(:,3) = other(:,3)+1900;
                    errdisp =  'The catalog dates appear to have 2 digits years. Action taken: added 1900 for Y2K compliance';
                    warndlg(errdisp)
                end
                if nCols==9
                    nRows=size(other,1);
                    obj.Date = datetime([floor(other(:,3)),...
                        other(:,[4,5,8,9]),...
                        zeros(nRows,1)]);
                else
                    obj.Date        = datetime([floor(other(:,3)), other(:,[4,5,8,9,10])]);
                end
                obj.Depth           = other(:,7) .* unitsratio(obj.DepthUnits,'kilometer');
                obj.Magnitude       = other(:,6);
                
                obj.MagnitudeType   = repmat(categorical({''}),size(obj.Magnitude));
                obj.Dip             = nan(obj.Count,1);
                obj.DipDirection    = nan(obj.Count,1);
                obj.Rake            = nan(obj.Count,1);
                
                if nargin==2 && ischar(varargin{1})
                    obj.Name        = varargin{1};
                end
                
            elseif isa(other,'ZmapCatalog')                     % ZMAPCATALOG(zmapcatalog)
                idx      = true(other.Count,1);
                obj      = other.subset(idx); % force a copy
                obj.Name = other.Name;
            end
            obj.Filter=true(size(obj.Longitude));
        end
       
        function val = get.Depth(obj)
            val = obj.XYZ(:,3);
        end
        
        function set.Depth(obj,val)
            obj.XYZ(1:numel(val),3)=val;
        end
        
        function val = get.Latitude(obj)
            val = obj.XYZ(:,2);
        end
        
        function set.Latitude(obj,val)
            obj.XYZ(1:numel(val),2)=val;
        end
        
        function val = get.Longitude(obj)
            val = obj.XYZ(:,1);
        end
        
        function set.Longitude(obj,val)
            obj.XYZ(1:numel(val),1)=val;
        end
                
        function set.RefEllipsoid(obj, value)
            % change reference ellipsoid associated with data WITHOUT updating lat & lon positions.
            % Reference ellipsoid is always of length unit 'kilometer'
            if ischarlike(value)
                obj.RefEllipsoid = referenceEllipsoid(value,'kilometer');
            elseif isa(value,'referenceEllipsoid')
                obj.RefEllipsoid = value;
                %obj.RefEllipsoid.LengthUnit='kilometer'; %% why forcing km?
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
                obj.Depth ...        % 7
                obj.Date.Hour,...    % 8
                obj.Date.Minute, ... % 9
                obj.Date.Second]; % position 10 of 10
            
            % ZmapArray that had 12 values is like above, except...
            % obj.Dip % position 10 of 12
            % obj.DipDirection % position 11 of 12
            % obj.Rake % position 12 of 12
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
            
            shortDepthUnitList = {
                'kilometer','km';
                'meter','m';
                'centimeter','cm';
                'millimeter','mm';
                'micron','nm';
                'mile','mi';
                'foot','ft';
                'inch','in';
                'yard','yd'                
                };
            depUn = shortDepthUnitList{string(obj.DepthUnits)==shortDepthUnitList(:,1),2};
                    
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
                        'Depths:     %4.2f ',depUn,' ',leq,' Z ',leq,' %4.2f', depUn,'\n',...
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
                        'Depths:     %4.2f ',depUn,' ',leq,' Z ',leq,' %4.2f ',depUn,'\n',...
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
                    fprintf('Date                      Lat       Lon   Dep(%s)    Mag  MagType\n',depUn);
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
        
        function obj = blank(~)
            % allows subclass-aware use of empty objects
            obj = ZmapCatalog();
        end
        
        function subset_in_place(obj,range)
            %SUBSET_IN_PLACE modifies this object, not a copy of it.
            subset_in_place@ZmapBaseCatalog(obj,range)
            
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
            
            obj = subset@ZmapBaseCatalog(existobj, range);
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
            obj = cat@ZmapBaseCatalog(objA, objB);
            
            otherFieldsToCopy = {'Dip','DipDirection','Rake'};
            for n = 1:numel(otherFieldsToCopy)
                fn = otherFieldsToCopy{n};
                
                % these fields might be empty in the other catalog, so let fill with nans
                if isempty(objA.(fn)) && ~isempty(objB.(fn))
                    obj.(fn)        = [nan(objA.Count,1);            objB.(fn)];
                elseif isempty(objB.(fn)) && ~isempty(objA.(fn))
                    obj.(fn)        = [objA.(fn);            nan(objB.Count,1)];
                else
                    obj.(fn)        = [objA.(fn);            objB.(fn)];
                end
            end
            
            obj.MomentTensor   = [objA.MomentTensor;   objB.MomentTensor];
            ...
                %add additional fields here!
            ...
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
                
        function [dists, units] = epicentralDistanceTo(obj, to_lat, to_lon)
            % get epicentral (lat-lon) distance to another point
            % dists = catalog.EPICENTRALDISTANCETO(to_lat, to_lon) returns the distance in the same
            % units as the catalog's RefEllipsoid.
            %
            % dists = catalog.EPICENTRALDISTANCETO(to_lat, to_lon, dist_units) converts the distances
            % into the desired units for further calculation
            dists    = distance(obj.Latitude, obj.Longitude, to_lat, to_lon, obj.RefEllipsoid);
            units = obj.RefEllipsoid.LengthUnit;
        end
        
        function [dists, units] = hypocentralDistanceTo(obj, to_lat, to_lon, to_depth_km)
            % get HYPOCENTRALDISTANCETO (lat,lon,z) distance to another point
            % dists_km = catalog.HYPOCENTRALDISTANCETO(to_lat, to_lon, to_depth_km)
            assert(obj.RefEllipsoid.LengthUnit == "kilometer") % we make this assumption because of depth units
            dists    = distance(obj.Latitude, obj.Longitude, to_lat, to_lon, obj.RefEllipsoid);
            delta_dep   = (obj.Depth - to_depth_km);
            dists    = sqrt( dists .^ 2 + delta_dep .^ 2);            
            units = obj.RefEllipsoid.LengthUnit;
        end
        
    end
    
end

function tb = get_empty_moment_tensor()
    tb = table([],[],[],[],[],[],'VariableNames', {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'});
end
