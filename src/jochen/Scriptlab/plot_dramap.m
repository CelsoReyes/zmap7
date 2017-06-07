function []=plot_dramap(vResults)
% --------------------------------------------
% Plot Mc map on topography
%
% Incoming variables:
% vResults: Necessarily includes vResults.mPolygon, vResults.mValueGrid, vResults.fSpacingHorizontal
% tmap    : Topographic map data ETOPO5
% tmapleg : Topographic map data ETOPO5 legend
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 27.02.03

% Get tmap from tbase.bin
[tmap,tmapleg] = tbase(20);


% Construct a map graticule mesh for surface object display
[lat,lon] = meshgrat(tmap,tmapleg);

% Get coordinates from calculated Mc values, set up matrices
vX=min(vResults.mPolygon(:,1)):vResults.fSpacingHorizontal:max(vResults.mPolygon(:,1));
vY=min(vResults.mPolygon(:,2)):vResults.fSpacingHorizontal:max(vResults.mPolygon(:,2));
[X , Y]  = meshgrid(vX,vY);

mVal= vResults.mValueGrid(:,10)./vResults.mValueGrid(:,9);
% Reshape
mMcValues=reshape(mVal,length(vY),length(vX));
% Interpolate Values
mMcGrid = interp2(X,Y,mMcValues,lon,lat);

% Create figure
exfig=figure_exists('worldmap',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','worldmap',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end

clf
hold on;
axis off;
axesm('MapProjection','robinson')

% Magic coloring
mi = min(min(mMcGrid));
l =  isnan(mMcGrid);
mMcGrid(l) = mi-10;
ll = tmap < 0 & mMcGrid < 0;
mMcGrid(ll) = mMcGrid(ll)*0 + 10;
hMap=meshm(mMcGrid,tmapleg,size(tmap),tmap);

daspectm('m',20);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

% j = jet(80000);
% j = j(500:75000,:);
mColor = gui_Colormap_4Colors(50);
j=mColor;
%j = flipud(j);
j = [ [ 0.9 0.9 0.9 ] ; j; [ 0.5 0.5 0.5] ];

caxis([ min(min(mMcValues)) max(max(mMcValues))-0.5]);
%caxis([4 7])
colormap(j); brighten(0.1);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',1);

setm(gca,'mlabellocation',60)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',25)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','FontSize',8,'Fontweight','bold','Fontname','times','Labelunits','degrees')
setm(gca,'Labelformat','none')
setm(gca,'Grid','on')
setm(gca,'GLineStyle','-')


h5 = colorbar;
set(h5,'position',[0.85 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',7);
set(gcf,'Inverthardcopy','off');
