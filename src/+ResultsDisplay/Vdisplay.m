classdef Vdisplay < ResultsDisplay.ZmapResultsPlugin
    % provides plug-in results display functionality
    
    properties(SetObservable, AbortSet)
        features cell ={}; % features to show on the map, such as 'borders','lakes','coast',etc.
        
        showRing        logical     = true; % show ring
        showPointValue	logical     = false;
        showTable       logical     = true;
        showResultPlots logical     = true;
        showEvents      logical     = true; % show events as dots
        
        lastPoint       = [nan nan]; % x, y of click
        pointChoice (1,1) char   {mustBeMember(pointChoice,{'A','B','-'})}   = 'A'; % choose points for comparison. 'A', or 'B'
        samplePoints = containers.Map(); % track individual points
        
        ColorBy {mustBeMember(ColorBy,{'result','choice'})} = 'choice'
        SelectionColors = [FancyColors.rgb('blue'); FancyColors.rgb('mandy')];
    end
    
    properties
        isUpdating      logical
    end
    
    properties(Constant)
        % The results can be explored  also by pressing keys. This creates the mapping
        % between the keys and actions
        KeyMap = struct(...
            'ToggleRadiusRing'  , 'r',...
            'ShowValue'         , 'T',...
            'ShowValueNoNan'    , 't',...
            'TogglePointValue'  , 'v',...
            'ChoosePointA'      , 'A',...
            'ChoosePointB'      , 'B',...
            'RemovePoint'       , sprintf('\b'),...
            'KeyHelp'           , '?'...
            );
    end
    
    properties(Dependent)
    	colorForThisPoint        % color used by the grid at this point, If no color specified, default to grey
    end
    properties(Constant, Hidden)
        gridMarkerSize        = 5;
        gridMarker            = '+';
        gridMarkerFaceAlpha   = 0.5;
        deemphasizeLineFcn    = @(lineobject) set(lineobject, 'Color', (lineobject.Color + [3 3 3]) ./ 4);
        deemphasizeScatterFcn = @(sob) set(sob,'MarkerEdgeAlpha', 0.2);
        deemphasizeEventsFcn  = @(ev) set(ev,'MarkerEdgeColor',[0.6 0.6 0.6],'Marker','.');
    end
    
    methods
        
        
        %% plotting functions
        
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
            
            [choice, colname, coldesc, colunits] = obj.Parent.ActiveDataColumnDetails(choice);
            
            tabGroup = resTab.Parent;
            
            ax=findobj(resTab,'Type','axes','-and','Tag','result_map');
            set(findobj(allchild(gcf),'Tag','lookmenu'),'Enable','on');
            if isempty(ax)
                % copy entire main map to this axes, and de-emphasized, and
                % then become the base for displaying results
                copyobj(findobj(tabGroup,'Tag','mainmap_ax'),resTab);
                ax=findobj(resTab,'Tag','mainmap_ax');
                cla(ax)
                ax.Tag      = 'result_map';
                ax.Units    = 'normalized';
                ax.Position = [0.05 0.05 .90 .90];
                daspect(ax,[1 1 1]);
                set(findobj(ax,'Type','scatter'),'MarkerEdgeAlpha',0.4);
                
                % de-emphasize all line objects
                arrayfun(@obj.deemphasizeLineFcn, findobj(ax,'Type','line'));
                arrayfun(@obj.deemphasizeScatterFcn, findobj(ax,'Type','scatter'));
                if ~obj.showEvents
                    arrayfun(@delete, findobj(ax,'Type','scatter','-and','Tag','active quakes'));
                else
                    arrayfun(@obj.deemphasizeEventsFcn, findobj(ax,'Type','scatter','-and','Tag','active quakes'));
                end
                
                hTopos=findobj(resTab,'-regexp','Tag','topographic_map_*');
                if ~isempty(hTopos)
                    deal_with_topography(ax,hTopos, resTab );
                end
            else
                ax = findobj(resTab,'Tag','result_map');
            end
            
            ax.NextPlot = 'add';
            delete(findobj(ax,'Tag','result overlay'));
            
            %% --  replace existing grid points with contour or color-coded grid showing results
            
            delete(findobj(ax,'-regexp','Tag','grid_\w.*'));
            if islogical(obj.Data.(colname)(1))
                p=double(obj.Data.(colname));
                p(p==0)=nan;
                h = obj.Parent.Grid.pcolor(ax,p, coldesc);
                shading(ax,'flat')
            else
                % [~,h]=obj.Parent.Grid.contourf(ax,obj.Data.(colname), coldesc, ZmapGlobal.Data.ResultOpts.NumContours);
                h=obj.patchplot(ax,colname);
            end

            axis tight
            axis equal
            ax.YDir = 'reverse';
            xlabel(ax,'Distance along strike');
            ylabel(ax,'Depth')
            % move the contour to the bottom layer so other graphical elements can be interacted with
            ax.Children = circshift(ax.Children,-1);
            
            val         = obj.Data.(colname);
            s           = findobj(ax, 'Tag', obj.Parent.Grid.Name);
            if isempty(s)
                % overlay colored grid on top of existing data
                s = scatter(ax,obj.Data.distance_along_strike, obj.Data.z, ...
                    obj.gridMarkerSize, val, obj.gridMarker, 'Tag', obj.Parent.Grid.Name);
                s.MarkerFaceAlpha = obj.gridMarkerFaceAlpha;
            else
                if islogical(val)
                    val = double(val);
                end
                set(s,'XData',obj.Data.distance_along_strike,'YData',obj.Data.z,'CData',val);
            end
            
            h.Tag = 'result overlay';
            
            if isempty(findobj(gcf,'Tag','lookmenu'))
                ZmapHGridFunction.add_menus(choice);
            end
            
            % add a menu to choose which layer / variable to examine
            c=findobj(gcf,'Type','uicontextmenu','-and','Tag',obj.PlotTag);
            delete(c); % avoid replotting old data.
            
            c=uicontextmenu('Tag',obj.PlotTag);
            resTab.UIContextMenu=c;
            
            update_layermenu(obj,colname, c);
            
            uimenu(c,'Separator','on','Label','Close tab',...
                MenuSelectedField(),@(~,~)delete(resTab));
            
            title(ax,sprintf('%s : [ %s ]',obj.Parent.RawCatalog.Name, coldesc), 'Interpreter', 'None');
            
            mySelectionChangedEvent = struct('OldValue', tabGroup.SelectedTab, 'NewValue', resTab);
            tabGroup.SelectedTab = resTab;
            
            minV=min(h.ZData(:));
            maxV=max(h.ZData(:));
            try
                if minV==maxV
                    ax.CLim=[-inf inf];
                else
                    %ax.CLim=[floor(minV), ceil(maxV)];
                end
                pretty_colorbar(ax,coldesc,colunits);
            catch ME
                warning(ME.message)
            end
            if mySelectionChangedEvent.OldValue ~= mySelectionChangedEvent.NewValue
                tabGroup.SelectionChangedFcn([],mySelectionChangedEvent);
            else
                % reestablish the points
            end
            drawnow
            obj.Parent.ax = ax;
            obj.interact(colname)
            
        end
        
        function plot(obj, choice)
            % plots the results
            % obj.PLOT( choice, ...) where choice is the name or number of the table column to plot.
            % if not provided, it will default to OBJ.active_col
            %
            % called by the ZmapGridFunction's doit() method
            
            report_this_filefun();
            if ~exist('choice','var')
                choice = obj.Parent.active_col;
            end
            
            %% plot into the ZMAP main window
            if get(gcf,'Tag') == "Zmap Main Window"
                theTab = obj.recreateExistingResultsTab(gcf);
                obj.overlay(theTab, choice)
                theTab.DeleteFcn=@ZmapGridFunction.cb_deleteTab;
                theTab.UserData = obj; % stash results in this tab for future access
                return
            end
            
            %% plotting into some window other than the Main ZMAP window
            
            [choice, myname, mydesc, myunits] = obj.Parent.ActiveDataColumnDetails(choice);
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f);
            set(f,'name',['results : ', myname])
            delete(findobj(f,'Type','axes'));
            % this is to show the data
            if islogical(obj.Data.(myname)(1))
                p=double(obj.Data.(myname));
                p(p==0)=nan;
                obj.Parent.Grid.pcolor([],p, mydesc);
            else
                obj.Parent.Grid.pcolor([],obj.Data.(myname), mydesc);
            end
            obj.Parent.ax = gca;
            set(obj.ax,'NextPlot','add');
            
            ZG = ZmapGlobal.Data;
            shading(ZG.shading_style);
            set(obj.Parent.ax,'NextPlot','add')
            
            obj.add_grid_centers();
            
            for n=1:numel(obj.features)
                ft = ZG.features(obj.features{n});
                copyobj(ft,obj.Parent.ax);
            end
            colorbar
            title(obj.Parent.ax,mydesc)
            xlabel(obj.Parent.ax,obj.Parent.RawCatalog.XLabel)
            ylabel(obj.Parent.ax,obj.Parent.RawCatalog.YLabel)
            
            if isempty(findobj(f,'Tag','lookmenu'))
                ZmapHGridFunction.add_menus(choice);
            end
            
            obj.update_layermenu(myname,f);
            
            mapdata_viewer(obj,obj.Parent.RawCatalog,f);
            
        end % plot function
        
        function mypatch = patchplot(obj,ax, choice)
            
            %{
    some_results is the results from one of the ZmapGridFunctions. It will contain:
    1.  a field called "values" which is a table.  This table will have columns for 'x', 'y' and
        col_heading (where col_heading is the name of one of the columns).
    2.  a field called Grid, which is a ZmapGrid and contains fields X, Y
        
            %}
            gr_s = obj.Parent.Grid;
            results = obj.Data;
            axes(ax);
            myX = results.distance_along_strike;
            nPointsAlongStrike = find(myX(1:end-1) > myX(2:end),1);
            myX = reshape(myX, nPointsAlongStrike, []);
            hold on;
            % assume: dx is constant everywhere
            % TOFIX there is an extra point in d_km at end that is a Longitude instead!
            Xvec =myX(:,1);
            Zvec = unique(gr_s.Z);
            [xs,zs] = meshgrid(Xvec, Zvec);
            
            myresultstmp = results.(choice);
            myresults = reshape(myresultstmp, fliplr(size(xs)))';
            dx = (Xvec(2)-Xvec(1))/2;
            dz = (Zvec(2)-Zvec(1))/2;
            shifted_X = xs - dx;
            shifted_Z = zs - dz;
            
            % myresults = reshape(myresults, size(shifted_X));
            
            %% because surfaces and patches are based on the lower-left corner, add col & row.
            
            % add row to top with same values as existing last (top)row
            myresults(end+1,:) = myresults(end,:);
            shifted_X(end+1,:) = shifted_X(end,:);
            shifted_Z(end+1,:) = shifted_Z(end,:) + dz;
            
            % add column to end with same values as existing last (right) column
            myresults(:,end+1) = myresults(:,end);
            shifted_X(:,end+1) = shifted_X(:,end) + dx;
            shifted_Z(:,end+1) = shifted_Z(:,end);
            
            pa = surf2patch(shifted_X, shifted_Z, zeros(size(shifted_X)), myresults);
            
            mypatch = patch(pa);
            mypatch.Faces(end,:) = []; %this point was made up.
            mypatch.Tag     = 'result overlay';
            mypatch.HitTest = 'off';
            shading faceted;
            
            set(gca, 'Children', circshift(get(gca,'Children'),-1)); % put this patch at the end
        end
        
        function updateClickPoint(obj,~,ev)
            % If user clicks in the active axis, then the point and sample are updated
            % disp(ev)
            if ~obj.isUpdating &&( (nargin>1 && ev.EventName ~= "Hit") || ~isvalid(obj.Parent.ax))
                return
            end
            mytab=obj.Parent.ax.Parent;
            mytabholder=mytab.Parent;
            if mytabholder.SelectedTab~=mytab % || ~obj.isUpdating
                return
            end
            axX=obj.Parent.ax.XLim;
            axY=obj.Parent.ax.YLim;
            pt=obj.Parent.ax.CurrentPoint(1,1:2);
            withinAxes = pt(1)<=axX(2) && pt(1)>=axX(1) && pt(2)<=axY(2) && pt(2) >=axY(1);
            if withinAxes
                obj.lastPoint = pt;
                mx=pt(1); my=pt(2);
                [~,nearest]=min((mx-obj.Data.x).^2 + (my-obj.Data.y).^2);
                x = obj.Data.x(nearest);
                y = obj.Data.y(nearest);
                
                % update point-specific details
                p = obj.Parent.samplePoints(obj.Parent.pointChoice);
                p.X = x;
                p.Y = y;
                p.idx = nearest;
                obj.Parent.samplePoints(obj.Parent.pointChoice) = p;
                
                obj.Parent.nearestSample=nearest;
                
                % update hilight
                HL = obj.Parent.samplePoints(obj.Parent.pointChoice).thisresulthilight;
                HL.XData = x;
                HL.YData = y;
                
            end
        end
        
        function interact(obj,myname)
            % make this results-plot interactive
            f = ancestor(obj.Parent.ax,'figure');
            obj.Parent.ax.NextPlot = 'add';
            ax = obj.Parent.ax
            
            delete(findobj(ax,'Tag','thisresulttext'));
            delete(findobj(ax,'Tag','thisresulthilight'));
            delete(findobj(ax,'Tag','thisradius'));
            
            textOpt.FontWeight     = 'bold';
            textOpt.BackgroundColor = 'w';
            textOpt.Interpreter    = 'none';
            textOpt.Tag            = 'thisresulttext';
            textOpt.UserData       = myname;
            textOpt.DisplayName='';
            
            hilightOpt.Marker            = 'o';
            hilightOpt.MarkerEdgeColor   = [0 0 0];
            hilightOpt.MarkerFaceColor   = obj.SelectionColors(1,:);
            hilightOpt.Tag               = 'thisresulthilight';
            hilightOpt.SizeData          = 80;
            hilightOpt.LineWidth         = 2;
            hilightOpt.DisplayName='';
            
            radiusOpt.LineStyle = ':';
            radiusOpt.Color = 'k';
            radiusOpt.Tag = 'thisradius';
            radiusOpt.LineWidth = 2;
            radiusOpt.DisplayName='';
            
            % POINT A
            TL = text(ax,nan,nan,'',textOpt);
            HL = scatter(ax, nan, nan);
            set(HL, hilightOpt);
            RL = line(ax,nan,nan,radiusOpt);
            obj.Parent.samplePoints('A') = struct(TL.Tag, TL, HL.Tag, HL, RL.Tag, RL,...
                'X',nan, 'Y', nan, 'idx', []);
            
            % POINT B
            hilightOpt.Marker = '^';
            hilightOpt.MarkerFaceColor=obj.SelectionColors(2,:);
            
            TL = text(ax,nan,nan,'',textOpt);
            HL = scatter(ax, nan, nan)
            set(HL, hilightOpt);
            RL = line(ax,nan,nan,radiusOpt);
            obj.Parent.samplePoints('B') = struct(TL.Tag, TL, HL.Tag, HL, RL.Tag, RL,...
                'X',nan, 'Y', nan, 'idx', []);
            
            CA = scatter(ax,nan,nan,'Marker','.','DisplayName','selection A','Tag','selectionA','CData',obj.SelectionColors(1,:));
            CB = scatter(ax,nan,nan,'Marker','.','DisplayName','selection B','Tag','selectionB','CData',obj.SelectionColors(2,:));
            
            
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
            ax.ButtonDownFcn = @trigger_update;
            
            % But, make sure that button presses are not intercepted, otherwise
            % the feedback will be intermittant.
            set(ax.Children,'HitTest','off');
            
            % allow for additional functionality by looking for key presses
            f.WindowKeyPressFcn     = @obj.keyupdate;
            
            return
            
            function trigger_update(src,ev)
                % start tracking the mouse location
                wbu_tmp = f.WindowButtonUpFcn;
                f.WindowButtonUpFcn = @falsifyIsUpdating;
                obj.isUpdating=true;
                try
                    obj.updateClickPoint(src,ev);
                    drawnow % limitrate
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
        
        function t = helptext(obj, subject)
            % provides help text, based on the subject.
            % -all lists everything
            % -choice gives list of topics one can ask about
            switch subject
                case "KeyMap"
                    t = "When viewing the results map, the following keys have special functions";
                    f=fieldnames(obj.KeyMap); f=sort(f);
                    for j=1:numel(f)
                        fn=string(f{j});
                        t=t+newline+"  "+ pad(fn,20,'right') + " : <strong>" + obj.KeyMap.(fn)+"</strong>";
                    end
                case "-choices"
                    t = "KeyMap";
                otherwise
                    t = "";
            end
        end
    
        function mycolor = get.colorForThisPoint(obj)
            % use the same color for the trend plot as is used for the results overlay
            switch obj.ColorBy
                case 'result'
                    cm=colormap(obj.ax);
                    cl=obj.ax.CLim;
                    lookup=linspace(min(cl), max(cl), length(cm));
                    mycolorFn = @(v) cm(v>=lookup(1:end-1) & v<lookup(2:end),:);
                    gr=findobj(obj.ax.Children,'flat','-regexp','Tag','.*[gG]rid.*');
                    gridx = find(gr.XData==obj.Parent.samplePoints(obj.Parent.pointChoice).X & gr.YData==obj.Parent.samplePoints(obj.Parent.pointChoice).Y);
                    %gridx = find(gr.XData==obj.nearestSamplePos(1) & gr.YData==obj.nearestSamplePos(2));
                    mycolor = mycolorFn(gr.CData(gridx));
                    
                    if isempty(mycolor),mycolor=[0.4 0.4 0.4];end
                    
                case 'choice'
                    switch obj.Parent.pointChoice
                        case 'A'
                            mycolor = obj.SelectionColors(1,:);
                        case 'B'
                            mycolor = obj.SelectionColors(2,:);
                    end
            end
        end
        
    end
    
    methods
        
        
        function addquakes_cb(obj, src, ~, catalog)
            report_this_filefun();
            
            qtag=findobj(gcf,'tag','quakes');
            if isempty(qtag)
                set(gca,'NextPlot','add')
                line(catalog.X, catalog.Y, 'Marker','o',...
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
                import callbacks.copytab
                uimenu(container,'Label','Copy Contents to new figure (static)','Callback',@copytab);
                
                hasValues = @(name) ~all(ismissing(obj.Data.(name)));
            
                for i=1:width(obj.Data)
                    varName=obj.Data.Properties.VariableNames{i};
                    uimenu(container,...
                        'Label',obj.Data.Properties.VariableDescriptions{i},...
                        'Tag',varName,...
                        'Enable',tf2onoff(hasValues(varName)),...
                        MenuSelectedField(),@(~,~)obj.overlay_cb(varName, container));
                end
                container.Children(end-1).Separator='on';
            end
            
            % make sure the correct option is checked
            set(findobj(container,'Tag',myname),'Checked','on');
        end
        
        function overlay_cb(obj, name, container)
            report_this_filefun();
            set(findobj(container,'type','uimenu'),'Checked','off');
            theTabHolder    = findobj(gcf,'Tag','main plots','-and','Type','uitabgroup');
            theTab          = findobj(theTabHolder,'Tag', obj.PlotTag);
            obj.Parent.active_col  = name; % % % % cgr 24.9.18
            obj.overlay(theTab,name);
        end
        
        function theTab = recreateExistingResultsTab(obj, f)
            % create tab for this result in the main window. Existing tab will be deleted
            theTabHolder = findobj(f, 'Tag','main plots','-and','Type','uitabgroup');
            delete(findobj(theTabHolder, 'Tag', obj.PlotTag))
            
            theTab = uitab(theTabHolder, 'Title', [obj.PlotTag ' Results'], 'Tag', obj.PlotTag);
        end
        
        function updateRing(obj, tb, sp)
            CR = sp.thisradius;
            if obj.showRing && ~isempty(tb)
                % update samplecircle
               assert(obj.Parent.RawCatalog.RefEllipsoid.LengthUnit=="kilometer");
               [La,Lo]=reckon(tb.y, tb.x, obj.Data.RadiusKm(obj.Parent.nearestSample), 0:2:360, obj.Parent.RawCatalog.RefEllipsoid);
                set(CR,'XData',Lo,'YData',La,'LineStyle','--');
            else
                set(CR,'XData',nan,'YData',nan);
           end
        end
        
        function updateText(obj,tb, sp)
            TX = sp.thisresulttext;
            myname = TX.UserData;
            if obj.showPointValue && ~isempty(tb)
                % update text
                TX.Position = [sp.X sp.Y 0];
                valstr = string(obj.Data.(myname)(obj.Parent.nearestSample));
                if ismissing(valstr)
                    TX.String = "  " + myname + " : <missing>";
                else
                    TX.String = "  " + myname + " : " + valstr;
                end
            else
                TX.String = "";
            end
        end
        
        function update(obj, ~, ~)
            % get current point and axes
            tb = obj.Parent.resultsForThisPoint;
            sp = obj.Parent.samplePoints(obj.Parent.pointChoice);
            obj.updateText(tb,sp);
            obj.updateRing(tb, sp);
            obj.updateSeries(sp);
        end
        
        function updateSeries(obj,sp)
            % update external plot(s)
            
            % discover external axes that are AnalysisWindow related: they will have an AnalysisWindow
            % subclass in their UserData.
            
            analysisWindows = obj.getAnalysisWindows(gcf);
            
            % define how trends will appear
            plOpt.Marker        = sp.thisresulthilight.Marker;
            plOpt.LineStyle     = '-';
            plOpt.LineWidth     = 3;
            plOpt.DisplayName   = [obj.PlotTag, ' ', obj.Parent.pointChoice,' selection'];
            plOpt.Color         = obj.colorForThisPoint;
            switch obj.Parent.pointChoice
                case 'A'
                    plOpt.Ypos=0.75;
                case 'B'
                    plOpt.Ypos=0.55;
            end
            
            c = obj.Parent.catalogForThisPoint;
            thetag = [obj.PlotTag ' ' obj.Parent.pointChoice, ' selection'];
            cellfun(@(aw) aw.add_series(c, thetag, plOpt), analysisWindows,'UniformOutput',false);
            set(findobj(obj.Parent.ax,'Tag',['selection', obj.Parent.pointChoice]),'XData',c.X','YData',c.Y);
            % clear_empty_legend_entries(gcf);
        end
        
        function keyupdate(obj, src, ev)
            % translate key presses into actions
            k = ev.Character;
            switch k
                case obj.KeyMap.KeyHelp
                    disp('Key Help')
                    fn=fieldnames(obj.KeyMap);
                    s="Certain keys affect the map...";
                    for i=1:numel(fn)
                        k=obj.KeyMap.(fn{i});
                        if k==sprintf('\b')
                            k='backspace';
                        elseif k==sprintf('\t')
                            k='tab';
                        end
                        s(i+1)=sprintf(' %17s  : %s',fn{i},k);
                    end
                    s=strjoin(s, newline);
                    disp(s);
                    hd=helpdlg(s,'Keys with special meaning');
                    hd.Position(3)=hd.Position(3) + 70;
                    hButton = findobj(hd,'Tag','OKButton');
                    hButton.Position(3) = hButton.Position(3)+70;
                    set(findobj(hd,'Type','text'),'HorizontalAlignment','left','FontName','Courier New');
                    
                case obj.KeyMap.ToggleRadiusRing
                    obj.showRing = ~obj.showRing;
                    
                case obj.KeyMap.TogglePointValue
                    obj.showPointValue = ~obj.showPointValue;
                    
                case obj.KeyMap.ShowValueNoNan
                    disp(obj.resultsForThisPointNoNan);
                    
                case obj.KeyMap.ShowValue
                    disp(obj.resultsForThisPoint);
                    
                case {upper(obj.KeyMap.ChoosePointA), lower(obj.KeyMap.ChoosePointA)}
                    % current point will not be updated until click
                    obj.Parent.pointChoice='A';
                    
                case {upper(obj.KeyMap.ChoosePointB), lower(obj.KeyMap.ChoosePointB)}
                    % current point will not be updated until click
                    obj.Parent.pointChoice='B';
                    
                    
                case obj.KeyMap.RemovePoint
                    p = obj.Parent.samplePoints(obj.Parent.pointChoice);
                    p.thisresulttext.Position=[nan nan 0];
                    set(p.thisresulthilight,'XData',nan,'YData',nan);
                    set(p.thisradius,'XData',nan,'YData',nan);
                    p.X = nan;
                    p.Y = nan;
                    p.idx= [];
                    obj.Parent.samplePoints(obj.Parent.pointChoice)=p;
                    obj.update();
            
                    analysisWindows = obj.getAnalysisWindows(gcf);
                    thetag = [obj.PlotTag ' ' obj.Parent.pointChoice, ' selection'];
                    cellfun(@(aw) aw.remove_series(thetag), analysisWindows,'UniformOutput',false);
                    
                    if obj.Parent.pointChoice == 'B'
                        obj.Parent.pointChoice = 'A';
                    elseif ~isnan(obj.Parent.samplePoints('B').X)
                        obj.Parent.pointChoice = 'B';
                    else
                        do_nothing()
                    end
                    return
                otherwise
                    % add additional key functionality here.
                    do_nothing();
            end
            obj.updateClickPoint()
        end
        
    end % Protected methods
    
    methods(Static)
        
        function aw = getAnalysisWindows(fig)
            analysisWindowFilter = @(x) ~isempty(x.UserData)&& isa(x.UserData,'AnalysisWindow');
            
            h = findobj(fig,'Type','axes');
            h = h(arrayfun(analysisWindowFilter,h));
            aw = {h.UserData};
        end
        
        function add_menus()
            
            lookmenu  = uimenu(gcf,'label','Results','Tag','lookmenu');
            shademenu = uimenu(lookmenu,'Label','shading','Tag','shading');
            activeTab = get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            activeax  = findobj(activeTab.Children,'Type','axes');
            
            shadingOptions = string({'interp','flat','faceted'});
            for jj=1:numel(shadingOptions)
                
                uimenu(shademenu,'Label',shadingOptions(jj),...
                    MenuSelectedField(),@(~,~)ZmapGridFunction.cb_shading(shadingOptions(jj)));
            end
           
            
            uimenu(lookmenu,'Separator','on',...
                'Label','brighten active map',...
                MenuSelectedField(),@(~,~)ZmapGridFunction.cb_brighten(0.4));
            uimenu(lookmenu,'Label','darken active map',...
                MenuSelectedField(),@(~,~)ZmapGridFunction.cb_brighten(-0.4));
            
            uimenu(lookmenu,'Separator','on',...
                'Label','decrease transparency (alpha) ( +0.2 )',...
                MenuSelectedField(), @(~,~)ZmapGridFunction.cb_alpha( 0.2));
            uimenu(lookmenu,'Label','increase transparency (alpha) ( -0.2 )',...
                MenuSelectedField(), @(~,~)ZmapGridFunction.cb_alpha( - 0.2));
           
            % in the main plots, the object is stored in the UserData of each result's tab
            actt = get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            theObj = actt.UserData;
            uimenu(lookmenu,'Separator','on',...
                'Label','Save results',...
                MenuSelectedField(),@theObj.Parent.save);
        end
    end
end

%% helper functions

function pretty_colorbar(ax, cb_title, cb_units)
    h = colorbar('peer',ax, 'location','EastOutside');
    if isempty(cb_units)
        h.Label.String = cb_title;
    else
        h.Label.String =  sprintf('%s [%s]',cb_title,cb_units);
    end
    
end

function deal_with_topography(hTopos, ax, resTab)
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
end