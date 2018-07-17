function c=menu_cumtimeseries(c)
    % menu_cumtimeseries add a context menu to the cumulative timeseries
    % plot(x,x,....,'UIContextMenu',menu_cumtimeseries);
    
    if ~exist('c','var')
        c=uicontextmenu('Tag','CumTimeSeriesContext');
    end
    
    uimenu(c, 'Label', 'filter',...
        'Enable','off',...
        MenuSelectedField(),@(~,~)msgbox('Unimplemented','Unimplemented'));
    uimenu(c, 'Label', 'also plot main catalog',...
        'Enable','off',...
        MenuSelectedField(),@(~,~)msgbox('Unimplemented','Unimplemented'));
    uimenu(c, 'separator','on','Label', 'start here',MenuSelectedField(),@start_here);
    uimenu(c, 'Label', 'end here',MenuSelectedField(),@end_here);
    uimenu(c, 'Label', 'trim to largest event',MenuSelectedField(),@trim_to_largest);
    uimenu(c, 'Label', 'show in map (keeping all)',MenuSelectedField(),@show_in_map,'Enable','off');
    uimenu(c, 'separator','on','Label', '- * t b a * -',...
        'Enable','off',...
        MenuSelectedField(),@(~,~)msgbox('Unimplemented','Unimplemented'));
    
    function trim_to_largest(~,~)
        disp('trim to largest')
        pl=CumTimePlot.getInstance;
        biggests = pl.catalog.Magnitude == max(pl.catalog.Magnitude);
        idx=find(biggests,1,'first');
        pl.catalog.DateRange(1)=pl.catalog.Date(idx);
        ZG=ZmapGlobal.Data;
        ZG.newt2 = pl.catalog.Catalog;
        pl.plot()
        %pl.update()
    end
    
    function start_here(src,ev)
        disp('start here')
        disp(src)
        disp(ev)
        [x,~]=click_to_datetime(gca)
        pl=CumTimePlot.getInstance;
        pl.catalog.DateRange(1)=x;
        ZG=ZmapGlobal.Data;
        ZG.newt2 = pl.catalog.Catalog;
        pl.plot()
    end
    
    function end_here(src,ev)
        [x,~]=click_to_datetime(gca)
        pl=CumTimePlot.getInstance;
        pl.catalog.DateRange(2)=x;
        ZG=ZmapGlobal.Data;
        ZG.newt2 = pl.catalog.Catalog;
        pl.plot()
    end
    
    function show_in_map()
        ZmapMessageCenter.set_info('Unimplemented. now there would be some green marks on the main map, too');
    end
        
end