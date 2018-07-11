function mapdata_viewer(res,catalog,resfig)
    % MAPDATA_VIEWER (PROTOTYPE) explore map data
    % interactive data map, based on results in the table from a ZmapFunction
    % put mouse in DataMap, and choose a symbol key (such as o+v^shp*. )
    %
    % closest grid datapoint is found.
    % - Circle is drawn, showing the radius for which events were used
    % in the calculation
    % - Bvalue is plotted
    % - Cum Rate is plotted
    % - depth profile is plotted
    % - Cumulative moment release is plotted
    %
    %  keep choosing symbols. If symbol isn't already chosen, it is added to the plot. this way several
    %  poinds can be simultaneously compared
    %  if the symbol already exists, the plot will move.
    %
    %  pressing ESCAPE stops the selection loop
    %
    % still in prototype mode
    %
    % Maybe TO add:
    %
    % - polar plots: show # events in radius
    % - radius plots: show # events as function of radius
    % - 3d depth plots of selection
    
    % RES is the results table
    report_this_filefun();
    tb = res.Result.values; % perhaps get sample data from running an Mc, a- and b- calculation from the main map
    
    keyBindings.delete = char(8); %backspace
    %keyBindings.delete = 127; %del
    keyBindings.quit = char(27); %escape
    
    %f.KeyPressFcn=@(src,ev)disp(ev);
    
    
    if exist('resfig','var')
        switch resfig.Type
            case 'figure'
                f=resfig;
                f.Position([3,4])=[1300 700];
                % use existing figure as the base of our axes
                mapax=findobj(resfig,'Type','axes');
                %mapax=copyobj(findobj(resfig,'Type','axes'),f);
                set(findobj(mapax,'Tag','pointgrid'),'visible','off');
                mapax.Units='pixels';
                mapax.Position=[50 150 650 500];
                mapax.Tag = 'dvMap';
                grid on
                subplotContainer=f;
            case'axes'
                mapax = resfig;
                f=mycontainingfigure(mapax.Parent);
                subplotContainer = figure;
                subplotContainer.Units='pixels';
                subplotContainer.Position = [60 60 1300 700];
                figure(subplotContainer)
            case 'uitabgroup'
                mapax = resfig;
                f=mycontainingfigure(mapax.Parent);
                subplotContainer = figure;
                subplotContainer.Units='pixels';
                subplotContainer.Position = [60 60 1300 700];
                figure(subplotContainer)
            case 'uitab'
                copyobj(findobj(resfig.Parent,'Tag','mainmap_ax'),resfig);
                mapax=findobj(resfig,'Tag','mainmap_ax');
                mapax.Tag='result_map';
                f=mycontainingfigure(mapax.Parent);
                subplotContainer = figure;
                subplotContainer.Units='pixels';
                subplotContainer.Position = [60 60 1300 700];
                figure(subplotContainer)
                
            otherwise
                warning('huh. unknown container');
        end
    else
        f=figure('Name','Data View');
        f.Units='pixels';
        f.Position = [60 60 1300 700];
        f.Resize='off';
        % main axes, with map-view of data
        mapax=axes(f,'units','pixels','Position',[50 150 650 500]);
        mapax.Tag = 'dvMap';
        grid on
        %f.KeyReleaseFcn = @(src,ev)disp(mapax.CurrentPoint);
        title(mapax, 'Data Map');
        xlabel(mapax,'Longitude');
        ylabel(mapax,'Latitude');
        mapax.YLim=[45.5 48];
        mapax.XLim=[5.75 8.75];
        subplotContainer=f;
    end
    % cross'colorbar(mapax);
    % mapax.UIContextMenu=mapcontext();
    
    bvalax=subplot(2,2,1);
    rateax=subplot(2,2,2);
    evdepax=subplot(2,2,3);
    momentax=subplot(2,2,4);
    
    analyPt = AnalysisPoint(mapax);
    
    
    % b-value axes, showing b-value rates
    %bvalax=axes(f,'units','pixels','Position',[850 375 300 275]);
    %bvalax=axes(f,'units','pixels','Position',[750 400 225 250]);
    bvalAnalyWin=AnalysisBvalues(bvalax);
    
    % cumulative event axes
    %rateax=axes(f,'units','pixels','Position',[750 100 225 250]);
    cumRateAnalyWin = CumRateAnalysisWindow(rateax);
    
    % event with depth axes
    %evdepax=axes(f,'units','pixels','Position',[1025 400 225 250]);
    
    %fff=figure;
    depAnalyWin = DepthAnalysisWindow(evdepax,...
        [floor(min(catalog.Depth)./5) : ceil(max(catalog.Depth)./5) ] .*5);
    
    %figure(f);
    
    % moment release axes
    %momentax=axes(f,'units','pixels','Position',[1025 100 225 250]);
    cumMomentAnalyWin=CumMomentAnalysisWindow(momentax);
    
    
    %%
    axes(mapax);
    set(gcf,'Pointer','cross')
    pause(.01)
    
    symbolIndexes = containers.Map;
    
    validMarkers={'+','o','*','.','x','s','d','v','^','<','>','p','h'};
    
    %disp('entering loop')
    curChar='o';
    
    
    % Instructions
    uicontrol('Style','text','Position',[10 45 200 20],...
        'String','LC: add/Move Pt, CC:Quit, RC:delete Pt',...
        'HorizontalAlignment','left');
    htmp=uicontrol('Style','text','Position',[10 25 200 20],'String','Change marker by pressing one of:',...
        'HorizontalAlignment','left');
    uicontrol('Style','text','Position',[(htmp.Position(1)+htmp.Extent(3)+5) 25 200 20],'String','os+.*xphv^',...
        'HorizontalAlignment','left', 'FontWeight','bold','FontName','fixedwidth');
    htmp=uicontrol('Style','text','Position',[10 5 105 20],...
        'String','Active marker: ', 'FontWeight','bold',...
        'HorizontalAlignment','left');
    amh= uicontrol('Style','text','Position',[(htmp.Position(1)+htmp.Extent(3)+5) 6 20 20],...
        'String', curChar, 'FontWeight','bold',...
        'HorizontalAlignment','left','FontName','fixedwidth');
    amh.FontSize=amh.FontSize * 1.2;
    
    %prepare_map_axes(f,mapax);
    %responseLoop()
    
    
    function prepare_map_axes(f,ax)
        
        % available FIGURE props (+UIContextMenu)
        
        %{
        %% statuses
        % CurrentAxes :
        % CurrentCharacter : last key pressed in figure
        % CurrentObject :
        % CurrentPoint :
        % SelectionType: 'Normal','Extend' [shift],'Alt' [ctrl],'Open'[dbl]. open is finnicky
        
        %% callbacks
        % CloseRequestFcn :
        % SizeChangedFcn :
        % WindowButtonDownFcn :
        % WindowButtonUpFcn :
        % WindowButtonMotionFcn :to get button position, use the axes' CurrentPoint x=(1,1), y=(1,2)
        %     and also do a drawnow if updating something graphical.  Values are reported in relation
        %     to requested axes.  So, for multiple axes, one would figure out which one the cursor
        %     is within  warning, drawnow might cause callback to be reentered.
        % WindowScrollWheelFcn : event contains 'VerticalScrollCount' and 'VerticalScrollAmount'
        %     if this property has a callback associated with it, then CurrentPoint is also updated
        %     prior to the callback's execution.
        % WindowKeyPressFcn : executes whenver the figure is in focus. Event has
        %     fields Character, Modifier, Key, Source, EventName
        % WindowKeyReleaseFcn :
        % ButtonDownFcn : also, see SelectionType to see what modifier keys were pressed
        % CreateFcn :
        % DeleteFcn :
        % KeyPressFcn : executes AFTER WindowKeyPressFcn, KeyPressFcn values can be intercepted
        %     a ui object (like a button) has defined a KeyPressFcn
        % KeyReleaseFcn :
        %}
        %{
        %% available AXES function callbacks (+UIContextMenu)
        % CurrentPoint :
        %
        % ButtonDownFcn :
        % CreateFcn :
        % DeleteFcn :
        
        %% available LINE callbacks (+UIContextMenu)
        % ButtonDownFcn :
        
        %% available UI object callbacks (buttons, etc)  (+UIContextMenu)
        % ButtonDownFcn :
        % CreateFcn :
        % DeleteFcn :
        % KeyPressFcn : executes AFTER WindowKeyPressFcn, KeyPressFcn values can be intercepted
        %     a ui object (like a button) has defined a KeyPressFcn
        % KeyReleaseFcn :
        %}
        oldMotionFcn=f.WindowButtonMotionFcn;
        oldKeyPressFcn=f.KeyPressFcn;
        f.WindowButtonMotionFcn=@do_nothing; % must be set in order to track mouse position
        f.KeyPressFcn = @kpfcb;
        oldAxButtonDownFcn = ax.ButtonDownFcn;
        ax.ButtonDownFcn=@kpfcb;
        sf=findobj(ax,'Type','surface');
        sf.ButtonDownFcn=@kpfcb;
        addmapcontext(sf);
        set(findobj(gca,'Type','image'),'HitTest','off');
        curChar = 'o';
        prevChar= ' ';
        
        function kpfcb(src,evt)
            % kpfcb KeyPressCallback executes at the figure level
            clickPos=ax.CurrentPoint(1,[1 2]);
            if ~insideAxes(ax, clickPos)
                return
            end
            
            if evt.EventName == "KeyPress"
                prevChar = curChar;
                curChar = evt.Character;
            elseif f.SelectionType == "alt"
                disp('right-click')
            end
            
            [~,idx]=min( (tb.y - clickPos(2)) .^2 +  (tb.x - clickPos(1)).^2 );% assuming cartesian axes
            %[~,idx]=min( distance([tb.y,tb.x], [clickPos(2), clickPos(1)]) );% assuming Lat-Lon axes
            
            [curChar,exitFlag] = evaluateChar(curChar, prevChar, idx, clickPos);
            if exitFlag
                restoreCallbacks
            end
            disp(tb(idx,:))
            
        end
            
        
        function tf = insideAxes(ax, xy)
            xl = ax.XLim;
            yl = ax.YLim;
            tf = ~ ( xy(1) > xl(2) || xy(1) < xl(1) || xy(2) > yl(2) ||xy(2) < yl(1) );
        end
        
        function restoreCallbacks()
            if isvalid(f)
                f.WindowMotionButton=oldMotionFcn;
                f.KeyPressFcn=oldKeyPressFcn;
                f.Pointer='arrow';
            end
            if isvalid(ax)
                ax.ButtonDownFcn=oldAxButtonDownFcn;
            end
        end
    end
    
    
    function [curChar,exitFlag] = evaluateChar(curChar, prevChar, index, clickPos)
        exitFlag=false;
        switch curChar
            case keyBindings.quit
                disp('Done')
                exitFlag=true;
                
                
            case keyBindings.delete
                disp('deleting closest selection')
                tag='';
                for n=symbolIndexes.keys
                    if symbolIndexes(n{:})==index
                        tag=n{:};
                        break;
                    end
                end
                if ~isempty(tag)
                    removeSeriesByTag(tag);

                end
                curChar=prevChar;
                
            case validMarkers
                
                ptName=sprintf('(%g,%g)',tb.y(index),tb.x(index));
                
                if any(strcmp(curChar, symbolIndexes.keys))
                    disp('symbol that is used')
                    plotAttribs={'DisplayName',sprintf('point %d',index)};
                else
                    disp('marker that wasn''t used yet. Creating')
                    plotAttribs={'Marker',curChar,'MarkerSize',12,...
                        'MarkerFaceColor','k','LineWidth',2, ...
                        'DisplayName',sprintf('point %d',index),...
                        'UIContextMenu',pointcontext(curChar)};
                end
                
                symbolIndexes(curChar)=index;
                
                analyPt.add_point(clickPos, tb(index,:), curChar, plotAttribs);
                thiscolor = analyPt.color(curChar);
                
                amh.ForegroundColor=thiscolor;
                
                theseEvents = catalog.selectCircle(res.EventSelector,tb.x(index),tb.y(index));
                theseEvents.Name=ptName;
                theseAttributes = {'Marker',curChar,'Color',thiscolor};
                
                cumRateAnalyWin.add_series(theseEvents,curChar,theseAttributes); % cum rate
                cumMomentAnalyWin.add_series(theseEvents,curChar,theseAttributes);%  cum moment
                depAnalyWin.add_series(theseEvents,curChar,theseAttributes); % events with depth
                bvalAnalyWin.add_series(theseEvents,curChar,theseAttributes); %b-val
                
                if ~isempty(mapax.Legend) && any(mapax.Legend.String == "do_not_show_in_legend")
                    legend(findobj(mapax.Children,'-not','DisplayName','do_not_show_in_legend','-not','Type','text'));
                end
                    
            otherwise
                disp('unmapped key')
        end
        

    end
    function removeSeriesByTag(tag)
        cumMomentAnalyWin.remove_series(tag);
        cumRateAnalyWin.remove_series(tag);
        depAnalyWin.remove_series(tag);
        analyPt.remove_point(tag)
        bvalAnalyWin.remove_series(tag);
        symbolIndexes.remove(tag);
    end
    function addmapcontext(obj)
        c=uicontextmenu('Tag','MapViewerMapContext');
        
        uimenu(c,'Label','Select Rectangle');
        uimenu(c,'Label','Select Circle');
        uimenu(c,'Label','Select Polygon');
        obj.UIContextMenu=c;
    end
    
    function c=pointcontext(marker)
        c=uicontextmenu('Tag','MapViewerPointContext');
        uimenu(c,'Label','Change Symbol');
        uimenu(c,'Label','Change Color');
        uimenu(c,'Label','Remove','MenuSelectedFcn',@(~,~)removeSeriesByTag(marker));
    end
end
function f = mycontainingfigure(f)
    while f.Type ~= "figure" && f.Type ~= "root"
        f=f.Parent;
    end
end