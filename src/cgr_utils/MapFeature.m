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
    % ylim(ax1,[min(ZG.a.Latitude) max(ZG.a.Latitude)])
    % xlim(ax1,[min(ZG.a.Longitude) max(ZG.a.Longitude)])
    % title(ax1,'normal plot')
    %
    % % PLOT FEATURE ON "MAP" PLOT AXES
    % % - SET UP THE AXES
    % ax2=subplot(1,2,2);
    % ax2m=axesm('lambert','MapLatLimit',[min(ZG.a.Latitude) max(ZG.a.Latitude)],'MapLonLimit',[min(ZG.a.Longitude) max(ZG.a.Longitude)]);
    % setm(ax2m,'MLineLocation',.25, 'PLineLocation',.25); % degrees for grid lines
    % setm(ax2m,'Grid','on')
    % setm(ax2m,'MeridianLabel','on','ParallelLabel','on')
    % setm(ax2m,'PLabelLocation',.5,'MLabelLocation',.5)  % degrees for labeling
    % setm(ax2m,'LabelFormat','signed','LabelUnits','dms') % display as +7˚ 00' 00"
    % title(ax2m,'lambert plot')
    %
    % lakes.plot(ax2m) % plot into map
    % lakes.plot(ax1) % plot onto "normal" axes

    properties
        Name                % name of this feature
        Loadfn              % function used to load/import this feature's data
        Savefn              % function used to save/export this feature's data
        PlottingDefaults    % properties used on this layer
        Value               % raw values to plot, as struct, class, or Table containing a "Longitude" and "Latitude" field
        ParentAxis          % handle to a parent axis. assigned when this is plotted
        MenuToggle          % handle to the uimenu used to show/hide this layer
    end
    properties(Dependent)
        Handle              % handle to this layer
        Longitude           % vector of Longitudes [deg] (to be plotted on X)
        Latitude            % vector of Latitudes [deg] (to be plotted on Y)
        Depth               % vector of Depths [km] (to be plotted on -Z)
    end
    
    methods
        function obj= MapFeature(name, load_fn, save_fn, plot_defaults)
            % create a MapFeature
            assert(isfield(plot_defaults,'Tag'));
            obj.Name = name;
            obj.Loadfn = load_fn;
            obj.Savefn = save_fn;
            obj.PlottingDefaults = plot_defaults;
            %obj.Value = load_fn();
        end
        
        function h =get.Handle(obj)
            % get.Handle get the handle to this feature's layer
            % if this layer hasn't been plotted yet, or has been deleted, then
            % this returns []
            
            % make sure Parent Axis is still valid
            if ~isempty(obj.ParentAxis) && ~isvalid(obj.ParentAxis)
                obj.ParentAxis = [];
            end
            
            if ~isempty(obj.ParentAxis)
                h = findobj(obj.ParentAxis, 'Tag', obj.PlottingDefaults.Tag);
            else
                error('This feature %s is not associated with a valid parent',obj.Name);
                % h = findobj(groot, 'Tag', obj.PlottingDefaults.Tag);
            end
        end
        
        function set.Value(obj, data)
            % set.Value does the painful work of importing data form a variety of data types
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
                    
                    obj.Value = struct('Longitude',data.(lon_field)(:) , 'Latitude', data.(lat_field)(:));
                case {'struct'}
                    fn = fieldnames(data);
                    x=startsWith(fn,'Longitude','IgnoreCase',true);
                    y=startsWith(fn,'Latitude','IgnoreCase',true);
                    
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
        
        function layer=plot(obj,ax)
            % plot this layer
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
            
            holdstatus = ishold(ax); hold(ax,'on');
            
            val = obj.getTrimmedData();
            layer=plot(ax,val.Longitude, val.Latitude);
            layer.ZData = val.Depth;
            
            if ~holdstatus; hold(ax,'off'); end
            
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
            
            holdstatus = ishold(ax); hold(ax,'on');
            
            val = obj.getTrimmedData();
            layer=plotm(val.Latitude, val.Longitude); %not allowed to specify axes
            zdatam(layer, val.Depth);
            daspectm('km');
            if ~holdstatus; hold(ax,'off'); end
            
            % set properties for this layer
            setm(layer, obj.PlottingDefaults);
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
            obj.Value = obj.Loadfn(varargin{:});
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
        
        
        function addToggleMenu(obj, parentH)
            % addToggleMenu add menu that hides/shows this Feature
            % addToggleMenu(parent) adds a toggle menu subordinate to the parent uimenu
            
            if ~isempty(obj.MenuToggle) && isvalid(obj.MenuToggle)
                error('ToggleMenu for Feature "%s" already exists.',obj.Name);
            end
            
            obj.MenuToggle = uimenu(parentH,...
                'Label',['Hide ' obj.Name],...
                'Callback',@(src,ev) obj.toggle_showhide_menu(src,ev));
        end
        function toggle_showhide_menu(obj, src, ~, contingencyFunction)
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
                h=findobj(parentFigure(src),'Tag', obj.PlottingDefaults.Tag);
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
    end
    
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
            
            % replace out-of-bounds values with NaN
            val.Longitude(~idx) = nan;
            val.Latitude(~idx) = nan;
            val.Depth(~idx)=nan;
            
            % reduce dataset by removing all nan's EXCEPT for one (per gap)
            val.Longitude(todel) = [];
            val.Latitude(todel) = [];
            val.Depth(todel)=[];
        end
        
    end
    
end


