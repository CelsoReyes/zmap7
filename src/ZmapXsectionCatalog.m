classdef ZmapXsectionCatalog < ZmapCatalog
    % ZMAPXSECTIONCATALOG a catalog specifically along a cross section
    % meaning, all events are on a great-circle line
    %
    
    properties
        Curve              = [nan,nan] % points along the curve [y,x]
        DistAlongStrike    double  % distance for each event from startPoint in units
        Displacement       double  % perpendicular distance of each event from the line in units
        CurveLength        = 0; % length of this cross-section
        ProjectedPoints    double = []
        Width              double 
    end
    
    properties(Dependent)
        startPoint % as y,x
        endPoint   % as y,x
        ProjectedX
        ProjectedY
        ProjectedZ
    end
    
    
    methods
        function obj = ZmapXsectionCatalog(catalog, p1yx, p2yx, width)
            %ZMAPXSECTIONCATALOG
            % obj = ZMAPXSECTIONCATALOG(catalog, endpoint1, endpoint2, swath_width)
            % endpoint1 and endpoint2 are each (lat, lon)
            %
            % see also project_on_gcpath
            obj.Width = width;
            
            if iscartesian(catalog.RefEllipsoid)
                % deal with cartesian coordinates
                obj.Curve = [p1yx; p2yx];
                obj.CurveLength = sqrt(sum((p1yx-p2yx).^2));
                p1 = [p1yx(2), p1yx(1)]; % flip from lat-lon to x-y
                p2 = [p2yx(2), p2yx(1)]; % flip from lat-lon to x-y
                [obj.ProjectedPoints, ...
                    obj.DistAlongStrike, ...
                    obj.Displacement] = projection(p1, p2, catalog.XYZ(:,[1,2]) );
                obj.ProjectedPoints(:,3) = catalog.Z;
                mask = obj.DistAlongStrike>=0 & obj.DistAlongStrike<obj.CurveLength &...
                    obj.Displacement<=obj.Width;
                obj = obj.copyFrom(catalog.subset(mask)); % necessary, otherwise this turns into a ZmapCatalog
                
            else
                
                % deal with geodetic coordinates
                CurveLength = distance(p1yx,p2yx,catalog.RefEllipsoid);
                nlegs    = ceil(CurveLength / width) .*2;
                [curvelats,curvelons] = gcwaypts(p1yx(1), p1yx(2), p2yx(1), p2yx(2), nlegs);
                curveInKm = CurveLength.*unitsratio('kilometer',catalog.RefEllipsoid.LengthUnit);
                scale = min(.1, curveInKm / 10000); %usded to determine how path is sampled
                [mindist,mask,gcDist] = project_on_gcpath(p1yx,p2yx, catalog, width/2, scale);
                obj = obj.copyFrom(catalog.subset(mask)); % necessary, otherwise this turns into a ZmapCatalog
                obj.Curve = [curvelats, curvelons];
                obj.DistAlongStrike = gcDist;
                obj.Displacement    = mindist;
                obj.CurveLength     = CurveLength;
            end
            

        end
        function updateFromCatalog(obj, catalog)
            if iscartesian(catalog.RefEllipsoid)
                % deal with cartesian coordinates
                p1 = obj.startPoint([2,1]); % flip from lat-lon to x-y
                p2 = obj.endpoint([2,1]); % flip from lat-lon to x-y
                [obj.ProjectedPoints, ...
                    obj.DistAlongStrike, ...
                    obj.Displacement] = obj.projection(p1, p2, catalog.XYZ(:,[1,2]) );
                obj.ProjectedPoints(:,3) = catalog.Z;
                mask = obj.DistAlongStrike>=0 & obj.DistAlongStrike<obj.CurveLength &...
                    obj.Displacement<=obj.Width;
                obj = obj.copyFrom(catalog.subset(mask)); % necessary, otherwise this turns into a ZmapCatalog
                
            else                
                % deal with geodetic coordinates
                curveInKm = obj.CurveLength.*unitsratio('kilometer',catalog.RefEllipsoid.LengthUnit);
                scale = min(.1, curveInKm / 10000); %used to determine how path is sampled
                [mindist,mask,gcDist] = project_on_gcpath(obj.startPoint,obj.endPoint, catalog, obj.Width/2, scale);
                obj = obj.copyFrom(catalog.subset(mask)); % necessary, otherwise this turns into a ZmapCatalog
                obj.DistAlongStrike = gcDist;
                obj.Displacement    = mindist;
            end
        end
                
        function p=get.startPoint(obj)
            p=obj.Curve(1,:);
        end
        function p=get.endPoint(obj)
            p=obj.Curve(end,:);
        end
        
        function me = copyFrom(me, other)
            C = metaclass(other);
            P = [C.Properties{:}];
            P([P.Dependent])=[];
            for k = 1:length(P)
                try
                    me.(P(k).Name) = other.(P(k).Name);
                catch ME
                    if ME.identifier~="MATLAB:class:SetProhibited"
                        rethrow(ME)
                    end
                end
            end
        end     
            
        
        function disp(obj)
            fprintf('cross-section catalog with %d events\n',obj.Count);
            sp = obj.startPoint;
            ep = obj.endPoint;
            fprintf('From (%g,%g) to (%g,%g) [%g km]\n',...
                sp(1),sp(2), ep(1),ep(2), obj.CurveLength);
        end
        
        function s=info(obj)
            s = sprintf('cross-section catalog with %d events\n', obj.Count);
            sp = obj.startPoint; 
            ep = obj.endPoint;
            s = [s,sprintf('From (%g,%g) to (%g,%g) [%g km]\n',...
                sp(1), sp(2), ep(1),ep(2), obj.CurveLength)];
        end
        function subsetInPlace(obj, range)
            subsetInPlace@ZmapCatalog(obj, range)
        end
                
        function obj = subset(existobj, range)
            obj = copy(existobj);
            obj.subsetInPlace(range);
        end
        
        function obj = cat(objA, ObjB)
            % cannot currently concatenate two of these
            unimplemented_error()
        end
        
        function obj = blank(~)
            obj = ZmapXsectionCatalog(blank@ZmapCatalog);
        end
        
        function [minicat, max_km] = selectPerpendicularCylander(obj, esp, offset, depth)
            
            if ~(esp.UseEventsInRadius || esp.UseNumClosestEvents)
                error('Error: No selection criteria was chosen. Results would be one value (based on entire catalog) repeated');
            end
            [dists, distunits] = obj.inPlaneDistanceTo(offset, depth);
            mask = esp.SelectionFromDistances(dists, distunits);
            minicat = obj.subset(mask);
            max_km = max(dists(mask));
        end
        
        function [dists, units] = inPlaneDistanceTo(obj, strikeOffset, depth)
            % get distance from all events to a point along x-section, ignoring displacement
            dists = sqrt(sum(([obj.DistAlongStrike, obj.Z] - [strikeOffset, depth]).^ 2));
            units = obj.HorizontalUnit;
        end
        
        function [dists, units] = planarHypocentralDistanceTo(obj, strikeOffset, depth)
            % get distance from all events to a point along x-section, taking displacement into account
            dists = sqrt(sum(([obj.DistAlongStrike, obj.Z, obj.Displacement] - [strikeOffset, depth, 0]).^ 2));
            units = obj.HorizontalUnit;
        end
        
    end
    
    methods(Static)
        function [lon, lat, h] = create_endpoints(ax,C)
            % create_endpoints returns lat, lon where each is [start,end] along with handle used to pick endpoints
            
            disp('click on start and end points for cross section');
            
            % pick first point
            [lon, lat] = ginput(1);
            set(gca, 'NextPlot', 'add');
            h = scatter(ax, lon, lat, 'Marker', 'x', 'LineWidth', 2, 'MarkerSize', 5, 'Color', C);
            
            % pick second point
            [lon(2), lat(2)] = ginput(1);
            h.XData = lon;
            h.YData = lat;
        end
    
        
            
        function [newQuake, DistAlongPlane, perp_dist] = projection(startPt, endPt, quake)
            V1 = endPt - startPt; % vector to project upon
            V2 = quake - startPt; % vector to project
            dfun = @(vec1, vec2)sqrt(sum((vec1-vec2).^2,2)); %nx2 vectors
            AngleToPlane  = angle(V1(:,1) + 1i*(V1(:,2)));
            AngleToQuake  = angle(V2(:,1) + 1i*(V2(:,2)));
            orientedAngle = wrapToPi(AngleToQuake - AngleToPlane);
            DistAlongPlane = cos(orientedAngle) .* dfun(V2,[0,0]);
            NewOffset =  [cos(AngleToPlane), sin(AngleToPlane)] .* DistAlongPlane;
            newQuake = NewOffset + startPt;
            perp_dist = sqrt(sum((quake-newQuake).^2,2));
        end

    end
end
