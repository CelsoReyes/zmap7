function [hPlot] = plot_FMDboth(mCatalog, fMc, fAvalue, fBvalue, fBinning, nMinNum)
% function [hPlot, fBValue, fAValue, fStdDev, fMc, fMeanMag]
%   = plot_FMD(mCatalog, bCumulative, hAxes, sSymbol, sColor, bPlotB, nCalculateMC, fBinning)
% -------------------------------------------------------------------------------------------
% Plots a cumulative and non-cumulative frequency magnitude distribution including the b-value
%
% plot_FMD(mCatalog) opens a figure and plots the frequency magnitude distribution
%   with standard parameters
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   fMc             Magnitude of completeness
%   fAValue         Calculateda-value
%   fBValue         Calculated b-value
%   fBinning        Magnitude binning of the catalog (default 0.1)
%   nMinNum         Minimum number of events
%
% Output parameters:
%   hPlot           Handle of the plot
%
% jowoe@gps.caltech.edu
% 25.01.2006

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Catalog size
[nRow,nCol] = size(mCatalog);

% Create the frequency magnitude distribution vector
[vFMD, vNonCFMD] = calc_FMD(mCatalog);

if ~exist('fBinning', 'var')
  fBinning = 0.1;
end

figure
% Plot cumulative frequency magnitude distribution
hPlot = semilogy(vFMD(1,:), vFMD(2,:));
set(hPlot,'Marker','^','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.75 0.75 0.75],'Markersize',8,'Linewidth',2,'Linestyle','none');
hold on
hPlot2 = semilogy(vNonCFMD(1,:), vNonCFMD(2,:));
set(hPlot2,'Marker','d','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.4 0.4 0.4],'Markersize',8,'Linewidth',2,'Linestyle','none');

% Add further plots to the axes
set(gca, 'NextPlot', 'add');

if (~isnan(fMc) & ~isnan(fBvalue) & nRow >= 2*nMinNum)
    % Determine the positions of 'x'-markers
    nIndexLo = find((vFMD(1,:) < fMc + 0.05) & (vFMD(1,:) > fMc - 0.05));
    fMagHi = vFMD(1,1);
    vSel = vFMD(1,:) <= fMagHi & vFMD(1,:) >= fMc-.0001;
    vMagnitudes = vFMD(1,vSel);

    % Plot the 'x'-marker
    hPlot = semilogy(vFMD(1,nIndexLo), vFMD(2,nIndexLo), 'x','Color',[0.8 0 0]);
    set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12);
    hPlot = semilogy(vFMD(1,1), vFMD(2,1), 'x','Color',[0.8 0 0]);
    set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12)

    % Plot the line representing the b-value
    vPoly = [-1*fBvalue fAvalue];
    fBFunc = 10.^(polyval(vPoly, vMagnitudes));
    hPlot = semilogy(vMagnitudes, fBFunc);
    set(hPlot, 'LineWidth', [2.0],'Linestyle','--','Color',[0.8 0 0]);
end
% Y-Limits
vYLim = get(gca,'YLim');
set(gca,'FontSize',12','Fontweight','bold','box','on','Ylim',[1 vYLim(2)],'Linewidth',1.5)
xlabel('Magnitude','FontSize',14','Fontweight','bold')
ylabel('Number of events','FontSize',14','Fontweight','bold')
