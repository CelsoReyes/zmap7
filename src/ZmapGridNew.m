classdef ZmapGridNew
    % ZMAPGRID evenly-spaced X,Y grid with ability to be masked
    %
    % ZMAPGRID
    %    obj = create_km_spacing(name, dx_km, dy_km, dz_km) keeps grid constant in distance.
    %
    %    obj=create_deg_spacing(name, dlat, dlon, dz_km) follows lat/lon parallels/meridians
    
    properties
        Name (1,:) char % name of this grid
        XYUnits (1,:) char % 'degrees' or 'kilometers'
        DX double
        DY double
        DZ double
    end
    
    properties(Constant,Hidden)
        POSSIBLY_TOO_MANY_POINTS = 1000 * 1000;
    end
    
    methods
        function obj=ZmapGridNew(name, dx, dy, dz, xyunits)
            assert(ismember(lower(xyunits),{'degrees','kilometers'}));
            obj.Name=name;
            obj.XYUnits=lower(xyunits);
            obj.DX=dx;
            obj.DY=dy;
            obj.DZ=dz;
        end
        
        function XYZ = get_km_grid(obj, origin_latlon, origin_km,  z0, xlims_km, ylims_km, zlims, myshape)
            %
            % point at Lat/Lon coordinates (lat0,lon0) maps to km coordinates (x0 y0)
            
            lat0 = origin_latlon(1);
            lon0 = origin_latlon(2);
            
            x0_km = origin_km(1);
            y0_km = origin_km(2);
            
            switch obj.XYUnits
                case 'degrees'
                    dLon = obj.DX ;
                    dLat = obj.DY;
                    
                    
                    % units are stored in degrees, so convert to kilometers before returning grid.
                    % for a map with km edges, lines will appear to converge toward the poles
                    
                    dy_km = deg2km(dLat); % always constant
                    yvector_deg = ZmapGridNew.getrange(lat0, dLat, ylims_km);
                    % yvector_km remains constant
                    yvector_km = deg2km(yvector_deg);
                    
                    [~,dxs_eachlat]=reckon('rh',yvector_deg,0,dLon,90);
                    
                    dxs_eachlat = deg2km(dxs_eachlat); %E-W distance for dLon at each Latitude
                    gridx=[];gridy=[];
                    for n=1:numel(yvector_km)
                        x_km = ZmapGridNew.getrange(x0_km, dxs_eachlat(n), xlims_km);
                        gridx=[gridx;x_km(:)];
                        gridy=[gridy;repmat(yvector_km(n),size(x_km(:)))];
                    end
                    XYZ=[gridx,gridy];
                    
                case 'kilometers'
                    % units are already in kilometers. For a map with km parallels, these lines will
                    % appear to remain parallel.
                    ytk = ZmapGridNew.getrange(y0_km, obj.DY, ylims_km);
                    xtk = ZmapGridNew.getrange(x0_km, obj.DX, xlims_km);
                    
                    %if exist('zlims','var') && ~isempty(zlims)
                    %    ztk = ZmapGridNew.getrange(z0, obj.DZ, zlims);
                    %    [x, y, z]=meshgrid(xtk,ytk,ztk);
                    %    XYZ=[x(:),y(:),z(:)];
                    %else
                    [x, y]=meshgrid(xtk,ytk);
                    XYZ=[x(:),y(:)];
                    %end
                    
                    
                otherwise
                    error('unspecified units');
            end
            if exist('myshape','var') && ~isempty(myshape)
                switch myshape.Units
                    case 'kilometers'
                        ll = myshape.isInside(XYZ(:,2),XYZ(:,1));
                        XYZ=XYZ(ll,:);
                    case 'degrees'
                        unimplemented_error()
                end
            end
            
            if ~isempty(obj.DZ) && exist('zlims','var') && ~isempty(zlims)
                if isempty(z0), z0=0; end
                zs = ZmapGridNew.getrange(z0, obj.DZ, zlims);
                n=size(XYZ,1);
                XYZ(:,3)=zs(1);
                XYZ=repmat(XYZ,numel(zs),1);
                for m=2:n
                    XYZ(m*n+1:((m+1)*n),3)=zs(m);
                end
            end
        end
        
        function LatLonDepth = get_deg_grid(obj, origin_latlon, z0, latlims, lonlims, zlims, myshape)
            % LatLonDepth = obj.grid_deg(origin_latlon, latlims, lonlims, zlims, myshape)
            %
            
            
            lat0 = origin_latlon(1);
            lon0 = origin_latlon(2);
            
            switch obj.XYUnits
                case 'degrees'
                    %since degrees are constant, longitudes get closer toward poles
                    % this will appear constant on a lat/lon (mercator-style) map
                    
                    dLon = obj.DX ;
                    dLat = obj.DY;
                    
                    las = ZmapGridNew.getrange(lat0, dLat, latlims);
                    los = ZmapGridNew.getrange(lon0, dLon, lonlims);
                    
                    % if exist('zlims','var') && ~isempty(zlims)
                    %     deps = unique([z0 : -obj.dz : zlims(1) , z0: obj.dz : zlims(2)]);
                    %     [lam, lom, depm]=meshgrid(las,los,deps);
                    %     LatLonDepth=[lam(:),lom(:),depm(:)];
                    %sz=[numel(las), numel(los), numel(deps)];
                    %else
                    [lam, lom]=meshgrid(las,los);
                    LatLonDepth=[lam(:),lom(:)];
                    %sz=[numel(las), numel(los)];
                    %end
                    
                case 'kilometers'
                    % units are specified in kilometers. convert to degrees before returning grid.
                    % since this is stored as a constant distances, they will appear to diverge
                    % as one approaches the poles on a lat/lon (mercator-style) map.
                    
                    % delta degrees of latitude
                    dLat=km2deg(obj.DY);
                    
                    % range of latitudes
                    las = ZmapGridNew.getrange(lat0, dLat, latlims);
                    
                    % arc distance of our DX
                    x_arclen = km2deg(obj.DX);
                    
                    
                    % how many rhomb degrees is this distance at each latitude?
                    [~,lon_rh_arclens] = reckon('rh',las, 0, x_arclen, 90);
                    
                    
                    gridlat=[];gridlon=[];
                    
                    for n=1:numel(lon_rh_arclens)
                        lons_at_lat = ZmapGridNew.getrange(lon0, lon_rh_arclens(n), lonlims);
                        gridlat=[gridlat;repmat(las(n),size(lons_at_lat(:)))];
                        gridlon = [gridlon;lons_at_lat(:)];
                    end
                    
                    LatLonDepth=[gridlat(:),gridlon(:)];
                    
                otherwise
                    error('unspecified units');
            end
            
            
            if exist('myshape','var') && ~isempty(myshape)
                switch myshape.Units
                    case 'degrees'
                        ll = myshape.isInside(LatLonDepth(:,2),LatLonDepth(:,1));
                        LatLonDepth=LatLonDepth(ll,:);
                    case 'kilometers'
                        unimplemented_error()
                end
            end
            
            if ~isempty(obj.DZ) && exist('zlims','var') && ~isempty(zlims)
                if isempty(z0), z0=0; end
                zs = ZmapGridNew.getrange(z0, obj.DZ, zlims);
                n=size(LatLonDepth,1);
                LatLonDepth(:,3)=zs(1);
                LatLonDepth=repmat(LatLonDepth,numel(zs),1);
                for m=2:n
                    LatLonDepth(m*n+1:((m+1)*n),3)=zs(m);
                end
            end
            
        end
    end
    
    methods(Static)
        
        
        function obj = create_km_spacing(name, dx_km, dy_km, dz_km)
            % CREATE_KM_SPACING creates a grid, given dx, dy, and dz (all in km)
            % obj = CREATE_KM_SPACING(name, dx_km, dy_km, dz_km)
            obj=ZmapGrid(name, dx_km, dy_km, dz_km,'kilometers');
        end
        
        function obj=create_deg_spacing(name, dlat, dlon, dz_km)
            % CREATE_DEG_SPACING creates a grid, given deltaLat, deltaLon, and dz
            %
            % obj = CREATE_DEG_SPACING(name, dlat, dlon, dz_km)
            obj=ZmapGrid(name, dlat, dlon, dz_km, 'degrees');
        end
    end
    
    methods(Static, Access=protected)
        function r = getrange(orig, delta, lims)
            % GETRANGE return a range within LIMS with a given DELTA that contains the point ORIG
            %  r = ZMAPGRIDNEW.GETRANGE(orig, delta, lims)
            r = unique([orig : -delta : min(lims) , orig : delta : max(lims)]);
        end
    end
end