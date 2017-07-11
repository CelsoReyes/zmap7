% Plot the clusters

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('Cluster Map',1);
clusFlag=~existFlag;

if clusFlag
    clmap = figure_w_normalized_uicontrolunits( ...
        'Name','Cluster Map',...
        'NumberTitle','off', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','on', ...
        'Position',[ (fipo(3:4) - [600 500]) ZmapGlobal.Data.map_len]);

    matdraw
    

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'Callback',' web([''file:'' hodi ''/help/declus'']) ');

else
    close(clmap); plotclust;
end

matdraw
add_menu_divider();

op4 = uimenu('Label','ZTools','BackgroundColor','m') ;
op6 =uimenu(op4,'Label','select clusters');

uimenu(op6,'Label','Select by Mouse',...
    'Callback','gecl = ''mouse'' ; getclu');
uimenu(op6,'Label','Plot largest Cluster',...
    'Callback','gecl = ''large''; getclu');

orient landscape
set(gcf,'PaperPosition',[ 1.0 1.0 8 6])
axis off

rect = [0.1,  0.20, 0.75, 0.65];
axes('position',rect);


plot(ZG.a.Longitude,ZG.a.Latitude,'k.','Markersize',2)
hold on
lec = max(clus);


st = ['ox+*sdv^<>ph^'];
col = hsv(lec);

for i = 1:max(clus)
    l = clus == i;
    rs = ceil(rand(1,1)*13);
    pl = plot(original(l,1),original(l,2),'o');
    set(pl,'Color',[col(i,1) col(i,2) col(1,3)],'Markersize',6,'Linewidth',1.,'Marker',st(rs),'tag',num2str(i))
end

overlay_

axis image
set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
    'FontWeight','bold','LineWidth',3.0,...
    'Box','on','SortMethod','childorder','TickDir','out')

axis([s2 s1 s4 s3])
xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
strib = [  ' Clusters in   '  name '; '  num2str(t0b,5) ' to ' num2str(teb,5) ];
title2(strib,'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')

ga = gca;


axes('pos',[0 0 1 1]); axis off; hold on
str = ['Cluster # 1'];
te  = text(0.8,0.9,str,'Fontweight','bold','FontSize',12);

axes(ga)
sl =   uicontrol('Style','slider',...
    'Position',[.85 0.15 0.05 0.6 ],...
     'Callback','markclus','Sliderstep',[ 0.01 0.1],...
    'Units','normalized');

%whitebg(gcf); set(gcf,'Color','k');


%set(sl,'min',1,'max',lec);

