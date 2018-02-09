function obj=selectSegmentUsingMouse(ax, color)
    ABORTKEY=27; % escape;
    if ~exist('ax','var')
        ax=gca; 
    else
        axes(ax)
    end
    if ~exist('color','var')
        color='k'
    end
    fig=gcf;
    started=false;
    obj=struct('xy1',[nan nan],'xy2',[nan nan],'dist_km',[0]);
    
    [x1, y1, x2, y2]=deal(nan);
    sel_start=tic;
    sel_elapse=toc(sel_start);
    
    % select center point, if it isn't provided
    disp('click on segment start');% . ESC aborts');
    f=gcf;
    TMP.fWBMF=f.WindowButtonMotionFcn;
    f.WindowButtonMotionFcn=@moveMouse;
    TMP.fWBUF = f.WindowButtonUpFcn;
    f.WindowButtonUpFcn=@endSegment;
    TMP.aBDF = ax.ButtonDownFcn;
    ax.ButtonDownFcn=@startSegment;
    
    x2=nan;
    y2=nan;
    selected=false;
    tmpstartpth=[];
    fig.Pointer='Cross';
    while ~started
        pause(.01);
    end
    disp('started!')
    % set center using ginput, which reads the button down
    b=0;%[x1,y1,b] = ginput(1);
    sel_start=tic;
    
    
    
    if b==ABORTKEY
        % restore previous window functions
        f.WindowButtonMotionFcn=TMP.fWBMF;
        f.WindowButtonUpFcn=TMP.fWBUF;
        ax.ButtonDownFcn=TMP.aBDF;
        fig.Pointer='arrow';
        error('Aborting segment creation'); %to calling routine: catch me!
    end
    
    hold on;
    %% mouse should still be pressed.
    delete(tmpstartpth);
    % draw line from origin to edge of circle
    h=plot([x1;x1],[y1;y1],'+:','markersize',10,'linewidth',2,'color',color);
    
    % write the text
    h(2)=text((x1+x2)/2,(y1+y2)/2,['Dist:' num2str(obj.dist_km,4) ' km'],...
        'FontSize',12,'FontWeight','bold','Color',color);
    hold off;
    
    % loop waits for mouse button to come back up before continuing
    while ~selected
        pause(.05)
    end
    disp('selection done!');
    obj.xy1=[x1,y1];
    obj.xy2=[x2,y2];
    obj.dist_km=deg2km(distance(y1,x1,y2,x2));
    
    % by now we have the new points and the distance.
    f.WindowButtonMotionFcn=TMP.fWBMF;
    f.WindowButtonUpFcn=TMP.fWBUF;
    ax.ButtonDownFcn=TMP.aBDF;
    pause(1)
    delete(h);
    fig.Pointer='arrow';
    
    function moveMouse(~,~)
        cp=get(gca,'CurrentPoint');
        x2=cp(1,1);
        y2=cp(1,2);
        h(1).XData(2)=x2;
        h(1).YData(2)=y2;
        obj.dist_km=deg2km(distance(y1,x1,y2,x2)); % assuming degrees.
        h(2).Position(1:2)= [(x1+x2)/2,(y1+y2)/2];
        h(2).String=['Dist:' num2str(obj.dist_km,4) ' km'];
    end
    
    function startSegment(~,ev)
        disp('start Line'); hold on;
        x1=ax.CurrentPoint(1,1);y1=ax.CurrentPoint(1,2)
        tmpstartpth=plot(ax,x1,y1,'+','MarkerSize',20,'color',color);
        sel_start=tic;
        started=true;
    end
    
    function endSegment(~,ev)
        cp=get(gca,'CurrentPoint');
        sel_elapse=toc(sel_start);
        disp(sel_elapse)
        if sel_elapse >=1 % prevent accidental click.
            selected=true;
        end
        disp(ev);
    end
    
end