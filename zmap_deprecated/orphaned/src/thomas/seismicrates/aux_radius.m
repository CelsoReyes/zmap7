function aux_radius(params, hParentFigure)
% function aux_FMD(params, hParentFigure);
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
axes(sr_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok');

% Get closest gridnode for the chosen point on the map
[fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY);
plot(fXGridNode, fYGridNode, '*r');

xx = -pi-0.1:0.1:pi;
if ~params.bMap
    plot(fXGridNode+cos(xx)*params.vResolution(nNodeGridPoint), fYGridNode+sin(xx)*params.vResolution(nNodeGridPoint),'-r')
else
    disp('WARNING: Radiusplot fuer mapview noch pruefen!! aux_radius.m')
    plot((fXGridNode+sin(xx)*params.vResolution(nNodeGridPoint)/(cos(pi/180*fYGridNode)*111))', (fYGridNode+sin(xx)*params.vResolution(nNodeGridPoint)/(cos(pi/180*fYGridNode)*111))','-k')
end
hold off;



% Get the data for the grid node
mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);
%%%% Doe: Determine next grid point and earthquakes associated with it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.fTimePeriod = params.fTimePeriod/365;
% Split the gridpoint catalog according to the defined Splittime
[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
       result.fSecondPeriod] = ex_SplitCatalog(mNodeCatalog_, params.fSplitTime, params.bTimePeriod,...
   params.fTimePeriod, params.bTimePeriod, params.fTimePeriod);


% Create the frequency magnitude distribution vectors for the two time periods
[vFMDOrg, vNonFMDOrg] = calc_FMD(mNodeCatalog_);
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
semilogy(vFMDOrg(1,:), vFMDOrg(2,:),'-k^');
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

