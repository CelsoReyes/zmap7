function plotclust()
    global clus
    ZG = ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
    clustNum0=[];
    
    close(findobj('Name','Cluster Map'));
    
    f=figure_w_normalized_uicontrolunits( ...
        'Name','Cluster Map',...
        'NumberTitle','off', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','on');
    
    create_my_menu();
    
    orient landscape
    set(f,'PaperPosition',[ 1.0 1.0 8 6])
    axis off
    
    rect = [0.1,  0.20, 0.75, 0.65];
    ax = axes(f,'position',rect);
    
    % plot catalog
    plot(ax, ZG.original.Longitude,ZG.original.Latitude,'k.',...
        'Markersize',2,...
        'DisplayName','catalog')
    hold on
    
    st = 'ox+*sdv^<>ph^'; % available markers
    col = hsv(max(clus));
    
    for i = 1:max(clus)
        l = clus==i;
        if sum(l)== 0
            fprintf('cluster # %d was empty!\n',i);
        end
        rs = ceil(rand(1,1)*13); % choose a marker randomly
        plot(ax, ZG.original.Longitude(l),ZG.original.Latitude(l),'o',...
            'Color',col(i,:),'Markersize', 6,...
            'Linewidth',1, 'Marker', st(rs),...
            'tag',num2str(i));
        
    end
    
    plot(ax, nan,nan,'ko',...
        'tag','clus_shadow');
    
    axis(ax, 'image')
    set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
        'FontWeight','bold','LineWidth',3.0,...
        'Box','on','SortMethod','childorder','TickDir','out')
    
    axis(ax,[min(ZG.primeCatalog.Longitude) max(ZG.primeCatalog.Longitude) min(ZG.primeCatalog.Latitude) max(ZG.primeCatalog.Latitude)])
    xlabel(ax,'Longitude [deg]','FontWeight','bold','FontSize',ZG.fontsz.m)
    ylabel(ax,'Latitude [deg]','FontWeight','bold','FontSize',ZG.fontsz.m)
    strib = [  ' Clusters in '  ZG.primeCatalog.Name ': '  char(min(ZG.primeCatalog.Date),'uuuu-MM-dd hh:mm') ' to ' char(max(ZG.primeCatalog.Date),'uuuu-MM-dd hh:mm') ];
    title(ax, strib,'FontWeight','bold',...
        'FontSize',ZG.fontsz.m,'Color','k')
    
    ga = ax;
    
    
    ax2=axes(f,'pos',[0 0 1 1]);
    axis(ax2,'off');
    hold(ax2,'on');
    str = ['Cluster # 1'];
    te = text(ax2, 0.8,0.9,str,'Fontweight','bold','FontSize',12);
    
    %axes(ax2)
    sl =   uicontrol(f,'Style','slider',...
        'Position',[.85 0.15 0.05 0.6 ],...
        'Min',1,'Max',max(clus),'Value',1,...
        'Callback',@markclus_callback,'Sliderstep',[1/max(clus) 1/(ceil(max(clus)/20))],...
        'Units','normalized');
    
    zmap_update_displays();
    axes(ax);
    markclus_callback(); % activate a cluster
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        op4 = uimenu('Label','ZTools') ;
        op6 =uimenu(op4,'Label','select clusters');
        
        uimenu(op6,'Label','Select by Mouse',...
            MenuSelectedFcnName(),@(~,~)getclu_callback('mouse'));
        uimenu(op6,'Label','Plot largest Cluster',...
            MenuSelectedFcnName(),@(~,~)getclu_callback('large'));
    end
    
    %% callback functions
    
    function markclus_callback(src,~)
        sl.Value=round(sl.Value);
        fprintf('slider value: %s\n',num2str(sl.Value));
        clustNum0 = markclus(clus, clustNum0, sl, te);
    end
    
    function getclu_callback(opt)
        clustNum0 = getclu(opt, clus, sl, te);
    end
end
