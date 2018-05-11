function [pgr] = create_grid(pts, follow_meridians, trim_final_grid_to_shape)
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
    
    
    FOLLOW_PARALLELS = exist('follow_parallels','var') && follow_meridians;
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
                USEPOLY=false
                clear pts
                axis([0 90 -20 80])
        end
    end
    
    %DISPLAY SURFACE FEATURES
    copyobj(ZG.features('borders'),ax);
    
    % DISPLAY POLYGON
    if USEPOLY
        plot(ax, pts(:,1),pts(:,2),'k:','LineWidth',2,'DisplayName','polygon');
    end
    
    legend(ax,'show')
    
    % SHOW INSTRUCTIONS
    t = uicontrol('style','text','units','pixels','position',[10 10 300 20],'String','temporary');
    
    % FEEDBACK
    tp = uicontrol('style','text','Units','pixels','Position',[10 50 300 20],'String','N Points: ???');
    d = uicontrol('style','text','Units','pixels','Position',[10 30 300 20],'String','Dist: ???? (deg) [???? (km)]');
    
    % ADDITIONAL CONTROLS
    uicontrol('style','pushbutton','Units','pixels','Position',[310 30 50 20],'String','SET','Callback',@set_grid);
    uicontrol('style','edit','Units','pixels','Position',[310 70 50 20],...
        'String',name,'Callback',@(~,~)update_plot());
    
    uicontrol('style','checkbox','Units','pixels','Position',[310 100 80 20],'String','Follow Meridians? (adjusts for lat)','Callback',@toggle_parallels);
    % SELECT FIXED POINT
    write_string(t,'Enter a fixed point for the grid');
    [fixed_x,fixed_y]=ginput(1);
    fp=plot(ax,fixed_x,fixed_y,'b+','LineWidth',2,'DisplayName','Origin');
    instruction_end(t);
    
    % SELECT OTHER POINT
    write_string(t,'Click at a distance that will define a grid');
    [x2,y2]=ginput(1);
    %tmph=plot(ax,x2,y2,'bo','LineWidth',2)
    instruction_end(t);
    
    dx = abs(x2-fixed_x);
    dy = abs(y2-fixed_y);
    
    % SELECT INITIAL GRID
    gpts_h2=plot(nan,nan,'gx','DisplayName','grid');
    
    update_plot();
    
    f.WindowScrollWheelFcn=@adjust_grid;
    f.WindowButtonDownFcn=@mouse_down;
    f.WindowButtonUpFcn=@mouse_up;
    f.DeleteFcn=@check_for_save;
    
    write_string(t,'Scroll the mouse wheel to scale')
    if nargout > 0
        waitfor(f);
        pgr =ZG.Grid;
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
        ZG.Grid=ZmapGrid(name,pgr.xs, pgr.ys, 'deg');
        if FOLLOW_PARALLELS
            ZG.gridopt = struct('dx',deg2km(dx),'dy',deg2km(dy),'dx_units','deg','dy_units','deg',...
                'dz',[],'dz_units','km');
        else
            ZG.gridopt = struct('dx',dx,'dy',dy,'dx_units','km','dy_units','km',...
                'dz',[],'dz_units','km');
        end
        changed=false;
    end
    
    function toggle_parallels(src,~)
        FOLLOW_PARALLELS=src.Value==1;
        update_plot();
    end
    
    function update_plot()
        changed=true;
        [gx,gy]=get_eq_grid(fixed_x,fixed_y,dx,dy);
        if USEPOLY
            ll=polygon_filter(pts(:,1),pts(:,2),gx(:),gy(:),'inside');
        else
            ll=true(size(gx(:)));
        end
        % plot points inside polygon, but grid still covers entire map.
        gpts_h2.XData=gx(ll);
        gpts_h2.YData=gy(ll);
        
        pgr.xs=gx;
        pgr.ys=gy;
        disp(pgr)
        
        % trim pgr to polygon before returning. Maybe I shouldn't!
        if USEPOLY && exist('trim_final_grid_to_shape','var') && trim_final_grid_to_shape
            ll=polygon_filter(pts(:,1),pts(:,2),pgr.xs,pgr.ys,'inside');
            pgr.xs(~ll)=nan;
            pgr.ys(~ll)=nan;
        end
        
        pgr=trim_nans(pgr);
        
        tp.String=sprintf('N Points: %d',sum(ll));
    end
    
    function [lonMat,latMat] = get_eq_grid(lon0,lat0,dLon,dLat)
        % GET_EQ_GRID
        % input is the origin point and arclength between points
        % output is 2 matrices (lon, lat)
        
        % base grid on a single distance, so that instead of separate dx & dy, we use dd
        dist_arc = max([...
            distance(lat0,lon0,lat0,lon0+dLon,'degrees'),...
            distance(lat0,lon0,lat0+dLat,lon0,'degrees')]);
        
        d.String=sprintf('Dist: %.3f (deg) [%.3f (km)]',dist_arc,deg2km(dist_arc));
        
        % use the axes limits (assumed degrees) to control size of grid
        ylims_deg = ylim(ax);
        xlims_deg = xlim(ax);
        
        % pick out latitude spacing. Our grid will have this many rows.
        lats = vector_including_origin(lat0, dist_arc, ylims_deg);
        lonMat=[];
        latMat=[];
        
        if FOLLOW_PARALLELS
            % when following the meridian lines, the longitude span covered by
            % the arc-distance at lat0 (along the rhumb!) remains constant.
            % that is, dLon 45 from origin (0,0) will always be 45, regardless of latitude.
            [~,dLon]=reckon('rh',lat0,0,dist_arc,90);
            
            % resulting in a rectangular matrix where, on a globe lines will converge, but on a graph
            lonValues = vector_including_origin(lon0, dLon, xlims_deg);
            
            %creates a meshgrid of size numel(lonValues) x numel(lats)
            [lonMat,latMat]=meshgrid(lonValues,lats);
            
        else
            % when ignoring meridian lines, and aiming for an approximately constant distance,
            % the dLon at each latitude will differ.
            
            % number of degrees longitude covered by the arclength at each latitude
            [~,dLon_per_lat]=reckon('rh',lats,0,dist_arc,90);
            
            for n=1:numel(lats)
                theseLonValues = vector_including_origin(lon0, dLon_per_lat(n), xlims_deg);
                lonMat=[lonMat;theseLonValues(:)]; %#ok<AGROW>
                latMat=[latMat;repmat(lats(n),size(theseLonValues(:)))]; %#ok<AGROW>
            end
            
            [lonMat,latMat] = cols2matrix(lonMat,latMat);
            % each gridx & gridy are vectors.
        end
    end
    
    function v = vector_including_origin(orig_deg, delta_deg, lims_deg)
        v = unique([orig_deg : -delta_deg : min(lims_deg) , orig_deg : delta_deg :max(lims_deg)]);
    end
    
    
    function [xs, ys] = cols2matrix(lonCol,latCol)
        % COLS2MATRIX convert columns of lats & lons into a matrix.
        % this takes lots of stuff into account
        %
        
        % assign pgrid
        ugy=unique(latCol); % lats in matrix
        nrows=numel(ugy); % number of latitudes in matrix
        [~,example]=min(abs(latCol(:))); % latitude closest to equator will have most number of lons in matrix
        mostCommonY=latCol(example); % account for the abs possibly flipping signs
        base_lon_idx=find(lonCol(latCol==mostCommonY)==fixed_x); % longitudes that must line up
        ncols=sum(latCol(:)==mostCommonY); % most number of lons in matrix
        ys=repmat(ugy(:),1,ncols);
        xs=nan(nrows,ncols);
        for n=1:nrows
            thislat=ugy(n); % lat for this row
            idx_lons=(latCol==thislat); % mask of lons in this row
            these_lons=lonCol(idx_lons); % lons in this row
            row_length=numel(these_lons); % number of lons in this row
            
            main_lon_idx=find(these_lons==fixed_x); % offset of X in this row
            offset=base_lon_idx - main_lon_idx;
            xs(n,(1:row_length)+offset)=these_lons;
        end
        
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
        fixed_x=ax.CurrentPoint(1,1);
        fixed_y=ax.CurrentPoint(1,2);
        fp.XData=fixed_x;
        fp.YData=fixed_y;
    end
    
    function check_for_save(~,~)
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

%{
function c=mycontext()
    c=uicontextmenu('Tag','GridContext')
    
    uimenu(c,'Label','Select Rectangle');
    uimenu(c,'Label','Select Circle');
    uimenu(c,'Label','Select Polygon');
    uimenu(c,'Separator','on','Label','Create Polygon');
end
%}
