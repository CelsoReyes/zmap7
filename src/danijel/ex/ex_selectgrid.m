function [mGrid, vXVector, vYVector, vUsedNodes] = ex_selectgrid(hFigure, fSpacingX, fSpacingY, bGridEntireArea)
% function [mGrid, vXVector, vYVector, vUsedNodes] = ex_selectgrid(hFigure, fSpacingX, fSpacingY, bGridEntireArea)
% ----------------------------------------------------------------------------------------------------------------
% Interactively select a polygon with a grid inside on figure with handle hFigure
%
% Input parameters:
%   hFigure           Handle to window containing the figure where the polygon has to defined
%   fSpacing          Spacing of gridnodes in X/Y-direction
%   bGridEntireArea   Use the entire area of current axes in hFigure (=1), select polygon for grid manually (=0)
%
% Output parameters:
%   mGrid             Matrix with gridnodes
%   vXVector          Vector containing the X-coordinates of mGrid
%   vYVector          Vector containing the Y-coordinates of mGrid
%   vUsedNodes        Vector containing the indices of an vXVector x vYVector grid which are part of mGrid
%
% Danijel Schorlemmer
% March 24, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

try
  % Bring figure-window to front
  figure_w_normalized_uicontrolunits(hFigure);
  hold on;

  if bGridEntireArea % Use entire area for grid
    vXLim = get(gca, 'XLim');
    vYLim = get(gca, 'YLim');
    vX = [vXLim(1); vXLim(1); vXLim(2); vXLim(2)];
    vY = [vYLim(2); vYLim(1); vYLim(1); vYLim(2)];
  else
    % Prepare variables
    vX = [];
    vY = [];
    nButton = 1;

    % Let the user click for defining grid polygon (right click closes the polygon)
    while (nButton == 1) | (nButton == 112)
      [fX, fY, nButton] = ginput(1);
      hMarker = plot(fX, fY, '+k', 'era', 'normal');
      set(hMarker, 'MarkerSize', [6], 'LineWidth', [1.0]);
      vX = [vX; fX];
      vY = [vY; fY];
    end
  end % of if bGridEntireArea

  % Closes the polygon
  vX = [vX; vX(1)];
  vY = [vY; vY(1)];

  % Plot outline
  figure_w_normalized_uicontrolunits(hFigure);
  plot(vX, vY, 'b-');

  % Create a rectangular grid
  vXVector = [min(vX):fSpacingX:max(vX)];
  vYVector = [min(vY):fSpacingY:max(vY)];
  mGrid = zeros((length(vXVector) * length(vYVector)), 2);
  nTotal = 0;
  for i = 1:length(vXVector)
    for j = 1:length(vYVector)
      nTotal = nTotal + 1;
      mGrid(nTotal,:) = [vXVector(i) vYVector(j)];
    end
  end

  % Extract all gridpoints in chosen polygon
  XI=mGrid(:,1);
  YI=mGrid(:,2);

  m = length(vX)-1;      %  number of coordinates of polygon
  l = 1:length(XI);
  l = (l*0)';
  vUsedNodes = l;               %  Algorithm to select points inside a closed
  %  polygon based on Analytic Geometry    R.Z. 4/94
  for i = 1:m

    l= ((vY(i)-YI < 0) & (vY(i+1)-YI >= 0)) & ...
      (XI-vX(i)-(YI-vY(i))*(vX(i+1)-vX(i))/(vY(i+1)-vY(i)) < 0) | ...
      ((vY(i)-YI >= 0) & (vY(i+1)-YI < 0)) & ...
      (XI-vX(i)-(YI-vY(i))*(vX(i+1)-vX(i))/(vY(i+1)-vY(i)) < 0);

    if i ~= 1
      vUsedNodes(l) = 1 - vUsedNodes(l);
    else
      vUsedNodes = l;
    end

  end
  %grid points in polygon
  mGrid = mGrid(vUsedNodes,:);

  % Plot the grid points finally
  figure_w_normalized_uicontrolunits(hFigure)
  plot(mGrid(:,1), mGrid(:,2), '+k', 'era', 'normal', 'MarkerSize', [8], 'LineWidth', [1]);
  drawnow;
catch
  mGrid = [];
  vXVector = [];
  vYVector = [];
  vUsedNodes = [];
end
