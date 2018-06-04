function aux_McEMR(params, hParentFigure)
% function aux_McEMR(params, hParentFigure);
%-------------------------------------------
% Plot determination of Mc for a grid point using the EMR-method
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% updated: 29.09.04

% Get the axes handle of the plotwindow
axes(sv_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
set(gca,'NextPlot','add');
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok');

% Get closest gridnode for the chosen point on the map
[fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY);
plot(fXGridNode, fYGridNode, '*r');
set(gca,'NextPlot','replace');

% Get the data for the grid node
mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);

% Start calculation
plot_McEMR(mNodeCatalog_, params.fBinning);

