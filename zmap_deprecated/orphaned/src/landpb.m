report_this_filefun(mfilename('fullpath'));

cdz
cd s%load /Seis/A/stefan/after_figs/landslip.mat

% plot image
%
orient portrait
set(gcf,'PaperPosition', [2. 1 7.0 5.0])

load /Seis/A/stefan/after_figs/landslip.mat

figure

gx = xvect; gy = yvect;
hocm = hot(64);
hocm = hocm(length(hocm):-1:1,:);
cmap2 = hocm;
cmap = [cmap1;cmap2];
colormap(hocm)

clf
yl = [-12 0],xl=[-42 58];
axes('pos',[0.1 0.7 0.85 0.25])
hold on
plot(newa(:,10),-newa(:,7),'ro','MarkerSize',4);
h0 = gca;
set(gca,'Color',[0 0 0 ],'Ylim',yl,'XLim',[xl],...
    'XTicklabel',[],'Box','on')
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
pl = plot(maex,-maey,'hk');
set(pl,'MarkerSize',10,'LineWidth',1,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')
[cs, hc]  =contour(gxd,gyd,sl/100,[1 2 3 4 5 6 7 8 ] ,'y')
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])
ylabel('Depth [km]')

axes('pos',[0.1 0.4 0.85 0.25])
pcolor(gx,gy,bv);
set(gca,'Color',[0 0 0] ,'Ylim',[yl],'XLim',[xl],'XTicklabel',[])
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
shading interp; brighten(-0.2)
hold on
pl = plot(maex,-maey,'hk');
set(pl,'MarkerSize',10,'LineWidth',1,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])
ylabel('Depth [km]')


z2 = pv + (max(bv(:))-min(pv(:))) +0.00;
h1 = gca;

axes('pos',[0.1 0.1 0.85 0.25])
pcolor(gx,gy,z2)
shading interp;
caxis([0.7 1.5])
hold on
pl = plot(maex,-maey,'hk');
set(pl,'MarkerSize',10,'LineWidth',1,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')

% cs =contour(gxd,gyd,sl/100,[1 2 3 4 5 6 7 8 ] ,'w');
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])
set(gca,'Color',[0 0 0 ] ,'Ylim',[yl],'XLim',[xl])
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
ylabel('Depth [km]')
xlabel('Distance along strike [km]')
ax = findobj(gcf,'Type','axes');
set(ax,'CLim', [min([bv(:);pv(:)]) max(z2(:))-0.25])

hc = colorbar('vert');
set(hc,'YLim',[min(z2(:)) max(z2(:))-0.25],'Pos',[0.85 0.1 0.02 0.25],'YTickLabels',[],'TickDir','out')

axes(h1)
hc2 = colorbar('vert');
set(hc2,'YLim',[min(bv(:)) max(bv(:))],'Pos',[0.85 0.4 0.02 0.25],'YTick',[],...
    'TickDir','out')


c = get(hc2,'Children');
for i =1:length(c)-1
    delete(c(i))
end

po1 =get(h1,'pos')
po0 =get(h0,'pos')
set(h0,'pos',[po0(1) po0(2) po1(3) po1(4)])

axes('pos',[0 0 1 1 ])
set(gca,'visible','off');
txt1=text(.89, .1,[ num2str(min(pv(:)))]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .1+0.125,[ num2str(min(pv(:)) + ( max(pv(:)) - min(pv(:)))/2,3 )]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .34,[ num2str(max(pv(:)),3)]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.85, 0.07,[ 'p-value ' ]);
set(txt1,'FontWeight','bold','FontSize',10,'Color','k')


txt1=text(.89, .4,[ num2str(min(bv(:)))]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .4+0.125,[ num2str(min(bv(:)) + (max(bv(:))-min(bv(:)))/2 )]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .64,[ num2str(max(bv(:)))]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.85, 0.38+0.30,[ 'b-value ' ]);
set(txt1,'FontWeight','bold','FontSize',10,'Color','k')


set(gcf,'Color','w','Inverthardcopy','off')
