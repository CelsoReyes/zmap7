classdef (ConstructOnLoad) ZmapCatalog < matlab.mixin.Copyable
    % ZmapCatalog represents the basic utilities for an event catalog
    %
    % ZmapCatalog properties:
    %   Name - name of this catalog
    %   Date - date and time of event
    %   XYZ - position of each event
    %   Magnitude - magnitude of each event
    %   MagnitudeType - Magnitude units, such as M, ML, MW, etc.
    %
    %   IsSortedBy - describes sort order
    %   SortDirection - describes sorting direction
    %
    % ZmapCatalog read-only properties:
    %   Count - number of events in catalog
    %
    %   X - read-only X position
    %   Y - read-only Y position
    %   Z - read-only Z position
    %
    %   DateSpan - time between first and last events in catalog (duration)
    %   DayOfYear - dates represented as the day of year
    %   DecimalYear - dates represented as a decimal year
    %
    %
    % ZmapCatalog methods:
    %
    %  Catalog construction:
    %   ZmapCatalog -
    %   blank - return a blank catalog
    %   cat - combines two catalogs
    %   copy - copy catalog. otherwise handles likely point to same object
    %
    %
    %  Output functions:
    %   blurb - get simple statement about catalog
    %   disp - Display array.
    %   summary - return a summary of this catalog
    %   table - write catalog as a table
    %
    %  Query methods:
    %   isempty - true when there are no events in the catalog
    %   relativeTimes - get times relative to first event or a specific time
    %
    %
    %  Plotting functions:
    %   scatter - Scatter/bubble plot
    %   scatter3 - 3-D Scatter plot
    %
    %  Set membership functions:
    %   setdiff - returns values that are in A but not in B with no repetitions. NO tolerance
    %   setxor - return combination of values that are either in A or B, but not in both. no tolerance
    %   intersect - return values common to both events, no repetitions. no tolerance
    %
    %  Sorting, Filtering, Subsetting methods:
    %   removeDuplicates - removes events from catalog that are similar within tolerances
    %   sort - sort this catalog by the specified field (IN PLACE)
    %   subset - get a subset of this catalog.
    %   subsetInPlace - modifies this catalog, not a copy of it.
    %
    %   sortedByDistanceTo - get a catalog that has been sorted by distance to a point
    %
    %  Spatial methods:
    %   distanceTo - get distance to events in catalog from a point or set of points
    %   epicentralDistanceTo - get distance from all events to a point (assuming Z is same for all)
    %   hypocentralDistanceTo - get 3D distance from all events to a point
    %   selectCircle - select events in a circle defined by distance, number of events, or both
    %   selectClosestEvents - determine which N events are closest to a point
    %   selectRadius - select subset catalog to a radius from a point
    %
    %  Misc. methods
    %   validate - check validity of the catalog
    
    properties
        Date            (:,1) datetime          % date and time of event
        EventID         (:,1) string            % id of this event
        Magnitude       (:,1) double            % Magnitude of each event
        MagnitudeType   (:,1) categorical       % Magnitude units, such as M, ML, MW, etc.
    end
    
    properties(SetObservable, AbortSet)
        Name            (1,:) char      = ''    % name of this catalog
        IsSortedBy      char            = ''    % describes sort order
        SortDirection   char            = ''    % describes sorting direction
        Filter          (:,1) logical           % logical filter for subsetting events
        XYZ             (:,3) double            % position of each event
        OtherFields     cell % of ZmapCatalogAddon  % TODO:  1st implementaion is MomentTensorAddon
    end
    
    properties(Hidden)
        XLabel          (1,:) char      = 'X'
        YLabel          (1,:) char      = 'Y'
        ZLabel          (1,:) char      = 'Z'
        ZDir            (1,:) char      = 'normal'
    end
    
    properties(Dependent)
        DecimalYear % dates represented as a decimal year
        DayOfYear   % dates represented as the day of year
        Count       % the number of events in catalog
        DateSpan    % the time between first and last events in catalog
        X               double      % X position of each event
        Y               double      % Y position of each event
        Z               double      % Z position of each event
        XLabelWithUnits
        YLabelWithUnits
        ZLabelWithUnits
        Longitude       double     	% Longitude (Deg) of each event
        Latitude        double     	% Latitude (Deg) of each event
        Depth           double     	% Depth of events
        LengthUnit                 % units for X, Y, Z offsets
    end
    
    properties(Dependent, Hidden)
        FieldnamesForColorby
        HorizontalUnit
    end
    
    events
        ValueChange
    end
    
    properties(Constant)
        DefaultRefEllipsoid = @()getappdata(groot, 'ZmapDefaultReferenceEllipsoid');
    end
    
    properties(SetAccess=immutable)
        Type        (1,:) char
        RefEllipsoid referenceEllipsoid = ZmapCatalog.DefaultRefEllipsoid();
    end
    
    properties(SetAccess=immutable, Hidden)
        distanceFcn2d   function_handle     = @obj.cartesianEpicentralDistanceTo;
        distanceFcn3d   function_handle     = @obj.cartesianHypocentralDistanceTo;
    end
    
    
    methods
        % ordered as: Constructors, dependent property methods, alphabetical list of all others
        function obj = ZmapCatalog(varargin)
            obj.Type = 'zmapcatalog';
            if ~isempty(varargin)
                if nargin==1 && isa(varargin{1}, 'ZmapCatalog')
                    obj = copy(varargin{1});
                    return
                end
                p = inputParser;
                p.addParameter('ReferenceEllipsoid', obj.RefEllipsoid);
                p.addParameter('Name', obj.Name);
                p.addParameter('LengthUnit', obj.RefEllipsoid.LengthUnit);
                p.parse(varargin{:});
                obj.RefEllipsoid = p.Results.ReferenceEllipsoid;
                obj.RefEllipsoid.LengthUnit = p.Results.LengthUnit;
                obj.Name = p.Results.Name;
            end
            
            if ~iscartesian(obj.RefEllipsoid)
                obj.XLabel = 'Longitude';
                obj.YLabel = 'Latitude';
                obj.ZLabel = 'Depth';
                obj.ZDir   = 'reverse';
                obj.distanceFcn2d   = @obj.geodeticEpicentralDistanceTo;
                obj.distanceFcn3d   = @obj.geodeticHypocentralDistanceTo;
            end
        end
        
        % -----------------
        function tf = hasAddon(obj, type)
            tf =  any(cellfun(@(x)x.Type == string(type), obj.OtherFields));
        end
        
        function list = getAddonTypes(obj)
            list = cellfun(@(x)x.Type, obj.OtherFields, 'UniformOutput', false);
        end
        
        function aoFnc = getAddon(obj, type)
            idx = cellfun(@(x)x.Type == string(type), obj.OtherFields);
            if any(idx)
                aoFnc = obj.OtherFields{idx};
            end
        end
        function setAddon(obj, other)
            type = other.Type;
            if obj.hasAddon(type)
                idx = getAddonTypes == string(type);
                obj.OtherFields(idx) = {other};
            else
                if ~iscell(obj.OtherFields)
                    obj.OtherFields = {};
                end
                obj.OtherFields(end+1) = {other};
            end
        end
        % -----------------
            
        function val = get.FieldnamesForColorby(obj)
            val = obj.GetFieldnamesForColorby;
        end
        
        function val = get.Count(obj)
            if numel(obj) == 0
                val = 0;
            else
                val = size(obj.XYZ, 1);
            end
        end
        
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
        function propval = get.X(obj)
            propval = obj.XYZ(:, 1);
        end
        function propval = get.Y(obj)
            propval = obj.XYZ(:, 2);
        end
        function propval = get.Z(obj)
            propval = obj.XYZ(:, 3);
        end
        
        function lu = get.LengthUnit(obj)
            lu = obj.RefEllipsoid.LengthUnit;
        end
        
        function hu = get.HorizontalUnit(obj)
            if iscartesian(obj.RefEllipsoid)
                hu = obj.RefEllipsoid.LengthUnit;
            else
                hu = 'degree';
            end
        end
        
        function lb = get.XLabelWithUnits(obj)
            lb = [obj.XLabel, ' [', obj.HorizontalUnit, ']'];
        end
        
        function lb = get.YLabelWithUnits(obj)
            lb = [obj.YLabel, ' [', obj.HorizontalUnit, ']'];
        end
        
        function lb = get.ZLabelWithUnits(obj)
            lb = [obj.ZLabel, ' [', obj.LengthUnit, ']'];
        end
        
        function val = get.Depth(obj)
            val = obj.XYZ(:, 3);
        end
        
        function set.Depth(obj, val)
            obj.XYZ(1:numel(val), 3)=val;
        end
        
        function val = get.Latitude(obj)
            val = obj.XYZ(:, 2);
        end
        
        function set.Latitude(obj, val)
            obj.XYZ(1:numel(val), 2)=val;
        end
        
        function val = get.Longitude(obj)
            val = obj.XYZ(:, 1);
        end
        
        function set.Longitude(obj, val)
            obj.XYZ(1:numel(val), 1)=val;
        end
        
        function s = blurb(obj)
            % BLURB get simple statement about catalog
            if numel(obj)>1
                s = sprintf('%s catalog matrix', strjoin(string(size(obj)), 'x'));
            elseif numel(obj)==1 && obj.Count > 0
                s = sprintf('%s "%s" with %d events\n', class(obj), obj.Name, obj.Count);
            else
                s = sprintf('empty %s', class(obj));
            end
        end
        
        function obj = cat(objA, objB)
            % CAT combines two catalogs
            % combinedCatalog = cat(catalogA, catalogB)
            % duplicates are not removed
            obj = copy(objA);
            
            
            the_fields = obj.fields_that_must_be_nevent_length();
            for n = 1 : numel(the_fields)
                f= the_fields{n};
                obj.(f) = [objA.(f) ; objB.(f)];
            end
            
            the_fields = obj.possibly_empty_fields();
            for n = 1 : numel(the_fields)
                fn = the_fields{n};
                
                if isempty(objA.(fn)) && isempty(objB.(fn))
                    continue
                end
                
                if istable(objA.(fn))
                    cols=@(x) 1;
                else
                    cols=@(x)size(x, 2);
                end
                
                if isempty(objA.(fn))
                    obj.(fn) = [repmat(missing, objA.Count, cols(objB.(fn)))	; objB.(fn)];
                elseif isempty(objB.(fn))
                    obj.(fn) = [objA.(fn)   ; repmat(missing, objB.Count, cols(objA.(fn)))];
                else
                    obj.(fn) = [objA.(fn);            objB.(fn)];
                end
                
            end
            
            
        end
        
        function disp(obj)
            if numel(obj)>1
                disp(obj.blurb);
                return
            end
            disp(obj.blurb)
            disp('with properties:');
            
            show_categorical = @(f) {numel(categories(obj.(f))), get_limited_categories(obj.(f))};
            show_logical = @(f) {sum(obj.(f)), numel(obj.(f))};
            show_cell    = @(f) {strjoin(num2str(size(obj.(f))), 'x')};
            show_simple  = @(f) {obj.(f)};
            show_range   = @(f) {min(obj.(f)), max(obj.(f))};
            show_refellipse=@(f) {obj.(f).Name, obj.(f).LengthUnit};
            
            business = { ... classname , dispformat, dispfun
                "categorical"   , '%d categories [ %s ]'        , show_categorical;...
                "logical"       , '<logical> [%d of %d are true]' , show_logical;...
                "cell"          , '<%s cell>'                   , show_cell;...
                "char"          , '''%s'''                      , show_simple;...
                "string"        , '''%s'''                      , show_simple;...
                "datetime"      , {'%s', '[ %s  to  %s ]'}      , {show_simple, show_range};...
                "duration"      , {'%s', '[ %s  to  %s ]'}      , {show_simple, show_range};...
                "referenceEllipsoid" , '%s [Units:%s]'          , show_refellipse;...
                ""              , {'%g', '[ %g  to  %g ]'}      , {show_simple, show_range}...
                };
            
            p = obj.display_order();
            for i = 1:numel(p)
                pn = p{i};
                logic = business(class(obj.(pn))==[business{:, 1}], :);
                if isempty(logic)
                    logic = business(end, :);
                end
                fn = logic{3};
                fmtstr = logic{2};
                if iscell(logic{2})
                    if numel(obj.(pn)) > 1
                        fmtstr = fmtstr{2};
                        fn = fn{2};
                    else
                        fmtstr = fmtstr{1};
                        fn = fn{1};
                    end
                end
                
                try
                    values = fn(pn);
                catch
                    if isempty(obj.(pn))
                        fmtstr = 'empty <%s>';
                    else
                        fmtstr = '<%s>';
                    end
                    values = class(obj.(pn));
                end
                fmtstr = "\t%20s : " + fmtstr + "\n";
                
                fprintf(fmtstr, pn, values{:});
            end
            if ~isempty(obj.OtherFields)
                disp(" With other fields:")
                for j = 1:numel(obj.OtherFields)
                    disp(obj.OtherFields{j})
                end
            end
            
        end

        function [dists, units] = distanceTo(obj, x, y, z)
            % get distance to events in catalog from a point or set of points
            if ~exist('z', 'var')||isempty(z)
                [dists, units] = obj.distanceFcn2d(x, y);
            else
                [dists, units] = obj.distanceFcn3d(x, y, z);
            end
        end
        
        function [dists, units] = epicentralDistanceTo(obj, x, y)
            [dists, units] = obj.distanceFcn2d(x, y);
        end
        
        function [dists, units] = hypocentralDistanceTo(obj, x, y, z)
            [dists, units] = obj.distanceFcn3d(x, y, z);
        end
        
        
        
        function [C, IA, IB] = intersect(A, B)
            % return values common to both events, no repetitions. no tolerance
            % based solely on Date,  X, Y, Z, and Magnitude
            dateFmt='uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
            compstrA = string(A.Date, dateFmt)+join(string(A.XYZ))+" "+string(A.Magnitude);
            compstrB = string(B.Date, dateFmt)+join(string(B.XYZ))+" "+string(B.Magnitude);
            IA=ismember(compstrA, compstrB);
            if nargout==3
                IB=ismember(compstrB, compstrA);
            end
            C=A.subset(IA);
        end
        
        function TF = isempty(obj)
            % ISEMPTY is true when there are no events in the catalog
            % tf = ISEMPTY(catalog)
            TF = numel(obj)==0 || isempty(obj.XYZ);
        end
        
        function rt = relativeTimes(obj, other)
            % get times relative to first event or a specific time
            % rt = catalog.RELATIVETIMES() get times relative to start
            % rt = catalog.RELATIVETIMES(other) get times relative to another time
            
            if ~exist('other', 'var')
                rt = obj.Date - min(obj.Date);
                return
            end
            switch class(other)
                case 'datetime'
                    rt = obj.Date - datetime;
                otherwise
                    error('ZMAP:ZmapCatalog:relativeTimes:unknownComparison',...
                        'do not know how to compare to a %s try giving a specific date',class(other));
            end
        end
        
        function [obj, sameidx] = removeDuplicates(obj, varargin)
            % REMOVEDUPLICATES removes events from catalog that are similar within tolerances
            %
            % catalog = catalog.REMOVEDUPLICATES() removes the duplicates according to default
            % tolerances. To specify tolerances, add them as NAME - VALUE pairs.
            %
            % Valid Tolerances names are:
            %   'tolHoriz_m'  : Horizontal distance tolerance, in meters
            %   'tolVert_m' : Z tolerance, in meters
            %   'tolTime'    : Time tolerance (in seconds) OR a duration
            %   'tolMag'     : Magnitude Tolerance
            %
            % For example:
            %   c = mycat.removeDuplicates('tolVert_m', 20 , 'tolTime', milliseconds(50))
            %
            % this only compares events adjacent in the catalog (sorted by time).
            %
            % catalog is returned in DateOrder
            
            
            obj.sort('Date');
            orig_size = obj.Count;
            p = inputParser();
            non_neg_scalar = @(x) isscalar(x) && x>=0;      % used to verify inputs
            p.addOptional('tolHoriz_m'  , 10            , non_neg_scalar );
            p.addOptional('tolVert_m'   , 0.5           , non_neg_scalar );
            p.addOptional('tolTime'     , seconds(0.01) , non_neg_scalar );
            p.addOptional('tolMag'      , 0.001         , non_neg_scalar );
            p.parse(varargin{:})
            
            tols = p.Results;
            if ~isduration(tols.tolTime)
                tols.tolTime = seconds(tols.tolTime);
            end
            msg.dbfprintf(['Removing duplicates\n Using Tolerances:\n'...
                '     Time : %10s\n Horiz Dist : %6g m\n    Vert Dist : %6g m\n      Mag : %6.3f\n'],...
                tols.tolTime, tols.tolHoriz_m, tols.tolVert_m, tols.tolMag);
            % Dip, DipDirection, Rake, MomentTensor are not included in calculation
            
            [dist, units] = obj.subset((1:obj.Count-1)).distanceTo(obj.Y(2:end), obj.X(2:end));
            
            isSame = abs(diff(obj.Date)) <= tols.tolTime & ...
                dist <= tols.tolHoriz_m * unitsratio('meter', units) & ...
                abs(diff(obj.Z))     <= tols.tolVert_m * unitsratio('meters', units) & ...
                abs(diff(obj.Magnitude)) <= tols.tolMag;
            sameidx = [false; isSame];
            obj = obj.subset(~sameidx);
            msg.dbfprintf('Removed %d duplicates\n', orig_size - obj.Count);
            obj.sort('Date')
        end
        
        function h = scatter(obj, varargin)
            if ~isempty(varargin) && isa(varargin{1}, 'matlab.graphics.axis.Axes')
                ax = varargin{1};
            else
                ax = gca;
            end
            h = scatter(ax, obj.XYZ(:, 1), obj.XYZ(:, 2), varargin{:});
            ax.XLabel.String = obj.XLabel;
            ax.YLabel.String = obj.YLabel;
        end
        
        function h = scatter3(obj, varargin)
            if ~isempty(varargin) && isa(varargin{1}, 'matlab.graphics.axis.Axes')
                ax = varargin{1};
            else
                ax = gca;
            end
            h = scatter3(ax, obj.XYZ(:, 1), obj.XYZ(:, 2), obj.XYZ(:, 3), varargin{:});
            ax.XLabel.String = obj.XLabel;
            ax.YLabel.String = obj.YLabel;
            ax.ZLabel.String = obj.ZLabel;
            ax.ZDir = obj.ZDir;
        end
        
        function [ minicat, max_km ] = selectCircle(obj, esp, x, y, z )
            %selectCircle Select events in a circle defined by either distance or number of events or both
            % [ minicat, maxd ] = catalog.SELECTCIRCLE( SELCRIT, x, y, z ) where selcrit is an
            % EventSelectionParameters object. The comparison point is x, y, z, where
            % x, y are in degrees, and z is in km or is empty [].
            % returns a catalog containing selected events, along with the maximum distance of the
            % catalog from the chosen point
            %
            % see also selectClosestEvents, selectRadius, EventSelectionParameters
            if ~(esp.UseEventsInRadius || esp.UseNumClosestEvents)
                error('ZMAP:ZmapCatalog:selectCircle:NoCriteriaChosen',...
                    'Error: Neither selection criteria was chosen. Results would be one value (repeated)');
            end
            [dists, distunits] = obj.distanceTo(y, x, z);
            
            mask = esp.SelectionFromDistances(dists, distunits);
            minicat = obj.subset(mask);
            max_km = max(dists(mask));
        end
        
        function [other, max_km] = selectClosestEvents(obj, x, y, z, n , flag)
            % SELECTCLOSESTEVENTS determine which N events are closest to a point (x, y, z).
            % [otherCat, max_km] = catalog.SELECTCLOSESTEVENTS(x, y, z, nEvents)
            % for epicentral distance, leave Z empty.
            %  ex.  selectClosestEvents(mycatalog, 82, -120, [], 20);
            % the distance to the nth closest event
            %
            %  catalog.SELECTCLOSESTEVENTS(... 'DistanceOnly')
            %  FLAG can be 'DistanceOnly', which means otherCat is never created.
            %  Use this optionwhen calling with a tilde.  For example: 
            %   [~, xxx] = catalog.SELECTCLOSESTEVENTS(x, y, z, nEvents, 'DistOnly')
            % 
            % sorting is unaffected
            %
            % see also selectCircle, selectRadius
            
            [dists, distunits] = obj.distanceTo(x, y, z);
            [smallest_dists, I] = mink(dists, n);
            evIdx=false(size(dists));
            evIdx(I)=true;
            max_km = smallest_dists(end) .* unitsratio('kilometer', distunits);
            if exist('flag', 'var') && flag=="DistanceOnly"
                other = obj.subset(evIdx);
            else
                other=[];
            end
        end
        
        function other = selectRadius(obj, x, y, z, radius, radius_units)
            %SELECTRADIUS  select subset catalog to a radius from a point
            % catalog = catalog.SELECTRADIUS(x , y, radius, radius_units) epicentral radius from a point. sortorder is preserved
            % catalog = catalog.SELECTRADIUS(x, y, z, radius, radius_units) hypocentral radius from a point. sortorder is preserved
            %
            % see also selectClosestEvents, selectCircle
            if isempty('z')
                [dists, distunits] = obj.distanceTo(x, y);
            else
                [dists, distunits] = obj.distanceTo(x, y, z);
            end
            
            mask = dists <= radius .* unitsratio(distunits, radius_units);
            other = obj.subset(mask);
        end
        
        function [C, IA] = setdiff(A, B)
            % returns values that are in A but not in B with no repetitions. NO tolerance.
            % based solely on Date, X, Y, Z, and Magnitude
            dateFmt='uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
            
            compstrA = string(A.Date, dateFmt)+join(string(A.XYZ))+" "+string(A.Magnitude);
            compstrB = string(B.Date, dateFmt)+join(string(B.XYZ))+" "+string(B.Magnitude);
            IA=ismember(compstrA, compstrB);
            C=A.subset(~IA);
        end
        
        function E = setxor(A, B)
            % return combination of values that are either in A or B, but not in both. no tolerance
            % based solely on Date,  X, Y, Z, and Magnitude
            C=setdiff(A, B); % in A, not in B
            D=setdiff(B, A); % in B, not in A
            E = C.cat(D);
        end
        
        function sort(obj, field, direction)
            % SORT this catalog by the specified field (IN PLACE)
            % catalog.SORT(field), where field is a valid ZmapCatalog property
            %
            % catalog.SORT(field, direction), where direction is 'ascend' or 'descend'
            % ex.
            % catalog.sort('Date', 'ascend')
            %
            % NOTE: modifies original
            %
            % see also sortedByDistanceTo
            
            if ~isprop(obj, field)
                error('ZMAP:ZmapCatalog:sort:invalidSortField',...
                    '%s is not a valid property of a ZmapCatalog', field);
            end
            if ~exist('direction', 'var')
                direction = 'ascend';
            end
            [~, idx] = sort(obj.(field), direction);
            obj.subsetInPlace(idx);
            obj.IsSortedBy      = field;
            obj.SortDirection   = direction;
        end
        
        function other = sortedByDistanceTo(obj, x, y, varargin)
            % SORTEDBYDISTANCE returns a catalog that has been sorted by distance to a point
            % ans=catalog.SORTEDBYDISTANCE(x, y) % epicentral sort
            % ans=catalog.SORTEDBYDISTANCE(x, y, z) % hypocentral sort
            %
            % does NOT modify original
            [~, idx]   = sort(obj.distanceTo(x, y, varargin{:}));
            other     = obj.subset(idx);
            other.IsSortedBy    = 'distance';
            other.SortDirection = 'ascending';
        end
        
        function newobj = subset(obj, range)
            % SUBSET get a subset of this object
            % newcatalog = catalog.SUBSET(mask) where mask is a t/f array matching obj.Count
            %    will keep all "true" events
            % newcatalog = catalog.SUBSET(range), where range evaluates to an integer array
            %    will retrieve the specified events.
            %    this option can be used to change the order of the catalog too
            
            newobj             = obj.blank();
            newobj.Name        = obj.Name;
            
            if isempty(range) || ~any(range)
                return
            end
            
            if islogical(range)
                cnt = obj.Count;
                if numel(range) == 1 && range && cnt > 1
                    range = true(cnt, 1);
                end
                if ~any(size(range) == cnt)
                    error('ZMAP:ZmapCatalog:subset:invalidDimension','When using logical indexing, one dimension must be the length of the catalog')
                end
            elseif ~isvector(range)
                error('ZMAP:ZmapCatalog:subset:tooManySubsets','multiple concurrent subsets not supported')
            end
            
            the_fields = obj.fields_that_must_be_nevent_length();
            for n = 1 : numel(the_fields)
                fn = the_fields{n};
                newobj.(fn) = obj.(fn)(range, :); % always copy rows
            end
            
            the_fields = obj.possibly_empty_fields();
            for n = 1 : numel(the_fields)
                fn = the_fields{n};
                if ~isempty(obj.(fn))
                    newobj.(fn) = obj.(fn)(range, :); % always copy rows
                end
            end
            for n = 1 : numel(obj.OtherFields)
                newobj.OtherFields{n} = obj.OtherFields{n}.subset(range);
            end
        end
        
        function subsetInPlace(obj, range)
            % SUBSET_IN_PLACE modifies this object, not a copy of it.
            the_fields = obj.fields_that_must_be_nevent_length();
            for n = 1 : numel(the_fields)
                fn = the_fields{n};
                obj.(fn) = obj.(fn)(range, :); % always copy rows
            end
            
            the_fields = obj.possibly_empty_fields();
            for n = 1 : numel(the_fields)
                fn = the_fields{n};
                if ~isempty(obj.(fn))
                    obj.(fn) = obj.(fn)(range, :); % always copy rows
                end
            end
            for n = 1 : numel(obj.OtherFields)
                obj.OtherFields{n}.subsetInPlace(range);
            end
        end
        
        function s = summary(obj, verbosity)
            % SUMMARY return a summary of this catalog
            % valid verbosity values: 'simple', 'stats'
            
            tFmt = 'uuuu-MM-dd HH:mm:ss';
            
            % add additional ways to look at catalog if it makes sense
            if ~exist('verbosity', 'var')
                verbosity = '';
            end
            if numel(obj) > 1
                s = sprintf('%d Catalogs', numel(obj));
                return
            end
            
            if isempty(obj) || obj.Count==0
                s = sprintf('Empty Catalog, named "%s"', obj.Name);
                return
            end
            leq = char(8804); %pretty version of <= , because a typed representation doesn't work across all platforms.
            depUn = shortenLengthUnit(obj.LengthUnit);
            
            switch verbosity
                case 'simple'
                    trange = bounds2(obj.Date);
                    mrange = bounds2(obj.Magnitude);
                    drange = bounds2(obj.Z);
                    mtypes  = cat2mtypestring();
                    fmtstr  = [...
                        'Catalog "%s" with %d events\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        obj.ZLabel, ':     %4.2f ', depUn, ' ', leq, ' Z ', leq, ' %4.2f', depUn, '\n',...
                        'Magnitudes: %2.1f ', leq, ' M ', leq, ' %2.1f\n',...
                        'MagnitudeTypes: %s'];
                    s = sprintf(fmtstr, obj.Name, obj.Count, string(trange(:), tFmt), drange, mrange, mtypes);
                case 'stats'
                    trange = bounds2(obj.Date);
                    mrange = bounds2(obj.Magnitude);
                    drange = bounds2(obj.Z);
                    
                    fmtstr = [...
                        'Catalog "%s"\nNumber of events: %d\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        '  %s\n',...
                        obj.ZLabel, ':     %4.2f ', depUn, ' ', leq, ' Z ', leq, ' %4.2f ', depUn, '\n',...
                        '  %s\n',...
                        'Magnitudes: %2.1f ', leq, ' M ', leq, ' %2.1f\n',...
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
                    meanstdmedian = @(x) [mean(x), std(x) median(x)];
                    s = sprintf(fmtstr, obj.Name, obj.Count, ...
                        string(trange, tFmt),...
                        sprintf('intervals: mean: %s ±std %s , median: %s', mean_int, std_int, median_int),...
                        drange, sprintf('mean: %.3f ±std %.3f , median: %.3f', meanstdmedian(obj.Z)),...
                        mrange, sprintf('mean: %.2f ±std %.2f , median: %.2f', meanstdmedian(obj.Magnitude)),...
                        cat2mtypestring());
                case 'list'
                    fprintf('Catalog "%s" with %d events\n', obj.Name, obj.Count);
                    fprintf('Date                      %3s       %3s   %3s(%s)    Mag  MagType\n', obj.YLabel, obj.XLabel, obj.ZLabel, depUn);
                    for n=1:obj.Count
                        fmtstr  = '%s  %8.4f  %9.4f   %6.2f   %4.1f   %s\n';
                        mt      = obj.MagnitudeType(n);
                        fprintf( fmtstr, string(obj.Date(n), tFmt),...
                            obj.Y(n), obj.X(n), obj.Z(n), obj.Magnitude(n), mt);
                    end
                otherwise
                    s = sprintf('Catalog "%s", containing %d events', obj.Name, obj.Count);
            end
            function mtypes = cat2mtypestring()
                % CAT2MTYPESTRING returns a string representation of the catalog type
                % mtypes = CAT2MTYPESTRING()
                mtypes = strjoin(categories(unique(obj.MagnitudeType)), ', ');
                if isempty(mtypes)
                    mtypes = '-none-';
                end
            end
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
            st       = rmfield(st, flds(todelete));
            tbl      = struct2table(st);
            tbl.Properties.Description = obj.Name;
        end
        
        
        function validate(obj)
            % check validity of the catalog
            data_len_fn = @(x)size(obj.(x), 1);
            flds =  obj.fields_that_must_be_nevent_length();
            data_lengths = unique(cellfun(data_len_fn, flds));
            if numel(unique(data_lengths)) ~= 1
                error( 'ZMAP:ZmapCatalog:validate:inconsistentFieldLengths', 'not all data fields are same length: %s', mat2str(data_lengths));
            end
            expected_len = data_lengths(1);
            data_len_fn = @(x) isempty(obj.(x)) || numel(obj.(x)) == expected_len; % returns TF vector
            
            flds = obj.possibly_empty_fields();
            data_len_ok = cellfun(data_len_fn, flds );
            if ~all(data_lengths_ok)
                error('ZMAP:ZmapCatalog:validate:incorrectFieldLengths','incorrect field lengths for: %s', strjoin(flds(~data_len_ok), ','));
            end
        end
    end
    
    methods(Hidden)
        % helper methods
        function [dists, units] = cartesianEpicentralDistanceTo(obj, x, y)
            % get distance from all events to a point (assuming Z is same for all)
            dists = sqrt(sum((obj.XYZ(:, 1:2) - [x, y]).^ 2));
            units = obj.HorizontalUnit;
        end
        
        function [dists, units] = cartesianHypocentralDistanceTo(obj, x, y, z)
            % get 3D distance from all events to a point
            %
            % [dists, units] = obj.hypocentralDistanceTo(x, y, z)
            % [dists, units] = obj.hypocentralDistanceTo([x, y, z])
            if nargin == 2 && ( isequal(size(x), [1 3]) || isequal(size(x), size(obj.XYZ)) )
                dists = sqrt(sum((obj.XYZ - x) .^2));
            else
                dists = sqrt(sum((obj.XYZ - [x, y, z]) .^2));
            end
            units = obj.HorizontalUnit;
        end
        
        function [dists, units] = geodeticEpicentralDistanceTo(obj, to_lat, to_lon)
            % get epicentral (lat-lon) distance to another point
            % [dists, units] = catalog.EPICENTRALDISTANCETO(to_lat, to_lon) returns the distance in the same
            % units as the catalog's RefEllipsoid.
            dists    = distance(obj.Latitude, obj.Longitude, to_lat, to_lon, obj.RefEllipsoid);
            units = obj.RefEllipsoid.LengthUnit;
        end
        
        function [dists, units] = geodeticHypocentralDistanceTo(obj, to_lat, to_lon, to_depth_km)
            % get hypocentral distance (3-D distance) to another point
            % [dists_km, units] = catalog.HYPOCENTRALDISTANCETO(to_lat, to_lon, to_depth_km)
            if obj.RefEllipsoid.LengthUnit == "kilometer"
            dists     = distance(obj.Latitude, obj.Longitude, to_lat, to_lon, obj.RefEllipsoid);
            delta_dep = (obj.Depth - to_depth_km);
            dists     = sqrt( dists .^ 2 + delta_dep .^ 2);
            units     = obj.RefEllipsoid.LengthUnit;
            else
                error('ZMAP:ZmapCatalog:incompatibleLengthUnit','For geodetic hypocentral distance, the ref ellipsoid must be kilometer, not %s',...
                    obj.RefEllipsoid.LengthUnit);
            end
        end
    end
    
    methods(Static)
        function obj = blank()  % To be implemented by every ZmapCatalog subclass
            % return a blank catalog
            obj = ZmapCatalog();
        end
        
        function obj = from(other)
            % create a zmap catalog from something else.
            % if it is another zmap catalog, then it is copied
            if isnumeric(other)
                obj = ZmapCatalog.fromZmapArray(other);
            elseif istable(other)
                obj = ZmapCatalog.fromTable(other);
            elseif isstruct(other)
                obj = ZmapCatalog.fromStruct(other);
            elseif isa(other, 'ZmapCatalog')
                obj = copy(other);
            else
                error('ZMAP:ZmapCatalog:unableToConvertfrom',...
                    'There is no known method to create a ZmapCatalog from a %s', class(other))
            end
        end
        
        function obj = fromTable(other)
            % catalog = ZMAPCATALOG(table) create a catalog from a table
            if ~istable(other)
                error('ZMAP:ZmapCatalog:unableToConvertFrom',...
                      'attempted to create a ZmapCatalog from a table, but was instead provided a %s',class(other));
            end                          % ZMAPCATALOG(table)
            
            other = table2zmapcatalogtable(other);
            obj=ZmapCatalog();
            vn = other.Properties.VariableNames;
            for i = 1:numel(vn)
                fieldname = vn{i};
                try
                    obj.(fieldname) = other.(fieldname);
                catch ME
                    fprintf('Error interpreting field: %s\n', fieldname);
                    warning(ME.message);
                end
            end
            
            if ~any(vn == "MagnitudeType") || isempty(obj.MagnitudeType)
                obj.MagnitudeType = repmat(categorical({''}), size(obj.Magnitude));
            end
            if ~any(vn == "EventID") || isempty(obj.EventID)
                obj.EventID = generate_event_ids(obj.Date);
            end
            
            obj.Name    = other.Properties.Description;
            pu          = other.Properties.VariableUnits;
            
            % automatically convert depth units
            if ~isempty(pu)
                depthIdx = vn == "Depth";
                if any(depthIdx)
                    units       = validateLengthUnit(pu{depthIdx});
                    obj.Depth   = unitsratio(obj.LengthUnit, units) * obj.Depth;
                end
            end
        end
        
        function obj = fromZmapArray(other, refEllipse)
            % catalog = ZMAPCATALOG(zmaparray) create a catalog from a ZmapArray with columns:
            %   [longitude, latitude, decyear, month, day, magnitude, depth_km, hour, minute, second]
            
            
            nCols = size(other, 2);
            
            validArray = isnumeric(other) && nCols >= 9 ...
                && all(abs(other(:,1)) <= 180)  ... check longitude
                && all(abs(other(:,2)) <= 90) ... check latitude
                && all(other(:,4) > 0) && all(other(:,4) <= 12) ... check month
                && all(other(:,8) >= 0) && all(other(:,8) <= 24) ... check hour
                && all(other(:,9) >= 0) && all(other(:,9) <= 60); % check minute
            
            if validArray && nCols == 10
                validArray = all(other(:, 10) >= 0) && all(other(:, 10) <= 60); % check seconds
            end
            
            if ~validArray 
                error('ZMAP:ZmapCatalog:unableToConvertFrom', ['(older) Zmap Arrays are Expected to be 9 or 10 column numeric matrix, containing:\n',...
              '[ lon lat decyr month day mag dep hr min [sec] ]']')
            end
            
            if ~any(other(:,3) > 100) && all(other(:,3)>=0)
                error('ZMAP:ZmapCatalog:ambiguousDates', ['The catalog dates appear to have 2-digits years.',...
                ' Change to 4-digit years before importing']);
            end
            
            % import Catalog from Array
            if nCols == 12
                mta = MomentTensorAddon();
                mta.Dip = other(:, 10);
                mta.DipDirection = other(:, 11);
                mta.Rake = other(:, 12);
                nCols = 9;
                % instead of seconds, it is dip, dip direction, and rake.
            end
            msg.dbfprintf(['importing from old catalog array with %d columns and %d events:\n'...
                '[ lon lat decyr month day mag dep hr min sec ]\n'], nCols, size(other, 1));
            
            if ~exist('refEllipse', 'var')
                refEllipse = referenceEllipsoid('earth', 'kilometer');
            end
            if iscartesian(ZmapCatalog.DefaultRefEllipsoid()),...
                error('ZMAP:ZmapCatalog:incompatibleRefEllipsoid',...
                'ZMAP arrays are in Lat-Lon, and is incompatible with this ZMAP session, which is in cartesian mode');
            end   
            obj = ZmapCatalog();
            other(:, 7) = other(:, 7) .* unitsratio(obj.LengthUnit, refEllipse.LengthUnit);
            obj.XYZ = other(:, [1, 2, 7]);
            if nCols==9 % no column for SECONDS
                other(:, 10)=0;
            end
            obj.Date = datetime([floor(other(:, 3)), other(:, [4, 5, 8, 9, 10])]);
            
            obj.Magnitude       = other(:, 6);
            obj.MagnitudeType   = repmat(categorical(missing), size(obj.Magnitude));
            
            obj.EventID = generate_event_ids(obj.Date);
            if exist('mta', 'var')
                obj.OtherFields{1}=mta;
            end
        end
        
        function obj = fromStruct(other)
            % requires exact names: [Longitude, Latitude, (or XYZ)], Magnitude, Depth, Date, MagnitudeType, Name[, Filter]
            obj=ZmapCatalog();
            if isfield(other, 'Name'), obj.Name = other.Name;end
            if isfield(other, 'Date')
                if ~isdatetime(other.Date)
                    error('ZMAP:ZmapCatalog:unableToConvertFrom',...
                        'Incoming dates must have datetime values, not %s',class(other.Date))
                end
                obj.Date = other.Date(:);
            end
            if isfield(other, 'XYZ')
                obj.XYZ = other.XYZ;
            elseif isfield(other, 'Latitude')
                obj.XYZ=[other.Longitude(:), other.Latitude(:), other.Depth(:)];
            elseif isfield(other, 'X')
                obj.XYZ=[other.X(:), other.Y(:), other.Z(:)];
            else
                error('ZMAP:ZmapCatalog:unableToConvertFrom',...
                    ['unable to determine XYZ or Latitude/Longitude/Depth. Please make sure the',...
                    ' field names are exact. ''XYZ'' or ''Latitude'',''Longitude'', and ''Depth'''])
            end
            
            if isfield(other,'EventID')
                obj.EventID = other.EventID;
            else
                if ~isempty(obj.Date)
                    obj.EventID = generate_event_ids(obj.Date);
                else
                    obj.EventID = generate_event_ids(1:size(obj.XYZ,1));
                end
            end
            if isfield(other, 'Magnitude')
                obj.Magnitude = other.Magnitude(:);
            end
            if isfield(other, 'MagnitudeType')
                obj.MagnitudeType = other.MagnitudeType(:);
            end
        end
        
    end
    methods(Static, Hidden)
        
        function val = GetFieldnamesForColorby()
            if iscartesian(ZmapGlobal.Data.ref_ellipsoid)
                val = {'Z', 'Date', 'Magnitude', '-none-'};
            else
                val = {'Depth', 'Date', 'Magnitude', '-none-'};
            end
        end
        
        function s = display_order()  % To be implemented by every ZmapCatalog subclass
            % get fields to display, in order.
            
            if iscartesian(ZmapCatalog.DefaultRefEllipsoid())
                    s = {'Name', 'Type', 'Date', 'DateSpan',...
                        'X', 'Y', 'Z', 'LengthUnit',...
                        'Magnitude', 'MagnitudeType',...
                        'IsSortedBy', 'SortDirection' ...
                        };
            else
                    % get fields to display, in order.
                    s = {'Name', 'Type', 'Date', 'DateSpan',...
                        'RefEllipsoid',...
                        'Longitude', 'Latitude', 'Depth', 'LengthUnit',...
                        'Magnitude', 'MagnitudeType',...
                        'IsSortedBy', 'SortDirection', ...
                        };
            end
        end
        
        function mbnel = fields_that_must_be_nevent_length()  % To be implemented by every ZmapCatalog subclass
            mbnel = {'Date', 'Magnitude', 'XYZ','EventID'};
        end
        
        function pef = possibly_empty_fields()  % To be implemented by every ZmapCatalog subclass
            % fields that may either match the # of events, or be empty
            pef = {'MagnitudeType', 'Filter'};
        end
        

    end
end


function EventIDs = generate_event_ids(values_to_sort_by, prefix)
    if ~exist('prefix','var')
        prefix = 'zmapunk.';
    end
    [~, orig_idx] = sort(values_to_sort_by);
    fmtstr="n%0" + ceil(log10(numel(orig_idx))+1) + "d";
    EventIDs = strcat(string(prefix), arrayfun(@(n)sprintf(fmtstr,n),orig_idx));
end
