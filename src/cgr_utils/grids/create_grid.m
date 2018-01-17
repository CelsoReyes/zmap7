function [pgr] = create_grid(pts, follow_parallels)
    % Interactively define a grid
    %
    % CREATE_GRID will create a ZmapGrid interactively. Upon closing the window or choosing "Set"
    % the global ZmapData.Grid will be updated.
    %
    % CREATE_GRID(PTS) PTS is a polygon. only grid points with PTS will be shown
    %  GR is all data points, as [lon,lat; ...]
    %  ZGR is a ZmapGrid.
    % CREATE_GRID(PTS, FOLLOW_PARALLELS) if FOLLOW_PARALLELS is false, then distances are constant.
    % if FOLLOW_PARALLELS is TRUE, then degrees of longitude are constant.
    %
    % Choose an origin point
    % Choose a point to define initial spacing
    % Use scroll Wheel to change spacing
    % Drag Point to change origin
    %
    % tests:
    %  create_grid('testpoly')
    %  create_grid('testworld');
    %
    % If FOLLOW_PARALLELS is true, then grid gets smaller as pole is approached.
    % Unfortunately, routines like pcolor this is necessary for pcolor, when Y axis is a lon.
    % This could be avoided if coordinate system was transformed into X-Y.
    %
    % When FOLLOW_PARALLELS is false, then longitudes drift in order to keep consistent sized boxes.
    
    % TODO: add edit fields that allow grid to be further modified
    % TODO: add SAVE and LOAD buttons
    % TODO: make this work with gridfun
    
    
    FOLLOW_PARALLELS = exist('follow_parallels','var') && follow_parallels;
    USEPOLY=exist('pts','var') && ~isempty(pts) && ~isnan(pts(1));
    name='grid';
    changed=false;
    
        ZG=ZmapGlobal.Data;
    
    f=figure('Name','Grid Selection','Units','pixels','Position',[200 75 730 700]);
    
    % DISPLAY EVENTS
    ax=subplot(4,4,[1,11]);
    ax.Units='points';
    ax.Position=fix(ax.Position);
    plot(ax,ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'.',...
        'color',[.75 .75 .8],'DisplayName','events');
    xlabel('longitude')
    ylabel('latitude')
    hold on;
    
    if exist('pts','var') && ischar(pts)
        switch pts
            case 'testpoly'
                pts =[... % SAMPLE POLYGON, FOR TESTING
                    7.3500   47.8007;...
                    8.3187   47.5009;...
                    8.8392   46.6736;...
                    8.4633   46.0321;...
                    7.4801   45.7263;...
                    6.5548   46.7095;...
                    7.3500   47.8007...
                    ];
            case 'testworld'
                clear pts
                axis([0 90 -20 80])
        end
    end
    
    %DISPLAY SURFACE FEATURES
    copyobj(ZG.features('borders'),ax);
    
    % DISPLAY POLYGON
    if USEPOLY
        plot(ax, pts(:,1),pts(:,2),'k:','linewidth',2,'DisplayName','polygon');
    end
    
    legend(ax,'show')
    
    % SHOW INSTRUCTIONS
    t = uicontrol('style','text','units','pixels','position',[10 10 300 20],'String','temporary');
    
    % FEEDBACK
    tp = uicontrol('style','text','Units','pixels','Position',[10 50 300 20],'String','N Points: ???');
    d = uicontrol('style','text','Units','pixels','Position',[10 30 300 20],'String','Dist: ???? (deg) [???? (km)]');
    
    % ADDITIONAL CONTROLS
    uicontrol('style','pushbutton','Units','pixels','Position',[310 30 50 20],'String','SET','Callback',@set_grid);
    ned = uicontrol('style','edit','Units','pixels','Position',[310 70 50 20],'String',name,'Callback',@(~,~)update_plot());
    
    uicontrol('style','checkbox','Units','pixels','Position',[310 30 80 20],'String','Follow Parallels? (adjusts for lat)','Callback',@toggle_parallels);
    % SELECT FIXED POINT
    write_string(t,'Enter a fixed point for the grid');
    [x,y]=ginput(1);
    fp=plot(ax,x,y,'b+','linewidth',2,'DisplayName','Origin');
    instruction_end(t)
    
    % SELECT OTHER POINT
    write_string(t,'Click at a distance that will define a grid');
    [x2,y2]=ginput(1);
    %tmph=plot(ax,x2,y2,'bo','linewidth',2)
    instruction_end(t);
    
    dx = abs(x2-x);
    dy = abs(y2-y);
    
    % SELECT INITIAL GRID
    %[gridx,gridy]=get_grid(x,y,dx,dy);
    %gpts_h=plot(gridx(:),gridy(:),'r+');
    gpts_h2=plot(nan,nan,'gx','DisplayName','grid');
    
    update_plot();
    
    f.WindowScrollWheelFcn=@adjust_grid;
    f.WindowButtonDownFcn=@mouse_down;
    f.WindowButtonUpFcn=@mouse_up;
    f.DeleteFcn=@check_for_save;
    
    write_string(t,'Scroll the mouse wheel to scale')
    if nargout > 0 
        waitfor(f)
    end
    
    function adjust_grid(~,ev)
        % adjust grid spacing when mouse wheel is scrolled
        scale=1.05;
        %disp(ev)
        if ev.VerticalScrollCount > 0
            dx=dx.*scale;
            dy=dy.*scale;
        elseif ev.VerticalScrollCount < 0
            dx=dx./scale;
            dy=dy./scale;
        end
        update_plot();
    end
    
    function set_grid(~,~)
        ZG.Grid=ZmapGrid(name,pgr.xs,pgr.ys,'deg');
        changed=false;
    end
    
    function toggle_parallels(src,~)
        FOLLOW_PARALLELS=src.Value==1;
        update_plot();
    end
    
    function update_plot()
        %[gx,gy]=get_grid(x,y,dx,dy);
        %gpts_h.XData=gx(:);
        %gpts_h.YData=gy(:);
        changed=true;
        [gx,gy]=get_eq_grid(x,y,dx,dy);
        if USEPOLY
            ll=polygon_filter(pts(:,1),pts(:,2),gx(:),gy(:),'inside');
        else
            ll=true(size(gx(:)));
        end
        gpts_h2.XData=gx(ll);
        gpts_h2.YData=gy(ll);
        
        gr=[gpts_h2.XData(:), gpts_h2.YData(:)];
        
        % assign pgrid
        ugy=unique(gy); % lats in matrix
        nrows=numel(ugy); % number of latitudes in matrix
        [~,example]=min(abs(gy(:))); % latitude closest to equator will have most number of lons in matrix
        mostCommonY=gy(example); % account for the abs possibly flipping signs
        base_lon_idx=find(gx(gy==mostCommonY)==x); % longitudes that must line up
        ncols=sum(gy(:)==mostCommonY); % most number of lons in matrix
        ys=repmat(ugy(:),1,ncols);
        xs=nan(nrows,ncols);
        for n=1:nrows
            thislat=ugy(n); % lat for this row
            idx_lons=(gy==thislat); % mask of lons in this row
            these_lons=gx(idx_lons); % lons in this row
            row_length=numel(these_lons); % number of lons in this row
            
            main_lon_idx=find(these_lons==x); % offset of X in this row
            offset=base_lon_idx - main_lon_idx;
            xs(n,[1:row_length]+offset)=these_lons;
        end
        pgr.xs=xs;
        pgr.ys=ys;
        if USEPOLY
            ll=polygon_filter(pts(:,1),pts(:,2),pgr.xs,pgr.ys,'inside');
            pgr.xs(~ll)=nan;
            pgr.ys(~ll)=nan;
        end
        
        pgr=trim_nans(pgr);
        
        tp.String=sprintf('N Points: %d',sum(ll));
    end
    
    function [gridx,gridy] = get_eq_grid(x0,y0,dx,dy)
        dd = max([distance(y0,x0,y0,x0+dx,'degrees'), distance(y0,x0,y0+dy,x0,'degrees')]);
        d.String=sprintf('Dist: %.3f (deg) [%.3f (km)]',dd,deg2km(dd));
        yl = ylim(ax);
        xl = xlim(ax);
        
        % pick out y spacing
        ytk = unique([y0 : -dd : yl(1) , y0: dd : yl(2)]);
        gridx=[];
        gridy=[];
        if FOLLOW_PARALLELS
            [~,dx]=reckon('rh',y0,0,dd,90); % find longitudinal distance at this latitude
            xtk = unique([x0 : -dx : xl(1) , x0 : dx :xl(2)]);
            [gridx,gridy]=meshgrid(xtk,ytk);
        else
            [~,dxs]=reckon('rh',ytk,0,dd,90);
            for n=1:numel(ytk)
                xtk = unique([x0 : -dxs(n) : xl(1) , x0 : dxs(n) :xl(2)]);
                gridx=[gridx;xtk(:)];
                gridy=[gridy;repmat(ytk(n),size(xtk(:)))];
            end
        end
        
    end
    
    function [gridx,gridy] = get_grid(x0,y0,dx,dy)
        xl = xlim(ax);
        xtk = unique([x0 : -dx : xl(1) , x0 : dx :xl(2)]);
        
        yl = ylim(ax);
        ytk = unique([y0 : -dy : yl(1) , y0: dy : yl(2)]);
        
        [gridx,gridy]=meshgrid(xtk,ytk);
    end
    
    function mouse_down(src,~)
        %mouse down, so make origin follow mouse around
        %disp(ev)
        %disp(ax.CurrentPoint)
        src.WindowButtonMotionFcn=@mouse_move;
        %disp('  ');
        src.Pointer='cross';
    end
    
    function mouse_up(src,~)
        %mouse up, so ignore position
        %disp(ev)
        %disp(ax.CurrentPoint);
        src.WindowButtonMotionFcn='';
        %disp('  ');
        update_plot()
        src.Pointer='arrow';
    end
    
    function mouse_move(~,~)
        x=ax.CurrentPoint(1,1);
        y=ax.CurrentPoint(1,2);
        fp.XData=x;
        fp.YData=y;
    end
    
    function check_for_save(src,ev)
        if changed
            dosave=questdlg('Save Changes?','Grid Creation','Yes','No','Yes');
            if strcmpi(dosave,'Yes')
                set_grid([],[]);
            end
        end
    end
    
end


function write_string(h,str)
    for i=1:length(str)-1
        h.String=[str(1:i),'..'];
        pause(.01);
    end
    h.String=str;
end

function instruction_end(h)
    h.ForegroundColor=[0 .5 0];
    pause(.3);
    h.String='';
    h.ForegroundColor='k';
end

function pgr=trim_nans(pgr)
        % REMOVE GRID POINTS BEYOND POLYGON (rows & cols of all nans)
        nanrows=all(isnan(pgr.xs),2);
        nancols=all(isnan(pgr.xs),1);
        pgr.xs(nanrows,:)=[];pgr.xs(:,nancols)=[];
        pgr.ys(nanrows,:)=[];pgr.ys(:,nancols)=[];
end


function c=mycontext()
    c=uicontextmenu
    
    uimenu(c,'Label','Select Rectangle');
    uimenu(c,'Label','Select Circle');
    uimenu(c,'Label','Select Polygon');
    uimenu(c,'Separator','on','Label','Create Polygon');
end
