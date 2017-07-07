report_this_filefun(mfilename('fullpath'));

% drap a colormap onto topography
%l = isnan(tmap);
%tmap(l) = 1;

%l = tmap< 1;
%tmap(l) = 1;


[lat,lon] = meshgrat(tmap,tmapleg);
%[smap,smapleg] = country2mtx('switzerland',100);
%[lat0, lon0] = meshgrat(smap,smapleg);


% tmap = km2deg(tmap/1);
[X , Y]  = meshgrid(gx,gy);

%sw = interp2(lon0,lat0,smap,lon,lat);

%  l = re4 < 0.82;
% re4(l) = 0.72;
l = re4 > 0.01;
re4(l) = 0.01;


ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;




figure_w_normalized_uicontrolunits('pos',[50 100 1000 700])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[10 55],'MapLonLimit',[55 120])


ll = tmap < 0 & ren < 0;
ren(ll) = ren(ll)*0 + 20;
meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',15);
tightmap
camlight; lighting phong
set(gca,'projection','perspective');

load worldlo
hl = displaym(POline);
set(hl(1),'color',[0.9 0.9 0.9],'Linewidth',1.)
delete(hl(2));
% h2 = displaym(PPpoint);
% h = displaym(PPtext);



% pl = plotm(ma(:,2),ma(:,1),'hw');
%  set(pl,'LineWidth',1.5,'MarkerSize',12,...
% 'MarkerFaceColor','w','MarkerEdgeColor','k')
%load coast.mat
%c = coast;


n = 0;
l0 = []; l1 = []; l2 = []; l3 = []; l4 = []; l5 = [];
for i = 1:3:length(px)-1
    n = n+1;
    j = jet;
    col = floor(ste(n,SA*2-1)/60*62)+1;
    if col > 64 ; col = 64; end
    pl = plotm(py(i:i+1),px(i:i+1),'k','Linewidth',1.5,'Markersize',1,'color',[ 0 0 0  ] );
    hold on
    dy = px(i)-px(i+1);
    dx = py(i) - py(i+1);
    pl2 = plotm(px(i),py(i),'ko','Markersize',0.1,'Linewidth',0.5,'color',[0 0 0] );
    l0 = pl2;
    pl3 = plotm([px(i) px(i)+dx],[py(i) py(i)+dy],'k','Linewidth',1.5,'color',[0 0 0] );

   if ste(n,1) > 52  && ste(n,5) < 35 ; set([pl pl3],'color','r'); set(pl2,'color','r'); l1 = pl; end
  if ste(n,1) > 40  && ste(n,1) <  52  && ste(n,5) < 20 ; set([pl pl3],'color','m'); set(pl2,'color','m'); l2 = pl; end
  if ste(n,1) < 40  && ste(n,3)> 45  && ste(n,5) < 20 ; set([pl pl3],'color',[0.2 0.8 0.2]); set(pl2,'color',[0.2 0.8 0.2]); l3 = pl; end
  if ste(n,1) < 20  && ste(n,3)> 45  && ste(n,5) < 40 ; set([pl pl3],'color',[0.2 0.8 0.2]); set(pl2,'color',[0.2 0.8 0.2]);l3 = pl; end
  if ste(n,1) < 20  && ste(n,5)> 40  && ste(n,5) < 20 ; set([pl pl3],'color','c'); set(pl2,'color','c');l4 = pl; end
   if ste(n,1) < 35  && ste(n,5)> 52  ; set([pl pl3],'color','b'); set(pl2,'color','b');l5 = pl;  end

end

%if isempty(l1) == 1; pl2 = plotm(px(i),py(i),'kx','Linewidth',1.,'color','r'); l1 = pl2; set(l1,'visible','off'); end
%if isempty(l2) == 1; pl2 = plotm(px(i),py(i),'kx','Linewidth',1.,'color','m'); l2 = pl2; set(l2,'visible','off'); end
%if isempty(l3) == 1; pl2 = plotm(px(i),py(i),'kx','Linewidth',1.,'color',[0.2 0.8 0.2] ); l3 = pl2; set(l3,'visible','off'); end
%if isempty(l4) == 1; pl2 = plotm(px(i),py(i),'kx','Linewidth',1.,'color','c' ); l4 = pl2; set(l4,'visible','off'); end
%if isempty(l5) == 1; pl2 = plotm(px(i),py(i),'kx','Linewidth',1.,'color','b' ); l5 = pl2; set(l5,'visible','off'); end
%if isempty(l0) == 1; l0 = plotm(px(i),py(i),'kx','Linewidth',1.,'color',[0 0 0 ] );  set(l0,'visible','off'); end

%legend([l1 l2 l3 l4 l5 l0],'NF','NS','SS','TS','TF','U');

% plotm(cu(:,2), cu(:,1),'w','Linewidth',2);





zdatam(handlem('allline'),10000) % keep line on surface
% zdatam(handlem('alltext'),10000) % keep line on surface




j = hot(64);
j = j(64:-1:1,:);
j = [ [ 0.9 0.9 0.9 ] ; j; [ 0.5 0.5 0.5] ];
caxis([ 0. 0.3]);

colormap(j);

axis off; set(gcf,'color','w')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','k','flinewidth',3);

setm(gca,'mlabellocation',15)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',15)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',16,'Labelunits','degrees')








