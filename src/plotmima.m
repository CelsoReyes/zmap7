function plotmima(var1)
    report_this_filefun(mfilename('fullpath'));
    
    ZG=ZmapGlobal.Data;
    global  mi  mif1 hndl3
    
    sc = get(hndl3,'Value');
    mi(:,2) = mi(:,2)+1;
    figure(mif1) %TODO figure out where mif1 comes from
    delete(findobj(mif1,'Type','axes'));
    rect = [0.15,  0.20, 0.75, 0.65];
    axes('position',rect)
    watchon
    
    
    if var1 == 1
        
        for i = 1:ZG.primeCatalog.Count
            pl =  plot(ZG.primeCatalog.Longitude(i),ZG.primeCatalog.Latitude(i),'ro');
            hold on
            set(pl,'MarkerSize',mi(i,2)/sc)
        end
        
    elseif var1 == 2
        
        for i = 1:ZG.primeCatalog.Count
            pl =  plot(ZG.primeCatalog.Longitude(i),ZG.primeCatalog.Latitude(i),'bx');
            hold on
            set(pl,'MarkerSize',mi(i,2)/sc,'LineWidth',mi(i,2)/sc)
        end
        
    elseif var1 == 3
        
        for i = 1:ZG.primeCatalog.Count
            pl =  plot(ZG.primeCatalog.Longitude(i),ZG.primeCatalog.Latitude(i),'bx');
            hold on
            c = mi(i,2)/max(mi(:,2));
            set(pl,'MarkerSize',mi(i,2)/sc,'LineWidth',mi(i,2)/sc,'Color',[ c c c ] )
        end
        
    elseif var1 == 4
        pl =  plot(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'bx');
    end
    
    hold on
    %axis([ s2 s1 s4 s3])
    %zmap_update_displays();
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    strib = 'Misfit Map ';
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    
    set(gca,'Color',color_bg);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    mi(:,2) = mi(:,2)-1;
    watchoff
end
