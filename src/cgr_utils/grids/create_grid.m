function [gr,zgr,pgr] = create_grid(pts)
    % Interactively define a grid
    %
    % [GR, ZGR] = CREATE_GRID(PTS)
    %     PTS is a polygon. only grid points with PTS will be shown
    %  GR is all data points, as [lon,lat; ...]
    %  ZGR is a ZmapGrid. This is only filled in if IGNORE_EFFECT_OF_LAT is true;
    %
    %  set creates PGR, which is a grid suitable for use in pcolor, but not for ZmapGrid
    %
    % Choose an origin point
    % Choose a point to define initial spacing
    % Use scroll Wheel to change spacing
    % Drag Point to change origin
    
    % If IGNORE_EFFECT_OF_LAT is true, then grid gets smaller as pole is approached.
    % Unfortunately, routines like pcolor this is necessary for pcolor, when Y axis is a lon.
    % This could be avoided if coordinate system was transformed into X-Y.
    %
    % When IGNORE_EFFECT_OF_LAT is false, then longitudes drift in order to keep consistent sized boxes.
    
    % TODO: add edit fields that allow grid to be further modified
    % TODO: add SAVE and LOAD buttons
    
    IGNORE_EFFECT_OF_LAT = false;
    name='grid';
    changed=false;
    pts =[... % SAMPLE POLYGON, FOR TESTING
    7.3500   47.8007;...
    8.3187   47.5009;...
    8.8392   46.6736;...
    8.4633   46.0321;...
    7.4801   45.7263;...
    6.5548   46.7095;...
    7.3500   47.8007...
    ];
    if ~exist('ZG','var') || isempty('ZG')
        ZG=ZmapGlobal.Data;
    end
    %clear pts
    % DISPLAY EVENTS
    
    f=figure('Name','Grid Selection','Units','pixels','Position',[200 75 730 700]);
    ax=subplot(4,4,[1,11]);
    ax.Units='points';
    ax.Position=fix(ax.Position);
    quake_dots=plot(ax,ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'.',...
        'color',[.75 .75 .8],'DisplayName','events');
    %axis([0 90 0 90])
    xlabel('longitude')
    ylabel('latitude')
    hold on;
    
    %DISPLAY SURFACE FEATURES
    copyobj(ZG.features('borders'),ax);
    
    % DISPLAY POLYGON
    if exist('pts','var')
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
    f.WindowButtonDownFcn=@md;
    f.WindowButtonUpFcn=@mu;
    f.DeleteFcn=@check_for_save
    
    write_string(t,'Scroll the mouse wheel to scale')
    %waitfor(f)
    
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
        if ~isempty(zgr)
            ZG.Grid=zgr;
        end
        changed=false;
        assignin('base','pgr',pgr);
    end
    
    function update_plot()
        %[gx,gy]=get_grid(x,y,dx,dy);
        %gpts_h.XData=gx(:);
        %gpts_h.YData=gy(:);
        changed=true;
        [gx,gy]=get_eq_grid(x,y,dx,dy);
        if exist('pts','var')
            ll=polygon_filter(pts(:,1),pts(:,2),gx(:),gy(:),'inside');
        else
            ll=true(size(gx(:)));
        end
        gpts_h2.XData=gx(ll);
        gpts_h2.YData=gy(ll);
        
        gr=[gpts_h2.XData(:), gpts_h2.YData(:)];
        
        if IGNORE_EFFECT_OF_LAT
            zgr=ZmapGrid(ned.String,unique(gx),unique(gy),'deg');
            zgr.ActivePoints(:)=ll;
        else
            zgr=[]; % ZMAPGRID has to have matrix of points, not point cloud
        end
        
        % assign pgrid
        ugy=unique(gy); % lats in matrix
        nrows=numel(ugy); % number of latitudes in matrix
        rowWithMost=min(abs(gy)); % latitude closest to equator will have most number of lons in matrix
        base_lon_idx=find(gx(gy==y)==x); % longitudes that must line up
        ncols=sum(abs(gy-rowWithMost)<0.001); % most number of lons in matrix
        ys=repmat(ugy(:),1,ncols);
        xs=nan(nrows,ncols);
        for n=1:nrows
            n
            thislat=ugy(n); % lat for this row
            idx_lons=(gy==thislat); % mask of lons in this row
            these_lons=gx(idx_lons); % lons in this row
            row_length=numel(these_lons) % number of lons in this row
            
            main_lon_idx=find(these_lons==x) % offset of X in this row
            %delta=main_lon_idx - base_lon_idx % offset of X in this row compared to standard row
            
            for i=1:row_length
                idx=i;%+delta;
                xs(n,idx)=these_lons(i);
            end
        end
        pgr.xs=xs;
        pgr.ys=ys;
        if exist('pts','var')
            ll=polygon_filter(pts(:,1),pts(:,2),pgr.xs,pgr.ys,'inside');
            pgr.xs(~ll)=nan;
            pgr.ys(~ll)=nan;
        end
        
        
        
        
        
        
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
        if IGNORE_EFFECT_OF_LAT
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
    
    function md(src,~)
        %mouse down, so make origin follow mouse around
        %disp(ev)
        %disp(ax.CurrentPoint)
        src.WindowButtonMotionFcn=@mv;
        %disp('  ');
        src.Pointer='cross';
    end
    function mu(src,~)
        %mouse up, so ignore position
        %disp(ev)
        %disp(ax.CurrentPoint);
        src.WindowButtonMotionFcn='';
        %disp('  ');
        update_plot()
        src.Pointer='arrow';
    end
    function mv(~,~)
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
