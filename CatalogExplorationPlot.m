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
        myscatter;
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
            if obj.color_by == "-none-"
                cl=[0 0 0];
            else
                cl=c.(obj.color_by);
                cl=obj.colorFcn(cl);
            end
            % delete(findobj(obj.ax,'Tag',tag));
            if isempty(obj.myscatter)
                obj.myscatter=scatter3(obj.ax,x, y, z, s, cl,'Marker',obj.marker,'Tag',tag);
                obj.myscatter.DisplayName=sprintf('size:%s\ncolor:%s',obj.size_by,obj.color_by);
                grid(obj.ax,'on');
                box(obj.ax,'on');
                fig=ancestor(obj.ax,'figure');
                xl = xlabel(obj.x_by,'interpreter','none');
                yl = ylabel(obj.y_by,'interpreter','none');
                zl = zlabel(obj.z_by,'interpreter','none');
                obj.xContextMenu(xl, tag, fig);
                obj.yContextMenu(yl, tag, fig);
                obj.zContextMenu(zl, tag, fig);
                obj.scatterContextMenu(obj.myscatter, tag);
                obj.ax.UserData.cep = obj;
            else
                obj.ax.NextPlot='replace';
                obj.myscatter.XData=x;
                obj.myscatter.YData=y;
                obj.myscatter.ZData=z;
                obj.myscatter.SizeData=s;
                obj.myscatter.CData=cl;
                obj.myscatter.DisplayName=sprintf('size:%s\ncolor:%s',obj.size_by,obj.color_by);
            end
            if isempty(obj.curview)
                view(obj.ax,2);
            else
                view(obj.ax,obj.curview);
            end
            
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
                switch obj.color_by
                    case '-none-'
                        cdata=obj.colorFcn(1);
                        if ~isequal(size(cdata),[1,3])
                            cdata = [0 0 0];
                        end
                    otherwise
                        cdata= obj.colorFcn(c.(obj.color_by));
                end
                switch obj.size_by
                    case 'Single Size'
                        sdata=obj.sizeFcn(1);
                    otherwise
                        sdata=obj.sizeFcn(c.(obj.size_by));
                end
                set( obj.myscatter,...
                    'XData', c.(obj.x_by),...
                    'YData', c.(obj.y_by),...
                    'ZData', c.(obj.z_by),...
                    'SizeData',sdata,...
                    'CData',cdata...
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
            %{
            function val = use_correct_ruler(obj, axisName, val)
                switch class(val)
                    case 'datetime'
                        if ~isa(obj.ax.(axisName),'matlab.graphics.axis.decorator.DatetimeRuler')
                            set(obj.ax, axisName, matlab.graphics.axis.decorator.DatetimeRuler);
                        end
                    case 'duration'
                        if ~isa(obj.ax.(axisName),'matlab.graphics.axis.decorator.DurationRuler')
                            set(obj.ax, axisName, matlab.graphics.axis.decorator.DurationRuler);
                        end
                    case 'categorical'
                        if ~isa(obj.ax.(axisName),'matlab.graphics.axis.decorator.CategoricalRuler')
                            set(obj.ax, axisName, matlab.graphics.axis.decorator.CategoricalRuler);
                        end
                    otherwise % numeric
                        if ~isa(obj.ax.(axisName),'matlab.graphics.axis.decorator.NumericRuler')
                            set(obj.ax, axisName, matlab.graphics.axis.decorator.NumericRuler);
                        end
                end
            end
            %}
            function doit(axAx, where, fld)
                % doit(axAx, where, fld) poor name.
                % axAx: 'XAxis', etc...
                % where: 'XData', etc...
                % fld: 'Longitude', etc... which is the result of obj.x_by, etc...
                % axisH = obj.ax.(axAx);
                    enforce_linear_scale_if_necessary();
                    try
                        obj.myscatter.(where) = c.(fld);
                        axruler=obj.ax.(axAx);
                        assert(...
                            (isnumeric(c.fld) &&  isa(axruler,'matlab.graphics.axis.decorator.NumericRuler')) || ...
                            (isdatetime(c.fld) && isa(axruler,'matlab.graphics.axis.decorator.DatetimeRuler')) || ...
                            (iscategorical(c.fld) && isa(axruler,'matlab.graphics.axis.decorator.CategoricalRuler')) ||...
                            (isduration(c.fld) && isa(axruler,'matlab.graphics.axis.decorator.DurationRuler'))...
                            );
                        
                    catch
                        % unable to reuse existing axes rulers. Since they are read-only, we'll have
                        % to recreate.  However, first stash some information that will be lost, so
                        % that the figure appears to only change instead of being recreated.
                        
                        % what is this scatter plot called again?
                        t=obj.myscatter.Tag;
                        ttl=get(obj.ax.Title);
                        % what is the state of the legend?
                        reshowLegend= ~isempty(obj.ax.Legend) && obj.ax.Legend.Visible =="on";
                        if reshowLegend
                            legendLocation = obj.ax.Legend.Location;
                        end
                        
                        % recreate the axes and scatter plot
                        cla(obj.ax);
                        obj.myscatter=[];
                        obj.scatter(t);
                        
                        obj.ax.Title.String=ttl.String;
                        obj.ax.Title.Color=ttl.Color;
                        obj.ax.Title.FontSize=ttl.FontSize;
                        obj.ax.Title.FontName=ttl.FontName;
                        obj.ax.Title.FontWeight=ttl.FontWeight;
                        
                        % restore the legend
                        if reshowLegend
                            legend(obj.ax,'show','Location',legendLocation);
                        end
                    end
                        
                        
                    
                %end
                
                function enforce_linear_scale_if_necessary()
                    xyzscale=[where(1) 'Scale'];
                    if obj.ax.(xyzscale)=="linear"
                        return
                    end

                    if iscell(c.(fld)) || iscategorical(c.(fld))
                        beep;
                        disp(['enforcing linear ' xyzscale ' because of data type']); 
                        obj.ax.(xyzscale)='linear';
                    elseif isnumeric(c.(fld))&&any(c.(fld)<=0) && obj.ax.(xyzscale) == "log"
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
        
        function updateCheckedStatus(obj,h, checkmask)
            labels = {h.Children.Label};
            choices=string(obj.axes_choices);
            for j=1:numel(h.Children)
                whichChoice = labels(j) == choices;
                set(h.Children(whichChoice), 'Checked', tf2onoff(checkmask(whichChoice)) );
            end
        end
        
        function xContextMenu(obj,xl, tag, fig)
            %delete(findobj(ancestor(ax),['xsel_ctxt' tag]));
            h=xl.UIContextMenu;
            checkmask = strcmp(obj.axes_choices, obj.x_by);
            if isempty(h)
                mytag = ['xsel_ctxt ' tag];
                delete(findobj(fig,'Type','uicontextmenu','-and','Tag',mytag));
                h=uicontextmenu('Tag',mytag);
                for i=1:numel(obj.axes_choices)
                    uimenu(h,'Label',obj.axes_choices{i}, Futures.MenuSelectedFcn,{@obj.change,'x_by'});
                end
                obj.add_axes_toggles(h,'X');
                xl.UIContextMenu=h;
            end
            obj.updateCheckedStatus(h, checkmask);
        end
        
        function yContextMenu(obj,yl,tag, fig)
            h=yl.UIContextMenu;
            checkmask = strcmp(obj.axes_choices, obj.y_by);
            if isempty(h)
                mytag = ['ysel_ctxt ' tag];
                delete(findobj(fig,'Type','uicontextmenu','-and','Tag',mytag));
                h=uicontextmenu('Tag',mytag);
                for i=1:numel(obj.axes_choices)
                    uimenu(h,'Label',obj.axes_choices{i},Futures.MenuSelectedFcn,{@obj.change,'y_by'});
                end
                obj.add_axes_toggles(h,'Y');
                yl.UIContextMenu=h;
            end
            obj.updateCheckedStatus(h, checkmask);
        end
        
        function zContextMenu(obj,zl,tag, fig)
            h=zl.UIContextMenu;
            checkmask = strcmp(obj.axes_choices, obj.z_by);
            if isempty(h)
                mytag = ['zsel_ctxt ' tag];
                delete(findobj(fig,'Type','uicontextmenu','-and','Tag',mytag));
                h=uicontextmenu('Tag',mytag);
                for i=1:numel(obj.axes_choices)
                    uimenu(h,'Label',obj.axes_choices{i}, Futures.MenuSelectedFcn,{@obj.change,'z_by'});
                end
                obj.add_axes_toggles(h,'Z');
                zl.UIContextMenu=h;
            end
            obj.updateCheckedStatus(h, checkmask);
        end
        
        function scatterContextMenu(obj,sc,tag)
            tag=['ssel_ctxt ' tag];
            f = ancestor(obj.ax,'figure');
            delete(findobj(f,'Tag',tag));
            h=uicontextmenu(f,'Tag',tag);
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
            ison = get(m,'Checked') == "on";
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
                if any(obj.myscatter.([letter 'Data']) <=0) && scales{1} == "log"
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
    
    methods (Static)
        function s=instructions(varargin)
            % Explore your data in 4-5 dimensions by choosing a parameter for each axis.
            % Right-click on the X, Y, or Z axes for a list of available variables.
            % Right-click on data points to choose how they will be sized or colored.
            helpwin('CatalogExplorationPlot.instructions');
        end
    end
end