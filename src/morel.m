function morel(mycat) 
    % MOREL this script will plot the cumulative moment
    % release as a function of time
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    %  Stefan Wiemer  2/95
    
    report_this_filefun();
    
    f=figure('Name','Cumulative Moment Release');
    set(f,'PaperPosition',[2 1 5.5 7.5])
    
    
    
    %  Do the calculation
    [~, c, ~] = calc_moment(mycat);
    %c = cumsum( 10.^(1.5*mycat.Magnitude + 16.1));
    
    ax = gca;
    pl = plot(ax,mycat.Date,c,'LineWidth',2.0);
    xlabel(ax,'Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel(ax,'Cumulative Moment ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    %te = text(0.1,0.9,'log10(Mo) = 1.5Ms + 16.1;','Units','normalized','FontWeight','bold')
    
    set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    
    set(gca,'NextPlot','add')
    grid
    
    
    
end
