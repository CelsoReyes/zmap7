classdef ZmapXsectionCatalog
    % ZMAPXSECTIONCATALOG a catalog specifically along a cross section
    % meaning, all events are on a great-circle line
    %
    
    properties
        Curve              = [nan,nan] % points along the curve [y,x]
        DistAlongStrike    double  % distance for each event from startPoint in units
        Displacement       double  % perpendicular distance of each event from the line in units
        CurveLength        = 0;
        ProjectedPoints    double = []
        Name
    end
    
    properties(SetAccess = immutable)
        Catalog     {mustBeZmapCatalog} = ZmapGlobal.Data.defaultCatalogConstructor() % points to an underlying zmap catalog
    end
    
    properties(Dependent)
        startPoint % as y,x
        endPoint   % as y,x
        X
        Y
        Z
        Magnitude
        MagnitudeType
        Date
        ProjectedX
        ProjectedY
        ProjectedZ
        Count
    end
    
    
    methods
        function obj = ZmapXsectionCatalog(catalog, p1yx, p2yx, width)
            %ZMAPXSECTIONCATALOG
            % obj = ZMAPXSECTIONCATALOG(catalog, endpoint1, endpoint2, swath_width)
            % endpoint1 and endpoint2 are each (lat, lon)
            %
            % see also project_on_gcpath
            class(catalog)
            if isa(catalog,'ZmapXsectionCatalog')
                obj.Catalog=catalog.Catalog;
            else
                obj.Catalog = catalog;
            end
            obj.Name=catalog.Name;
            switch ZmapGlobal.Data.CoordinateSystem
                case CoordinateSystems.geodetic
                    tdist = distance(p1yx,p2yx,catalog.RefEllipsoid);
                    nlegs    = ceil(tdist_km / width) .*2;
                    [curvelats,curvelons] = gcwaypts(p1yx(1),p1yx(2),p2yx(1),p2yx(2),nlegs);
                    scale = min(.1, tdist.*unitsratio('kilometer',catalog.RefEllipsoid.LengthUnit) / 10000);
                    [c2,mindist,~,gcDist] = project_on_gcpath(p1yx,p2yx, catalog, width/2, scale);
                    obj = obj.copyFrom(c2); % necessary, otherwise this turns into a ZmapCatalog
                    obj.Curve = [curvelats, curvelons];
                    obj.DistAlongStrike = gcDist;
                    obj.Displacement    = mindist;
                    obj.CurveLength     = tdist;
                case CoordinateSystems.cartesian
                    obj.Curve = [p1yx; p2yx];
                    obj.CurveLength = sqrt(sum((p1yx-p2yx).^2));
                    p1 = [p1yx(2), p1yx(1)];
                    p2 = [p2yx(2), p2yx(1)];
                    [obj.ProjectedPoints,obj.DistAlongStrike, obj.Displacement]=projection(p1, p2, [catalog.X, catalog.Y]);
                    obj.ProjectedPoints(:,3)=catalog.Z;
            end
            
            function [newQuake, DistAlongPlane, perp_dist]=projection(startPt, endPt, quake)
                V1 = endPt - startPt; % vector to project upon
                V2 = quake - startPt; % vector to project
                dfun=@(vec1, vec2)sqrt(sum((vec1-vec2).^2,2)); %nx2 vectors
                AngleToPlane   = angle(V1(:,1) + 1i*(V1(:,2)));
                AngleToQuake = angle(V2(:,1) + 1i*(V2(:,2)));
                orientedAngle = wrapToPi(AngleToQuake - AngleToPlane);
                DistAlongPlane = cos(orientedAngle) .* dfun(V2,[0,0]);
                NewOffset =  [cos(AngleToPlane),sin(AngleToPlane)] .* DistAlongPlane;
                newQuake = NewOffset + startPt;
                perp_dist = sqrt(sum((quake-newQuake).^2,2));
            end


        end
        function c = get.Count(obj)
            c = obj.Catalog.Count;
        end
        function x = get.X(obj)
            x = obj.Catalog.X;
        end
        function x = get.ProjectedX(obj)
            x = obj.ProjectedPoints(:,1);
        end
        
        function y = get.Y(obj)
            y = obj.Catalog.Y;
        end
        
        function y = get.ProjectedY(obj)
            y = obj.ProjectedPoints(:,2);
        end
        
        function z = get.Z(obj)
            z = obj.Catalog.Z;
        end
        function z = get.ProjectedZ(obj)
            z = obj.ProjectedPoitns(:,3);
        end
        
        function d = get.Date(obj)
            d = obj.Catalog.Date;
        end
        
        function m = get.Magnitude(obj)
            m = obj.Catalog.Magnitude;
        end
        
        function mt = get.MagnitudeType(obj)
            mt = obj.Catalog.MagnitudeType;
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
            sp=obj.startPoint; ep=obj.endPoint;
            fprintf('From (%g,%g) to (%g,%g) [%g km]\n',...
                sp(1),sp(2), ep(1),ep(2), obj.CurveLength);
        end

        function s=info(obj)
            s=sprintf('cross-section catalog with %d events\n',obj.Count);
            sp=obj.startPoint; ep=obj.endPoint;
            s=[s,sprintf('From (%g,%g) to (%g,%g) [%g km]\n',...
                sp(1),sp(2), ep(1),ep(2), obj.CurveLength)];
        end
        
        function obj = subset(existobj, range)
            obj=subset@ZmapCatalog(existobj,range);
            
            obj.DistAlongStrike = existobj.DistAlongStrike(range);
            obj.Displacement = existobj.Displacement(range);
            obj.CurveLength=existobj.CurveLength;
            obj.Curve = existobj.Curve;
        end
        
        function obj = cat(objA, ObjB)
            % cannot currently concatinate two of these
            unimplemented_error()
        end
        
        function obj=blank(obj2)
            % BLANK creates a cleared-out object of this class
            obj=ZmapXsectionCatalog();
        end
    end
    
    
    
    methods(Static)
        function [lon, lat,h] = create_endpoints(ax,C)
            % create_endpoints returns lat, lon where each is [start,end] along with handle used to pick endpoints
            
            disp('click on start and end points for cross section');
            
            % pick first point
            [lon, lat] = ginput(1);
            set(gca,'NextPlot','add');
            h=scatter(ax,lon,lat,'Marker','x','LineWidth',2,'MarkerSize',5,'Color',C);
            
            % pick second point
            [lon(2), lat(2)] = ginput(1);
            h.XData=lon;
            h.YData=lat;
        end
    end
end
