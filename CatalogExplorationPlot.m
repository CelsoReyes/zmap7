classdef CatalogExplorationPlot < handle
    % CATALOGEXPLORATIONPLOT create a plot where x,y,z,color, and size are modifiable
    properties
        x_by (1,:) char ='Latitude'
        y_by (1,:) char ='Longitude'
        z_by (1,:) char ='Depth'
        color_by (1,:) char =ZmapGlobal.Data.mainmap_plotby%'Date'
        size_by (1,:) char ='Magnitude'
        colorFcn function_handle = @datenum
        sizeFcn function_handle = @mag2dotsize
        catalogFcn function_handle;
        axes_choices cell = {};
        myscatter matlab.graphics.chart.primitive.Scatter;
        ax matlab.graphics.axis.Axes;
        conversions;
        curview;
        marker = ZmapGlobal.Data.event_marker;
    end
    methods
        
        function obj=CatalogExplorationPlot(ax, catalogFcn)
            % creates a plot with arbitrarily modifiable axes
            % obj=CATALOGEXPLORATIONPLOT(ax, catalogFcn)
            obj.catalogFcn=catalogFcn;
            obj.set_valid_axes_choices();
            obj.set_conversions();
            obj.ax=ax;
            c=ax.UIContextMenu;
            if isempty(c)
                c=uicontextmenu('Tag','catexplot');
                addLegendToggleContextMenuItem(c,'top','below');
                ax.UIContextMenu=c;
            else
                addLegendToggleContextMenuItem(c,'top','below');
            end
        end
        
        function scatter(obj, tag, varargin)
            % scatter plot with interactive axes
            c=obj.catalogFcn();
            x=c.(obj.x_by);
            y=c.(obj.y_by);
            z=c.(obj.z_by);
            s=c.(obj.size_by);
            s=obj.sizeFcn(s);
            if strcmp(obj.color_by,'-none-')
                cl=[0 0 0];
            else 
                cl=c.(obj.color_by);
                cl=obj.colorFcn(cl);
            end
            
            delete(findobj(obj.ax,'Tag',tag));
            obj.myscatter=scatter3(obj.ax,x, y, z, s, cl,'Marker',obj.marker,'Tag',tag);
            obj.myscatter.DisplayName=sprintf('size:%s\ncolor:%s',obj.size_by,obj.color_by);
            if isempty(obj.curview)
                view(obj.ax,2);
            else
                view(obj.ax,obj.curview);
            end
            %obj.myscatter.ZData=c.(obj.z_by);
            xl = xlabel(obj.x_by,'interpreter','none');
            obj.xContextMenu(xl, tag);
            yl = ylabel(obj.y_by,'interpreter','none');
            obj.yContextMenu(yl, tag);
            zl = zlabel(obj.z_by,'interpreter','none');
            obj.zContextMenu(zl, tag);
            obj.scatterContextMenu(obj.myscatter, tag);
            grid(obj.ax,'on');
            box(obj.ax,'on');
        end
        
        function update(obj, specific)
            % UPDATE updates the scatter plot, optionally changing only one axis (or color or size)
            %
            % obj.update() update all aspects of the scatter plot
            % 
            % obj.update( SPECIFIC ) updates only thes specific part of the plot, where SPECIFIC can
            % be 'x_by', 'y_by', 'z_by', 'size_by', 'sin
            % 
            c=obj.catalogFcn();
            [obj.curview(1), obj.curview(2)] = view(obj.ax);
            if ~exist('specific','var')
                set( obj.myscatter,...
                    'XData',c.(obj.x_by),...
                    'YData',c.(obj.y_by),...
                    'ZData',c.(obj.z_by),...
                    'SizeData',obj.sizeFcn(c.(obj.size_by)),...
                    'CData',obj.colorFcn(c.(obj.color_by))...
                    );
            else
                switch specific
                    case 'x_by'
                        doit('XAxis','XData', obj.x_by);
                    case 'y_by'
                        doit('YAxis','YData', obj.y_by);
                    case 'z_by'
                        doit('ZAxis','ZData', obj.z_by);
                    case 'size_by'
                        switch obj.size_by
                            case 'Single Size'
                                set(obj.myscatter,'SizeData',obj.sizeFcn(1));
                            otherwise
                                set(obj.myscatter,'SizeData',obj.sizeFcn(c.(obj.size_by)));
                        end
                    case 'color_by'
                        switch obj.color_by
                            case '-none-'
                                set(obj.myscatter,'CData',obj.colorFcn(1));
                            otherwise
                                set(obj.myscatter,'CData',obj.colorFcn(c.(obj.color_by)));
                        end
                        
                end
            end
            
            function doit(axAx, where, fld)
                % doit(axAx, where, fld) poor name.
                % axAx: 'XAxis', etc...
                % where: 'XData', etc...
                % fld: 'Longitude', etc... which is the result of obj.x_by, etc...
                axisH = obj.ax.(axAx);
                DateTimeRulerClass='matlab.graphics.axis.decorator.DatetimeRuler';
                DurationRulerClass='matlab.graphics.axis.decorator.DurationRuler';
               % NumericRulerClass='matlab.graphics.axis.decorator.NumericRuler';
                
                %cur_name = axisH.Label.String;
                %cur_context = axisH.Label.UIContextMenu;
                
                if isa(c.(fld), 'datetime') && ~isa(axisH,DateTimeRulerClass)
                    
                    obj.myscatter.(where) = years(c.(fld) - datetime(0,0,0,0,0,0,0));
                    
                elseif isa(c.(fld), 'duration') && ~isa(axisH,DurationRulerClass)
                    % convert durations to a numbers depending on max duration
                    [obj.myscatter.(where), axisH.Label.String] = duration2numbers(c.(fld));
                    enforce_linear_scale_if_necessary();
                    
                elseif islogical(c.(fld))
                    % plot as 1 and 0
                    obj.myscatter.(where) = double(c.(fld));
                elseif iscell(c.(fld))
                    warndlg(['These data [' fld '] are stored in cells, and are therefore not plottable']);
                    obj.myscatter.(where) = nan(size(c.(fld)));
                else
                    
                    % if any value is less than 0, cannot use a log scale plot.
                    enforce_linear_scale_if_necessary();
                    obj.myscatter.(where) = c.(fld);
                    
                end
                function enforce_linear_scale_if_necessary()
                    xyzscale=[where(1) 'Scale'];
                    if iscell(c.(fld))
                        beep;
                        obj.ax.(xyzscale)='linear';
                    elseif any(c.(fld)<=0) && strcmp(obj.ax.(xyzscale),'log')
                        beep;
                        disp(['enforcing linear ' xyzscale ' because of negative values']);
                        obj.ax.(xyzscale)='linear';
                    end
                end
                
                function [n, scalename] = duration2numbers(d)
                    % put the duration on a reasonable scale
                    persistent logic
                    if isempty(logicparts)
                        % do change how durations are displayed, change this table
                        logictable={... scalename , converterFcn , minValue
                            'years', @years, years(4);
                            'months',@months, months(6);
                            'days',  @days, days(5);
                            'hours', @hours, hours(3);
                            'minutes', @minutes, minutes(2);
                            'seconds', @seconds, seconds(-inf)};
                        
                        logic = cell2struct(logictable,{'name','fn','minval'},2);
                    end
                    idx = 1;
                    mymax = max(d);
                    
                    % min_dur gives us the minimum duration value based on the index
                    
                    while mymax < logic(idx).minval
                        idx = idx + 1;
                    end
                    
                    scalename = logic(idx).name;
                    n = logic(idx).fn(d);
                end
                
            end % DOIT
        end
    end
    methods(Hidden)
        
        function set_valid_axes_choices(obj)
            c=obj.catalogFcn();
            p = properties(c);
            usable=true(size(p));
            nEvents=  c.Count;
            for i=1:numel(p)
                try
                    usable(i)=length(c.(p{i}))==nEvents;
                catch
                    usable(i)=false;
                end
                try
                     if all(isnan(c.(p{i})))
                         usable(i)=false;
                     end
                end
            end
            obj.axes_choices=p(usable);
        end
        
        function set_conversions(obj)
            for j=1:numel(obj.axes_choices)
                ch=obj.axes_choices{j};
            end
            
        end
        function xContextMenu(obj,xl, tag)
            h=uicontextmenu('Tag',['xsel_ctxt ' tag]);
            checkmask = strcmp(obj.axes_choices, obj.x_by);
            for i=1:numel(obj.axes_choices)
                uimenu(h,'Label',obj.axes_choices{i},'Checked',tf2onoff(checkmask(i)),...
                    Futures.MenuSelectedFcn,{@obj.change,'x_by'});
            end
            obj.add_axes_toggles(h,'X');
            xl.UIContextMenu=h;
        end
        
        function yContextMenu(obj,yl, tag)
            h=uicontextmenu('Tag',['ysel_ctxt ' tag]);
            checkmask = strcmp(obj.axes_choices, obj.y_by);
            for i=1:numel(obj.axes_choices)
                uimenu(h,'Label',obj.axes_choices{i},'Checked',tf2onoff(checkmask(i)),...
                    Futures.MenuSelectedFcn,{@obj.change,'y_by'});
            end
            obj.add_axes_toggles(h,'Y');
            yl.UIContextMenu=h;
        end
        
        function zContextMenu(obj,zl,tag)
            h=uicontextmenu('Tag',['zsel_ctxt ' tag]);
            checkmask = strcmp(obj.axes_choices, obj.z_by);
            for i=1:numel(obj.axes_choices)
                uimenu(h,'Label',obj.axes_choices{i},'Checked',tf2onoff(checkmask(i)),...
                    Futures.MenuSelectedFcn,{@obj.change,'z_by'});
            end
            obj.add_axes_toggles(h,'Z');
            zl.UIContextMenu=h;
        end
        
        function scatterContextMenu(obj,sc,tag)
            tag=['ssel_ctxt ' tag];
            delete(findobj(gcf,'Tag','tag'));
            h=uicontextmenu('Tag',tag);
            szm = uimenu(h,'Label','Size by...',...
                Futures.MenuSelectedFcn,{@obj.cleanChildren_cb,'size_by'});
            clm = uimenu(h,'Label','Color by...',...
                Futures.MenuSelectedFcn,{@obj.cleanChildren_cb,'color_by'});
            obj.sizeContextMenu(szm);
            obj.colorContextMenu(clm);
            sc.UIContextMenu=h;
        end
        function cleanChildren_cb(obj,src,ev,bywhat)
            m=findobj(src.Children,'Type','uimenu');
            labels = get(m,'Label');
            ison = strcmp(get(m,'Checked'),'on');
            isoff = ~ison;
            checkmask = strcmp(labels, obj.(bywhat));
            disp(labels{checkmask})
            set(m(~checkmask & ison),'Checked','off');
            set(m(checkmask & isoff),'Checked','on');
        end

        function sizeContextMenu(obj,h)
            for i=1:numel(obj.axes_choices)
                uimenu(h,'Label',obj.axes_choices{i},Futures.MenuSelectedFcn,@obj.changeSize);
            end
            uimenu(h,'Separator','on','Label','Single Size',Futures.MenuSelectedFcn,@obj.changeSize);
            
        end
        
        function colorContextMenu(obj,h)
            for i=1:numel(obj.axes_choices)
                uimenu(h,'Label',obj.axes_choices{i},Futures.MenuSelectedFcn,@obj.changeColor);
            end
            uimenu(h,'Separator','on','Label','-none-',Futures.MenuSelectedFcn,@obj.changeColor);
        end
        
        function add_axes_toggles(obj,h,letter)
            uimenu(h,'Label','Flip axes direction','Separator','on',...
                Futures.MenuSelectedFcn,@(src,~)cb_axisdir(letter));
            uimenu(h,'Label','Toggle Log/Linear scale','Separator','on',...
                Futures.MenuSelectedFcn,@(src,~)cb_axisscale(letter));
            
            function cb_axisdir(letter)
                dirs={'normal','reverse'};
                prop=[letter 'Dir'];
                dirs(strcmp(obj.ax.(prop),dirs))=[];
                obj.ax.(prop) = dirs{1};
            end
            
            function cb_axisscale(letter)
                scales={'linear','log'};
                prop=[letter 'Scale'];
                
                scales(strcmp(obj.ax.(prop),scales))=[];
                
                % if any data is non-positive, axes must remain linear
                if any(obj.myscatter.([letter 'Data']) <=0) && strcmp(scales{1},'log')
                    beep
                    disp(['enforcing linear ' prop ' because of negative values'])
                    obj.ax.(prop) = 'linear'; 
                else
                    obj.ax.(prop) = scales{1};
                end
            end
        end
        function change(obj,src,~,whatby)
            % whatby is x_by, y_by, etc...
            
            % remove checkmarks
            set(src.Parent.Children,'Checked','off');
            
            % change the plotting value
            obj.(whatby) = src.Label;
            
            % add new checkmark
            src.Checked='on';
            
            % relabel
            obj.ax.([upper(whatby(1)), 'Label']).String=src.Label;
            %h.String=src.Label;
            
            %replot
            obj.update(whatby);
        end
        
        function changeSize(obj,src,~)
            % whatby is x_by, y_by, etc...
            
            
            % change the plotting value
            obj.size_by= src.Label;
            
            % relabel
            set(gco,'DisplayName',sprintf('size:%s\ncolor:%s', obj.size_by, obj.color_by));
            switch(obj.size_by)
                case 'Date'
                    obj.sizeFcn=@(x) normalize(x,2,8,@(x)x.^2 );
                case 'Magnitude'
                    obj.sizeFcn=@mag2dotsize;
                case 'Single Size'
                    sz=num2str(round(mode(obj.myscatter.SizeData)));
                    val = str2double(inputdlg('Choose Marker Size','',1,{sz}));
                    if ~isempty(val) && ~isnan(val)
                        obj.sizeFcn=@(x)val;
                    end
                otherwise
                    obj.sizeFcn=@(x) normalize(x,2,8,@(x)x.^2);
            end
            %replot
            obj.update('size_by');
            
            function x=normalize(x, minval, scalar, modifier)
                if isa(x,'datetime')
                    x=x - min(x); % now duration
                end
                if isa(x,'duration')
                    x=days(x);
                end
                x = (x-min(x)) ./ range(x);
                x = modifier(x .* scalar + minval);
            end
            
        end
        function changeColor(obj,src,~)
            % whatby is x_by, y_by, etc...
            
            % remove checkmarks
            set(src.Parent.Children,'Checked','off');
            
            % change the plotting value
            obj.color_by = src.Label;
            
            % add new checkmark
            src.Checked='on';
            
            % relabel
            set(gco,'DisplayName',sprintf('size:%s\ncolor:%s',obj.size_by,obj.color_by));
            %h.String=src.Label;
            
            switch(obj.color_by)
                case 'Date'
                    obj.colorFcn=@datenum;
                case '-none-'
                    val=uisetcolor();
                    obj.colorFcn=@(x)val;
                otherwise
                    obj.colorFcn=@(x) normalize(x, 0, 1,@(x)x);
            end
            
            function x=normalize(x, minval, scalar, modifier)
                if isa(x,'datetime')
                    x=x - min(x); % now duration
                end
                if isa(x,'duration')
                    x=days(x);
                end
                x = (x-min(x)) / range(x);
                x = modifier(x.* scalar + minval);
            end
            %replot
            obj.update('color_by');
        end
    end % HIDDEN methods
end