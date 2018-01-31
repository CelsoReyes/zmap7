function f=ZmapMainWindow(f)
    if exist('f','var')
        delete(f);
    end
    f=figure('Position',[100 80 1200 650],'Name','Zmap Main Window');
    mycat=catalog();
    
    ZG=ZmapGlobal.Data;
        
    
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
        figure(f)
        % set up main map window
        ax=axes('Units','pixels','Position',[100 100 600 500]);
        ax.Tag = 'mainmap_ax';
        ax.TickDir='out';
        ax.Box='on';
        primecat=ZG.primeCatalog;
        alleq=plot(ax,primecat.Longitude,primecat.Latitude,'.','color',[.76 .75 .8]);
        alleq.ZData=primecat.Depth;
        hold on;
        eq=scatter(ax, mycat.Longitude, mycat.Latitude,mag2dotsize(mycat.Magnitude),datenum(mycat.Date));
        eq.ZData=mycat.Depth;
        eq.Marker='s';
        ax.ZDir='reverse';
        grid(ax,'on');
        shp=ZG.selection_shape;
        if ~isempty(shp)
            shp.plot(gca)
        end
        
        %ZmapCatalogView('primeCatalog').plot(ax)
        title(ax,'Catalog Name and Date')
        xlabel('Longitude')
        ylabel('Latitude');
        
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
        bdiff2(mycat,false,ax);
        
        % Cumulative Event Plot
        %tg2=uitabgroup('Units','pixels','Position',[790 20 380 310],'TabLocation',TabLocation);
        %t21=uitab(tg2,'title','cumplot');
        delete(t21.Children);
        ax=axes(t21);
        ax.TickDir='out';
        p=plot(ax,mycat.Date,1:mycat.Count,'r','linewidth',2);
        ylabel(ax,'Cummulative Number of events');xlabel(ax,'Time');
        c=uicontextmenu
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
        ylabel(ax,'Magnitude');xlabel(ax,'Time');
        TimeMagnitudePlotter.plot(mycat,ax);
        ax.Title=[];
        c=uicontextmenu;
        uimenu(c,'Label','Open in new window','Callback',@(~,~)TimeMagnitudePlotter.plot(mycat));
        ax.UIContextMenu=c;
        
        %t23=uitab(tg2,'title','Time-Depth');
        delete(t23.Children);
        ax=axes(t23);cla(ax);
        ylabel(ax,'Depth');xlabel(ax,'Time');
        TimeDepthPlotter.plot(mycat,ax);
        ax.Title=[];
        c=uicontextmenu;
        uimenu(c,'Label','Open in new window','Callback',@(~,~)TimeDepthPlotter.plot(mycat));
        ax.UIContextMenu=c;
        
        function cb_starthere(ax)
            [x,~]=click_to_datetime(ax);
            mycat=mycat.subset(mycat.Date>=x);
            replot_all();
        end
        
        function cb_endhere(ax)
            [x,~]=click_to_datetime(ax);
            mycat=mycat.subset(mycat.Date<=x);
            replot_all();
        end
        
        function cb_trim_to_largest(~,~)
            biggests = mycat.Magnitude == max(mycat.Magnitude);
            idx=find(biggests,1,'first');
            mycat = mycat.subset(mycat.Date>=mycat.Date(idx));
            replot_all()
        end
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


