function overlay_()
    % This subroutine "overlay.m" is called from varios
    % program (view_*.m, subcata.m). It plots an overlay
    % of coastlines, faults, earthquakes etc on a map.
    % This file should be customized for each region
    %  Stefan Wiemer   11/94
    
    report_this_filefun(mfilename('fullpath'));
    
    global main mainfault faults coastline vo maepi well minmag
    
    hold on
    ax = findobj('Tag','main_map_ax');
    if ~isempty(coastline)
        mapplot = plot(ax,coastline(:,1),coastline(:,2));
        set(mapplot,'LineWidth', 1.0, 'Color',[0  0  0 ])
        mapplot.DisplayName = 'coastline';
        mapplot.Tag = 'coastline';
    end
    
    
    if ~isempty(vo)
        plovo = plot(ax,vo(:,1),vo(:,2),'^r');
        set(plovo,'LineWidth', 1.5,'MarkerSize',6,...
            'MarkerFaceColor','w','MarkerEdgeColor','r');
        plovo.DisplayName = 'Volcanoes';
        plovo.Tag = 'volcanoes';
    end
    
    % plot the well location
    if ~isempty(well)
        i = find(well(:,1) == inf);
        plowe = plot(ax,well(i+1,1),well(i+1,2),'d');
        set(plowe,'LineWidth',1.5,'MarkerSize',6,...
            'MarkerFaceColor','k','MarkerEdgeColor','k');
        plowe.DisplayName = 'wells';
        plowe.Tag = 'wells';
    end
    
    %plot main faultline
    if ~isempty(mainfault)
        plo3 = plot(ax,mainfault(:,1),mainfault(:,2),'b');
        plo3.LineWidth = 3.0;
        plo3.DisplayName = 'main faultline';
        plo3.Tag = 'faultlines';
    end
    
    %
    % plot big earthquake epicenters with a 'x' and the data/magnitude
    %
    if ~isempty(maepi) && maepi.Count > 0
        epimax = plot(ax,maepi.Longitude,maepi.Latitude,'hm');
        set(epimax,'LineWidth',1.5,'MarkerSize',12,...
            'MarkerFaceColor','y','MarkerEdgeColor','k')
        epimax.DisplayName = sprintf('Events > M %2.1f', minmag);
        
        stri2 = '';
        for i = 1:maepi.Count
            s = sprintf('   %3.2f M=%3.1f',decyear(maepi.Date(i)),maepi.Magnitude(i));
            if length(s) == 15 ; s = [' ' s] ; end
            if length(s) == 14 ; s = ['  ' s] ; end
            if length(s) == 13 ; s = ['   ' s] ; end
            stri2 = [stri2 ; s];
        end   % for i
        te1 = text(ax,maepi.Longitude,maepi.Latitude,stri2);
        set(te1,'FontWeight','bold','Color','k','FontSize',9,'Clipping','on')
    end
    
    
    %plot mainshock(s)
    %
    if ~isempty(main) && main.Count > 0
        plo1 = plot(ax,main.Longitude,main.Latitude,'*k');
        set(plo1,'MarkerSize',12,'LineWidth',2.0)
        plo1.DisplayName = 'mainshocks';
        plo1.Tag = 'mainshocks';
    end
    
    if ~isempty(faults)
        plo4 = plot(ax,faults(:,1),faults(:,2),'k');
        set(plo4,'LineWidth',0.2)
        plo4.DisplayName = 'faults';
        plo4.Tag = 'faults';
    end
end
    
