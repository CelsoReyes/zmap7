classdef ZmapBaseCatalog < matlab.mixin.Copyable
    properties
        Date            datetime                        % date and time of event (capable of storing data to microseconds)
        Magnitude       double                          % Magnitude of each event
        MagnitudeType   categorical                     % Magnitude units, such as M, ML, MW, etc.
    end
    
    properties(SetObservable, AbortSet)
        Name            (1,:) char      = ''        % name of this catalog
        IsSortedBy      char            = ''        % describes sort order
        SortDirection   char            = ''        % describes sorting direction
        Filter          logical                     % logical filter for subsetting events
    end
    
    properties(Hidden)
        XYZ             (:,3) double
        PositionUnits   char        = 'meter'
    end
    
    properties(Dependent)
        DecimalYear % read-only
        DayOfYear % read-only
        Count       % read-only number of events in catalog
        DateSpan    % read-only duration
    end
    
    methods(Abstract)
        obj = blank(~)
    end
    
    methods
        
        function val = get.Count(obj)
            if numel(obj) == 0
                val = 0;
            else
                val = size(obj.XYZ,1);
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
        
        function TF = isempty(obj)
            % ISEMPTY is true when there are no events in the catalog
            % tf = ISEMPTY(catalog)
            TF = numel(obj)==0 || isempty(obj.XYZ);
        end
        
        %% IO funs
        %
        
        function s = blurb(obj)
            % BLURB get simple statement about catalog
            if numel(obj)>0 && obj.Count > 0
                s = sprintf('%s "%s" with %d events\n',class(obj), obj.Name,obj.Count);
            else
                s = sprintf('empty %s', class(obj));
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
        
        %% subsetting, set, and sorting functions
        %
        
        function subset_in_place(obj,range)
            obj.Date = obj.Date(range);
            obj.XYZ = obj.XYZ(range,:);
            obj.Magnitude       = obj.Magnitude(range) ;
            obj.MagnitudeType   = obj.MagnitudeType(range) ;
        end
        
        function newobj = subset(obj, range)
            newobj             = obj.blank();
            newobj.Name        = obj.Name;
            
            newobj.Date             = obj.Date(range);       % datetime
            newobj.XYZ              = obj.XYZ(range,:);
            newobj.Magnitude        = obj.Magnitude(range);
            newobj.MagnitudeType    = obj.MagnitudeType(range) ;
        end
        
        
        function clearFilter(obj)
            % CLEARFILTER sets all items in Filter to true
            % catalog.CLEARFILTER
            obj.Filter = true(size(obj.XYZ,1));
        end
        
        function obj = getCropped(existobj)
            % GETCROPPED get a new, cropped ZmapCatalog from this one
            
            if isempty(existobj.Filter)
                obj = existobj;
            else
                obj = existobj.subset(existobj.Filter);
            end
        end
        
        function obj = cat(objA, objB)
            % CAT combines two catalogs
            % combinedCatalog = cat(catalogA, catalogB)
            % duplicates are not removed
            initialCount = objA.Count + objB.Count;
            obj = copy(objA);
            obj.Date           = [objA.Date;           objB.Date];
            obj.XYZ            = [objA.XYZ;            objB.XYZ];
            obj.Magnitude      = [objA.Magnitude;      objB.Magnitude];
            obj.MagnitudeType  = [objA.MagnitudeType;  objB.MagnitudeType];
            obj.clearFilter();
            assert(obj.Count == initialCount);
        end
        
        function [C, IA] = setdiff(A, B)
            % returns values that are in A but not in B with no repetitions. NO tolerance.
            % based solely on Date, Longitude, Latitude, Depth, and Magnitude
            dateFmt='uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
            
            compstrA = string(A.Date,dateFmt)+join(string(A.XYZ))+" "+string(A.Magnitude);
            compstrB = string(B.Date,dateFmt)+join(string(B.XYZ))+" "+string(B.Magnitude);
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
            dateFmt='uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
            compstrA = string(A.Date,dateFmt)+join(string(A.XYZ))+" "+string(A.Magnitude);
            compstrB = string(B.Date,dateFmt)+join(string(B.XYZ))+" "+string(B.Magnitude);
            IA=ismember(compstrA,compstrB);
            if nargout==3
                IB=ismember(compstrB,compstrA);
            end
            C=A.subset(IA);
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
            %
            % see also sortedByDistanceTo
            
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
        
        function other = sortedByDistanceTo(obj, x, y, varargin)
            % SORTEDBYDISTANCE returns a catalog that has been sorted by distance to a point
            % ans=catalog.SORTEDBYDISTANCE(x, y) % epicentral sort
            % ans=catalog.SORTEDBYDISTANCE(x, y, z) % hypocentral sort
            %
            % does NOT modify original
            [~,idx]   = sort(obj.DistanceTo(x,y, varargin{:}));
            other     = obj.subset(idx);
            other.IsSortedBy    = 'distance';
            other.SortDirection = 'ascending';
        end
        
        %% spatial functions
        %
       
        function [dists, units] = hypocentralDistanceTo(obj, x, y, z)
            % [dists, units] = obj.hypocentralDistanceTo(x,y,z)
            % [dists, units] = obj.hypocentralDistanceTo([x,y,z])
            if nargin == 2 && ( isequal(size(x),[1 3]) || isequal(size(x),size(obj.XYZ)) )
                dists = sqrt(sum((obj.XYZ - x) .^2));
            else
                dists = sqrt(sum((obj.XYZ - [x,y,z]) .^2));
            end
            units = obj.PositionUnits;
        end
        
        function [dists, units] = epicentralDistanceTo(obj, x, y)
            dists = sqrt(sum((obj.XYZ(:,1:2) - [x,y]).^ 2));
            units = obj.PositionUnits;
        end
        
        
        function [dists, units] = DistanceTo(obj, x, y, z)
            % get distance to events in catalog from a point or set of points
            
            if ~exist('z','var')||isempty(z)
                [dists, units] = obj.epicentralDistanceTo(x,y);
            else
                [dists, units] = obj.hypocentralDistanceTo(x,y,z);
            end
        end
        
        function [other, max_km] = selectClosestEvents(obj, x, y, z, n)
            % SELECTCLOSESTEVENTS determine which N events are closest to a point (x,y, z).
            % [otherCat, max_km] = catalog.SELECTCLOSESTEVENTS(x,y, z, nEvents)
            % for epicentral distance, leave depth empty.
            %  ex.  selectClosestEvents(mycatalog, 82, -120, [], 20);
            % the distance to the nth closest event
            %
            % see also selectCircle, selectRadius
            
            [dists, distunits] = obj.DistanceTo(x, y, z);
            [sorted_dists,I]=sort(dists);
            n=min(n, obj.Count); %protect against indexing errors
            evIdx = I(1:n);
            other = obj.subset(evIdx);
            max_km = sorted_dists(n) .* unitsratio('kilometer', distunits);
            
        end
        
        function other = selectRadius(obj, x, y, z, radius, radius_units)
            %SELECTRADIUS  select subset catalog to a radius from a point
            % catalog = catalog.SELECTRADIUS(x , y, radius, radius_units) epicentral radius from a point. sortorder is preserved
            % catalog = catalog.SELECTRADIUS(x, y, z, radius, radius_units) hypocentral radius from a point. sortorder is preserved
            %
            % see also selectClosestEvents, selectCircle
            if isempty('z')
                [dists, distunits] = obj.DistanceTo(x,y);
            else
                [dists, distunits] = obj.DistanceTo(x,y,z);
            end
            
            mask = dists <= radius .* unitsratio(distunits, radius_units);
            other = obj.subset(mask);
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
            [dists, distunits] = obj.DistanceTo(y,x,z);
            
            mask = esp.SelectionFromDistances(dists, distunits);
            minicat = obj.subset(mask);
            max_km = max(dists(mask));
        end
        %% plotting functions
        %
        
        function h = scatter(obj, varargin)
            if ~isempty(varargin) && isa(varargin{1},'matlab.graphics.axis.Axes')
                ax = varargin{1};
            else
                ax = gca;
            end
            h = scatter(ax,obj.XYZ(:,1), obj.XYZ(:,2),varargin{:});
        end
        
        function h = scatter3(obj, varargin)
            if ~isempty(varargin) && isa(varargin{1},'matlab.graphics.axis.Axes')
                ax = varargin{1};
            else
                ax = gca;
            end
            h = scatter3(ax, obj.XYZ(:,1), obj.XYZ(:,2), obj.XYZ(:,3), varargin{:});
        end
        
        
        %% other functions
        %
        %
        %
        
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
end