classdef MapFeature < handle
    %MapFeature Summary of this class goes here
    %   Detailed explanation goes here
    
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
        Longitude
        Latitude
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
            switch class(data)
                case 'ZmapCatalog'
                    obj.Value = data;
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
                    
                    obj.Value = struct('Longitude',data.(lon_field)(:) , 'Latitude', data.(lat_field)(:));
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
        
        function plot(obj,ax)
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
            
            if ~holdstatus; hold(ax,'off'); end
            
            % set properties for this layer
            set(layer, obj.PlottingDefaults);
        end
        
        function refreshPlot(obj)
            % refreshPlot updates the X,Y values without deleting the layer
            %
            % refreshPlot useful for when the axis limits have changed or
            % when the values have changed
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
            set(layer,obj.PlottingDefaults);
        end
        
        function load(obj)
            % load this feature
            % uses the Loadfn provided during Feature Construction
            obj.Value = obj.Loadfn();
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
        
        
        
        function val = getTrimmedData(obj)
            % trim data to parent axis limits
            % obj.getTrimmedData()
            %
            % gaps where data was removed are replaced with a single "nan" value
            % this reduces the data size, and keeps segments from connecting when
            % they shouldn't.
            
            ax = obj.ParentAxis;
            idx  = obj.Value.Longitude >= min(xlim(ax)) & obj.Value.Longitude <= max(xlim(ax));
            idx = idx & obj.Value.Latitude >= min(ylim(ax)) & obj.Value.Latitude <= max(ylim(ax));
            val=obj.Value;
            todel = [false; ~idx(1:end-1)] & [false; ~idx(2:end)];
            val.Longitude(~idx) = nan;
            val.Latitude(~idx) = nan;
            val.Longitude(todel) = [];
            val.Latitude(todel) = [];
        end
        
        function addToggleMenu(obj, parentH)
            % addToggleMenu add menu that hides/shows this Feature
            % addToggleMenu(parent) adds a toggle menu subordinate to the parent item
            
            if ~isempty(obj.MenuToggle) && isvalid(obj.MenuToggle)
                error('ToggleMenu for Feature "%s" already exists.',obj.Name);
            end
            
            obj.MenuToggle = uimenu(parentH,...
                'Label',['Hide ' obj.Name],...
                'Callback',@(src,ev) obj.toggle_showhide_menu(src,ev));
        end
        function toggle_showhide_menu(obj, src, ~, contingencyFunction)
            h=obj.Handle;
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
        end
    end
    
end


