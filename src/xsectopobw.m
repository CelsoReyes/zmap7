% make a x-section plus topography...

if exist('tmap') == 0
    mainmap_overview()
    warndlg('Please create a topo map first')
end

l = isnan(tmap);
tmap(l) = -300;


if toflag == '3'
    [vlat , vlon] = meshgrat(tmap,tmapleg);
    vlat = vlat(:,1);
    vlon = vlon(1,:);
end



% plot location on map
figure_w_normalized_uicontrolunits(to1)
plot([lon1 lon2],[lat1 lat2],'m','Linewidth',3);

% make a track
lis1 = linspace(lat1,lat2,100);
lis2 = linspace(lon1,lon2,100);

tr = [lis2 ; lis1]; tr = tr';
z = [];
% get the topo at each point

for i = 1:length(tr)
    x = find(abs(vlon - tr(i,1)) == min(abs(vlon - tr(i,1))) );
    y = find(abs(vlat - tr(i,2)) == min(abs(vlat - tr(i,2))) );
    z = [z tmap(y,x)  ];
end

di = 0:max(xsecx)/99:max(xsecx);
figure
axes('pos',[0.15 0.1 0.7 0.5])
set(gcf,'renderer','painters')

c = hsv;

for i = 1:length(xsecx)
    pl =plot(xsecx(i),-xsecy(i),'ok');
    hold on
    fac = 64/max(newa(:,7));

    facm = 10/max(newa(:,6));
    sm = newa(i,6)* facm;
    if sm < 1; sm = 1; end

    col = ceil(newa(i,7)*fac)+1; if col > 63; col = 63; end
    set(pl,'Markersize',sm,'markerfacecolor',[1 1 1 ]);
end

set(gca,'Ylim',[ -max(newa(:,7)) 0]);
ax = axis;

sa = axis;

set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.,...
    'Box','on','TickDir','out','color',[1 1 1])

ylabel('Depth [km]')
xlabel('Distance [km]')

hold on


[cmap, clim] = demcmap(z/1000, 256); shading flat; hold on


axes('pos',[0.15 0.6 0.7 0.2])

di2 = [di ax(2)   ax(2) 0 ];
z2 =  [ z 0  min(z)*1.1 min(z)*1.1 ];
patch(di2,z2/1000,'k');
hold on

di2 = [di ax(2) 0];
z2 = [z 0 0];
patch(di2,z2/1000,z2/1000);
hold on


%load topo2
%topo2 = topo2(1:12:3000,:);
colormap(gray(15))

set(gca,'Ylim',[min(z/1000)*1.1 max(z/1000)*1.1],'Xlim',[ax(1) ax(2)])
set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.,...
    'Box','on','TickDir','out','color',[  1 1  1])
ylabel('Elevevation [km]')

set(gca,'XTickLabel',[],'Yaxislocation','right');
box off

hold on

if exist('maix') > 0
    if isempty(maix) == 0
        pl = plot(maix,6.5,'vr');
        set(pl,'Markersize',10,'markerfacecolor','r','clipping','off')
        pl = plot(maix,-6,'^r');
        set(pl,'Markersize',10,'markerfacecolor','r','clipping','off')
    end
end

set(gcf,'color','w');
return


try
    axes('pos',[0.02 0.78 0.2 0.2])
    pcolor(mx(1:n),my(1:m),tmap); shading flat
    hold on
    axis off
    axis image
    plot([lon1 lon2],[lat1 lat2],'w','Linewidth',1);
    brighten(0.3)
    set(gca,'visible','on','LineWidth',0.5,...
        'Box','on','TickDir','out','color',[  1 1  1],'XTicklabel',[ ],'YTicklabel',[ ])
catch
end

%whitebg(gcf)



