function [hPlot, fBValue, fAValue, fStdDev, fMc, fMeanMag] = plot_FMD(mCatalog, bCumulative, hAxes, sSymbol, sColor, bPlotB, nCalculateMC, fBinning)
% function [hPlot, fBValue, fAValue, fStdDev, fMc, fMeanMag]
%   = plot_FMD(mCatalog, bCumulative, hAxes, sSymbol, sColor, bPlotB, nCalculateMC, fBinning)
% -------------------------------------------------------------------------------------------
% Creates and plots a frequency magnitude distribution including the b-value
%
% plot_FMD(mCatalog) opens a figure and plots the frequency magnitude distribution
%   with standard parameters
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   bCumulative     Plot cumulative frequency magnitude distribution (=1) or non-cumulative (=0)
%   hAxes           Handle of axes to plot the frequency magnitude distribution
%   sSymbol         Type of symbol for plotting (refer to Matlab 'plot')
%   sColor          Color of plot (refer to Matlab 'plot')
%   bPlotB          Also plot the b-value line with markers
%   nCalculateMC    Method to determine the magnitude of completeness
%                   1: Maximum curvature
%                   2: Fixed Mc = minimum magnitude (Mmin)
%                   3: Mc90 (90% probability)
%                   4: Mc95 (95% probability)
%                   5: Best combination (Mc95 - Mc90 - maximum curvature)
%   fBinning        Magnitude binning of the catalog (default 0.1)
%
% Output parameters:
%   hPlot           Handle of the plot
%   fBValue         Calculated b-value
%   fAValue         Calculateda-value
%   fStdDev         Standard deviation of b-value
%   fMc             Magnitude of completeness
%   fMeanMag        Determined mean magnitude
%
% Danijel Schorlemmer
% June 16, 2003

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Create the frequency magnitude distribution vector
[vFMD, vNonCFMD] = calc_FMD(mCatalog);

% Define missing input parameters
if ~exist('bCumulative', 'var')
  bCumulative = 1;
end
if ~exist('hAxes', 'var')
  figure;
  hAxes = newplot;
end
if ~exist('sSymbol', 'var')
  sSymbol = 's';
end
if ~exist('sColor', 'var')
  sColor = 'k';
end
if ~exist('bPlotB', 'var')
  bPlotB = 1;
end
if ~exist('nCalculateMC', 'var')
  nCalculateMC = 2;
end
if ~exist('fBinning', 'var')
  fBinning = 0.1;
end

% Activate given axes
axes(hAxes);

% Plot the frequency magnitude distribution
if bCumulative
  hPlot = semilogy(vFMD(1,:), vFMD(2,:), [sSymbol sColor]);
else
  hPlot = semilogy(vNonCFMD(1,:), vNonCFMD(2,:), [sSymbol sColor]);
end

if exist('bPlotB')
  if bPlotB
    % Add further plots to the axes
    set(hAxes, 'NextPlot', 'add');

    % Calculate magnitude of completeness
    fMc = calc_Mc(mCatalog, nCalculateMC, fBinning);

    % Determine the positions of 'x'-markers
    nIndexLo = find((vFMD(1,:) < fMc + 0.05) & (vFMD(1,:) > fMc - 0.05));
    fMagHi = vFMD(1,1);
    vSel = vFMD(1,:) <= fMagHi & vFMD(1,:) >= fMc-.0001;
    vMagnitudes = vFMD(1,vSel);

    % Plot the 'x'-marker
    hPlot = semilogy(vFMD(1,nIndexLo), vFMD(2,nIndexLo), ['x' sColor]);
    set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12);
    hPlot = semilogy(vFMD(1,1), vFMD(2,1), ['x' sColor]);
    set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12)

    % Calculate the b-value etc. for M > Mc
    vSel = mCatalog.Magnitude >= fMc-(fBinning/2);
    [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog.subset(vSel), fBinning);

    % Plot the line representing the b-value
    vPoly = [-1*fBValue fAValue];
    fBFunc = 10.^(polyval(vPoly, vMagnitudes));
    hPlot = semilogy(vMagnitudes, fBFunc, sColor);
    set(hPlot, 'LineWidth', [2.0]);
  end
end

