classdef ZmapXsectionCatalog < ZmapCatalog
    % ZMAPXSECTIONCATALOG a catalog specifically along a cross section
    % meaning, all events are on a great-circle line
    %
    
    properties
        curve=[nan,nan] % points along the curve
        dist_along_strike_km=[]; % distance for each event from startPoint, in km
        displacement_km=[]; % perpendicular distance of each event from the line
        curvelength_km=0;
    end
    properties(Dependent)
        startPoint
        endPoint
    end
    
    methods
        function obj = ZmapXsectionCatalog(catalog, p1, p2, width_km)
            %ZMAPXSECTIONCATALOG
            % obj = ZMAPXSECTIONCATALOG(catalog, endpoint1, endpoint2, swath_width_km)
            % endpoint1 and endpoint2 are each (lat, lon)
            %
            % see also project_on_gcpath
            if nargin==0
                return
            end
            tdist_km = deg2km(distance(p1,p2));
            nlegs = ceil(tdist_km / width_km) .*2;
            [curvelats,curvelons]=gcwaypts(p1(1),p1(2),p2(1),p2(2),nlegs);
            scale = min(.1,tdist_km / 10000);
            [c2,mindist,~,gcDist_km]=project_on_gcpath(p1,p2, catalog, width_km/2, scale);
            obj=obj.copyFrom(c2); % necessary, otherwise this turns into a ZmapCatalog
            obj.curve=[curvelats, curvelons];
            obj.dist_along_strike_km=gcDist_km;
            obj.displacement_km=mindist;
            obj.curvelength_km=tdist_km;
        end
        
        function p=get.startPoint(obj)
            p=obj.curve(1,:);
        end
        function p=get.endPoint(obj)
            p=obj.curve(end,:);
        end
        function p=get.curvelength_km(obj)
            p=deg2km(distance(obj.startPoint,obj.endPoint));
        end
        
        function me = copyFrom(me, other)
            C = metaclass(other);
            P = [C.Properties{:}];
            P([P.Dependent])=[];
            for k = 1:length(P)
                    me.(P(k).Name) = other.(P(k).Name);
            end
        end     
            
        
        function disp(obj)
            fprintf('cross-section catalog with %d events\n',obj.Count);
            sp=obj.startPoint; ep=obj.endPoint;
            fprintf('From (%g,%g) to (%g,%g) [%g km]\n',...
                sp(1),sp(2), ep(1),ep(2), obj.curvelength_km);
        end

        function s=info(obj)
            s=sprintf('cross-section catalog with %d events\n',obj.Count);
            sp=obj.startPoint; ep=obj.endPoint;
            s=[s,sprintf('From (%g,%g) to (%g,%g) [%g km]\n',...
                sp(1),sp(2), ep(1),ep(2), obj.curvelength_km)];
        end
        
        function obj = subset(existobj, range)
            obj=subset@ZmapCatalog(existobj,range);
            
            obj.dist_along_strike_km = existobj.dist_along_strike_km(range);
            obj.displacement_km = existobj.displacement_km(range);
            obj.curvelength_km=existobj.curvelength_km;
            obj.curve = existobj.curve;
        end
        
        function obj = cat(objA, ObjB)
            % cannot currently concatinate two of these
            error('unimplemented for ZmapXsectionCatalog');
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
            hold on;
            h=scatter(ax,lon,lat,'Marker','x','LineWidth',2,'MarkerSize',5,'Color',C);
            
            % pick second point
            [lon(2), lat(2)] = ginput(1);
            h.XData=lon;
            h.YData=lat;
        end
    end
end
