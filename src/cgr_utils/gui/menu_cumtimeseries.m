function c=menu_cumtimeseries(parent)
    % menu_cumtimeseries add a context menu to the cumulative timeseries
    % plot(x,x,....,'UIContextMenu',menu_cumtimeseries);
    
    c=uicontextmenu;
    
    uimenu(c, 'Label', 'filter',...
        'Enable','off',...
        'Callback',@(~,~)msgbox('Unimplemented','Unimplemented'));
    uimenu(c, 'Label', 'also plot main catalog',...
        'Enable','off',...
        'Callback',@(~,~)msgbox('Unimplemented','Unimplemented'));
    uimenu(c, 'separator','on','Label', 'start here','Callback',@start_here);
    uimenu(c, 'Label', 'end here','Callback',@end_here);
    uimenu(c, 'Label', 'trim to largest event','Callback',@trim_to_largest);
    uimenu(c, 'Label', 'show in map (keeping all)','Callback',@show_in_map,'Enable','off');
    uimenu(c, 'separator','on','Label', '- * t b a * -',...
        'Enable','off',...
        'Callback',@(~,~)msgbox('Unimplemented','Unimplemented'));
    
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
    
    function [X,Y] = click_to_datetime(ax)
        %TODO move to external function
        %
        % see also num2ruler
        selector='';
        xyz=get(ax,'CurrentPoint');
        X=xyz(1);
        Y=xyz(2);
        X = num2ruler(X, ax.XAxis);
        Y = num2ruler(Y, ax.YAxis);
        if isa(X,'datetime')
            X = round_time(X,selector);
        end
        if isa(Y,'datetime')
            Y = round_time(Y,selector);
        end
    end
    
    function dates = round_time(dates, selector)
        % TODO move to external function
        switch selector
            case 'nearest_day'
                dates = datetime(dates.Year, dates.Month, dates.Day + round(dates.Hour ./ 24));
            case 'nearest_hour'
                dates = datetime(dates.Year, dates.Month, dates.Day, dates.Hour + round(dates.Minute/60),0,0);
            otherwise
                dates.Format='uuuu-MM-dd hh:mm:ss';
                % do nothing
        end
    end
    function show_in_map()
        ZmapMessageCenter.set_info('Unimplemented. now there would be some green marks on the main map, too');
    end
        
end