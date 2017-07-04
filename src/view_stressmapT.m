

report_this_filefun(mfilename('fullpath'));

SA = 1;


ste = [bvg(:,2) bvg(:,1)-bvg(:,8)  bvg(:,4) bvg(:,3)+180 bvg(:,6) bvg(:,5)+180 bvg(:,7) ];
s = ste;
ste2 = s;
s(:,SA*2) = s(:,SA*2)+90



normlap2=ones(length(tmpgri(:,1)),1)*nan;

re3=reshape(normlap2,length(yvect),length(xvect));
s11 = re3;

normlap2(ll)= bvg(:,7);
r=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,1);
s11=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,4);
s31=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,1)-bvg(:,7);
ds1=reshape(normlap2,length(yvect),length(xvect));

figure

plq = quiver(newgri(:,1),newgri(:,2),-cos(s(:,SA*2)*pi/180),sin(s(:,SA*2)*pi/180),0.7,'.')
set(plq,'LineWidth',2,'Color','k')
hold on

%pl = quiver(newgri(:,1),newgri(:,2),-cos(s(:,2)*pi/180/3),-sin(s(:,2)*pi/180),2)
%set(pl,'LineWidth',2,'Color','r')



px = get(plq,'Xdata'); py = get(plq,'Ydata');
figure
whitebg(gcf);
n = 0;
l0 = []; l1 = []; l2 = []; l3 = []; l4 = []; l5 = [];
for i = 1:3:length(px)-1
    n = n+1;j = jet;
    col = floor(ste(n,SA*2-1)/60*62)+1;
    if col > 64 ; col = 64; end
    pl = plot(px(i:i+1),py(i:i+1),'k','Linewidth',1.5,'color',[ 1 1 1 ] );
    hold on
    dx = px(i)-px(i+1);
    dy = py(i) - py(i+1);
    pl2 = plot(px(i),py(i),'ko','Linewidth',1.5,'color',[1 1 1] );
    l0 = pl2;
    pl3 = plot([px(i) px(i)+dx],[py(i) py(i)+dy],'k','Linewidth',1.5,'color',[1 1 1] );

   if ste(n,1) > 52  && ste(n,5) < 35 ; set([pl pl3],'color','r'); set(pl2,'color','r'); l1 = pl2; end
  if ste(n,1) > 40  && ste(n,1) <  52  && ste(n,5) < 20 ; set([pl pl3],'color','m'); set(pl2,'color','m'); l2 = pl2; end
  if ste(n,1) < 40  && ste(n,3)> 45  && ste(n,5) < 20 ; set([pl pl3],'color','g'); set(pl2,'color','g'); l3 = pl2; end
  if ste(n,1) < 20  && ste(n,3)> 45  && ste(n,5) < 40 ; set([pl pl3],'color','g'); set(pl2,'color','g');l3 = pl2; end
  if ste(n,1) < 20  && ste(n,5)> 40  && ste(n,5) < 20 ; set([pl pl3],'color','c'); set(pl2,'color','c');l4 = pl2; end
   if ste(n,1) < 35  && ste(n,5)> 52  ; set([pl pl3],'color','b'); set(pl2,'color','b');l5 = pl2;  end

end

if isempty(l1) == 1; pl2 = plot(px(i),py(i),'ko','Linewidth',2,'color','r'); l1 = pl2; set(l1,'visible','off'); end
if isempty(l2) == 1; pl2 = plot(px(i),py(i),'ko','Linewidth',2,'color','m'); l2 = pl2; set(l2,'visible','off'); end
if isempty(l3) == 1; pl2 = plot(px(i),py(i),'ko','Linewidth',2,'color','g' ); l3 = pl2; set(l3,'visible','off'); end
if isempty(l4) == 1; pl2 = plot(px(i),py(i),'ko','Linewidth',2,'color','c' ); l4 = pl2; set(l4,'visible','off'); end
if isempty(l5) == 1; pl2 = plot(px(i),py(i),'ko','Linewidth',2,'color','b' ); l5 = pl2; set(l5,'visible','off'); end
l0 = plot(px(i),py(i),'ko','Linewidth',2,'color',[1 1 1] );  set(l0,'visible','off');

legend([l1 l2 l3 l4 l5 l0],'NF','NS','SS','TS','TF','U');

hold on
axis('equal')
%overlay_

title2([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.m,...
    'Color','r','FontWeight','bold')

xlabel('Longitude ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Latitude ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)


set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

matdraw


return

curpt2
i = 1;
stereo

