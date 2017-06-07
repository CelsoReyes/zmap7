report_this_filefun(mfilename('fullpath'));

%
orient portrait
set(gcf,'PaperPosition', [2. 1 7.0 5.0])

clf
set(gcf,'Color','w')
yl = [-15 0],xl=[0 60];
axes('pos',[0.1 0.7 0.85 0.25])
hold on
plot(newa(:,10),-newa(:,7),'bx')
h0 = gca;
set(gca,'Color',[1 1 0.7],'Ylim',yl,'XLim',[xl],...
    'XTicklabel',[],'Box','on')
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])
ylabel('Depth [km]')

axes('pos',[0.1 0.4 0.85 0.25])
pcolor(gx,gy,bv);
set(gca,'Color',[0.9 0.9 0.9] ,'Ylim',[yl],'XLim',[xl])
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
caxis([0.75 1.5])
shading interp
hold on
xlabel('Distance along strike [km]')
ylabel('Depth [km]')
set(gca,'YTick',[ -10 -5 0 ])
set(gca,'YTickLabels',[10 5 0 ])

h1 = gca;
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
hc2 = colorbar('vert');
set(hc2,'Pos',[0.85 0.4 0.03 0.25],'YTick',[])


c = get(hc2,'Children');
for i =1:length(c)-1
    delete(c(i))
end

po1 =get(h1,'pos')
po0 =get(h0,'pos')
set(h0,'pos',[po0(1) po0(2) po1(3) po1(4)])

axes('pos',[0 0 1 1 ])
set(gca,'visible','off');

txt1=text(.89, .4,[ num2str(min(bv(:)))]);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .4+0.125,[ '1.12']);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.89, .64,[ '1.5']);
set(txt1,'FontWeight','normal','FontSize',10,'Color','k')
txt1=text(.85, 0.37,[ 'b-value ' ]);
set(txt1,'FontWeight','bold','FontSize',10,'Color','k')
