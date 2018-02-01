function fig=ZmapMainWindow(fig)
    %TOFIX filtering of Dates are not preserved when "REDRAW" is clicked
    %TOFIX shape lags behind
    
    if exist('fig','var')
        delete(fig);
    end
    fig=figure('Position',[100 80 1200 650],'Name','Zmap Main Window');
    mycat=catalog();
    
    ZG=ZmapGlobal.Data;
    
    shp=ZG.selection_shape;
    s=Stack(5); % remember last 5 catalogs
    pushState();
    add_menu_divider()
    emm = uimenu(fig,'label','Edit!');
    undohandle=uimenu(emm,'label','Undo','Callback',@cb_undo,'Enable','off');
    redrawhandle=uimenu(emm,'label','Redraw','Callback',@cb_redraw);
    % TODO: undo could also stash grid options & grids
    
    
    TabLocation = 'top'; % 'top','bottom','left','right'
    tg=uitabgroup('Units','pixels','Position',[790 330 380 310],'TabLocation',TabLocation);
    tg2=uitabgroup('Units','pixels','Position',[790 20 380 310],'TabLocation',TabLocation);
    
    t1=uitab(tg,'title','Magnitude');
    
    t2=uitab(tg,'title','Depth');
    t3=uitab(tg,'title','Time');
    t4=uitab(tg,'title','Hour');
    t5=uitab(tg,'title','FMD');
    
    t21=uitab(tg2,'title','cumplot');
    t22=uitab(tg2,'title','Time-Mag');
    t23=uitab(tg2,'title','Time-Depth');
    
    replot_all()
    
    function replot_all()
        figure(fig)
        shp=ZG.selection_shape;
        % set up main map window
        axm=findobj(fig,'Tag','mainmap_ax');
        if isempty(axm)
            axm=axes('Units','pixels','Position',[100 100 600 500]);
            primecat=ZG.primeCatalog;
            alleq=plot(axm,primecat.Longitude,primecat.Latitude,'.','color',[.76 .75 .8],'Tag','all events');
            alleq.ZData=primecat.Depth;
            axm.Tag = 'mainmap_ax';
            axm.TickDir='out';
            axm.Box='on';
            hold on;
            eq=scatter(axm, mycat.Longitude, mycat.Latitude,mag2dotsize(mycat.Magnitude),datenum(mycat.Date),'Tag','active quakes');
            eq.ZData=mycat.Depth;
            eq.Marker='s';
            axm.ZDir='reverse';
        else
            %alleq=findobj(axm,'Tag','all events');
            eq=findobj(axm, 'Tag','active quakes')
            eq.XData=mycat.Longitude;
            eq.YData=mycat.Latitude;
            eq.ZData=mycat.Depth;
            eq.SizeData=mag2dotsize(mycat.Magnitude);
            eq.CData=datenum(mycat.Date);
        end
        hold on;
        grid(axm,'on');
        %newshape=ZG.selection_shape
        %if ~isequal(newshape,shp)
        %    disp ('shape changed');
        %    shp=newshape;
        %end
        if ~isempty(shp)
            shp.plot(axm)
        end
        assert(strcmp(axm.Tag,'mainmap_ax'))
        
        %ZmapCatalogView('primeCatalog').plot(ax)
        title(axm,'Catalog Name and Date')
        xlabel(axm,'Longitude')
        ylabel(axm,'Latitude');
        
        % Each tab group will have a "SelectionChanghedFcn", "CreateFcn", "DeleteFcn", "UIContextMenu"
        %TabLocation = 'top'; % 'top','bottom','left','right'
        %tg=uitabgroup('Units','pixels','Position',[790 330 380 310],'TabLocation',TabLocation);
        
        % Each tab has UiContextMenu,
        %t1=uitab(tg,'title','Magnitude');
        if isempty(t1.Children)
            ax=axes(t1);%ylabel(ax,'# events');xlabel(ax,'Magnitude');
            hisgra(mycat,'Magnitude',ax)
        else
            ax=t1.Children;
            ax.Children.Data=mycat.Magnitude; %TODO move into hisgra
        end
        
        
        %t2=uitab(tg,'title','Depth');
        if isempty(t2.Children)
            ax=axes(t2);%ylabel(ax,'# events');xlabel(ax,'Depth [km]');
            hisgra(mycat,'Depth',ax);
        else
            ax=t2.Children;
            ax.Children.Data=mycat.Depth; %TODO move into hisgra
        end
        
        
        %t3=uitab(tg,'title','Time');
        if isempty(t3.Children)
            ax=axes(t3);%ylabel(ax,'# events');xlabel(ax,'Date');
            hisgra(mycat,'Date',ax)
        else
            ax=t3.Children;
            ax.Children.Data=mycat.Date; %TODO move into hisgra
        end
        
        %t4=uitab(tg,'title','Hour');
        if isempty(t4.Children)
            ax=axes(t4);%ylabel(ax,'# events');xlabel(ax,'Hour');
            hisgra(mycat,'Hour',ax);
        else
            ax=t4.Children;
            ax.Children.Data=hours(mycat.Date.Hour); %TODO move into hisgra
        end
        
        %t5=uitab(tg,'title','FMD');
        delete(t5.Children);
        ax=axes(t5);
        ylabel(ax,'Cum # events');xlabel(ax,'Magnitude');
        
        mainax=findobj(fig,'Tag','mainmap_ax');
        bdiff2(mycat,false,ax);
        
        mainax2=findobj(fig,'Tag','mainmap_ax');
        assert(mainax==mainax2);
        
        % Cumulative Event Plot
        %tg2=uitabgroup('Units','pixels','Position',[790 20 380 310],'TabLocation',TabLocation);
        %t21=uitab(tg2,'title','cumplot');
        delete(t21.Children);
        ax=axes(t21);
        ax.TickDir='out';
        p=plot(ax,mycat.Date,1:mycat.Count,'r','linewidth',2);
        ylabel(ax,'Cummulative Number of events');xlabel(ax,'Time');
        c=uicontextmenu;
        uimenu(c,'Label','start here','Callback',@(~,~)cb_starthere(ax));
        uimenu(c,'Label','end here','Callback',@(~,~)cb_endhere(ax));
        uimenu(c, 'Label', 'trim to largest event','Callback',@cb_trim_to_largest);
        p.UIContextMenu=c;
        uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)timeplot());
        c=uicontextmenu;
        ax.UIContextMenu=c;
        uimenu(c,'Label','Open in new window','Callback',@(~,~)timeplot());
        
        %Time-Magnitude Plot
        %t22=uitab(tg2,'title','Time-Mag');
        delete(t22.Children);
        ax=axes(t22);
        TimeMagnitudePlotter.plot(mycat,ax);
        ax.Title=[];
        c=uicontextmenu;
        uimenu(c,'Label','Open in new window','Callback',@(~,~)TimeMagnitudePlotter.plot(mycat));
        ax.UIContextMenu=c;
        
        %t23=uitab(tg2,'title','Time-Depth');
        delete(t23.Children);
        ax=axes(t23);cla(ax);
        %ylabel(ax,'Depth');xlabel(ax,'Time');
        TimeDepthPlotter.plot(mycat,ax);
        ax.Title=[];
        c=uicontextmenu;
        uimenu(c,'Label','Open in new window','Callback',@(~,~)TimeDepthPlotter.plot(mycat));
        ax.UIContextMenu=c;
        
        function cb_starthere(ax)
            [x,~]=click_to_datetime(ax);
            pushState();
            mycat=mycat.subset(mycat.Date>=x);
            replot_all();
        end
        
        function cb_endhere(ax)
            [x,~]=click_to_datetime(ax);
            pushState();
            mycat=mycat.subset(mycat.Date<=x);
            replot_all();
        end
        
        function cb_trim_to_largest(~,~)
            biggests = mycat.Magnitude == max(mycat.Magnitude);
            idx=find(biggests,1,'first');
            pushState();
            mycat = mycat.subset(mycat.Date>=mycat.Date(idx));
            replot_all()
        end
    end
    function cb_undo(~,~)
        %try
            popState()
        %catch ME
        %    errordlg('can''t undo');
        %    return
        %end
        replot_all();
    end
    function cb_redraw(~,~)
        % REDRAW if things have changed, then also push the new state
        watchon
        item=s.peek();
        do_stash=true;
        if ~isempty(item)
            do_stash = ~strcmp(item{1}.summary('stats'),mycat.summary('stats')) ||...
                ~isequal(ZG.selection_shape,item{2});
        end
        shp=ZG.selection_shape;
        if do_stash
            disp('pushing')
            pushState();
        end
        mycat=catalog();
        shp=ZG.selection_shape;
        replot_all();
        watchoff
    end
    
    %% push and pop state
    function pushState()
        s.push({mycat, copy(shp)});%ZG.selection_shape
        undohandle.Enable='on';
    end
    
    function popState()
        fig.Pointer='watch';
        pause(0.01);
        items = s.pop();
        shp=copy(items{2});
        ZG.selection_shape = shp;
        if ~isempty(shp)
            shp.plot(findobj(fig,'Tag','mainmap_ax'))
        end
        mycat = items{1};
        if isempty(s)
            undohandle.Enable='off';
        end
        fig.Pointer='arrow';
        pause(0.01);
    end
end

function c=catalog()
    ZG=ZmapGlobal.Data;
    c = ZG.Views.primary;
    sh=ZG.selection_shape;
    if ~isempty(sh)
        c=c.subset(sh.isInside(c.Longitude,c.Latitude));
    end
end
