function relm_PaintCumPlot(rRelmTest, sXLabel, hAxes)
% function relm_PaintCumPlot(rRelmTest, sXLabel, hAxes)
% -----------------------------------------------------
% Creates the result plots of one of the RELM tests
%
% Input parameters:
%   rRelmTest		Record of results from one of the RELM tests
%   sXLabel		Label of X-axis (optional)
%   hAxes		Handle of existing axes. If not specified, a figure is created
%
% Copyright (C) 2002-2006 by Danijel Schorlemmer
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the
% Free Software Foundation, Inc.,
% 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

if ~exist('sXLabel')
  sXLabel = '';
end
if ~exist('hAxes')
  figure_w_normalized_uicontrolunits('Name', 'Result plot', 'NumberTitle', 'off');
  hAxes = newplot;
end

% Activate the given or newly created axes
axes(hAxes);

% Plot the CDF and the line of observed data
vIndex = [1:rRelmTest.nNumberSimulation]/rRelmTest.nNumberSimulation;
vObservedX = [rRelmTest.fObservedData, rRelmTest.fObservedData];
vObservedY = [0,1];
plot(rRelmTest.vSimValues_H, vIndex, 'g', rRelmTest.vSimValues_N, vIndex, 'r', vObservedX, vObservedY, 'k', 'LineWidth', 1);

% Add the patches
set(hAxes, 'NextPlot', 'add');
vPatch1Y = [1 1 0.975 0.975];
vPatch2Y = [0.025 0.025 0 0];
vXLim = xlim;
vPatch1X = [vXLim(1) rRelmTest.fObservedData rRelmTest.fObservedData vXLim(1)];
vPatch2X = [rRelmTest.fObservedData vXLim(2) vXLim(2) rRelmTest.fObservedData];
patch(vPatch1X, vPatch1Y, [0.8 0.8 0.8], 'facealpha', 0.7);
patch(vPatch2X, vPatch2Y, [0.8 0.8 0.8], 'facealpha', 0.7);

% Add information
title(['\alpha = ' num2str(rRelmTest.fAlpha) ', \beta = ' num2str(rRelmTest.fBeta)]);
ylabel('Fraction of cases');
xlabel(sXLabel);



