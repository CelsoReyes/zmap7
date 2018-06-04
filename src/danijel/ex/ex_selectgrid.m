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

report_this_filefun();

try
  % Bring figure-window to front
  figure(hFigure);
  set(gca,'NextPlot','add');

  if bGridEntireArea % Use entire area for grid
    vXLim = get(gca, 'XLim');
    vYLim = get(gca, 'YLim');
    vX = [vXLim(1); vXLim(1); vXLim(2); vXLim(2); vXLim(1)];
    vY = [vYLim(2); vYLim(1); vYLim(1); vYLim(2); vYLim(2)];
  else
    % Prepare variables
    vX = [];
    vY = [];
    nButton = 1;

    % Let the user click for defining grid polygon (right click closes the polygon)
    while (nButton == 1) || (nButton == 112)
      [fX, fY, nButton] = ginput(1);
      hMarker = plot(fX, fY, '+k');
      set(hMarker, 'MarkerSize', [6], 'LineWidth', [1.0]);
      vX = [vX; fX];
      vY = [vY; fY];
    end
      % Closes the polygon
      vX = [vX; vX(1)];
      vY = [vY; vY(1)];
  end % of if bGridEntireArea


  % Plot outline
  figure(hFigure);
  plot(vX, vY, 'b-');

  % Create a rectangular grid
  vXVector = [min(vX):fSpacingX:max(vX)];
  vYVector = [min(vY):fSpacingY:max(vY)];
  [A,B]=meshgrid(vXVector,vYVector);
  mGrid=[A(:),B(:)];
  % Extract all gridpoints in chosen polygon
  XI=mGrid(:,1);
  YI=mGrid(:,2);

    vUsedNodes = polygon_filter(vX,vY, XI, YI, 'inside');
  %grid points in polygon
  mGrid = mGrid(vUsedNodes,:);

  % Plot the grid points finally
  figure(hFigure);
  plot(mGrid(:,1), mGrid(:,2), '+k',  'MarkerSize', [8], 'LineWidth', [1]);
  drawnow;
catch ME
    warning(ME.message)
  mGrid = [];
  vXVector = [];
  vYVector = [];
  vUsedNodes = [];
end
