function aux_AIC(params, hParentFigure)
% function aux_AIC(params, hParentFigure);
%-------------------------------------------
% Calculates the AICs of the models
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 29.10.02

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

% Get the data for the grid node
mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);
%%%% Doe: Determine next grid point and earthquakes associated with it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.fTimePeriod = params.fTimePeriod/365;
% Split the gridpoint catalog according to the defined Splittime
[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
        result.fSecondPeriod] = ex_SplitCatalog(mNodeCatalog_, params.fSplitTime, params.bTimePeriod,...
    params.fTimePeriod, params.bTimePeriod, params.fTimePeriod);

%%% Maximum likelihood scores and corrected AICs
[fProb_nochange, fAICc_nochange] = calc_loglikelihood_nochange2(mFirstCatalog, mSecondCatalog);
[fdM, fProb_dM, fAICc_dM, mLikeli_dM] = calc_loglikelihood_dM2(mFirstCatalog, mSecondCatalog);
[fdMc, fProb_dMc, fAICc_dMc] = calc_llhd_dMc2(mFirstCatalog, mSecondCatalog);
%[fS, fProb_stretch, fAICc_stretch, mLikeli_dS] = calc_loglikelihood_stretch(mFirstCatalog, mSecondCatalog);
[fFac, fProb_Rate, fAICc_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(mFirstCatalog, mSecondCatalog);
[fdM_rate, fdM_Fac, fProb_dMrate, fAICc_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(mFirstCatalog, mSecondCatalog);
%[fdS_rate, fdS_Fac, fProb_dSrate, fAICc_dSrate mLikeli_dSrate] = calc_loglikelihood_stretch_rate(mFirstCatalog, mSecondCatalog);
%[fdM_st, fStretch, fProb_Trans, fAICc_Trans, mLikeli_Trans] = calc_loglikelihood_Trans(mFirstCatalog, mSecondCatalog);
%[fdM_all, fdS_all, fFac_all, fProb_all, fAICc_all, mLikeli_all] = calc_loglikelihood_dMdSrate(mFirstCatalog, mSecondCatalog);


%vAICc = [fAICc_nochange; fAICc_dM; fAICc_stretch; fAICc_Rate; fAICc_dMrate; fAICc_Trans; fAICc_dSrate; fAICc_all];
vAICc = [fAICc_nochange; fAICc_dM;  fAICc_dMc; fAICc_Rate; fAICc_dMrate]
