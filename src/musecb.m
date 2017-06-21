% function to create a cross-section consisting of multiple segments
%
% stefan wiemer 1/97

report_this_filefun(mfilename('fullpath'));

global rbox  sw

nlammap;

% first lets input the endpoints
but = 1;x=[];y=[];
while but == 1 | but == 112
    [xi,yi,but] = ginput(1);
    [lat1, lon1] = lc_froca(xi,yi);
    lc_event(lat1,lon1,'rx',6,2)
    x = [x; lon1];
    y = [y; lat1];
end

org3 = a;
% feed in coyote lake aft
b = a(:,1:9); b = [b , b(:,1)*0+1 ];
b  = [b ;  coyo(:,1:9) , coyo(:,1)*0+2 ];
b  = [b ;  mor(:,1:9)  ,  mor(:,1)*0+3 ];
b  = [b ;  maepi(:,1:9)  ,  maepi(:,1)*0+4 ];

a = b; getxsec ;
a = org3;



% now lets plot the combined x-section
% with origin at the larget event

figure
rect = [0.15,  0.20, 0.55, 0.55];
axes('position',rect)
newa2 = newa;

l = newa2(:,10) == 1;
pl =plot(newa2(l,11),-newa2(l,7),'ro');
set(pl,'Linewidth',1.,'MarkerSize',2)
hold on
newa = newa.subset(l);
xsecx = newa(:,po)';
xsecy = newa(:,7);

l = newa2(:,10) == 2;
pl =plot(newa2(l,11),-newa2(l,7),'xb');
set(pl,'Linewidth',1.,'MarkerSize',2)
xcoyo = newa2(l,:);

l = newa2(:,10) == 3;
pl =plot(newa2(l,11),-newa2(l,7),'xg');
set(pl,'Linewidth',1.,'MarkerSize',2)
xmor = newa2(l,:);

l = newa2(:,10) == 4;
pl =plot(newa2(l,11),-newa2(l,7),'hm');
set(pl,'LineWidth',1.5,'MarkerSize',12,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')
xma = newa2(l,:);

set(gca,'Ylim',[-15 0])
set(gca,'Color',[cb1 cb2 0.7])
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',12,'Linewidth',1.2)

xlabel('Distance in [km]')
ylabel('Depth in [km]')
matdraw


uic3 = uicontrol('Units','normal',...
    'Position',[.80 .88 .20 .10],'String','Make z-grid',...
     'Callback','sel = ''in'';magrcros');

uic4 = uicontrol('Units','normal',...
    'Position',[.80 .68 .20 .10],'String','b-grid (const N) ',...
     'Callback','sel = ''in'';bcross');

uicontrol('Units','normal',...
    'Position',[.80 .58 .20 .10],'String','b-grid (const R) ',...
     'Callback','sel = ''in'';bcrossV2');
uic5 = uicontrol('Units','normal',...
    'position',[.8 .48 .2 .1],'String','Select Eqs',...
     'Callback','crosssel;newt2=newa2;newcat=newa2;timeplot;');
uicontrol('Units','normal',...
    'position',[.8 .28 .2 .1],'String','Time Plot ',...
     'Callback','timcplo;');

xsec_fig = gcf;
figure_w_normalized_uicontrolunits(mapl)

uic2 = uicontrol('Units','normal',...
    'Position',[.70 .92 .30 .06],'String','New selection ?',...
     'Callback','delete(uic2),nlammap');


