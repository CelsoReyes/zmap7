load /Seis/A/stefan/after_figs/moslip.mat

report_this_filefun(mfilename('fullpath'));

% plot image
%
orient portrait
set(gcf,'PaperPosition', [2. 1 7.0 5.0])


cmap1 = jet(64);
hocm = hot(64);
hocm = hocm(length(hocm):-1:1,:);
cmap2 = hocm;
cmap = [cmap1;cmap2];
colormap(cmap)

clf
yl = [-12 0],xl=[-25 10];
axes('pos',[0.1 0.7 0.8 0.25])
hold on
plot(newa(:,12),-newa(:,7),'bx')
h0 = gca;
set(gca,'Color',[1 1 0.7],'Ylim',yl,'XLim',[xl],...
    'XTicklabel',[],'Box','on')
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
pl = plot(maex,-maey,'xk');
set(pl,'MarkerSize',12,'LineWidth',2)
cs =contour(-gxd,gyd,sl/100,[0 0.2 0.4 0.6 0.8  1] ,'k');
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])




axes('pos',[0.1 0.4 0.8 0.25])
pcolor(gx,gy,bv);
set(gca,'Color',[0.9 0.9 0.9] ,'Ylim',[yl],'XLim',[xl],'XTicklabel',[])
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
shading interp
hold on
pl = plot(maex,-maey,'xw');
set(pl,'MarkerSize',12,'LineWidth',2)
cs =contour(-gxd,gyd,sl/100,[0 0.2 0.4 0.6 0.8  1] ,'w');
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])


z2 = pv + (max(bv(:))-min(pv(:))) +0.08;
h1 = gca;

axes('pos',[0.1 0.1 0.8 0.25])
pcolor(gx,gy,z2)
shading interp
hold on
pl = plot(maex,-maey,'xw');
set(pl,'MarkerSize',12,'LineWidth',2)
cs =contour(-gxd,gyd,sl/100,[0 0.2 0.4 0.6 0.8  1] ,'w');
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])
set(gca,'Color',[0.9 0.9 0.9] ,'Ylim',[yl],'XLim',[xl])
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
ax = findobj(gcf,'Type','axes');
set(ax,'CLim', [min([bv(:);pv(:)]) max(z2(:))])

hc = colorbar('vert');
set(hc,'YLim',[min(z2(:)) max(z2(:))],'Pos',[0.85 0.1 0.03 0.25],'YTickLabels',[])

c = get(hc,'Children');
for i =1:length(c)-1
    delete(c(i))
end

axes(h1)
hc2 = colorbar('vert');
set(hc2,'YLim',[min(bv(:)) max(bv(:))],'Pos',[0.85 0.4 0.03 0.25],'YTick',[])


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
txt1=text(.89, .1+0.125,[ num2str(min(pv(:)) + max(pv(:))/2 )]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .34,[ num2str(max(pv(:)))]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.85, 0.08,[ 'p-value ' ]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')


txt1=text(.89, .4,[ num2str(min(bv(:)))]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .4+0.125,[ num2str(min(bv(:)) + max(bv(:))/2 )]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .64,[ num2str(max(bv(:)))]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.85, 0.38,[ 'b-value ' ]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
