function [fBValue, fAValue, fStdDev, fMc] = plot_FMD2(mCatalog, hAxes, rCalculateMC, rDisplay)
% function [fBValue, fAValue, fStdDev, fMc]
%   = plot_FMD2(mCatalog, bCumulative, hAxes, sSymbol, sColor, bPlotB, nCalculateMC, fBinning)
% --------------------------------------------------------------------------------------------
% Creates and plots a frequency magnitude distribution including the b-value
%
% plot_FMD2(mCatalog) opens a figure and plots the frequency magnitude distribution
%   with standard parameters
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   hAxes           Handle of axes to plot the frequency magnitude distribution
%   rCalculateMC    Record with information about magnitude of completeness computing
%     nMethod       Method to determine the magnitude of completeness (see calc_Mc) (default 1)
%     bConstrain    Constrain Mc to a given range [fMinMc; fMaxMc] (default 0)
%     fMinMc        Minimum Mc when constrained
%     fMaxMc        Maximum Mc when constrained
%     fBinning      Magnitude binning of the catalog (default 0.1)
%   rDisplay        Record with display preferences
%     sSymbol       Symbol for FMD (default 's')
%     sColor        Color of FMD (default 'k')
%     bPlotB        Plot b-value line (=1) or not (=0) (default 1)
%     bCumulative   Plot cumulative frequency magnitude distribution (=1) or non-cumulative (=0)
%
% Output parameters:
%   fBValue         Calculated b-value
%   fAValue         Calculateda-value
%   fStdDev         Standard deviation of b-value
%   fMc             Magnitude of completeness
%
% Danijel Schorlemmer
% November 5, 2003

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Create the frequency magnitude distribution vector
[vFMD, vNonCFMD] = calc_FMD(mCatalog);

% Define missing input parameters
if ~exist('hAxes', 'var')
  figure;
  hAxes = newplot;
end
if ~exist('rCalculateMC', 'var')
  rCalculateMC.nMethod = 1;
  rCalculateMC.bConstrain = 0;
  rCalculateMC.fMinMc = -10;
  rCalculateMC.fMaxMc = 10;
  rCalculateMC.fBinning = 0.1;
end
if ~exist('rDisplay', 'var')
  rDisplay.sSymbol = 's';
  rDisplay.sColor = 'k';
  rDisplay.bPlotB = 1;
  rDisplay.bCumulative = 1;
end

% Activate given axes
axes(hAxes);
set(hAxes, 'NextPlot', 'add');

% Plot the frequency magnitude distribution
if rDisplay.bCumulative
  hPlot = semilogy(vFMD(1,:), vFMD(2,:), [rDisplay.sSymbol rDisplay.sColor]);
else
  hPlot = semilogy(vNonCFMD(1,:), vNonCFMD(2,:), [rDisplay.sSymbol rDisplay.sColor]);
end
set(hAxes, 'YScale', 'log'); % Bug in Matlab

if rDisplay.bPlotB
  % Calculate magnitude of completeness
  [fBValue, vDummy, fMc, fAValue] = calc_BandMc(mCatalog, 0, rCalculateMC.nMethod, rCalculateMC.fBinning, rCalculateMC.bConstrain, rCalculateMC.fMinMc, rCalculateMC.fMaxMc);

  % Determine the positions of 'x'-markers
  nIndexLo = find((vFMD(1,:) < fMc + (rCalculateMC.fBinning/2)) & (vFMD(1,:) > fMc - (rCalculateMC.fBinning/2)));
  fMagHi = vFMD(1,1);
  vSel = vFMD(1,:) <= fMagHi & vFMD(1,:) >= fMc-.0001;
  vMagnitudes = vFMD(1,vSel);

  % Plot the 'x'-marker
  hPlot = semilogy(vFMD(1,nIndexLo), vFMD(2,nIndexLo), ['x' rDisplay.sColor]);
  set(hPlot, 'LineWidth', [2], 'MarkerSize', 12);
  hPlot = semilogy(vFMD(1,1), vFMD(2,1), ['x' rDisplay.sColor]);
  set(hPlot, 'LineWidth', [2], 'MarkerSize', 12)

  % Plot the line representing the b-value
  vPoly = [-1*fBValue fAValue];
  fBFunc = 10.^(polyval(vPoly, vMagnitudes));
  hPlot = semilogy(vMagnitudes, fBFunc, rDisplay.sColor);
  set(hPlot, 'LineWidth', [2]);
end


