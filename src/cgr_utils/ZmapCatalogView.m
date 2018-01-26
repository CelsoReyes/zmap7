classdef ZmapCatalogView
    % ZmapCatalogView provides a way to interact with one of the global catalogs without copying it
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
    %   zcv.linkedplot(gca,'zcv'); %  plot onto current axis
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
    % ZmapCatalogView properties:
    %
    %     sourcename - name of catalog's global variable, for example 'primeCatalog'
    %     ViewName - name given to this view for plotting
    %     DateRange - [mindate maxdate] as dateime
    %     MagnitudeRange - [minmag maxmag]
    %     LatitudeRange - [minlat maxlat]
    %     LongitudeRange - [minlon maxlon] % doesn't take dateline into account
    %     DepthRange - [mindepth maxdepth]
    %     Marker - default marker used when plotting this view
    %     MarkerSize - default marker size for plotting
    %     MarkerFaceColor - default marker fill for plotting
    %     MarkerEdgeColor - default marker outline for plotting
    %     DisplayName - name used in the legend for this view
    %     Tag - tag used for finding plotted versions of this view via findobj
    %
    %     Name - catalog's Name
    %     Date - Date for each event in this view [read-only]
    %     Latitude - Latitude for each event in this view [read-only]
    %     Longitude - Longitude for each event in this view [read-only]
    %     Depth - Depth for each event in this view, km [read-only]
    %     Count - Count for each event in this view [read-only]
    %     Magnitude - Magnitude for each event in this view [read-only]
    %     MagnitudeType - Magnitude for each event in this view [read-only]
    %
    %
    % ZmapCatalogView protected properties:
    %
    %   mycat - provides access to the underlying catalog [read only]
    %   filter - logical mask, true where events meet all range & polygon criteria
    %   polymask - logical mask, true where events are within(†) polygon
    %   polygon - [Nx2] containing polygon.Latitude & polygon.Longitude
    %
    %   (†) - OR outside polygon, depending on PolygonInvert
    % ZmapCatalogView methods:
    %
    %   ZmapCatalogView - create a view from either global catalog or another view
    %
    %   Catalog - get a ZmapCatalog created from this view
    %   cat - combine catalogs or catalog views (returns a catalog, not a view)
    %
    %   reset - reset all the ranges to their original values
    %   isempty - returns true if this view contains no events
    %
    %   Plotting Routines:
    %   linkedplot - plot this view, but plot will autoupdate when view changes
    %   plot - plot this view (catalog)
    %   plotm - plot this view (catalog) on a map
    % 
    %   disp - display this view
    %   trace - trace shows this and all Catalogs / Views from which this is descended
    %   parent - return the object upon which this is based
    %   
    %   subset - get a catalog that is a subset of this view (catalog) via logical/numeric indexing
    % 
    %   ZmapCatalogView polygon routines:
    %   PolygonApply - further masks the view with a polygon. Events must be inside/outside polygon
    %   PolygonRemove - clears the polygon, so that 
    %   PolygonInvert - changes whether events must be inside or outside polygon
    %
    % see also ZmapCatalog
    
    
    properties
        % sourcename - name of catalog's global variable, for example 'primeCatalog', 
        % which means the original catalog can be found in ZmapData.primeCatalog
        sourcename
        
        ViewName % name given to this view for plotting
        
        DateRange % [mindate maxdate] as dateime
        MagnitudeRange % [minmag maxmag]
        LatitudeRange % [minlat maxlat]
        LongitudeRange % [minlon maxlon] % doesn't take dateline into account
        DepthRange % [mindepth maxdepth]
        
        sortby='';
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
        Name % catalog name, (augmented by view?)
        Date % Date for each event in this view
        Latitude % Latitude for each event in this view
        Longitude % Longitude for each event in this view
        Depth % Depth for each event in this view, km
        Count % Count for each event in this view
        Magnitude % Magnitude for each event in this view
        MagnitudeType % Magnitude for each event in this view
    end
    
    properties(Access=protected)
        mycat % the actual catalog. [read only]
        filter
        polymask = []; % logical mask
        polygon=struct('Latitude',[],'Longitude',[]); % polygon.Latitude & polygon.Longitude
    end
    
    methods
        function n=get.Name(obj)
            n=obj.ViewName;
        end
        function obj=set.Name(obj, name)
            obj.ViewName=name;
        end
        function c= get.mycat(obj)
            names=strsplit(obj.sourcename,'.');
            
            c= ZmapGlobal.Data.(names{1});
            names(1)=[];
            while ~isempty(names)
                c=c.(names{1});
                names(1)=[];
            end
            %c= ZmapGlobal.Data.(obj.sourcename);
        end
        
        function obj=ZmapCatalogView(catname,varargin)
            %
            % obj=ZmapCatalogView(catname)
            % obj=ZmapCatalogView(catname,Name1,Property1,...)
            %
            % see properties for valid arguments
            obj.sourcename=catname;
            obj.ViewName=obj.mycat.Name;
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
            % reset all the ranges to their original values
            obj.DateRange=obj.mycat.DateRange;
            obj.MagnitudeRange=obj.mycat.MagnitudeRange;
            obj.LatitudeRange=[min(obj.mycat.Latitude) max(obj.mycat.Latitude)];
            obj.LongitudeRange=[min(obj.mycat.Longitude) max(obj.mycat.Longitude)];
            obj.DepthRange=[min(obj.mycat.Depth) max(obj.mycat.Depth)];
            obj=obj.PolygonRemove();
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
                if numel(f) ~= numel(obj.polymask)
                    warning('mask and events out of sync. loosing polygon mask')
                    obj=obj.PolygonRemove();
                else
                    f=f & obj.polymask;
                end
            end
            if ~isempty(obj.sortby)
                [~,idx]=sort(obj.mycat.(obj.sortby));
                % f(idx) is the t/f value for the sorted index
                f=idx(f(idx)); % returns numeric index of sorted values
            end
                
                
        end
        
        function obj = sort(obj,field)
            if isempty(field)
                obj.sortby='';
            elseif isprop(obj,field)
                obj.sortby=field;
            else
                error('cannot sort by : %s',field);
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
                %refreshdata;
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
                %refreshdata;
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
                %refreshdata;
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
                %refreshdata;
                return
            end
            if ~isa(val,'datetime')
                val=datetime(val);
            end
            if isempty(val)
                val=obj.mycat.DateRange;
            end
            obj.DateRange=val;
            %refreshdata;
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
                %refreshdata;
            end
        end
        
        function cnt=get.Count(obj)
            % return number of events represented by this view
            cnt=sum(obj.filter);
        end
        
        %% plotting routines
        function linkedplot(obj,ax, mysource, varargin)
            % LINKEDPLOT plot this on an axes, linking the data so that range changes are reflected on the plot
            % linkedplot(obj,ax, mysource, varargin)
            % ax is the valid axis, and will be held before plotting
            % mysource is a string that evaluates into this object for linking
            % vararign are additional aprameters passed tot he set plot
            %
            % data is NOT automatically linked. use linkdata on to turn on the linking
            % see also linkdata
            
            % build up additional features
            v={};
            s=mysource;
            for i=1:numel([obj.ValidProps])
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
            %linkdata on
        end
        
        function rt = relativeTimes(obj, other)
            % relativeTimes
            % rt = obj.relativeTimes() get times relative to start
            % rt = obj.relativeTimes(other) get times relative to another time
        
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
        
        function h=plot(obj, ax, varargin)
            % PLOT this catalog. It will plot on
            % h=plot (obj,ax, varargin)
            %
            % see also refreshPlot

            % build up additional features
            v={};
            for i=1:numel([obj.ValidProps])
                prop = obj.ValidProps{i};
                val = obj.(prop);
                if ~isempty(val)
                    v=[v,{prop,val}]; %#ok<AGROW>
                end
            end
            %h=ishold(ax);
            %hold(ax,'on');
            h=plot(ax,0,0,'o'); % was p
            set(h,...
                'YData',obj.Latitude, ...
                'XData',obj.Longitude,...
                'Zdata', obj.Depth, ...
                v{:}, varargin{:});
            %hold(ax,logical2onoff(h));
            axes(ax)
            %linkdata on
            %{
            if has_toolbox('Mapping Toolbox') && ismap(ax)
                h=obj.plotm(ax,varargin{:});
                return
            end
            
            hastag=find(strcmp('Tag',varargin),1,'last');
            
            if ~isempty(hastag)
                mytag=varargin{hastag+1};
            else
                mytag=['catalog_',obj.mycat.Name];
                varargin(end+1:end+2)={'Tag',mytag};
            end
            
            % clear the existing layer
            h = findobj(ax,'Tag',mytag);
            if ~isempty(h)
                delete(h);
            end
            
            holdstatus = ishold(ax); 
            hold(ax,'on');
            
            % val = obj.getTrimmedData();
            h=plot(ax,nan,nan,'x');
            set(h,'XData',obj.Longitude,'YData', obj.Latitude, 'ZData',obj.Depth);
            set(h,varargin{:}); % if Tag is in varargin, it will override default tag
            %h.ZData = obj.Depth;
            hold(ax,logical2onoff(holdstatus));
            %}
        end
        
        
        function h=plotm(obj,ax, varargin)
            % plot this layer onto a map (Requires mapping toolbox)
            % will delete layer if it exists
            % note features will only plot the subset of features within the
            % currently visible axes
            %
            % see also refreshPlot
            
            
            if isempty(ax) || ~isvalid(ax) || ~ismap(ax)
                error('Feature "%s" ->plot has no associated axis or is not a map',obj.mycat.Name);
            end
            
            hastag=find(strcmp('Tag',varargin));
            if ~isempty(hastag)
                mytag=varargin{hastag}+1;
            else
                mytag=['catalog_',obj.mycat.Name];
                varargin(end+1:end+2)={'Tag',mytag};
            end
            
            h = findobj(ax,'Tag',mytag);
            if ~isempty(h)
                delete(h);
            end
            
            holdstatus = ishold(ax); hold(ax,'on');
            h=plotm(obj.Latitude, obj.Longitude, '.',varargin{:});
            set(h, 'ZData',obj.Depth);
            set(ax,'ZDir','reverse');
            daspectm('km');
            hold(ax,logical2onoff(holdstatus));
            
        end
       
        %% in-out routines
        function c=Catalog(obj)
            % get the subset catalog represented by this view
            c=obj.mycat.subset(obj.filter);
            c.Name=obj.ViewName;
        end
        
        function c=subset(obj,idx)
            %return a subsetted catalog from this view
            c=obj.mycat.subset(obj.filter);
            c=c.subset(idx);
        end
        
        function c=cat(obj, otherobj)
            % combine catalogs or catalog views
            if isa(obj,'ZmapCatalogView')
                if isa(otherobj,'ZmapCatalogView')
                    c=cat(obj.Catalog(),otherobj.Catalog());
                else
                    c=cat(obj.Catalog(),otherobj);
                end
            else
                c=cat(obj,otherobj.Catalog());
            end
        end
        function disp(obj)
            fprintf('  View Name: %s  [Cat Name: %s]\n',obj.Name, obj.mycat.Name);
            fprintf('     source: %s\n',obj.sourcename);
            % DISP display the ranges used to view a catalog. The actual catalog dates do not need to match
            
            fprintf('      Count: %d events\n',obj.Count);
            fprintf('      Dates: %s to %s\n', char(obj.DateRange(1),'uuuu-MM-dd hh:mm:ss'),...
                 char(obj.DateRange(2),'uuuu-MM-dd hh:mm:ss'));
             magtypes =strjoin(unique(obj.mycat.MagnitudeType(obj.filter)),',');
            disp('Filter ranges for this catalog view are set to:');
            % actual catalog will have ranges inside and out
            fprintf(' Magnitudes: %.4f to %.4f  [%s]\n',...
                obj.MagnitudeRange, magtypes);
            
            fprintf('  Latitudes: %.4f to %.4f  [deg]\n', obj.LatitudeRange);
            fprintf(' Longitudes: %.4f to %.4f  [deg]\n', obj.LongitudeRange);
            fprintf('     Depths: %.2f to %.2f  [km]\n', obj.DepthRange);
            fprintf('     Symbol: marker ''%s'', size: %.1f\n', obj.Marker, obj.MarkerSize);
            if ~isempty(obj.polymask)
                disp('     Polygon filtering in effect');
            end
            if ~isempty(obj.sortby)
                disp(['  sorted by: ' obj.sortby]);
            end
        end
        function blurb(obj, leadingspaces)
            if ~exist('leadingspaces','var')
                leadingspaces=0;
            end
            if numel(obj)>1
                fprintf('multiple views  size:%s\n',mat2str(size(obj)));
                for i=1:numel(obj)
                    blurb(obj(i),leadingspaces+20);
                end
                return
            end
            s=repmat(' ',1,leadingspaces);
            % one line summary
            fprintf('%s ZmapCatalogView "%s" -> %s',s, obj.Name, obj.sourcename);
            
            % DISP display the ranges used to view a catalog. The actual catalog dates do not need to match
            
            fprintf(' {%d/%d events}',obj.Count,ZmapGlobal.Data.(obj.sourcename).Count);
            if ~isempty(obj.polymask)
                fprintf('(POLY)');
            end
            if ~isempty(obj.sortby)
                fprintf('(SORT:%s)',obj.sortby);
            end
            fprintf('\n');
        end
        
        function tf = isempty(obj)
            tf=obj.Count==0;
        end
        
        function obj=PolygonApply(obj,polygon)
            %ApplyPolygon applies a polygon mask to the catalog, further filtering results
            % events must be within polygon AND meet the range criteria
            % assumes polygon is either [lat,lon;...;latN,lonN] or struct with fields
            % 'Latitude' and 'Longitude'
            %
            %in_or_out is one of 'inside', 'outside'
            nargoutchk(1,1) % to avoid confusion, don't let this NOT be assigned
            if isempty(polygon)
                return
            end
            disp('Applying shape to catalog')
            if exist('polygon','var')
                if isnumeric(polygon)
                    obj.polygon.Latitude=polygon(:,2);
                    obj.polygon.Longitude=polygon(:,1);
                elseif isa(polygon,'ShapeGeneral')
                    oln=polygon.Outline;
                    obj.polygon.Latitude=oln(:,2);
                    obj.polygon.Longitude=oln(:,1);
                else
                    error('unanticipated polygon input')
                end
            end
            if isempty(obj.polygon.Latitude) || all(isnan(obj.polygon.Latitude))
                    obj=obj.PolygonRemove();
                return
            end
            obj.polymask = polygon_filter(obj.polygon.Longitude, obj.polygon.Latitude,...
                obj.mycat.Longitude, obj.mycat.Latitude, 'inside');
            %refreshdata;
        end
        
        function obj=PolygonRemove(obj)
            nargoutchk(1,1) % to avoid confusion, don't let this NOT be assigned
            if ~isempty(obj.polymask) ||...
                    ~isempty(obj.polygon.Latitude) ||...
                    ~isempty(obj.polygon.Longitude)
                obj.polymask=[];
                obj.polygon.Latitude=[];
                obj.polygon.Longitude=[];
                %refreshdata;
            end
        end
        
        function obj=PolygonInvert(obj)
            nargoutchk(1,1) % to avoid confusion, don't let this NOT be assigned
            obj.polymask=~obj.polymask;
        end
            
        function trace(obj)
            % trace shows this and all Catalogs / Views from which this is descended
            disp(obj)
            disp(['- - - - from:' obj.sourcename]);
            disp('v v v v');
            disp(ZmapGlobal.Data.(obj.sourcename));
        end
        
        function p=parent(obj)
            % return the object upon which this is based
            p=ZmapGlobal.Data.(obj.sourcename);
        end
    end
end