function aux_2FMD(params, hParentFigure)
% function aux_2FMD(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 19.08.02

% Track of changes:
% 19.08.02: Replaced fcumulsum.m with calc_cumulsum.m

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

%[caNodeIndices] = ex_CreateIndexCatalog(params.mCatalog, params.mPolygon, params.bMap, params.nGriddingMode,...
%    params.nNumberEvents, params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);
%mNodeCatalog_ = params.mCatalog(caNodeIndices{nNodeGridPoint}, :);
% Get the data for the grid node
 mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);

%%%% Doe: Determine next grid point and earthquakes associated with it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.fTimePeriod = params.fTimePeriod/365;
% Split the gridpoint catalog according to the defined Splittime
[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
       result.fSecondPeriod] = ex_SplitCatalog(mNodeCatalog_, params.fSplitTime, params.bTimePeriod,...
   params.fTimePeriod, params.bTimePeriod, params.fTimePeriod);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start First Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine cumulative and non-cumulative sums
[mEv_val mMags mEv_valsum mEv_valsum_rev,  mMags_rev] = calc_cumulsum(mFirstCatalog);
[mEv_val2 mMags2 mEv_valsum2 mEv_valsum_rev2,  mMags_rev2] = calc_cumulsum(mSecondCatalog);

if exist('cum_mag_fig','var') &  ishandle(cum_mag_fig)
   set(0,'Currentfigure',cum_mag_fig);
   disp('Figure exists');
else
    cum_mag_fig=figure_w_normalized_uicontrolunits('tag','cumFMD','Name','Cumulative FMD','Units','normalized','Nextplot','add','Numbertitle','off');
    cum_mag_axs=axes('tag','ax_cumFMD','Nextplot','add','box','on');
end
% Figure: Bar and cumulative sums

subplot(2,1,1);
set(gca,'tag','ax_cumFMD1','Nextplot','replace','box','on');
axs3=findobj('tag','ax_cumFMD1');
axes(axs3(1));
plot(mMags,mEv_val,'-o',mMags2,mEv_val2,'-*')
xlim([floor(min(mNodeCatalog_(:,6))) ceil(max(mNodeCatalog_(:,6)))]);
ylabel('Non-cumulative sum ');
subplot(2,1,2);
set(gca,'tag','ax_cumFMD2','Nextplot','replace','box','on','Yscale','log');
axs4=findobj('tag','ax_cumFMD2');
axes(axs4(1));
semilogy(mMags,mEv_valsum,'-o','Color',[0 0 1])
hold on;
semilogy(mMags_rev,mEv_valsum_rev,'-o','Color',[0 0 1])
semilogy(mMags2,mEv_valsum2,'-*','Color',[0 0.5 0])
semilogy(mMags_rev2,mEv_valsum_rev2,'-*','Color',[0 0.5 0])
xlim([floor(min(mNodeCatalog_(:,6))) ceil(max(mNodeCatalog_(:,6)))]);
ylabel('Cumulative number');
xlabel('Magnitude')
hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End First Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
set(gca,'tag','ax_bnew','Nextplot','replace','box','on');
axs5=findobj('tag','ax_bnew');
axes(axs5(1));
semilogy(vFMD(1,:), vFMD(2,:),'-o');
hold on;
semilogy(vFMDSecond(1,:), vFMDSecond(2,:),'-*','Color', [0 0.5 0]);
sColor = 'b';

% Calculate magnitude of completeness
fMc = calc_Mc(mFirstCatalog, params.nCalculateMC);
fMcSecond = calc_Mc(mSecondCatalog, params.nCalculateMC);

% First period
[nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mFirstCatalog, vFMD, fMc);
 % Calculate the b-value etc. for M > Mc
[fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mFirstCatalog(vSel,:),0.1);
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
txtInfoString = ['a: ' num2str(fAValue) ', b: ' num2str(fBValue) ', std: ' num2str(fStdDev)];
text(0.1, 1.1, txtInfoString, 'Color', [0 0 1]);

%% Temporaer
vFMD(2,nIndexLo)
%% Second period
sColor = 'g';
[nIndexLoSecond, fMagHiSecond, vSelSecond, vMagnitudesSecond] = fMagToFitBValue(mSecondCatalog, vFMDSecond, fMcSecond);
% Calculate the b-value etc. for M > Mc
[fMeanMagSecond, fBValueSecond, fStdDevSecond, fAValueSecond] =  calc_bmemag(mSecondCatalog(vSelSecond,:), 0.1);
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
txtInfoString = ['a: ' num2str(fAValueSecond) ', b: ' num2str(fBValueSecond) ', std: ' num2str(fStdDevSecond)];
text(0.1, 1.4, txtInfoString, 'Color', [0 0.5 0]);

% Determine magnitude shift
fMintercept = 1/fBValueSecond*(fAValueSecond-log10(vFMD(2,nIndexLo)));
fMshift = fMintercept - vFMD(1,nIndexLo);

% Entire plot labels
xlabel('Magnitude');
ylabel('Cumulative sum per grid node');
if params.bTimePeriod == 0
    sTitleString = ['o: ' num2str(min(mFirstCatalog(:,3))) ' - ' num2str(max(mFirstCatalog(:,3))) ' *: ' num2str(min(mSecondCatalog(:,3)))...
        ' - ' num2str(max(mSecondCatalog(:,3)))];
else
    sTitleString = ['o: ' num2str(params.fSplitTime-params.fTimePeriod) ' - ' num2str(params.fSplitTime) ' *: ' num2str(params.fSplitTime)...
        ' - ' num2str(params.fSplitTime+params.fTimePeriod)];
end
title(sTitleString);
hold off;

