function []=plot_dramapB(vResults)
% --------------------------------------------
% Plot Mc map on topography
%
% Incoming variables:
% vResults: Necessarily includes vResults.mPolygon, vResults.mValueGrid, vResults.fSpacingHorizontal
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 27.02.03

% get tbase.bin values
[tmap,tmapleg] = tbase(3);

% Construct a map graticule mesh for surface object display
[lat,lon] = meshgrat(tmap,tmapleg);

% Get coordinates from calculated Mc values, set up matrices
vX=min(vResults.mPolygon(:,1)):vResults.fSpacingHorizontal:max(vResults.mPolygon(:,1));
vY=min(vResults.mPolygon(:,2)):vResults.fSpacingHorizontal:max(vResults.mPolygon(:,2));
[X , Y]  = meshgrid(vX,vY);

% % Set values of Mc to NaN
 vSel = find(vResults.mValueGrid(:,9)> 2.2);
 vResults.mValueGrid(vSel,9) = NaN;

% Reshape
mBvalues=reshape(vResults.mValueGrid(:,9),length(vY),length(vX));


% Interpolate Values
mBGrid = interp2(X,Y,mBvalues,lon,lat);

% Create figure
exfig=figure_exists('b-value worldmap',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','b-value worldmap',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end

clf
hold on;
axis off;
axesm('MapProjection','robinson')

% Magic coloring
mi = min(min(mBGrid));
l =  isnan(mBGrid);
mBGrid(l) = mi-10;
ll = tmap < 0 & mBGrid < 0;
mBGrid(ll) = mBGrid(ll)*0 + 10;
hMap=meshm(mBGrid,tmapleg,size(tmap),tmap);

daspectm('m',20);
tightmap
view([0 90])
camlight; lighting phong
set(gca,'projection','perspective');

j = jet(60000);
j = j(30000:60000,:);
%j = winter(80000);
%j = flipud(j);
j = [ [ 0.9 0.9 0.9 ] ; j; [ 0.5 0.5 0.5] ];

%caxis([ min(min(mBvalues)) max(max(mBvalues)) ]);
%Harvard 0-70km
%caxis([0.6 2.2])
% ISC 0-70km
caxis([ 0.5 2]);
colormap(j); brighten(0.1);

axis off; set(gcf,'color','k')

setm(gca,'ffacecolor','k')
setm(gca,'fedgecolor','w','flinewidth',1);

setm(gca,'mlabellocation',60)
setm(gca,'meridianlabel','on')
setm(gca,'plabellocation',25)
setm(gca,'parallellabel','on')
setm(gca,'Fontcolor','w','FontSize',10,'Fontweight','bold','Fontname','times','Labelunits','degrees')
setm(gca,'Labelformat','none')
setm(gca,'Grid','on')
setm(gca,'GLineStyle','-')

h5 = colorbar;
% Harvard 0-70km
% set(h5,'position',[0.82 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
%     'Fontweight','bold','FontSize',10,'YTick',[0.6 1 1.4  1.8 2.2] );
% ISC 0-70km
set(h5,'position',[0.82 0.35 0.01 0.3],'TickDir','out','Ycolor','w','Xcolor','w',...
    'Fontweight','bold','FontSize',10,'Ytick',[0.5 1 1.5 2]);

set(gcf,'Inverthardcopy','off');

