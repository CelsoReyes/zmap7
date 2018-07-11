classdef MapFeature < handle
    %MapFeature used to track and plot features on a map (works in 3d)
    %
    %   sample usage:
    %       load_fn = @get_earthquakes;
    %       save_fn = [];
    %       plot_defaults = struct('Tag','important_feature',...
    %            'DisplayName','importantFeature',...
    %            'LineWidth', 3.0,...
    %            'Color',[.1 .2 .5]);
    %
    %       f = MapFeature('feature', load_fn, save_fn, plot_defaults);
    %       ax = axes; % create new axes
    %       f.plot(ax);
    %
    %       % .. do something here that might change the axes limits or something
    %
    %       f.refreshPlot();
    %
    %
    %
    % lakes = ZG.features('lakes')
    %
    % % COMPARING PLOT and PLOTM in same figure
    % fig=figure;
    %
    % % PLOT FEATURE ON "NORMAL" PLOT AXES
    % % - SET UP THE AXES
    % ax1=subplot(1,2,1);
    % ylim(ax1,[min(ZG.primeCatalog.Latitude) max(ZG.primeCatalog.Latitude)])
    % xlim(ax1,[min(ZG.primeCatalog.Longitude) max(ZG.primeCatalog.Longitude)])
    % title(ax1,'normal plot')
    %
    % % PLOT FEATURE ON "MAP" PLOT AXES
    % % - SET UP THE AXES
    % ax2=subplot(1,2,2);
    % ax2m=axesm('lambert','MapLatLimit',[min(ZG.primeCatalog.Latitude) max(ZG.primeCatalog.Latitude)],'MapLonLimit',[min(ZG.primeCatalog.Longitude) max(ZG.primeCatalog.Longitude)]);
    % setm(ax2m,'MLineLocation',.25, 'PLineLocation',.25); % degrees for grid lines
    % setm(ax2m,'Grid','on')
    % setm(ax2m,'MeridianLabel','on','ParallelLabel','on')
    % setm(ax2m,'PLabelLocation',.5,'MLabelLocation',.5)  % degrees for labeling
    % setm(ax2m,'LabelFormat','signed','LabelUnits','dms') % display as +7˚ 00' 00"
    % title(ax2m,'lambert plot')
    %
    % lakes.plot(ax2m) % plot into map
    % lakes.plot(ax1) % plot onto "normal" axes
    
    properties(Transient, Hidden)
        Loadfn function_handle = @do_nothing % function used to load/import this feature's data
        Savefn function_handle = @do_nothing % function used to save/export this feature's data
    end
    properties
        Name (1,:) char        % name of this feature
        PlottingDefaults struct  % properties used on this layer
        Value struct           % raw values to plot, as struct, class, or Table containing a "Longitude" and "Latitude" field
        ParentAxis matlab.graphics.axis.Axes % handle to a parent axis. assigned when this is plotted
        MenuToggle matlab.ui.container.Menu % handle to the uimenu used to show/hide this layer
        WasLoaded logical = false;
    end
    properties(Dependent)
        Handle              % handle to this layer
        Longitude           % vector of Longitudes [deg] (to be plotted on X)
        Latitude            % vector of Latitudes [deg] (to be plotted on Y)
        Depth               % vector of Depths [km] (to be plotted on -Z)
        Names
    end
    
    methods
        function obj= MapFeature(name, load_fn, save_fn, plot_defaults)
            % create a MapFeature
            % obj= MAPFEATURE(name, load_fn, save_fn, plot_defaults)
            
            assert(isfield(plot_defaults,'Tag'));
            obj.Name = name;
            if ~isempty(load_fn)
                obj.Loadfn = load_fn;
            end
            
            if ~isempty(save_fn)
                obj.Savefn = save_fn;
            end
            
            obj.PlottingDefaults = plot_defaults;
        end
        
        function obj=copyobj(orig,AX)
            % COPYOBJ copies a feature into a specified axes
            % feature.COPYOBJ(AX) where AX is the destination axes
            %
            % obj=feature.COPYOBJ(...) returns a handle to the copied Mapfeature.
            %
            % see also copyobj
            obj=MapFeature(orig.Name, orig.Loadfn, orig.Savefn, orig.PlottingDefaults);
            obj.Value=orig.Value;
            obj.WasLoaded=orig.WasLoaded;
            obj.plot(AX);
        end
        
        function h =get.Handle(obj)
            % get.HANDLE get the handle to this feature's layer
            % if this layer hasn't been plotted yet, or has been deleted, then
            % this returns []
            
            % make sure Parent Axis is still valid
            if ~isempty(obj.ParentAxis) && ~isvalid(obj.ParentAxis)
                obj.ParentAxis = [];
            end
            
            if ~isempty(obj.ParentAxis)
                h = findobj(obj.ParentAxis, 'Tag', obj.PlottingDefaults.Tag);
            else
                h=[];
                %error('This feature %s is not associated with a valid parent',obj.Name);
                % h = findobj(groot, 'Tag', obj.PlottingDefaults.Tag);
            end
        end
        
        function lons = get.Longitude(obj)
            lons = obj.Value.Longitude;
        end
        function lats = get.Latitude(obj)
            lats = obj.Value.Latitude;
        end
        function depths = get.Depth(obj)
            depths = obj.Value.Depth;
        end
        
        function names = get.Names(obj)
            try
                names = obj.Value.Names;
            catch ME
                names = {'no name'};
            end
        end
        
        function layer=plot(obj,ax)
            % plot this layer
            % will delete layer if it exists
            % note features will only plot the subset of features within the
            % currently visible axes
            %
            % see also refreshPlot
            
            assert(obj.WasLoaded,'load before plotting!')
            
            if ~exist('ax','var')
                ax = obj.ParentAxis;
            else
                obj.ParentAxis = ax;
            end
            
            if isempty(ax) || ~isvalid(ax)
                error('Feature "%s" ->plot has no associated axis',obj.Name);
            end
            
                
            if has_toolbox('Mapping Toolbox') && ismap(ax)
                obj.plotm(ax);
                return
            end
            % clear the existing layer
            h = obj.Handle;
            if ~isempty(h)
                delete(h);
            end
            if isempty(obj.Value)
                return % nothing to plot
            end
            
            holdstatus = ishold(ax); ax.NextPlot='add';
            
            val = obj.getTrimmedData();
            layer=line(ax,'XData',val.Longitude, 'YData',val.Latitude,'ZData',val.Depth');
            ax.ZDir='reverse';
            %stackorder_menu(layer)
            
            if ~holdstatus; ax.NextPlot='replace'; end
            
            % set properties for this layer
            set(layer, obj.PlottingDefaults);
        end
        
        function layer=plotm(obj,ax)
            % plot this layer onto a map (Requires mapping toolbox)
            % will delete layer if it exists
            % note features will only plot the subset of features within the
            % currently visible axes
            %
            % see also refreshPlot
            
            if ~exist('ax','var')
                ax = obj.ParentAxis;
            else
                obj.ParentAxis = ax;
            end
            
            if isempty(ax) || ~isvalid(ax)
                error('Feature "%s" ->plot has no associated axis',obj.Name);
            end
            
            % clear the existing layer
            h = obj.Handle;
            if ~isempty(h)
                delete(h);
            end
            
            if isempty(obj.Value)
                return % nothing to plot
            end
            
            holdstatus = ishold(ax); ax.NextPlot='add';
            
            val = obj.getTrimmedData();
            layer=plotm(val.Latitude, val.Longitude); %not allowed to specify axes
            zdatam(layer, val.Depth(:)');
            daspectm('km');
            if ~holdstatus; ax.NextPlot='replace'; end
            
            % set properties for this layer
            set(layer, obj.PlottingDefaults);
        end
        
        function refreshPlot(obj)
            % refreshPlot updates the X,Y,Z values without deleting the layer
            %
            % refreshPlot useful for when the axis limits have changed or
            % when the values have changed.  The plotted data will be trimmed, which reduces
            % the plotting overhead.
            %
            % see also plot
            
            %find this layer
            layer=obj.Handle;
            if isempty(layer)
                disp([obj.Name,' plot did not exist']);
            end
            val = obj.getTrimmedData();
            % set properties for this layer
            layer.XData=val.Longitude;
            layer.YData=val.Latitude;
            layer.ZData=val.Depth;
            set(layer,obj.PlottingDefaults);
        end
        
        function load(obj,varargin)
            % load this feature
            % uses the Loadfn provided during Feature Construction
            % loadFunction is expected to return a table or struct containing fields for
            % 'Latitude', 'Longitude', and 'Depth' (things with ELEVATION would have negative depth)
            item = obj.Loadfn(varargin{:});
            obj.Value = toValueStruct(item);
            obj.WasLoaded = true;
        end
        
        function save(obj)
            % save this feature
            % uses the Savefn provided during Feature construction
            obj.Savefn(obj)
        end
        
        function changeDefaults(obj, propname_struct)
            %changeDefaults changes this layer's properties and applies the change
            fn=fieldnames(propname_struct);
            for i=1:numel(fn)
                obj.PlottingDefaults.(fn{i}) = propname_struct.(fn{i});
            end
            set(obj.Handle,obj.PlottingDefaults);
        end
        
        
        function addToggleMenu(obj, parentH, ax)
            % addToggleMenu add menu that hides/shows this Feature
            % addToggleMenu(parent) adds a toggle menu subordinate to the parent uimenu
            
            if ~isempty(obj.MenuToggle) && isvalid(obj.MenuToggle)
                error('ToggleMenu for Feature "%s" already exists.',obj.Name);
            end
            
            obj.MenuToggle = uimenu(parentH,...
                'Label',['Hide ' obj.Name],...
                'MenuSelectedFcn',{@obj.toggle_showhide_menu, ax});
        end
        function toggle_showhide_menu(obj, src, ~, ax, contingencyFunction)
            % switch the show/hide menu between the "Show" and "Hide" stat
            % obj.toggle_showhide_menu(src, ~, contingencyFunction
            %   this is intended to be the Callback for the addToggleMenu.
            %
            % if the plot this toggles no longer exists, then
            % the user-provided contingencyFunction will be run, which might be able to get things
            % back on track.
            h=obj.Handle;
            watchon
            drawnow;
            if isempty(h)
                if exist('contingencyFunction','var')
                    contingencyFunction();
                end
                h=findobj(ax,'Tag', obj.PlottingDefaults.Tag);
                errordlg('missing a layer %s', obj.PlottingDefaults.Tag);
            end
            axis(obj.ParentAxis,'manual')
            washeld = ishold(obj.ParentAxis); hold(obj.ParentAxis,'on');
            if startsWith(src.Label,'Hide ')
                src.Label = ['Show ' obj.Name];
                h.Visible = 'off';
            else % assume it starts with 'Show '
                src.Label = ['Hide ' obj.Name];
                h.Visible = 'on';
            end
            if ~washeld, hold(obj.ParentAxis,'off');end
            watchoff
            drawnow;
        end
    end % methods
    
    methods(Access=protected)
        function val = getTrimmedData(obj)
            % trim data to parent axis limits
            % obj.getTrimmedData()
            %
            % gaps where data was removed are replaced with a single "nan" value
            % this reduces the data size, and keeps segments from connecting when
            % they shouldn't.
            
            ax = obj.ParentAxis;
            if ismap(ax)
                trimLat=getm(ax,'maplatlimit');
                trimLon=getm(ax,'maplonlimit');
            else
                trimLat=ylim(ax);
                trimLon=xlim(ax);
            end
            idx  = obj.Value.Longitude >= trimLon(1) & obj.Value.Longitude <= trimLon(2);
            idx = idx & obj.Value.Latitude >= trimLat(1) & obj.Value.Latitude <= trimLat(2);
            
            val=obj.Value;
            
            % index used to delete any nan's after the first (per gap)
            todel = [false; ~idx(1:end-1)] & [false; ~idx(2:end)];
            if ~isfield(val,'Depth')
                val.Depth=zeros(size(val.Latitude));
            end
            % replace out-of-bounds values with NaN
            val.Longitude(~idx) = nan;
            val.Latitude(~idx) = nan;
            val.Depth(~idx)=nan;
            
            % reduce dataset by removing all nan's EXCEPT for one (per gap)
            val.Longitude(todel) = [];
            val.Latitude(todel) = [];
            val.Depth(todel)=[];
        end
        
    end %protected methods
    
    methods(Static)
        function foreach(features,funcname,varargin)
            %FOREACH run a function on a Map or array full of MapFeature
            % FOREACH(features) where features is either a map or array of MapFeature
            % FOREACH(features,arg1,...) arguments to pass to the function
            if isa(features,'containers.Map')
                k=features.keys;
                for i=1:numel(k)
                    ftr=features(k{i});
                    ftr.(funcname)(varargin{:});
                end
            else
                % treat as an array
                for i=1:numel(features)
                    ftr=features(i);
                    ftr.(funcname)(varargin{:});
                end
            end
        end
        
        function foreach_waitbar(features,funcname,varargin)
            %FOREACH run a function on a Map or array full of MapFeature
            % FOREACH(features) where features is either a map or array of MapFeature
            % FOREACH(features,arg1,...) arguments to pass to the function
            
            
            h=waitbar(0,'Calculating features for map...');
            if isa(features,'containers.Map')
                k=features.keys;
                for i=1:numel(k)
                    h.Name=[funcname ' : ', k{i}];
                    ftr=features(k{i});
                    ftr.(funcname)(varargin{:});
                    waitbar(i/numel(k),h);
                end
            else
                % treat as an array
                k = numel(features);
                for i=1:k
                    h.Name=[funcname ' : ', features(i).Name];
                    ftr=features(i);
                    ftr.(funcname)(varargin{:});
                    waitbar(i/k,h);
                end
            end
            delete(h)
        end
        
    end %static methods
end

function [finder, namer] = how_to_deal_with(item)
    switch class(item)
        case 'table'
            xx = item.Properties.VariableNames;
            finder = @(item, fn) startsWith(item.Properties.VariableNames, fn,'IgnoreCase',true);
            namer = @(idx) xx{idx};
            %accessor = @(item,fn) item.(fn)(:);
        case 'struct'
            xx = fieldnames(item);
            finder = @(item, fn) startsWith(xx, fn, 'IgnoreCase',true);
            fidx = fieldnameFromIndex(xx);
            namer = @(idx) fidx(idx);% fieldnameFromIndex(fieldnames(item));
            %accessor = @(item,fn) item.(fn)(:);
        otherwise
            xx=properties(item);
            assert(~isempty(xx),'item is not a table, struct, or class');
            finder = @(item, fn) startsWith(xx, fn, 'IgnoreCase',true);
            
            fidx = fieldnameFromIndex(xx);
            namer = @(idx) fidx(idx);% fieldnameFromIndex(fieldnames(item));
            %accessor = @(item,fn) item.(fn)(:);
    end
    function fn=fieldnameFromIndex(flds)
        fn = @(idx) flds{idx};
    end
end


function value = toValueStruct(data)
    % set.Value does the painful work of importing data form a variety of data types
    % result will have Latitude, Longitude, probably Depth, and possibly Names
    
    value=struct('Longitude',[],'Latitude',[],'Depth',[],'Names','');
    
    if isnumeric(data)
        % do number crunching
        
        if isempty(data)
            return
        end
        
        if size(data,2)>3 || size(data,2) < 2
            error('Feature "%s" expected 2-3 columns of data, or something with Latitude and Longitude fields',obj.Name); %#ok<MCSUP>
        end
        
        % assume longitude in first column
        if max(abs(data(:,2))) > 90.000001
            error('Feature "%s" expected latitudes in range of -90 to 90 in second column',obj.Name); %#ok<MCSUP>
        end
        
        if max(abs(data(:,1))) > 180.000001
            error('Feature "%s" expected longitudes in -180 to 180 range [%f]',obj.Name, max(abs(data(:,1)))); %#ok<MCSUP>
        end
        
        value.Longitude = data(:,1);
        value.Latitude = data(:,2);
        
        if size(data,2)==3
            value.Depth = data(:,3);
        else
            value.Depth = zeros(size(value.Longitude));
        end
        
        return
    end
    
    % data is in a class, struct, or table
    
    [searchFor, nameFromIdx] = how_to_deal_with(data);
    x = searchFor(data,'Longitude');
    y = searchFor(data,'Latitude');
    
    % assume parallel structure between x & y, so check x only and treat y accordingly
    
    if sum(x)==1
        % all is ok
    elseif ~any(x)
        x=searchFor(data,'Lon');
        y=searchFor(data,'Lat');
    end
    
    if ~any(x) || ~any(y)
        error('Feature %s Looking for data with a "Longitude" and "Latitude" fields', obj.Name); %#ok<MCSUP>
    elseif sum(x)>1 || sum(y)>1
        error('Feature %s Found too many "Longitude"-ish and "Latitude"-ish fields', obj.Name); %#ok<MCSUP>
    end
    
    lon_field = nameFromIdx(x);
    lat_field = nameFromIdx(y);
    
    d = searchFor(data,'Depth');
    el = searchFor(data,'Elev');
    
    if any(d)
        dep_field = nameFromIdx(d);
        value.Longitude = [data.(lon_field)];
        value.Latitude = [data.(lat_field)];
        value.Depth = [data.(dep_field)];
    elseif any(el)
        dep_field = nameFromIdx(el);
        value.Longitude = [data.(lon_field)];
        value.Latitude = [data.(lat_field)];
        value.Depth = -[data.(dep_field)];
    else
        value.Longitude = [data.(lon_field)];
        value.Latitude = [data.(lat_field)];
        value.Depth = zeros(size(value.Latitude));
    end
    
    value.Longitude = value.Longitude(:);
    value.Latitude = value.Latitude(:);
    value.Depth = value.Depth(:);
    
    nm = searchFor(data,'Name');
    if any(nm)
        value.Names = data.(nameFromIdx(nm));
    end
    %{
            switch class(data)
                case 'ZmapCatalog'
                    obj.Value = data;  %sets Latitude, Longitude, and Depth
                case {'table'}
                    x=startsWith(data.Properties.VariableNames,'Longitude','IgnoreCase',true);
                    y=startsWith(data.Properties.VariableNames,'Latitude','IgnoreCase',true);
                    
                    % assume parallel structure between x & y, so check x only and treat y accordingly
                    if numel(find(x))==1
                        %all ok
                    elseif ~any(x)
                        x=startsWith(data.Properties.VariableNames,'Lon','IgnoreCase',true);
                        y=startsWith(data.Properties.VariableNames,'Lat','IgnoreCase',true);
                        if ~any(x) || ~any(y)
                            error('Feature %s Looking for data with a "Longitude" and "Latitude" fields', obj.Name); %#ok<MCSUP>
                        end
                    else
                        error('Feature %s Found too many "Longitude"-ish and "Latitude"-ish fields', obj.Name); %#ok<MCSUP>
                    end
                    lon_field=data.Properties.VariableNames{x};
                    lat_field=data.Properties.VariableNames{y};
                    
                    d=startsWith(data.Properties.VariableNames,'Depth','IgnoreCase',true);
                    el = startsWith(data.Properties.VariableNames,'Elev','IgnoreCase',true);
                    
                    if any(d)
                        dep_field=data.Properties.VariableNames{d}; %prefer depth
                        obj.Value = struct('Longitude',data.(lon_field)(:) , ...
                            'Latitude', data.(lat_field)(:),...
                            'Depth',data.(dep_field)(:));
                    elseif any(el)
                        dep_field= data.Properties.VariableNames{el}; %settle for eleveation
                        obj.Value = struct('Longitude',data.(lon_field)(:) , ...
                            'Latitude', data.(lat_field)(:),...
                            'Depth',-data.(dep_field)(:));
                    else
                        obj.Value = struct('Longitude',data.(lon_field)(:) , ... or zeros
                            'Latitude', data.(lat_field)(:),...
                            'Depth',zeros(size(data.(lon_field)(:))));
                    end
                    
                    nm=startsWith(data.Properties.VariableNames,'Name','IgnoreCase',true);
                    if any(nm)
                        nmfield=data.Properties.VariableNames{nm};
                        obj.Value.Names=data.(nmfield)(:);
                    end
                    
                case {'struct'}
                    fn = fieldnames(data);
                    x=startsWith(fn,'Longitude','IgnoreCase',true);
                    y=startsWith(fn,'Latitude','IgnoreCase',true);
                    d=startsWith(fn,'Depth','IgnoreCase',true);
                    el=startsWith(fn,'Elev','IgnoreCase',true);
                    nm=startsWith(fn,'Name','IgnoreCase',true);
                    % assume parallel structure between x & y, so check x only and treat y accordingly
                    if numel(find(x))==1
                        %all ok
                    elseif ~any(x)
                        x=startsWith(fn,'Lon','IgnoreCase',true);
                        y=startsWith(fn,'Lat','IgnoreCase',true);
                        if ~any(x) || ~any(y)
                            error('Feature %s Looking for data with a "Longitude" and "Latitude" fields', obj.Name); %#ok<MCSUP>
                        end
                    else
                        error('Feature %s Found too many "Longitude"-ish and "Latitude"-ish fields', obj.Name); %#ok<MCSUP>
                    end
                    lon_field=fn{x};
                    lat_field=fn{y};
                    
                    obj.Value = struct('Longitude',[data.(lon_field)] , 'Latitude', [data.(lat_field)]);
                    obj.Value.Longitude=obj.Value.Longitude(:);
                    obj.Value.Latitude=obj.Value.Latitude(:);
                    
                    if any(d)
                        dep_field=fn{d};
                        obj.Value.Depth = [data.(dep_field)];
                        obj.Value.Depth=obj.Value.Depth(:);
                    elseif ~isempty(el)
                        dep_field=fn{el};
                        obj.Value.Depth = -[data.(dep_field)];
                        obj.Value.Depth=obj.Value.Depth(:);
                    end
                    if any(nm)
                        if iscell([data.(fn{nm})])
                            obj.Value.Names=data.(fn{nm});
                        else
                            obj.Value.Names={data.(fn{nm})};
                        end
                        obj.Value.Names=obj.Value.Names(:);
                    end
                    
                otherwise
                    obj.Value=struct('Longitude',[],'Latitude',[]);
                    if isnumeric(data)
                        if isempty(data)
                            obj.Value=struct('Longitude',[],'Latitude',[]);
                        elseif size(data,2) == 2
                            % assume longitude in first column
                            if max(abs(data(:,2))) > 90.000001
                                error('Feature "%s" expected latitudes in second column',obj.Name); %#ok<MCSUP>
                            end
                            if max(abs(data(:,1))) > 180.000001
                                
                                error('Feature "%s" expected longitudes in -180 to 180 range [%f]',obj.Name, max(abs(data(:,1)))); %#ok<MCSUP>
                            end
                            obj.Value = struct('Longitude', data(:,1), 'Latitude', data(:,2));
                        else
                            error('Feature "%s" expected 2 columns of data, or something with Latitude and Longitude fields',obj.Name); %#ok<MCSUP>
                        end
                    end
                    
            end
    %}
    
end
