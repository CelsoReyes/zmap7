classdef (ConstructOnLoad) MomentTensorAddon < ZmapCatalogAddon
    %   MomentTensorAddon for a ZmapCatalog
    %   Dip - angle of dip
    %   DipDirection - direction of dip
    %   Rake - direction of movement for hanging wall block
    %
    %   MomentTensor - table, as mrr, mtt, mff, mrt, mrf, mtf
    %
    
    properties
        Dip             double      % angle of dip, between 0 (horiz) and 90 degrees (vert)
        DipDirection    double      % direction of dip (clockwise from north
        Rake            double      % direction of movement for hanging wall block
        MomentTensor    table       = get_empty_moment_tensor() % moment tensor information
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
            obj.ZUnits = 'kilometer';
            obj.PositionUnits = 'degree';
            
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
        
    end
    
    methods(Static)
        function obj = blank()
            % allows subclass-aware use of empty objects
            obj = ZmapCatalog();
        end
        
    end
    methods (Static, Hidden)
        
        % % % intentionally not implementing: fields_that_must_be_nevent_length(); 
        function s = display_order()
            s = ZmapCatalog.display_order();
            s = [s,{'Dip','DipDirection','Rake','MomentTensor'}];
        end
        
        function pef = possibly_empty_fields()
            % fields that are either empty, or have the same length as event.
            pef = [possibly_empty_fields@ZmapCatalog , {'Dip','DipDirection','Rake', 'MomentTensor'}];
        end

    end
end

function tb = get_empty_moment_tensor()
    tb = table([],[],[],[],[],[],'VariableNames', {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'});
end
