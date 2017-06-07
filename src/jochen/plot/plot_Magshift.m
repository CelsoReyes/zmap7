function [fMshift] = plot_Magshift(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC)
% function [fMshift] = plot_Magshift(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC);
% ------------------------------------------------------------------------------------
% Function to calculate simple magnitude shift between two time periods using the
% procedure proposed by Zuniga & Wyss, BSSA, Vol.85, No.6, 1858-1866, 1995
% Mnew = Mold + fMshift
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% fSplitTime   : Splittime of catalog
% bTimePeriod  :
% fTimePeriod  :
% nCalculateMC
%
% Outgoing variable:
% fMshift : magnitude shift
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 10.07.02

[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
       result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, bTimePeriod, fTimePeriod);

% Create the frequency magnitude distribution vectors for the two time periods
[vFMD, vNonCFMD] = calc_FMD(mFirstCatalog);
[vFMDSecond, vNonCFMDSecond] = calc_FMD(mSecondCatalog);

if exist('new_fig','var') &  ishandle(new_fig)
   set(0,'Currentfigure',new_fig);
   disp('Figure exists');
else
    new_fig=figure_w_normalized_uicontrolunits('tag','bnew','Name','Cumulative FMD and b-value fit','Units','normalized','Nextplot','add','Numbertitle','off');
    new_axs=axes('tag','ax_bnew','Nextplot','add','box','on');
end
set(gca,'tag','ax_bnew','Nextplot','replace','box','on', 'Xlim', [0 max(mCatalog(:,6))]);
set(gca,'tag','ax_bnew','Nextplot','replace','box','on');
axs5=findobj('tag','ax_bnew');
axes(axs5(1));
semilogy(vFMD(1,:), vFMD(2,:),'-o');
hold on;
semilogy(vFMDSecond(1,:), vFMDSecond(2,:),'-*','Color', [0 0.5 0]);
sColor = 'b';

% Calculate magnitude of completeness
fMc = calc_Mc(mFirstCatalog, nCalculateMC);
fMcSecond = calc_Mc(mSecondCatalog, nCalculateMC);

% First period
[nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mFirstCatalog, vFMD, fMc);
 % Calculate the b-value etc. for M > Mc
[fMeanMag, fBValue, fStdDev, fAValue] =  bmemag(mFirstCatalog(vSel,:));
% Plot the 'x'-marker
hPlot = semilogy(vFMD(1,nIndexLo), vFMD(2,nIndexLo), ['x' sColor]);
set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12);
hPlot = semilogy(vFMD(1,1), vFMD(2,1), ['x' sColor]);
set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12)

% Plot the line representing the b-value
vPoly = [-1*fBValue fAValue];
fBFunc = 10.^(polyval(vPoly, vMagnitudes));
hPlot = semilogy(vMagnitudes, fBFunc, sColor);
set(hPlot, 'LineWidth', [2.0]);
txtInfoString = ['Max. Likelihood: a: ' num2str(fAValue) ', b: ' num2str(fBValue) ', std: ' num2str(fStdDev)];
text(0.2, 2, txtInfoString, 'Color', [0 0 1]);

%% Second period
sColor = 'g';
[nIndexLoSecond, fMagHiSecond, vSelSecond, vMagnitudesSecond] = fMagToFitBValue(mSecondCatalog, vFMDSecond, fMcSecond);
% Calculate the b-value etc. for M > Mc
[fMeanMagSecond, fBValueSecond, fStdDevSecond, fAValueSecond] =  bmemag(mSecondCatalog(vSelSecond,:));
% Plot the 'x'-marker
hPlot = semilogy(vFMDSecond(1,nIndexLoSecond), vFMDSecond(2,nIndexLoSecond), ['x' sColor]);
set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12);
hPlot = semilogy(vFMDSecond(1,1), vFMDSecond(2,1), ['x' sColor]);
set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12)

% Plot the line representing the b-value
vPolySecond = [-1*fBValueSecond fAValueSecond];
fBFuncSecond = 10.^(polyval(vPolySecond, vMagnitudesSecond));
hPlot = semilogy(vMagnitudesSecond, fBFuncSecond, 'Color', [0 0.5 0]);
set(hPlot, 'LineWidth', [2.0]);
txtInfoString = ['Max. Likelihood :a: ' num2str(fAValueSecond) ', b: ' num2str(fBValueSecond) ', std: ' num2str(fStdDevSecond)];
text(0.2, 1.2, txtInfoString, 'Color', [0 0.5 0]);

% Determine magnitude shift
fMintercept = 1/fBValueSecond*(fAValueSecond-log10(vFMD(2,nIndexLo)));
fMshift = fMintercept - vFMD(1,nIndexLo);
% set(gca,'tag','ax_bnew','Nextplot','add','box','on', 'Xlim', [0 ceil(max(mCatalog(:,6)))]);
% axs5=findobj('tag','ax_bnew');
% axes(axs5(1));
% semilogy(vFMD(1,:)+fMshift, vFMD(2,:),'-sm');
% txtInfoString = ['Magnitude shift: ' num2str(fMshift)];
% text(0.5, 0.9, txtInfoString, 'Color', [0.5 0.5 0.5]);
hold off;

% Entire plot labels
xlabel('Magnitude');
ylabel('Cumulative sum');
if bTimePeriod == 0
    sTitleString = ['o: ' num2str(min(mFirstCatalog(:,3))) ' - ' num2str(max(mFirstCatalog(:,3))) ' *: ' num2str(min(mSecondCatalog(:,3)))...
        ' - ' num2str(max(mSecondCatalog(:,3)))];
else
    sTitleString = ['o: ' num2str(fSplitTime-fTimePeriod/365) ' - ' num2str(fSplitTime) ' *: ' num2str(fSplitTime)...
        ' - ' num2str(fSplitTime+fTimePeriod/365)];
end
title(sTitleString);
