function plotclust()
    global clus
    ZG = ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
    clustNum0=[];
    
    close(findobj(0,'Name','Cluster Map'));
    
    figure_w_normalized_uicontrolunits( ...
        'Name','Cluster Map',...
        'NumberTitle','off', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','on', ...
        'Position',[ (ZG.fipo(3:4) - [600 500]) ZG.map_len]);
    
    % matdraw
    
    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
        'Callback',@(~,~) web(['file:' ZG.hodi '/help/declus']) );
    
    add_menu_divider();
    
    op4 = uimenu('Label','ZTools') ;
    op6 =uimenu(op4,'Label','select clusters');
    
    uimenu(op6,'Label','Select by Mouse',...
        'Callback',@(~,~)getclu_callback('mouse'));
    uimenu(op6,'Label','Plot largest Cluster',...
        'Callback',@(~,~)getclu_callback('large'));
    
    orient landscape
    set(gcf,'PaperPosition',[ 1.0 1.0 8 6])
    axis off
    
    rect = [0.1,  0.20, 0.75, 0.65];
    axes('position',rect);
    
    % plot catalog
    plot(ZG.a.Longitude,ZG.a.Latitude,'k.','Markersize',2)
    hold on
    
    st = 'ox+*sdv^<>ph^'; % available markers
    col = hsv(max(clus));
    
    for i = 1:max(clus)
        l = clus == i;
        rs = ceil(rand(1,1)*13); % choose a marker randomly
        pl = plot(ZG.original.Longitude(l),ZG.original.Latitude(l),'o');
        set(pl,'Color',col(i,:),'Markersize', 6, 'Linewidth',1, 'Marker',st(rs),'tag',num2str(i))
    end
    
    overlay_
    
    axis image
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
        'FontWeight','bold','LineWidth',3.0,...
        'Box','on','SortMethod','childorder','TickDir','out')
    
    axis([s2 s1 s4 s3])
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZG.fontsz.m)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZG.fontsz.m)
    strib = [  ' Clusters in   '  name '; '  num2str(t0b,5) ' to ' num2str(teb,5) ];
    title(strib,'FontWeight','bold',...
        'FontSize',ZG.fontsz.m,'Color','k')
    
    ga = gca;
    
    
    axes('pos',[0 0 1 1]); axis off; hold on
    str = ['Cluster # 1'];
    text(0.8,0.9,str,'Fontweight','bold','FontSize',12);
    
    axes(ga)
    sl =   uicontrol('Style','slider',...
        'Position',[.85 0.15 0.05 0.6 ],...
        'Callback',@markclus_callback,'Sliderstep',[ 0.01 0.1],...
        'Units','normalized');
    
    function markclus_callback(src,~)
        clustNum0 = markclus(clus, clustNum0, sl, te);
    end
        
    function getclu_callback(opt)
        getclu(opt,clustNum0);
    end
end
