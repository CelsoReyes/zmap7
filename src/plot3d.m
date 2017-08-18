function plot3d()
    % TODO Delete this, functionality is now in the regular map.
    % ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
    % does the calculation and makes displays the map
    % stefan wiemer 11/94
    %
    % make dialog interface and call maxzlta
    %
    % This is the info window text
    %
    global a faults mainfault main
    report_this_filefun(mfilename('fullpath'))
    
ZG=ZmapGlobal.Data; % get zmap globals;
    tag='mainmap3_ax';
    watchon
    think
    ttlStr='3 D seismicity view                                  ';
    hlpStr1= ...
        [' This plot is a 3 dimensional view of the seismicity '
        ' currently selected in the map window. Use the Viewer'
        ' to change the angle of perspective. To change the   '
        ' legend, recreate the plot with the desired legend   '
        ' legend as a function of depth/time) in the map      '
        ' window and recreate the 3D view.                    '];
    
    % Find out if figure already exists
    watchon
    
    
    map3=findobj('Type','Figure','-and','Name','3 D View');
    
    % Set up the Seismicity Map 3 D window Enviroment
    %
    if isempty(map3)
        map3 = figure_w_normalized_uicontrolunits( ...
            'Name','3 D View',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Tag', tag, ...
            'Position',[  200 200 400 600]);
        
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .10 .06],'String','Print ',...
            'callback',@callbackfun_001)
        
        uicontrol('Units','normal',...
            'Position',[.2 .93 .10 .06],'String','Close ',...
            'callback',@callbackfun_002)
        
        uicontrol('Units','normal',...
            'Position',[.4 .93 .10 .06],'String','Info ',...
            'callback',@callbackfun_003)
        
        uicontrol('Units','normal',...
            'Position',[.6 .93 .20 .06],'String','3D-Rotate',...
            'callback',@callbackfun_004)
        
    end   % if exist newmap3
    
    
    report_this_filefun(mfilename('fullpath'));
    
    figure(map3)
    delete(gca);
    rect= [0.2 0.2 0.6 0.6];
    ax=axes('pos',rect);
    set(gca,'visible','off');
    hold on
    
    if ~exist('divs','var')
        divs=[]
    end
    % plot earthquakes according to depth
    switch ZmapGlobal.Data.mainmap_plotby
        case 'depth'
            plotQuakesByDepth(ax, a, []);
            
            
            %plot earthquakes according time
        case 'tim'
            timidx = ZG.a.Date<=tim2&ZG.a.Date>=tim1;
            plo =plot3(ZG.a.Longitude(timidx),ZG.a.Latitude(timidx),-ZG.a.Depth(timidx),'+b');
            set(plo,'MarkerSize',6,'LineWidth',1.)
            timidx = ZG.a.Date<=tim3&ZG.a.Date>tim2;
            plo =plot3(ZG.a.Longitude(timidx),ZG.a.Latitude(timidx),-ZG.a.Depth(timidx),'og');
            set(plo,'MarkerSize',6,'LineWidth',1.)
            timidx = ZG.a.Date<=tim4&ZG.a.Date>tim3;
            plo =plot3(ZG.a.Longitude(timidx),ZG.a.Latitude(timidx),-ZG.a.Depth(timidx),'xr');
            set(plo,'MarkerSize',6,'LineWidth',1.)
            
            ls1 = sprintf('%3.1f < t < %3.1f ',tim1,tim2);
            ls2 = sprintf('%3.1f < t < %3.1f ',tim2,tim3);
            ls3 = sprintf('%3.1f < t < %3.1f ',tim3,tim4);
            
    end
    
    
    
    %le =legend([,ls1,'og',ls2,'xr',ls3);
    %set(le,'position',[ 0.65 0.02 0.32 0.12])
    
    
    view(3);
    
    grid
    hold on
    
    %if isempty(coastline) == 0
    %l = coastline(:,1) < s1  & coastline(:,1) > s2 & coastline(:,2) < s3 & coastline(:,2) > s4| coastline(:,1) == inf;
    %pl1 =plot3(coastline(l,1),coastline(l,2),ones(length(coastline(l,:)),1)*0,'k');
    %end
    if isempty(faults) == 0
        l = faults(:,1) < s1  & faults(:,1) > s2 & faults(:,2) < s3 & faults(:,2) > s4| faults(:,1) == inf;
        pl1 =plot3(faults(l,1),faults(l,2),ones(length(faults(l,:)),1)*0,'k');
    end
    if isempty(mainfault) ==0
        pl2 =plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault(:,1)),1)*0,'m');
        pl2b =plot3(mainfault(:,1),mainfault(:,2),ones(length(mainfault(:,1)),1)*0,'m');
        set(pl2,'LineWidth',3.0)
        set(pl2b,'LineWidth',3.0)
    end
    if isempty(main) ==0
        pl3 =plot3(main(:,1),main(:,2),ones(length(main(:,1)),1)*0,'xk');
        pl3b =plot3(main(:,1),main(:,2),ones(length(main(:,1)),1)*0,'xk');
        set(pl3,'LineWidth',3.0)
        set(pl3b,'LineWidth',3.0)
    end
    
    axis([ min(ZG.a.Longitude) max(ZG.a.Longitude) min(ZG.a.Latitude) max(ZG.a.Latitude) min(-ZG.a.Depth) max(-ZG.a.Depth)  ])
    orient tall
    
    set(gca,'box','on',...
        'SortMethod','childorder',...
        'TickDir','out',...
        'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s,...
        'Linewidth',1.0,'visible','on')
    
    %whitebg(gcf,[0 0 0]);
    watchoff
    
    vie = gcf;
    figure(map3)
    watchoff
    done;
    
    
    function plotQuakesByDepth(ax, mycat, divs)
        % plotQuakesByDepth
        % plotQuakesByDepth(catalog)
        % plotQuakesByDepth(catalog, divisions)
        %   divisions is a vector of depths (up to 7)
        
        % magdivisions: magnitude split points
        global event_marker_types
        if isempty(event_marker_types)
            event_marker_types='+++++++'; %each division gets next type.
        end
        
        if isempty(divs)
            divs = linspace(min(mycat.Depth),max(mycat.Depth),4);
            divs([1 4])=[]; % no need for min, and no quakes greater than max...
        end
        
        assert(numel(divs) < 8); % else, too many for our colormap.
        
        cmapcolors = colormap('lines');
        cmapcolors=cmapcolors(1:7,:); %after 7 it starts repeating
        
        
        mask = mycat.Depth <= divs(1);
        
        %ax = mainAxes();
        %clear_quake_plotinfo();
        washeld = ishold(ax); hold(ax,'on')
        
        h = plot3(ax, mycat.Longitude(mask), mycat.Latitude(mask),-mycat.Depth(mask),...
            'Marker',event_marker_types(1),...
            'Color',cmapcolors(1,:),...
            'LineStyle','none',...
            'MarkerSize',ZG.ms6,...
            'Tag','mapax_part0');
        h.DisplayName = sprintf('Z ≤ %.1f km', divs(1));
        
        for i = 1 : numel(divs)
            mask = mycat.Depth > divs(i);
            if i < numel(divs)
                mask = mask & mycat.Depth <= divs(i+1);
            end
            dispname = sprintf('Z > %.1f km', divs(i));
            plot3(ax, mycat.Longitude(mask), mycat.Latitude(mask),-mycat.Depth(mask),...
                'Marker',event_marker_types(i+1),...
                'Color',cmapcolors(i+1,:),...
                'LineStyle','none',...
                'MarkerSize',ZG.ms6,...
                'Tag',['mapax_part' num2str(i)],...
                'DisplayName',dispname);
        end
        xlabel(ax,'Longitude');
        ylabel(ax,'Latitude');
        zlabel(ax,'Depth [km]');
        if ~washeld; hold(ax,'off'); end
    end
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint;
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close(map3);
        close(vie);
        zmap_message_center();
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1);
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        rotate3d;
    end
end
