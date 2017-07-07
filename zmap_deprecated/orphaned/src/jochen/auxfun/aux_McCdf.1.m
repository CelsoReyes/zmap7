function aux_FMD(params, hParentFigure)
% function aux_FMD(params, hParentFigure);
%-------------------------------------------
% Plot determination of Mc for a grid point using  calc_McCdf_plot
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 23.01.03

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

% Start calculation
%[mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = plot_McEMR(mNodeCatalog_, 0.1)
[mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] =plot_McCdfnormal(mNodeCatalog_, 0.1)
%plot_McCdf2(mNodeCatalog_, 0.1);
