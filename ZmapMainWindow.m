function f=ZmapMainWindow(f)
    if exist('f','var')
        delete(f);
    end
f=figure('Position',[100 80 1200 650],'Name','Zmap Main Window');

% set up main map window
ax=axes('Units','pixels','Position',[100 100 600 500]);
ax.Tag = 'mainmap_ax';
ax.TickDir='out';
ax.Box='on';
mycat=catalog();
ZG=ZmapGlobal.Data;
primecat=ZG.primeCatalog;
alleq=plot(ax,primecat.Longitude,primecat.Latitude,'.','color',[.76 .75 .8]);
alleq.ZData=primecat.Depth;
hold on;
eq=scatter(ax, mycat.Longitude, mycat.Latitude,mag2dotsize(mycat.Magnitude),datenum(mycat.Date));
eq.ZData=mycat.Depth;
eq.Marker='s'
ax.ZDir='reverse';
grid(ax,'on');
shp=ZG.selection_shape.plot(gca)

%ZmapCatalogView('primeCatalog').plot(ax)
title(ax,'Catalog Name and Date')
xlabel('Longitude')
ylabel('Latitude');

% Each tab group will have a "SelectionChanghedFcn", "CreateFcn", "DeleteFcn", "UIContextMenu"
TabLocation = 'top'; % 'top','bottom','left','right'
tg=uitabgroup('Units','pixels','Position',[790 330 380 310],'TabLocation',TabLocation);

% Each tab has UiContextMenu, 
t1=uitab(tg,'title','Magnitude');
ax=axes(t1);%ylabel(ax,'# events');xlabel(ax,'Magnitude');
hisgra(catalog(),'Magnitude',gca)


t2=uitab(tg,'title','Depth'); 
ax=axes(t2);%ylabel(ax,'# events');xlabel(ax,'Depth [km]');
hisgra(mycat,'Depth',gca);

t3=uitab(tg,'title','Time'); 
ax=axes(t3);%ylabel(ax,'# events');xlabel(ax,'Date');
hisgra(mycat,'Date',gca)

t4=uitab(tg,'title','Hour'); 
ax=axes(t4);%ylabel(ax,'# events');xlabel(ax,'Hour');
hisgra(mycat,'Hour',gca);

t5=uitab(tg,'title','FMD');
ax=axes(t5);ylabel(ax,'Cum # events');xlabel(ax,'Magnitude');


tg2=uitabgroup('Units','pixels','Position',[790 20 380 310],'TabLocation',TabLocation);
t21=uitab(tg2,'title','cumplot');
ax=axes(t21);
ax.TickDir='out';
plot(ax,mycat.Date,1:mycat.Count,'r','linewidth',2);
ylabel(ax,'Cummulative Number of events');xlabel(ax,'Time');
c=uicontextmenu;
uimenu(c,'Label','Open in new window','Callback',@(~,~)timeplot());
ax.UIContextMenu=c;

t22=uitab(tg2,'title','Time-Mag');
ax=axes(t22);ylabel(ax,'Magnitude');xlabel(ax,'Time');
pl=TimeMagnitudePlotter.plot(mycat,ax);
ax.Title=[];
c=uicontextmenu;
uimenu(c,'Label','Open in new window','Callback',@(~,~)TimeMagnitudePlotter.plot(mycat));
ax.UIContextMenu=c;

t23=uitab(tg2,'title','Time-Depth');
ax=axes(t23);ylabel(ax,'Depth');xlabel(ax,'Time');
TimeDepthPlotter.plot(mycat,ax);
ax.Title=[];
c=uicontextmenu;
uimenu(c,'Label','Open in new window','Callback',@(~,~)TimeDepthPlotter.plot(mycat));
ax.UIContextMenu=c;
end

function c=catalog()
    ZG=ZmapGlobal.Data;
    c = ZG.Views.primary;
    sh=ZG.selection_shape;
    if ~isempty(sh)
        c=c.subset(sh.isInside(c.Longitude,c.Latitude));
    end
end

