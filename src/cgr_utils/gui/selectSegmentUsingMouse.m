function [obj, ok]=selectSegmentUsingMouse(ax, varargin)
    % tracks user mouse movements to define a great-circle line segment
    % RESULT = SELECTSEGMENTUSINGMOUSE( AX, COLOR, additionalUpdateFcn) where AX is the axis in which to
    % draw your line segment as the great-circle line.
    %
    % RESULT is a struct with fields:
    %   xy1 : starting point [x , y]
    %   xy2 : ending point [x , y]
    %   dist: distance between x & y in units specified by the figure's RefEllipsoid (stored in its appdata).
    %
    % once the segment has been chosen, it is removed from the plot.
    
    
    ABORTKEY=27; % escape;
    ok=false;
    
    p = inputParser();
    p.addRequired('ax');
    p.addRequired('color')
    p.addOptional('addlUpdateFcn',@do_nothing);
    p.parse(ax, varargin{:});
    
    axes(ax);
    color = p.Results.color;
    addlUpdateFcn = p.Results.addlUpdateFcn;
    
    fig = ancestor(ax,'figure');
    
    
    if ~(isnumeric(ax.XLim) && isnumeric(ax.YLim))
        complain_about_axes(ax)
        return
    end
        
    refEllipse  = getappdata(fig, 'RefEllipsoid');
    
    %% 
    started=false;
    
    % create a struct
    obj.xy1     = [nan nan];
    obj.xy2     = [nan nan];
    obj.units   = refEllipse.LengthUnit;
    obj.dist    =  0;
    
    [x1, y1, x2, y2]=deal(nan);
    
    % select center point, if it isn't provided
    disp('click on segment start');% . ESC aborts');
    
    if fig.CurrentCharacter==ABORTKEY
        fig.CurrentCharacter=' ';
    end
    
    TMP.aBDF = ax.ButtonDownFcn;
    TMP.fWBUF = fig.WindowButtonUpFcn;
    TMP.fWBMF=fig.WindowButtonMotionFcn;
    
    h = gobjects(0);
    
    ax.ButtonDownFcn=@startSegment;
    fig.WindowButtonMotionFcn=@queryFirstPoint;
    
    
    selected = false;
    fig.Pointer = 'Cross';
    instructionTextFmt  = 'Choose start point\n (x:%g, y:%g)';
    instructionText     = text(nan,nan,'Choose start point','FontSize',12,...
        'FontWeight','bold','HitTest','off','BackgroundColor','w');
    
    if iscartesian(refEllipse)
        dist = @(x1,y1,x2,y2) sqrt((x1-x2).^2 + (y1-y2).^2);
    else
        dist = @(x1,y1,x2, y2) distance(y1,x1,y2,x2,refEllipse);
    end
    
    %% pause because we need completed user input before exiting this function
    while ~started
        pause(.01);
    end
    disp('started!')
    
    b = fig.CurrentCharacter;
    if b==ABORTKEY
        % restore previous window functions
        fig.WindowButtonMotionFcn = TMP.fWBMF;
        fig.WindowButtonUpFcn     = TMP.fWBUF;
        ax.ButtonDownFcn        = TMP.aBDF;
        fig.Pointer             = 'arrow';
        delete(instructionText);
        delete(h);
        fig.CurrentCharacter = ' ';
        if nargout<2
            error('Aborting segment creation'); %to calling routine: catch me!
        else
            return;
        end
    end
    
    set(ax,'NextPlot','add');
 
    %% loop waits for mouse button to come back up before continuing
    
    while ~selected
        pause(.05)
    end
    disp('selection done!');
    obj.xy1 = [x1,y1];
    obj.xy2 = [x2,y2];
    obj.units = refEllipse.LengthUnit;
    obj.dist = dist(x1,y1,x2,y2);
    
    delete(h);
    
    b=  fig.CurrentCharacter;
    if b == ABORTKEY
        fig.CurrentCharacter=' ';
    else
        ok = true;
    end
        
    return
    
    %%
    function complain_about_axes(ax)
        ed=errordlg('Axes should be degrees or distance, the selected axes has a non numeric scale');
        origcolor = ax.Color;
        bringToForeground(ax);
        drawnow;
        ax.Color=[1 .7 .7];
        waitfor(ed);
        ax.Color=origcolor;
    end
    
    function startSegment(~,ev)
        disp('start Line'); 
        set(gca,'NextPlot','add');
        cp = ax.CurrentPoint;
        
        x1 = cp(1,1);
        y1 = cp(1,2);
        h = plot(ax,[x1;x1], [y1;y1], 'o:','MarkerSize',15,'color','k',...
            'MarkerFaceColor',color,'MarkerEdgeColor','k',...
            'LineWidth',2,'DisplayName','Choose Xsection');
        started = true;
        
        % write the text
        h(2)=text((x1+x2)/2,(y1+y2)/2,['Dist: 0 ' refEllipse.LengthUnit],...
            'FontSize',12,'FontWeight','bold','Color',color);
        
        
        fig.WindowButtonMotionFcn = @moveMouse;
        
        instructionTextFmt = 'Choose end point\n (x:%g, y:%g)';
        instructionText.String = sprintf(instructionTextFmt,x1,y1);
    end
    
    function v = range_limited(v, minmax)
        if v > minmax(2)
            v = minmax(2);
        elseif v < minmax(1)
            v = minmax(1);
        end
    end
        
    function queryFirstPoint(~,~)
        % move mouse before any point is selected
        cp = ax.CurrentPoint;
        xl = ax.XLim; 
        x = range_limited(cp(1,1), xl);
        y = range_limited(cp(1,2), ax.YLim);

        dx = abs(diff(xl))/100;
        if (x > mean(xl)) 
            textPos = [x-dx y 0]; 
            hAlign = 'right';
        else
            textPos = [x+dx y 0]; 
            hAlign = 'left';
        end
        set(instructionText,'HorizontalAlignment',hAlign,'Position',textPos,'String',sprintf(instructionTextFmt,x,y));
        
    end
    
    function moveMouse(~,~)
        cp = ax.CurrentPoint;
        ax.ButtonDownFcn      = @endSegment;
        fig.WindowButtonUpFcn = @endSegment;
        x2 = range_limited(cp(1,1), ax.XLim);
        y2 = range_limited(cp(1,2), ax.YLim);
        
        if iscartesian(refEllipse)
            h(1).XData(2) = x2;
            h(1).YData(2) = y2;
        else
            [h(1).YData, h(1).XData] = gcwaypts(y1,x1, y2, x2,20);
            h(1).MarkerIndices = [1 numel(h(1).YData)];
        end
        
        obj.dist = dist(x1,y1,x2,y2);
        h(2).Position(1:2)  = [(x1+x2)/2,(y1+y2)/2];
        h(2).String         = ['Dist:' num2str(obj.dist,4) ' ' refEllipse.LengthUnit];
        
        % update instruction text
        dx=abs(diff(ax.XLim))/100;
        if (x2 > mean(ax.XLim)) 
            set(instructionText,'HorizontalAlignment','right','Position',[x2-dx y2 0],'String',sprintf(instructionTextFmt,x2,y2));
        else
            set(instructionText,'HorizontalAlignment','left','Position',[x2+dx y2 0],'String',sprintf(instructionTextFmt,x2,y2));
        end
        addlUpdateFcn([x1 y1],[x2 y2],obj.dist);
    end
    
    
    function endSegment(~,~)
        if strcmp(fig.SelectionType, 'open')
            % was a double click. just ignore it.
            return
        end
        
        if isvalid(instructionText)
            delete(instructionText);
        end
        
        selected = true;
        fig.WindowButtonMotionFcn = TMP.fWBMF;
        fig.WindowButtonUpFcn     = TMP.fWBUF;
        ax.ButtonDownFcn        = TMP.aBDF;
        fig.Pointer             = 'arrow';
        
    end
    
end