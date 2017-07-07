function aux_Omori(params, hParentFigure)
% function aux_Omori(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 04.07.2005

% Get the axes handle of the plotwindow
axes(sv_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok');

% Get closest gridnode for the chosen point on the map
[fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY);
plot(fXGridNode, fYGridNode, '*r');
hold off;

% Get the data for the grid node
mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);
vSel = (params.fTstart <= mNodeCatalog_(:,3) & mNodeCatalog_(:,3) < params.fTstart+params.fTimePeriod);
mCat = mNodeCatalog_(vSel,:);

% Omori parameters
fpval1 = params.mValueGrid(nNodeGridPoint,1);
fcval1= params.mValueGrid(nNodeGridPoint,2);
fkval1= params.mValueGrid(nNodeGridPoint,3);
fBgrate = params.mValueGrid(nNodeGridPoint,17);
[fTafshock] = plot_Afseqlength(mCat,params.mMainshock,fpval1,fcval1,fkval1,fBgrate,3000,'y')

%[vRate,vBin] = plot_LogOmori(mNodeCatalog_,params.mMainshock);

plot_llkstest(mCat,params.fTimePeriod*365,0,1,params.mMainshock);
