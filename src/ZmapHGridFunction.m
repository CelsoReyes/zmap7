classdef ZmapHGridFunction < ZmapGridFunction
    % ZMAPHGRIDFUNCTION is a ZmapFunction that produces a grid of results plottable on map (horiz slice)
    %
    % see also ZMAPGRIDFUNCTION
    
    properties(SetObservable, AbortSet)
        features cell ={'borders'}; % features to show on the map, such as 'borders','lakes','coast',etc.
        
        showRing        = false;
        showPointValue	= false;
        showTable       = true;
        showResultPlots = true;
        
        nearestSample   = 0;         % current index (where user clicked) within the result table
        lastPoint       = [nan nan]; % x, y of click
        nearestSamplePos= [nan nan]; % x, y of measurement
    end
    
    properties
        isUpdating
    end
    
    properties(Constant)
        % The results can be explored  also by pressing keys. This creates the mapping
        % between the keys and actions
        KeyMap = struct(...
            'ToggleRadiusRing', 'r',...
            'ShowValue', 'T',...
            'ShowValueNoNan', 't',...
            'TogglePointValue', 'v',...
            'KeyHelp','?'...
            );
        Type='XY';
    end
    
    properties(Dependent)
        resultsForThisPoint
        resultsForThisPointNoNan
        selectionForThisPoint
        catalogForThisPoint
        colorForThisPoint
    end
    
    methods
        
        function obj=ZmapHGridFunction(varargin)
            obj@ZmapGridFunction(varargin{:});
            obj.addlistener('nearestSample','PostSet', @obj.update);
        end
        
        function tb = get.resultsForThisPoint(obj)
            if obj.nearestSample
                tb = obj.Result.values(obj.nearestSample,:);
            else
                tb=obj.Result.values([],:);
            end
        end
        
        function tb = get.resultsForThisPointNoNan(obj)
            tb = obj.Result.values(obj.nearestSample,:);
            OK = ~cellfun(@(x)isnumeric(x)&&isnan(x),table2cell(tb));
            tb = tb(:,OK);
        end
        
        function mask = get.selectionForThisPoint(obj)
            tb = obj.resultsForThisPoint;
            if isempty(tb); mask=[];return; end
            % evsel = obj.EventSelector;
            dists = obj.RawCatalog.epicentralDistanceTo(tb.y,tb.x);
            mask = dists <= tb.RadiusKm;
            if sum(mask) > tb.Number_of_Events
                warning('Selection doesn''t exactly match results.')
            end
            
        end
        
        function c = get.catalogForThisPoint(obj)
            c=obj.RawCatalog.subset(obj.selectionForThisPoint);
        end
        
        
        function mycolor = get.colorForThisPoint(obj)
            % use the same color for the trend plot as is used for the results overlay
            cm=colormap(obj.ax);
            cl=obj.ax.CLim;
            lookup=linspace(min(cl), max(cl), length(cm));
            mycolorFn = @(v) cm(v>=lookup(1:end-1) & v<lookup(2:end),:);
            gr=findobj(obj.ax.Children,'flat','-regexp','Tag','.*[gG]rid.*');
            gridx = find(gr.XData==obj.nearestSamplePos(1) & gr.YData==obj.nearestSamplePos(2));
            mycolor = mycolorFn(gr.CData(gridx));
            
            if isempty(mycolor),mycolor=[0.4 0.4 0.4];end
        end
        
        
        %{
function showInTab(obj, ax, choice)
            % plots the results on the provided axes.
            
            if exist('choice','var')
                [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails(choice);
            else
                [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails();
            end
            
            ax.NextPlot='add';
            delete(findobj(ax,'Tag','result overlay'));
            
            % this is to show the data
            if islogical(obj.Result.values.(myname)(1))
                p=double(obj.Result.values.(myname));
                p(p==0)=nan;
                h=obj.Grid.pcolor(ax,p, mydesc);
            else
                h=obj.Grid.pcolor(ax,obj.Result.values.(myname), mydesc);
            end
            h.Tag = 'result overlay';
            shading(obj.ZG.shading_style);
            
            if isempty(findobj(gcf,'Tag','lookmenu'))
                add_menus(obj,choice);
            end
            
            update_layermenu(obj,myname, ax);
            
            mapdata_viewer(obj,obj.RawCatalog,findobj(gcf,'Tag','mainmap_ax'));
            ax.Title.String=sprintf('%s : [ %s ]',obj.RawCatalog.Name, mydesc);
            ax.Title.Interpreter='none';
        end
        %}
        function overlay(obj, resTab, choice)
            % plots the results in the provided Tab.
            % expects that tab is empty
            
            % no yet implemented:
            % Layer Situation
            %  TOP: grid points
            %       Earthquakes(?)
            %  MIDDLE: Contour
            %
            %  Bottom: Features
            %          Topographic stuff
            
            report_this_filefun();
            
            [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails(choice);
            
            tabGroup = resTab.Parent;
            
            ax=findobj(resTab,'Type','axes','-and','Tag','result_map');
            
            if isempty(ax)
                
                copyobj(findobj(tabGroup,'Tag','mainmap_ax'),resTab);
                ax=findobj(resTab,'Tag','mainmap_ax');
                ax.Tag='result_map';
                ax.Units='normalized';
                ax.Position=[0.025 0.05 .95 .90];
                set(findobj(ax,'Type','scatter'),'MarkerEdgeAlpha',0.4);
                lineobjs=findobj(ax,'Type','Line');
                for n=1:numel(lineobjs)
                    set(lineobjs(n),'Color', (lineobjs(n).Color + [3 3 3]) ./ 4);
                end
                hTopos=findobj(resTab,'-regexp','Tag','topographic_map_*');
                if ~isempty(hTopos)
                    % topography map needs to exist underneath plot
                    ax2=axes(resTab,'Position',ax.Position,'YLim',ax.YLim,'XLim',ax.XLim,...
                        'DataAspectRatio',ax.DataAspectRatio,...
                        'DataAspectRatioMode',ax.DataAspectRatioMode,...
                        'Tag','topo_underlay','Visible','off');
                    
                    set(hTopos,'Parent',ax2); % move topography over to new axes
                    linkaxes([ax ax2]);
                    linkprop([ax ax2],{'Position','DataAspectRatio','DataAspectRatioMode'});
                    
                    % modify colormap for topography
                    dc=demcmap([min(arrayfun(@(x)double(min(x.CData(:))),hTopos)),...
                        max(arrayfun(@(x)double(max(x.CData(:))),hTopos)) ]);
                    colormap(ax2, ((brighten(gray,0.8).*2 + brighten(dc,-0.5) )./ 3))
                    
                    % modify colormap for results
                    colormap(ax, colormap(ancestor(resTab,'figure')));
                    resTab.Children=circshift(resTab.Children,-1); %new axes must be below existing
                    ax.Color='none';
                    %ax2.Visible='off';
                end
            else
                ax=findobj(resTab,'Tag','result_map');
            end
            
            ax.NextPlot='add';
            delete(findobj(ax,'Tag','result overlay'));
            
            % delete existing grid points
            delete(findobj(ax,'-regexp','Tag','grid_\w.*'));
            
            % this is to show the data
            if islogical(obj.Result.values.(myname)(1))
                p=double(obj.Result.values.(myname));
                p(p==0)=nan;
                h=obj.Grid.pcolor(ax,p, mydesc);
            else
                [~,h]=obj.Grid.contourf(ax,obj.Result.values.(myname),mydesc, ZmapGlobal.Data.ResultOpts.NumContours);
                
            end
            ax.Children=circshift(ax.Children,-1); % move the contour to the bottom layer
            val = obj.Result.values.(myname);
            s = findobj(ax,'Tag',obj.Grid.Name);
            if isempty(s)
                s=scatter(ax,obj.Result.values.x,obj.Result.values.y,10,val,'+','Tag',obj.Grid.Name);
                s.MarkerFaceAlpha=[0.5];
            else
                if islogical(val)
                    val = double(val);
                end
                set(s,'XData',obj.Result.values.x,'YData',obj.Result.values.y,'CData',val);
            end
            
            h.Tag = 'result overlay';
            %shading(ax,obj.ZG.shading_style);
            
            if isempty(findobj(gcf,'Tag','lookmenu'))
                add_menus(obj,choice);
            end
            
            % add a menu to choose which layer / variable to examine
            c=findobj(gcf,'Type','uicontextmenu','-and','Tag',obj.PlotTag);
            delete(c); % avoid replotting old data.
            
            c=uicontextmenu('Tag',obj.PlotTag);
            resTab.UIContextMenu=c;
            
            update_layermenu(obj,myname, c);
            
            uimenu(c,'Separator','on','Label','Close tab',...
                MenuSelectedField(),@(~,~)delete(resTab));
            % mapdata_viewer(obj,obj.RawCatalog,ax);
            title(ax,sprintf('%s : [ %s ]',obj.RawCatalog.Name, mydesc), 'Interpreter', 'None');
            % shading(ax,obj.ZG.shading_style);
            
            tabGroup.SelectedTab = resTab;
            minV=min(h.ZData(:));
            maxV=max(h.ZData(:));
            try
                if minV==maxV
                    ax.CLim=[-inf inf];
                else
                    ax.CLim=[floor(minV), ceil(maxV)];
                end
                pretty_colorbar(ax,mydesc,myunits);
            catch ME
                warning(ME.message)
            end
                
            drawnow
            obj.ax = ax;
            obj.interact(myname)
        end
        
        function plot(obj, choice)
            % plots the results
            % obj.PLOT( choice, ...) where choice is the name or number of the table column to plot.
            % if not provided, it will default to OBJ.active_col
            %
            % called by the ZmapGridFunction's doit() method
            
            report_this_filefun();
            if ~exist('choice','var')
                choice = obj.active_col;
            end
            
            %% plot into the ZMAP main window
            if get(gcf,'Tag') == "Zmap Main Window"
                theTab = obj.recreateExistingResultsTab(gcf);
                obj.overlay(theTab, choice)
                theTab.DeleteFcn=@cb_deleteTab
                theTab.UserData = obj; % stash results in this tab for future access
                return
            end
            
            %% plotting into some window other than the Main ZMAP window
            
            [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails(choice);
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f);
            set(f,'name',['results : ', myname])
            delete(findobj(f,'Type','axes'));
            % this is to show the data
            if islogical(obj.Result.values.(myname)(1))
                p=double(obj.Result.values.(myname));
                p(p==0)=nan;
                obj.Grid.pcolor([],p, mydesc);
            else
                obj.Grid.pcolor([],obj.Result.values.(myname), mydesc);
            end
            obj.ax = gca;
            set(obj.ax,'NextPlot','add');
            
            
            shading(obj.ZG.shading_style);
            set(obj.ax,'NextPlot','add')
            
            obj.add_grid_centers();
            
            for n=1:numel(obj.features)
                ft=obj.ZG.features(obj.features{n});
                copyobj(ft,obj.ax);
            end
            colorbar
            title(obj.ax,mydesc)
            xlabel(obj.ax,'Longitude')
            ylabel(obj.ax,'Latitude')
            
            %dcm_obj=datacursormode(gcf);
            %dcm_obj.UpdateFcn=@ZmapGridFunction.mydatacursor;
            %dcm_obj.SnapToDataVertex='on';
            
            if isempty(findobj(f,'Tag','lookmenu'))
                obj.add_menus(choice);
            end
            
            obj.update_layermenu(myname,f);
            
            mapdata_viewer(obj,obj.RawCatalog,f);
            
            function cb_deleteTab(src,ev)
                % also delete the selection lines
                tagBase = src.Tag;
                regexp_str = tagBase + " .*selection";
                delete(findobj(ancestor(src,'figure'),'-regexp','Tag',regexp_str));
            end
            
        end % plot function
        
        function add_menus(obj,choice)
            
            add_menu_divider();
            lookmenu=uimenu(gcf,'label','graphics','Tag','lookmenu');
            shademenu=uimenu(lookmenu,'Label','shading','Tag','shading');
            activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            activeax=findobj(activeTab.Children,'Type','axes');
            
            uimenu(shademenu,'Label','interpolated',MenuSelectedField(),@(~,~)cb_shading('interp'));
            uimenu(shademenu,'Label','flat',MenuSelectedField(),@(~,~)cb_shading('flat'));
            
            plottype=uimenu(lookmenu,'Label','plot type');
            %uimenu(plottype,'Label','Pcolor plot','Tag','plot_pcolor',...
            %    MenuSelectedField(),@(src,~)obj.plot(choice),'Checked','on');
            
            % countour-related menu items
            
            uimenu(plottype,'Label','Plot Contours','Tag','plot_contour',...
                'Enable','off',...not fully unimplmented
                MenuSelectedField(),@(src,~)obj.contour(choice));
            uimenu(plottype,'Label','Plot filled Contours','Tag','plot_contourf',...
                'Enable','off',...not fully unimplmented
                MenuSelectedField(),@(src,~)contourf(choice));
            uimenu(lookmenu,'Label','change contour interval',...
                'Enable','off',...
                MenuSelectedField(),@(src,~)changecontours_cb(src));
            
            % display overlay menu items
            %{
            uimenu(lookmenu,'Label','Show grid centerpoints','Checked',char(obj.showgridcenters),...
                MenuSelectedField(),@obj.togglegrid_cb);
            uimenu(lookmenu,'Label',['Show ', obj.RawCatalog.Name, ' events'],...
                MenuSelectedField(),{@obj.addquakes_cb, obj.RawCatalog});
            %}
            uimenu(lookmenu,'Separator','on',...
                'Label','brighten active map',...
                MenuSelectedField(),@(~,~)cb_brighten(0.4));
            uimenu(lookmenu,'Label','darken active map',...
                MenuSelectedField(),@(~,~)cb_brighten(-0.4));
            
            uimenu(lookmenu,'Separator','on',...
                'Label','increase alpha ( +0.2 )',...
                MenuSelectedField(), @(~,~)cb_alpha( 0.2));
            uimenu(lookmenu,'Label','decrease alpha ( -0.2 )',...
                MenuSelectedField(), @(~,~)cb_alpha( - 0.2));
            function cb_shading(val)
                % must be in function because ax must be evaluated in real-time
                activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
                ax=findobj(activeTab.Children,'Type','axes','-and','Tag','result_map');
                shading(ax,val)
            end
            function cb_brighten(val)
                activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
                ax=findobj(activeTab.Children,'Type','axes','-and','Tag','result_map');
                cm=colormap(ax);
                colormap(ax,brighten(cm,val));
            end
            function cb_alpha(val)
                activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
                ax=findobj(activeTab.Children,'Type','axes','-and','Tag','result_map');
                ss = findobj(ax.Children,'Tag','result overlay');
                if isprop(ss,'FaceAlpha')
                    newAlpha = ss.FaceAlpha + val;
                    if newAlpha < 0; newAlpha = 0; end
                    if newAlpha > 1; newAlpha = 1; end
                    alpha(ss,newAlpha);
                else
                    beep;
                    fprintf('alpha not supported for %s\n',ss.Type);
                end
            end
            
        end
        
        function updateClickPoint(obj,src,~)
            % If user clicks in the active axis, then the point and sample are updated
            
            if ~isvalid(obj.ax)
                % src
                return
            end
            mytab=obj.ax.Parent;
            mytabholder=mytab.Parent;
            if mytabholder.SelectedTab~=mytab || ~obj.isUpdating
                return
            end
            axX=obj.ax.XLim;
            axY=obj.ax.YLim;
            pt=obj.ax.CurrentPoint(1,1:2);
            withinAxes = pt(1)<=axX(2) && pt(1)>=axX(1) && pt(2)<=axY(2) && pt(2) >=axY(1);
            if withinAxes
                obj.lastPoint = pt;
                mx=pt(1); my=pt(2);
                [~,nearest]=min((mx-obj.Result.values.x).^2 + (my-obj.Result.values.y).^2);
                x = obj.Result.values.x(nearest);
                y = obj.Result.values.y(nearest);
                obj.nearestSample=nearest;
                obj.nearestSamplePos = [x , y];
                % update hilight
                HL=findobj(obj.ax.Children,'flat','Tag','thisresulthilight');
                HL.XData = x;
                HL.YData = y;
            end
        end
        
        function t = helptext(obj, subject)
            switch subject
                case 'KeyMap'
                    t = "When viewing the results map, the following keys have special functions";
                    f=fieldnames(obj.KeyMap); f=sort(f);
                    for j=1:numel(f)
                        fn=string(f{j});
                        t=t+newline+"  "+ pad(fn,20,'right') + " : <strong>" + obj.KeyMap.(fn)+"</strong>";
                    end
                case "-choices"
                    t = helptext@ZmapGridFunction(obj,subject);
                    t = [t, "KeyMap"];
                otherwise
                    t= helptext@ZmapGridFunction(obj,subject);
            end
        end
    end % Public methods
    
    methods(Access=protected)
        
        
        function addquakes_cb(obj, src, ~, catalog)
            report_this_filefun();
            
            qtag=findobj(gcf,'tag','quakes');
            if isempty(qtag)
                set(gca,'NextPlot','add')
                line(catalog.Longitude, catalog.Latitude, 'Marker','o',...
                    'MarkerSize',3,...
                    'MarkerEdgeColor',[.2 .2 .2],...
                    'LineStyle','none',...
                    'Tag','quakes');
                set(gca,'NextPlot','replace')
            else
                ison=qtag.Visible == "on";
                qtag.Visible=tf2onoff(~ison);
                src.Checked=tf2onoff(~ison);
                drawnow
            end
        end
        
        function update_layermenu(obj, myname, container)
            % updates the layers associated with some container. usually the context menu for a tab.
            report_this_filefun();
            if ~exist('container','var')
                container=uimenu(gcf,'Label','layer');
            end
            
            
            % UPDATE_LAYERMENU
            if isempty(container.Children)  % TODO: change to plotTag_layermeu
                %layermenu=uimenu(gcf,'Label','layer','Tag','layermenu');
                import callbacks.copytab
                uimenu(container,'Label','Copy Contents to new figure (static)','Callback',@copytab);
                for i=1:width(obj.Result.values)
                    tmpdesc=obj.Result.values.Properties.VariableDescriptions{i};
                    tmpname=obj.Result.values.Properties.VariableNames{i};
                    uimenu(container,'Label',tmpdesc,'Tag',tmpname,...
                        'Enable',tf2onoff(~all(isnan(obj.Result.values.(tmpname)))),...
                        MenuSelectedField(),@(~,~)overlay_cb(tmpname));
                    %MenuSelectedField(),@(~,~)plot_cb(tmpname)); %FIXME just replot the layer
                end
                container.Children(end-1).Separator='on';
            end
            
            % make sure the correct option is checked
            %layermenu=findobj(container,'Tag','layermenu');
            set(findobj(container,'Tag',myname),'Checked','on');
            
            % plot here
            function plot_cb(name)
                report_this_filefun();
                set(findobj(container,'type','uimenu'),'Checked','off');
                obj.plot(name);
            end
            
            function overlay_cb(name)
                report_this_filefun();
                set(findobj(container,'type','uimenu'),'Checked','off');
                theTabHolder = findobj(gcf,'Tag','main plots','-and','Type','uitabgroup');
                theTab=findobj(theTabHolder,'Tag', obj.PlotTag);
                obj.overlay(theTab,name);
            end
        end
        
        function add_grid_centers(obj)
            % show grid centers, but don't make them clickable
            report_this_filefun();
            dbk=dbstack(1);
            disp(dbk(1).name);
            
            gph=obj.Grid.plot(gca,'ActiveOnly');
            gph.Tag='pointgrid';
            gph.PickableParts='none';
            gph.Visible=char(obj.showgridcenters);
        end
        
        function theTab = recreateExistingResultsTab(obj, f)
            % create tab for this result in the main window. Existing tab will be deleted
            theTabHolder = findobj(f, 'Tag','main plots','-and','Type','uitabgroup');
            delete(findobj(theTabHolder, 'Tag', obj.PlotTag))
            
            theTab = uitab(theTabHolder, 'Title', [obj.PlotTag ' Results'], 'Tag', obj.PlotTag);
        end
        
        function updateRing(obj)
            CR = findobj(obj.ax,'Tag','thisradius');
            tb=obj.resultsForThisPoint;
            if obj.showRing
                % update samplecircle
                [La,Lo]=reckon(tb.y, tb.x, km2deg(obj.Result.values.RadiusKm(obj.nearestSample)), 0:2:360);
                set(CR,'XData',Lo,'YData',La,'LineStyle','--');
            else
                set(CR,'XData',nan,'YData',nan);
            end
        end
        
        function updateText(obj)
            TX = findobj(obj.ax,'Tag','thisresulttext');
            myname = TX.UserData;
            if obj.showPointValue
                % update text
                TX.Position=[obj.nearestSamplePos,0];
                valstr=string(obj.Result.values.(myname)(obj.nearestSample));
                if ismissing(valstr)
                    TX.String="  " + myname + " : <missing>";
                else
                    TX.String="  " + myname + " : " + valstr;
                end
            else
                TX.String="";
            end
        end
        function update(obj, ~, ~)
            % get current point and axes
            
            obj.updateText();
            obj.updateRing();
            obj.updateSeries();
        end
        
        function updateSeries(obj)
            % update external plot(s)
            
            h=findobj(gcf,'Tag','CumPlot axes');
            if isempty(h)
                warning('Something is wrong. cannot find CumPlot axes handle');
            end
            
            % define how these trends will appear
            plOpt.Marker='o';
            plOpt.LineStyle='-.';
            plOpt.LineWidth=2;
            plOpt.DisplayName = [obj.PlotTag, ' selection'];
            plOpt.Color = obj.colorForThisPoint;
            c = obj.catalogForThisPoint;
            h.UserData.add_series(c, [obj.PlotTag, ' selection'], plOpt);
        end
        
        function interact(obj,myname)
            % make this results-plot interactive
            f=ancestor(obj.ax,'figure');
            obj.ax.NextPlot='add';
            delete(findobj(obj.ax,'Tag','thisresulttext'));
            delete(findobj(obj.ax,'Tag','thisresulthilight'));
            delete(findobj(obj.ax,'Tag','thisradius'));
            text(obj.ax,nan,nan,'','FontWeight','bold','BackgroundColor','w',...
                'Interpreter','none','Tag','thisresulttext','UserData',myname);
            HL = scatter(obj.ax,nan,nan,'o','MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',[1 0 0],...
                ...'CData',[0 0 0],...
                'Tag','thisresulthilight',...
                'SizeData',60,...
                'LineWidth',3);
            line(obj.ax,nan,nan,'LineStyle',':','Color','k','Tag','thisradius','LineWidth',2);
            
            %%
            % desired behavior:
            %  - do nothing until mouse is down
            %  - on mouse click, choose the nearest data point, and update all relevant graphs with
            %    data associated with that point.
            %       - MainMap shows the appropriate data point, and may show radius and value
            %       - Subplots may update with the catalog represented by that point
            %  - While mouse is down, continuously update location
            
            % Do not update until mouse button is pressed
            obj.isUpdating=false;
            
            % update the data-point positions as the mouse moves
            f.WindowButtonMotionFcn = @obj.updateClickPoint;
            
            % Whenever the mouse is pressed in this axes, start doing updates
            obj.ax.ButtonDownFcn = @trigger_update;
            
            % But, make sure that button presses are not intercepted, otherwise
            % the feedback will be intermittant.
            set(obj.ax.Children,'HitTest','off');
            
            % allow for additional functionality by looking for key presses
            f.WindowKeyPressFcn     = @keyupdate;
            
            return
            
            function keyupdate(src, ev)
                % translate key presses into actions
                k = ev.Character;
                switch k
                    case obj.KeyMap.KeyHelp
                        disp('Key Help')
                        fn=fieldnames(obj.KeyMap)
                        for i=1:numel(fn)
                            fprintf('   %20s  : %s\n',fn{i},obj.KeyMap.(fn{i}));
                        end
                        
                    case obj.KeyMap.ToggleRadiusRing
                        obj.showRing = ~obj.showRing;
                        
                    case obj.KeyMap.TogglePointValue
                        obj.showPointValue = ~obj.showPointValue;
                        
                    case obj.KeyMap.ShowValueNoNan
                        disp(obj.resultsForThisPointNoNan);
                        
                    case obj.KeyMap.ShowValue
                        disp(obj.resultsForThisPoint);
                        
                    otherwise
                        % add additional key funcitonality here.
                        do_nothing();
                end
                obj.updateClickPoint()
            end
            function trigger_update(src,ev)
                % start tracking the mouse location
                wbu_tmp = f.WindowButtonUpFcn;
                f.WindowButtonUpFcn = @falsifyIsUpdating;
                obj.isUpdating=true;
                try
                    obj.updateClickPoint(src,ev);
                    drawnow
                catch ME
                    falsifyIsUpdating()
                    rethrow(ME)
                end
                
                function falsifyIsUpdating(~,~)
                    % stop updating the selected results.
                    obj.isUpdating=false;
                    f.WindowButtonUpFcn=wbu_tmp;
                end
                
            end
            
            
        end
        
    end % Protected methods
    
end


function changecontours_cb()
    % CHANGECONTOURS_CB doesn't depend on this obj at all.
    dlgtitle='Contour interval';
    s.prompt='Enter interval';
    contr= findobj(gca,'Type','Contour');
    s.value=get(contr,'LevelList');
    if all(abs(diff(s.value)-diff(s.value(1:2))<=eps)) % eps is floating-point number spacing
        s.toChar = @(x)sprintf('%g:%g:%g',x(1),diff(x(1:2)),x(end));
    end
    s.toValue = @mystr2vec;
    answer = smart_inputdlg(dlgtitle,s);
    set(contr,'LevelList',answer.value);
    
    function x=mystr2vec(x)
        % ensures only valid characters for the upcoming eval statement
        if ~all(ismember(x,'(),:[]01234567890.- '))
            x = str2num(x); %#ok<ST2NM>
        else
            x = eval(x);
        end
    end
end

function pretty_colorbar(ax, cb_title, cb_units)
    h=colorbar('peer',ax, 'location','EastOutside');
    if isempty(cb_units)
        h.Label.String = cb_title;
    else
        h.Label.String =  sprintf('%s [%s]',cb_title,cb_units);
    end
    
end