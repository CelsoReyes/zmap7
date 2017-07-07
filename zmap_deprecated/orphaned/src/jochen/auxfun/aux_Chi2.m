function aux_Chi2(params, hParentFigure)
% function aux_Chi2(params, hParentFigure);
%-------------------------------------------
% Plot the Chi^2-Test result and distributions for the closest events
% defined by nNumberEvents (default = 100)
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 19.08.02

% Track of changes:

% Get the axes handle of the plotwindow
axes(pf_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'*g', 'Markersize',12);

% % Get closest gridnode for the chosen point on the map
% [fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY);
% plot(fXGridNode, fYGridNode, '*r');
% hold off;
%
% % Get the data for the grid node
% mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);
% %%%% Done: Determine next grid point and earthquakes associated with it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [fChi2] = plot_Chi2(mNodeCatalog_);

[mCatClose] = calc_CloseQuakes(params.mCatalog, fX, fY, params.nNumberEvents);
plot(mCatClose(:,1), mCatClose(:,2),'ro');
[fChi2] = plot_Chi2(mCatClose);
