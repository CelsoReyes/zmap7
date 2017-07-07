function aux_Bic(params, hParentFigure)
% function aux_Bic(params, hParentFigure);
%-------------------------------------------
% Function to display maximum likelihood scores and BIC determination
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 04.11.02

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start First Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Comparison of data modelling only magnitudes above Mc
[fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM(mFirstCatalog, mSecondCatalog);
[fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch(mFirstCatalog, mSecondCatalog);
[fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate(mFirstCatalog, mSecondCatalog);
[fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate(mFirstCatalog, mSecondCatalog);
[fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_loglikelihood_stretch_rate(mFirstCatalog, mSecondCatalog);
[fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans(mFirstCatalog, mSecondCatalog);
[fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_loglikelihood_dMdSrate(mFirstCatalog, mSecondCatalog);

vBic = [fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
