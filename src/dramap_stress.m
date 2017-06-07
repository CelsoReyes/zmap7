% drap a colormap of variance, S1 orinetation onto topography
report_this_filefun(mfilename('fullpath'));

% check if mapping toolbox and topo map exists
if exist('meshgrat') ~= 2
    errordlg('It seems like you do not have the mapping toolbox installed - plotting topography will not work without it, sorry');
    return
end

if exist('tmap') == 0; tmap = 0; end
[xx, yy] = size(tmap);
if xx*yy < 30
    errordlg('Please create a topomap first, using the options from the seismicty map window');
    return
end


% use this for setting water levels to one color
%l = isnan(tmap);
%tmap(l) = 1;

%l = tmap< 0.1;
%tmap(l) = 0;

% this recreaset stg
SA = 1;
ste = [bvg(:,2) bvg(:,1)+180  bvg(:,4) bvg(:,3)+180 bvg(:,6) bvg(:,5)+180 bvg(:,7) ];
sor = ste;
ste2 = s;
sor(:,SA*2) = sor(:,SA*2)+90;

% start data setup
[lat,lon] = meshgrat(tmap,tmapleg);
[X , Y]  = meshgrid(gx,gy);

ren = interp2(X,Y,re4,lon,lat);

mi = min(min(ren));
l =  isnan(ren);
ren(l) = mi-20;

%start figure
figure_w_normalized_uicontrolunits('pos',[50 100 800 600])

hold on; axis off
axesm('MapProjection','eqaconic','MapParallels',[],...
    'MapLatLimit',[s4 s3],'MapLonLimit',[s2 s1])

meshm(ren,tmapleg,size(tmap),tmap);

daspectm('m',4);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

% plot the bars
plq = quiverm(newgri(:,2),newgri(:,1),-cos(ste(:,SA*2)*pi/180),sin(ste(:,SA*2)*pi/180),0.9)
set(plq,'LineWidth',0.4,'Color','k','Markersize',0.1)
hold on

delete(plq(2))

pl = plotm(maepi(:,2),maepi(:,1),'hw');
set(pl,'LineWidth',1,'MarkerSize',14,...
    'MarkerFaceColor','w','MarkerEdgeColor','k')
zdatam(handlem('allline'),10000) % keep line on surface

j = hsv;
%j = j(64:-1:1,:);
j = [ [ 0.9 0.9 0.9 ] ; j];
caxis([ min(min(re4)) max(max(re4)) ]);

colormap(j); brighten(0.1);
axis off;

if exist('colback') == 0; colback = 1; end

if colback == 2  % black background
    set(gcf,'color','k')
    setm(gca,'ffacecolor','k')
    setm(gca,'fedgecolor','w','flinewidth',3);

    % change the labels if needed
    setm(gca,'mlabellocation',0.25)
    setm(gca,'meridianlabel','on')
    setm(gca,'plabellocation',0.25)
    setm(gca,'parallellabel','on')
    setm(gca,'Fontcolor','w','Fontweight','bold','FontSize',12,'Labelunits','dm')

    h5 = colorbar;
    set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
        'Fontweight','bold','FontSize',12);
    set(gcf,'Inverthardcopy','off');

else % white background
    set(gcf,'color','w')
    setm(gca,'ffacecolor','w')
    setm(gca,'fedgecolor','k','flinewidth',3);

    % change the labels if needed
    setm(gca,'mlabellocation',0.25)
    setm(gca,'meridianlabel','on')
    setm(gca,'plabellocation',0.25)
    setm(gca,'parallellabel','on')
    setm(gca,'Fontcolor','k','Fontweight','bold','FontSize',12,'Labelunits','dm')

    h5 = colorbar;
    set(h5,'position',[0.8 0.35 0.01 0.3],'TickDir','out','Ycolor','k','Xcolor','k',...
        'Fontweight','bold','FontSize',12);
    set(gcf,'Inverthardcopy','off');

end










