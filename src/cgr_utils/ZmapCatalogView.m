classdef ZmapCatalogView
    % ZMAPCATALOGVIEW provides a way to interact with one of the global catalogs without copying it
    % filters can be applied, and it can be plotted
    % if filters are changed, the plot automatically changes, too.
    % other than changing the filters and a few plotting properties, the view is read-only,
    % and depends entirely upon the global catalog upon which it is based
    %
    % obj=ZmapCatalogView(catname)
    % obj=ZmapCatalogView(catname,Name1,Property1,...), where vald property names can be seen with
    %    ZmapCatalogView.ValidProps.  Properties are case sensitive.
    %
    % ex
    %   zcv = ZmapCatalogView('primeCatalog') % creates a view into ZmapGlobal.Data.primeCatalog
    %   zcv.linkedplot(gca); %  plot onto current axis
    %   zcv.MagnitudeRange=[2 3]; %set filter to show mags >=2 and <=3.  map updates automatically*
    %
    %   minicat = zcv.Catalog(); %get the catalog that matches the filters
    %
    % *beware that there might be an issue with variable name scope.
    %  
    % zcv = zcv.reset(); %return to original ranges
    %
    % Polygons
    %
    % additionally, the view can be filtered using a polygon, where polygon is a struct or class
    % with a field/property "points". points is [lon1 , lat1; ...; lonN, latN]
    %
    % ZmapCatalogView.PolygonApply(poly, in_or_out)  : creates a polygon mask
    % ZmapCatalogView.PolygonRemove : removes the polygon filter
    % ZmapCatalogView.PolygonInvert : Inverts the polygon filter
    %
    %
    
    properties
        name % name of catalog variable, as seen in ZmapData
        DateRange % [mindate maxdate] as dateime
        MagnitudeRange % [minmag maxmag]
        LatitudeRange % [minlat maxlat]
        LongitudeRange % [minlon maxlon] % doesn't take dateline into account
        DepthRange % [mindepth maxdepth]
        Marker=''
        MarkerSize=[]
        MarkerFaceColor=[]
        MarkerEdgeColor=[]
        DisplayName='unset';
        Tag='unset';
        
    end
    properties(Constant)
        ValidProps = {'Marker';'MarkerSize';'MarkerFaceColor';'MarkerEdgeColor';'DisplayName';'Tag'};
    end
    properties(Dependent)
        Date % Date for each event in this view
        Latitude % Latitude for each event in this view
        Longitude % Longitude for each event in this view
        Depth % Depth for each event in this view, km
        Count % Count for each event in this view
        Magnitude % Magnitude for each event in this view
        MagnitudeType % Magnitude for each event in this view
        Catalog % get a ZmapCatalog created from this view
    end
    properties(Access=protected)
        mycat
        filter
        polymask; % logical mask
        polygon; % polygon.Latitude & polygon.Longitude
    end
    
    methods
        function c= get.mycat(obj)
            c= ZmapGlobal.Data.(obj.name);
        end
        
        function obj=ZmapCatalogView(catname,varargin)
            %
            % obj=ZmapCatalogView(catname)
            % obj=ZmapCatalogView(catname,Name1,Property1,...)
            %
            % see properties for valid arguments
            obj.name=catname;
            obj=obj.reset();
            
            %these are allowed to be created with the view
            while ~isempty(varargin)
                if ~ismember(varargin{1},obj.ValidProps)
                    disp(obj.ValidProps);
                    error('invalid Argument [%s]',varargin{1});
                end
                try
                    obj.(varargin{1})=varargin{2};
                catch
                    error('problem parsing ZmapCatalogView argument or its value : [%s]',varargin{1});
                end
                varargin(1:2)=[];
            end    
        end
        
        function obj=reset(obj)
            % reset all the ranges to their oriinal values
            obj.DateRange=obj.mycat.DateRange;
            obj.MagnitudeRange=obj.mycat.MagnitudeRange;
            obj.LatitudeRange=[min(obj.mycat.Latitude) max(obj.mycat.Latitude)];
            obj.LongitudeRange=[min(obj.mycat.Longitude) max(obj.mycat.Longitude)];
            obj.DepthRange=[min(obj.mycat.Depth) max(obj.mycat.Depth)];
            obj=obj.RemovePolygon();
        end
        
        function f = get.filter(obj)
            f = obj.mycat.Latitude >= obj.LatitudeRange(1) &...
                obj.mycat.Latitude <= obj.LatitudeRange(2) &...
                obj.mycat.Longitude >= obj.LongitudeRange(1) &...
                obj.mycat.Longitude <= obj.LongitudeRange(2) &...
                obj.mycat.Magnitude >= obj.MagnitudeRange(1) &...
                obj.mycat.Magnitude <= obj.MagnitudeRange(2) &...
                obj.mycat.Depth >= obj.DepthRange(1) &...
                obj.mycat.Depth <= obj.DepthRange(2) &...
                obj.mycat.Date >= obj.DateRange(1) & ...
                obj.mycat.Date <= obj.DateRange(2);
            if ~isempty(obj.polymask)
                f=f & obj.polymask;
            end
        end
        
        function lat=get.Latitude(obj)
            lat=obj.mycat.Latitude(obj.filter);
        end
                
        function mt=get.MagnitudeType(obj)
            mt=obj.mycat.MagnitudeType(obj.filter);
        end
        
        function obj=set.LatitudeRange(obj,val)
            % change the latitude ranges. 
            % setting to [] will reset to the catalog's min/max values
            if isempty(val)
                val=obj.mycat.LatitudeRange;
            end
            if ~isequal(val,obj.LatitudeRange)
                obj.LatitudeRange=val;
                refreshdata;
            end
        end
        
        function lon=get.Longitude(obj)
            lon=obj.mycat.Longitude(obj.filter);
        end
                
        function obj=set.LongitudeRange(obj,val)
            % change the longitude ranges. 
            % setting to [] will reset to the catalog's min/max values
            if isempty(val)
                val=obj.mycat.LatitudeRange;
            end
            if ~isequal(val,obj.LongitudeRange)
                obj.LongitudeRange=val;
                refreshdata;
            end
        end
        
        
        
        function mag=get.Magnitude(obj)
            mag=obj.mycat.Magnitude(obj.filter);
        end
                
        function obj=set.MagnitudeRange(obj,val)
            % change the magnitude ranges. 
            % setting to [] will reset to the catalog's min/max values
            if isempty(val)
                val=[min(obj.mycat.Magnitude) max(obj.mycat.Magnitude)];
            end
            if ~isequal(val,obj.MagnitudeRange)
                obj.MagnitudeRange=val;
                refreshdata;
            end
        end
        
        
        function d=get.Date(obj)
            d=obj.mycat.Date(obj.filter);
        end
        
        function obj=set.DateRange(obj,val)
            % change the date range
            % setting to [] will reset to the catalog's min/max values
            
            if ~isa(obj.DateRange,'datetime') || isempty(val)
                obj.DateRange=obj.mycat.DateRange;
                refreshdata;
                return
            end
            if ~isa(val,'datetime')
                val=datetime(val);
            end
            if isempty(val)
                val=obj.mycat.DateRange;
            end
            obj.DateRange=val;
            refreshdata;
        end
        
        function d=get.Depth(obj)
            d=obj.mycat.Depth(obj.filter);
        end
        
        function obj=set.DepthRange(obj,val)
            % change the depth ranges. setting to [] will reset to the catalog's min/max values
            if isempty(val)
                val=[min(obj.mycat.Depth) max(obj.mycat.Depth)]; %#ok<*MCSUP>
            end
            if ~isequal(val,obj.DepthRange)
                obj.DepthRange=val;
                refreshdata;
            end
        end
        
        function cnt=get.Count(obj)
            % return number of events represented by this view
            cnt=sum(obj.filter);
        end
        function linkedplot(obj,ax, varargin)
            % plot this on an axes, linking the data so that range changes are reflected on the plot
            %
            % see also linkdata
            
            % build up additional features
            v={};
            s=inputname(1);
            for i=1:numel(obj.ValidProps)
                prop = obj.ValidProps{i};
                val = obj.(prop);
                if ~isempty(val)
                    v=[v,{prop,val}]; %#ok<AGROW>
                end
            end
            h=ishold(ax);
            hold(ax,'on');
            p=plot(ax,0,0,'o');
            set(p,...
                'YData',obj.Latitude, ...
                'XData',obj.Longitude,...
                'Zdata', obj.Depth, ...
                'YDataSource',[s '.Latitude'],...
                'XDataSource',[s '.Longitude'],...
                'ZDataSource',[s '.Depth'], v{:}, varargin{:});
            hold(ax,logical2onoff(h));
            axes(ax)
            linkdata on
        end
        function c=get.Catalog(obj)
            % get the subset catalog represented by this view
            c=obj.mycat.subset(obj.filter);
        end
        
        function c=subset(obj,idx)
            %return a subsetted catalog from this view
            c=obj.mycat.subset(obj.filter);
            c=c.subset(idx);
        end
        
        function disp(obj)
            fprintf('      Count: %d events\n',obj.Count);
            fprintf('      Dates: %s to %s\n', char(obj.DateRange(1),'uuuu-MM-dd hh:mm:ss'),...
                 char(obj.DateRange(2),'uuuu-MM-dd hh:mm:ss'));
             magtypes =strjoin(unique(obj.mycat.MagnitudeType(obj.filter)),',');
            fprintf(' Magnitudes: %.4f to %.4f  [%s]\n',...
                obj.MagnitudeRange, magtypes);
            
            fprintf('  Latitudes: %.4f to %.4f  [deg]\n', obj.LatitudeRange);
            fprintf(' Longitudes: %.4f to %.4f  [deg]\n', obj.LongitudeRange);
            fprintf('     Depths: %.2f to %.2f  [km]\n', obj.DepthRange);
            fprintf('     Symbol: marker ''%s'', size: %.1f\n', obj.Marker, obj.MarkerSize);
            if ~isempty(obj.polymask)
                disp('     Polygon filtering in effect');
            end
        end
        function tf = isempty(obj)
            tf=obj.Count==0;
        end
        
        function obj=PolygonApply(obj,polygon)
            %ApplyPolygon applies a polygon mask to the catalog, further filtering results
            % assumes polygon is either [lat,lon;...;latN,lonN] or struct with fields
            % 'Latitude' and 'Longitude'
            %
            %in_or_out is one of 'inside', 'outside'
            nargoutchk(1,1) % to avoid confusion, don't let this NOT be assigned
            if exist('polygon','var')
                if isnumeric(polygon)
                    obj.polygon.Latitude=polygon(:,2);
                    obj.polygon.Longitude=polygon(:,1);
                else
                    obj.polygon.Latitude=polygon.Latitude;
                    obj.polygon.Longitude=polygon.Longitude;
                end
            end
            if isempty(obj.polygon.Latitude)
                % nothing to do
                return
            end
            obj.polymask = polygon_filter(obj.polygon.Longitude, obj.polygon.Latitude,...
                obj.mycat.Longitude, obj.mycat.Latitude, 'inside');
            refreshdata;
        end
        
        function obj=PolygonRemove(obj)
            nargoutchk(1,1) % to avoid confusion, don't let this NOT be assigned
            obj.polymask=[];
            obj.polygon=struct('Lat',[],'Lon',[]);
            refreshdata;
        end
        
        function obj=PolygonInvert(obj)
            nargoutchk(1,1) % to avoid confusion, don't let this NOT be assigned
            obj.polymask=~obj.polymask;
        end
            
    end
end