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
        Dip             double
        DipDirection    double
        Rake            double
        MomentTensor    table               = get_empty_moment_tensor()
        RefEllipsoid    referenceEllipsoid  = referenceEllipsoid('wgs84','kilometer'); % reference ellipsoid for Longitude and Latitude as specified in QuakeML
        % additions to this table need to be also added to a bunch of functions:
        %    summary (?), getCropped, sort, subset
    end
    
    properties(Dependent)
        Depth           double                          % Depth of events (in kilometers)
        Longitude       double                          % Longitude (Deg) of each event
        Latitude        double                          % Latitude (Deg) of each event
        DepthUnits
    end
    
    
    events
        ValueChange
    end
    
    
    methods
        % % %
        % constructor
        % % %
        
        function obj = ZmapCatalog(other, varargin)
            % ZMAPCATALOG create a ZmapCatalog object
            %
            % catalog = ZMAPCATALOG() get an empty catalog
            % catalog = ZMAPCATALOG(name) get an empty catalog, but set the name
            % catalog = ZMAPCATALOG(otherCatalog) get a copy of a catalog
            % catalog = ZMAPCATALOG(table) create a catalog from a table
            % catalog = ZMAPCATALOG(zmaparray) create a catalog from a ZmapArray with columns:
            %   [longitude, latitude, decyear, month, day, magnitude, depth_km, hour, minute, second]
            obj.XLabel = 'Longitude';
            obj.YLabel = 'Latitude';
            obj.ZLabel = 'Depth';
            obj.ZDir   = 'reverse';
            obj.ZUnits = 'kilometer';
            
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
       
        % % %
        %
        % positional interpretations (lat, lon, depth from/to base class)
        %
        % % %
        function val = get.Depth(obj)
            val = obj.XYZ(:,3);
        end
        
        function set.Depth(obj,val)
            obj.XYZ(1:numel(val),3)=val;
        end
        
        function val = get.DepthUnits(obj)
            val = obj.ZUnits;
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
                
        %% 
        %
        %
        
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
        
        %%  distance functions that are lat/lon aware
        %
        %
        
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
    
    methods(Static)
        function obj = blank()
            % allows subclass-aware use of empty objects
            obj = ZmapCatalog();
        end
        
    end
    methods (Static, Hidden)
        function s = display_order()
            % get fields to display, in order.
            s = {'Name','Type','Date','DateSpan',...
                'RefEllipsoid',...
                'Longitude','Latitude','Depth','DepthUnits',...
                'Magnitude','MagnitudeType',...
                'IsSortedBy','SortDirection', ...
                'Dip','DipDirection','Rake','MomentTensor'...
                };
        end
        function pef = possibly_empty_fields()
            % fields that are either empty, or have the same length as event.
            pef = [possibly_empty_fields@ZmapBaseCatalog , {'Dip','DipDirection','Rake', 'MomentTensor'}];
        end
        
    end
end

function tb = get_empty_moment_tensor()
    tb = table([],[],[],[],[],[],'VariableNames', {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'});
end
