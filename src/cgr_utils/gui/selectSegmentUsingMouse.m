function obj=selectSegmentUsingMouse(ax, axunits, dispunits, color)
    % SELECTSEGMENTSUSINGMOUSE tracks user mouse movements to define a great-circle line segment
    % RESULT = SELECTSEGMENTSUSINGMOUSE( AX, AXUNITS, DISPUNITS, COLOR) where AX is the axis in which to
    % draw your line segment.  AXUNITS is the distance units of the axis (either 'deg' or 'km').
    % If axis is deg, then the line sement is drawn as the great-circle line.  Otherwise, it is a 
    % straight line (in cartesian coords). DISPUNITS are the units in which the distance is reported
    % (either 'deg' or 'km').  color is the color in which the line segment is drawn.
    %
    % RESULT is a struct with fields:
    %   xy1 : starting point [x , y]
    %   xy2 : ending point [x , y]
    %   IF dispunits is 'km', then the field returned is:
    %   dist_km : distance between x & y in km.
    %   IF dispunits is 'deg', then the field returned is:
    %   dist_deg : distance between x & y in deg
    %
    % once the segment has been chosen, it is removed from the plot.
    
    ABORTKEY=27; % escape;
    if ~exist('ax','var')
        ax=gca; 
    else
        axes(ax);
    end
    if ~exist('color','var')
        color='k';
    end
    
    if ~exist('axunits','var') || isempty(axunits)
        axunits='km';
    end
    
    if ~exist('dispunits','var') || isempty(dispunits)
        dispunits='km';
    end
    
    fig=gcf;
    started=false;
    
    obj=struct('xy1',[nan nan],'xy2',[nan nan],['dist_',dispunits],0);
    
    [x1, y1, x2, y2]=deal(nan);
    
    % select center point, if it isn't provided
    disp('click on segment start');% . ESC aborts');
    f=gcf;
    
    TMP.aBDF = ax.ButtonDownFcn;
    TMP.fWBUF = f.WindowButtonUpFcn;
    TMP.fWBMF=f.WindowButtonMotionFcn;
    
    h = gobjects(0);
    
    ax.ButtonDownFcn=@startSegment;
    f.WindowButtonMotionFcn=@queryFirstPoint;
    
    
    
    selected=false;
    fig.Pointer='Cross';
    instructionText = text(nan,nan,'Choose start point','FontSize',12,...
        'FontWeight','bold','HitTest','off','BackgroundColor','w');
    
    
    switch dispunits
        case 'km'
            switch axunits
                case 'km'
                    dist=@(x1,y1,x2,y2) sqrt((x1-x2).^2 + (y1-y2).^2);
                case 'deg'
                    dist=@(x1,y1,x2, y2)deg2km( distance(y1,x1,y2,x2));
            end
        case 'deg'
            switch axunits
                case 'km'
                    dist=@(x1,y1,x2,y2)km2deg(sqrt((x1-x2).^2 + (y1-y2).^2));
                case 'deg'
                    dist=@(x1,y1,x2, y2)distance(y1,x1,y2,x2);
            end
    end
    distfld=(['dist_',dispunits]);
    % pause because we need completed user input before exiting this function
    while ~started
        pause(.01);
    end
    disp('started!')
    % set center using ginput, which reads the button down
    b=0;
    
    
    b=f.CurrentCharacter;
    if b==ABORTKEY
        % restore previous window functions
        f.WindowButtonMotionFcn=TMP.fWBMF;
        f.WindowButtonUpFcn=TMP.fWBUF;
        ax.ButtonDownFcn=TMP.aBDF;
        fig.Pointer='arrow';
        error('Aborting segment creation'); %to calling routine: catch me!
    end
    
    hold on;
 
    % loop waits for mouse button to come back up before continuing
    
    while ~selected
        pause(.05)
    end
    disp('selection done!');
    obj.xy1=[x1,y1];
    obj.xy2=[x2,y2];
    obj.(distfld)=dist(x1,y1,x2,y2);
    
    delete(h);
    return
    
    function startSegment(~,ev)
        disp('start Line'); 
        hold on;
        cp=ax.CurrentPoint;
        
        x1=cp(1,1);
        y1=cp(1,2);
        h=plot(ax,[x1;x1], [y1;y1], 'o:','MarkerSize',15,'color','k',...
            'MarkerFaceColor',color,'MarkerEdgeColor','k',...
            'linewidth',2,'DisplayName','Choose Xsection');
        started=true;
        
        % write the text
        h(2)=text((x1+x2)/2,(y1+y2)/2,['Dist: 0 ' dispunits],...
            'FontSize',12,'FontWeight','bold','Color',color);
        switch axunits
            case 'deg'
                f.WindowButtonMotionFcn=@moveMouseGC;
            case 'km'
                f.WindowButtonMotionFcn=@moveMouse;
        end
        instructionText.String='Choose end point';
    end
    
    function v = range_limited(v, minmax)
        if v>minmax(2)
            v=minmax(2);
        elseif v<minmax(1)
            v=minmax(1);
        end
    end
        
    function queryFirstPoint(~,~)
        % move mouse before any point is selected
        cp=ax.CurrentPoint;
        xl=ax.XLim; 
        x=range_limited(cp(1,1), xl);
        y=range_limited(cp(1,2), ax.YLim);

        dx=abs(diff(xl))/100;
        if (x > mean(xl)) 
            set(instructionText,'HorizontalAlignment','right','Position',[x-dx y 0]);
        else
            set(instructionText,'HorizontalAlignment','left','Position',[x+dx y 0]);
        end
    end
    
    function moveMouse(~,~)
        cp=ax.CurrentPoint;
        ax.ButtonDownFcn=@endSegment;
        f.WindowButtonUpFcn=@endSegment;
        x2=range_limited(cp(1,1), ax.XLim);
        y2=range_limited(cp(1,2), ax.YLim);
        h(1).XData(2)=x2;
        h(1).YData(2)=y2;
        obj.(distfld)=dist(x1,y1,x2,y2);
        h(2).Position(1:2)= [(x1+x2)/2,(y1+y2)/2];
        h(2).String=['Dist:' num2str(obj.(distfld),4) ' ' dispunits];
        
        % update instruction text
        dx=abs(diff(ax.XLim))/100;
        if (x2 > mean(ax.XLim)) 
            set(instructionText,'HorizontalAlignment','right','Position',[x2-dx y2 0]);
        else
            set(instructionText,'HorizontalAlignment','left','Position',[x2+dx y2 0]);
        end
    end
    
    function moveMouseGC(~,~)
        cp=ax.CurrentPoint;
        ax.ButtonDownFcn=@endSegment;
        f.WindowButtonUpFcn=@endSegment;
        x2=range_limited(cp(1,1), ax.XLim);
        y2=range_limited(cp(1,2), ax.YLim);
        [h(1).YData, h(1).XData]=gcwaypts(y1,x1, y2, x2,20);
        h(1).MarkerIndices=[1 numel(h(1).YData)];
        obj.(distfld)=dist(x1,y1,x2,y2);
        h(2).Position(1:2)= [(x1+x2)/2,(y1+y2)/2];
        h(2).String=['Dist:' num2str(obj.(distfld),4) ' ' dispunits];
        
        % update instruction text
        dx=abs(diff(ax.XLim))/100;
        if (x2 > mean(ax.XLim)) 
            set(instructionText,'HorizontalAlignment','right','Position',[x2-dx y2 0]);
        else
            set(instructionText,'HorizontalAlignment','left','Position',[x2+dx y2 0]);
        end
    end
    
    
    function endSegment(~,~)
        if strcmp(f.SelectionType, 'open')
            % was a double click. just ignore it.
            return
        end
        
        if isvalid(instructionText)
            delete(instructionText);
        end
        
        selected=true;
        f.WindowButtonMotionFcn=TMP.fWBMF;
        f.WindowButtonUpFcn=TMP.fWBUF;
        ax.ButtonDownFcn=TMP.aBDF;
        fig.Pointer='arrow';
        
    end
    
end