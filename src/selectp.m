function selectp(in_or_out)
    %  This .m file selects the earthquakes within a polygon
    %  and plots them. Sets "a" equal to the catalogue produced after the
    %  general parameter selection. Operates on "storedcat", replaces "a"
    %  with new data and makes "a" equal to newcat
    %
    %   operates on main map window
    % plot tags:
    %  'poly_selected_events' : earthquakes in/out of polygon
    %  'mouse_points_overlay' : polygon outline
    
    global a newcat storedcat newt2 hoda
    echo on
    % ___________________________________________________________
    %  Please use the left mouse button or the cursor to select
    %  the polygon vertexes.
    %
    %  Use the right mouse button to select the final point.
    %_____________________________________________________________
    echo off
        report_this_filefun(mfilename('fullpath'));
    %zoom off
    newt2 = [ ];           % reset catalogue variables
    %a = storedcat;              % uses the catalogue with the pre-selected main
    % general parameters
    newcat = a;
    
    delete(findobj('Tag','mouse_points_overlay'));
    delete(findobj('Tag','poly_selected_events'));
    
    messtext=...
        ['To select events inside a polygon.        '
        'Please use the LEFT mouse button or the   '
        'character P to select the polygon vertexes'
        'Use the RIGHT mouse button for the final  '
        'point.  Mac Users: use the keybord:       '
        ' p: more points, l: lst point             '
        'Operates on the original catalogue        '
        'producing a reduced  subset which in turn '
        'the other routines operate on.            '];
    
    zmap_message_center.set_message('Select EQ in Polygon',messtext);
    
    
    % pick polygon points,
    ax = findobj('Tag','mainmap_ax');
    [x,y, mouse_points_overlay] = select_polygon(ax);
    
    zmap_message_center.set_info('Message',' Thank you .... ')
    if ~exist('in_or_out','var')
        in_or_out = 'inside';
    end
    if isnumeric(a)
        error('old catalog');
    else
        mask = polygon_filter(x,y, a.Longitude, a.Latitude, in_or_out);
        a.addFilter(mask);
        newt2 = a.getCropped();
        a.clearFilter();
        % Plot of new catalog
        %
        washeld=ishold(ax); hold(ax,'on');
        MainInteractiveMap.plotOtherEvents(newt2,0,...
            'Marker','.',...
            'LineStyle','none',...
            'MarkerEdgeColor','g',...
            'MarkerFaceColor','none',...
            ...'Linewidth',1.5,...
            'DisplayName','Selected Events');
        set(mouse_points_overlay,'LineStyle',':','LineWidth',1,'Color',[.5 .5 .5],'Marker','none');
        if ~washeld; hold(ax,'off');end
    end
    xy = [x y];
    
    %save polcor.dat xy -ascii
    [file1,path1] = uiputfile([hoda '*.txt'],'Save Polygon ? (yes/cancel)');
    if length(file1) > 1
        if length(file1)>3
            if strcmp(file1(length(file1)-3:length(file1)),'.txt')==0
                file1=[file1 '.txt']
            end
        end
        %bollocks, changed it to a normal command
        %sapa2 = ['save ' path1 file1  '  xy -ascii '] ;
        %eval(sapa2)
        save([path1 file1],'xy', '-ascii');
    end
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %
    %   The new catalog (newcat) with points only within the
    %   selected Polygon is created and resets the original
    %   "a" .
    disp(' The selected polygon was saved in the file polcor.dat')
    %
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    newcat = newt2;                   % resets newcat and newt2
    
    timeplot
    
    h=zmap_message_center;
    h.update_catalog();