function [hPlot] = plot_CDF(vDistribution, hAxes, sColor)
% function [hPlot] = plot_CDF(vDistribution, hAxes, sColor)
% ---------------------------------------------------------
% Plots the cumulative density function of a given distribution.
% NaN values are removed from the distribution.
%
% plot_CDF(vDistribution) opens a figure and plots the cumulative density function
%   with default parameters.
%
% Input parameters:
%   vDistribution   Distribution of values to be plotted
%   hAxes           Handle of axes to plot the cumulative density function
%   sColor          Color of plot (refer to Matlab 'plot')
%
% Output parameters:
%   hPlot           Handle of the plot
%
% Danijel Schorlemmer
% July 9, 2003

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Define missing input parameters
if ~exist('hAxes', 'var')
  figure;
  hAxes = newplot;
end
if ~exist('sColor', 'var')
  sColor = 'k';
end

% Remove NaN-values
vSel = ~isnan(vDistribution);
vPlotDist = vDistribution(vSel,:);

% Activate given axes
axes(hAxes);

% Plot the cumulative density function
nLen = length(vPlotDist);
vIndices = [1:nLen]/nLen;
vDist = sort(vPlotDist);
hPlot = plot(vDist, vIndices, sColor);
