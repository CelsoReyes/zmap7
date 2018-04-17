function obj=selectSegmentUsingMouse(ax, color)
    ABORTKEY=27; % escape;
    if ~exist('ax','var')
        ax=gca; 
    else
        axes(ax);
    end
    if ~exist('color','var')
        color='k';
    end
    
    fig=gcf;
    started=false;
    
    obj=struct('xy1',[nan nan],'xy2',[nan nan],'dist_km',0);
    
    [x1, y1, x2, y2]=deal(nan);
    sel_start=tic;
    % sel_elapse=toc(sel_start);
    
    % select center point, if it isn't provided
    disp('click on segment start');% . ESC aborts');
    f=gcf;
    
    TMP.aBDF = ax.ButtonDownFcn;
    TMP.fWBUF = f.WindowButtonUpFcn;
    TMP.fWBMF=f.WindowButtonMotionFcn;
    
    ax.ButtonDownFcn=@startSegment;
    
    
    selected=false;
    fig.Pointer='Cross';
    
    % pause because we need completed user input before exiting this function
    while ~started
        pause(.01);
    end
    disp('started!')
    % set center using ginput, which reads the button down
    b=0;
    sel_start=tic;
    
    
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
    %{
    %% mouse should still be pressed.
    % draw line from origin to edge of circle
    h=plot([x1;x1],[y1;y1],'+:','markersize',10,'linewidth',2,'color',color);
    
    % write the text
    h(2)=text((x1+x2)/2,(y1+y2)/2,['Dist:' num2str(obj.dist_km,4) ' km'],...
        'FontSize',12,'FontWeight','bold','Color',color);
    hold off;
    
    % loop waits for mouse button to come back up before continuing
    %}
    while ~selected
        pause(.05)
    end
    disp('selection done!');
    obj.xy1=[x1,y1];
    obj.xy2=[x2,y2];
    obj.dist_km=deg2km(distance(y1,x1,y2,x2));
    
    delete(h);
    
    function startSegment(~,ev)
        disp('start Line'); 
        hold on;
        cp=ax.CurrentPoint;
        
        x1=cp(1,1);
        y1=cp(1,2);
        h=plot(ax,[x1;x1], [y1;y1], '+:','MarkerSize',20,'color',color,'linewidth',2);
        %sel_start=tic;
        started=true;
        
        % write the text
        h(2)=text((x1+x2)/2,(y1+y2)/2,['Dist: 0 km'],...
            'FontSize',12,'FontWeight','bold','Color',color);
        
        f.WindowButtonMotionFcn=@moveMouse;
    end
    
    function moveMouse(~,~)
        cp=ax.CurrentPoint;
        ax.ButtonDownFcn=@endSegment;
        f.WindowButtonUpFcn=@endSegment;
        x2=cp(1,1);
        y2=cp(1,2);
        h(1).XData(2)=x2;
        h(1).YData(2)=y2;
        obj.dist_km=deg2km(distance(y1,x1,y2,x2)); % assuming degrees.
        h(2).Position(1:2)= [(x1+x2)/2,(y1+y2)/2];
        h(2).String=['Dist:' num2str(obj.dist_km,4) ' km'];
    end
    
    
    function endSegment(~,~)
        if strcmp(f.SelectionType, 'open')
            % was a double click. just ignore it.
            return
        end
        %cp=get(gca,'CurrentPoint');
        %sel_elapse=toc(sel_start);
        %disp(sel_elapse)
        %if sel_elapse >=1 % prevent accidental click.
        selected=true;
        f.WindowButtonMotionFcn=TMP.fWBMF;
        f.WindowButtonUpFcn=TMP.fWBUF;
        ax.ButtonDownFcn=TMP.aBDF;
        fig.Pointer='arrow';
    end
    
end