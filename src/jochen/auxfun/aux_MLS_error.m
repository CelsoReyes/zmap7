function aux_MLS_error(params, hParentFigure)
% function aux_MLS_error(params, hParentFigure);
%-------------------------------------------
% Function to plot the best fitting model of seismicity variation parameters using the maximum likelihood score determination
% !!! FIND REASON FOR STRANGE RESULTS
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
fdM = nan;
fdS = nan;
fRf = nan;
nModel = params.mValueGrid(nNodeGridPoint,6)
switch nModel
case 1
    [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange(mFirstCatalog, mSecondCatalog);
    sTxt_nochange = ['No change!']
case 2
    [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM(mFirstCatalog, mSecondCatalog);
    plot_mls1p(mLikeli_dM(:,1), mLikeli_dM(:,2), 1);
    fdM = fdM;
    sTxt_dM = ['Simple magnitude shift: dM = ' num2str(fdM) ' , '...
            ' Max. likelihood score = ' num2str(fProb_dM) ' , BIC = ' num2str(fBic_dM)]
% case 3
%     [fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch(mFirstCatalog, mSecondCatalog);
%     plot_mls1p(mLikeli_dS(:,1), mLikeli_dS(:,2), 2);
%     fdS = fS;
%     sTxt_stretch = ['Magnitude stretch: c = ' num2str(fS) ' , '...
%             ' Max. likelihood score = ' num2str(fProb_stretch) ' , BIC = ' num2str(fBic_stretch)]
case 3
    [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate(mFirstCatalog, mSecondCatalog);
    plot_mls1p(mLikeli_Rate(:,1), mLikeli_Rate(:,2), 3);
    fRf = fFac;
    sTxt_rate = ['Rate change: R_f = ' num2str(fFac) ' , '...
            ' Max. likelihood score = ' num2str(fProb_Rate) ' , BIC = ' num2str(fBic_Rate)]
case 4
    [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate(mFirstCatalog, mSecondCatalog);
    plot_mls2p(mLikeli_dMrate(:,1), mLikeli_dMrate(:,2), mLikeli_dMrate(:,3),3);
    fdM = fdM_rate;
    fRf = fdM_Fac;
    sTxt_dMrate = ['Magnitude shift and rate change: dM = ' num2str(fdM_rate) ' , R_f =' num2str(fdM_Fac) ' , '...
            ' Max. likelihood score = ' num2str(fProb_dM) ' , BIC = ' num2str(fBic_dMrate)]
% case 6
%     [fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans(mFirstCatalog, mSecondCatalog);
%     plot_mls2p(mLikeli_Trans(:,1), mLikeli_Trans(:,2), mLikeli_Trans(:,3), 1);
%     fdM = fdM_st;
%     fdS = fStretch;
%     sTxt_Trans = ['Magnitude transformation: c = ' num2str(fStretch) ' , dM_st = ' num2str(fdM_st) ' , '...
%             ' Max. likelihood score = ' num2str(fProb_Trans) ' , BIC = ' num2str(fBic_Trans)]
% case 7
%     [fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_loglikelihood_stretch_rate(mFirstCatalog, mSecondCatalog);
%     plot_mls2p(mLikeli_dSrate(:,1), mLikeli_dSrate(:,2), mLikeli_dSrate(:,3), 2);
%     fdS = fdS_rate;
%     fRf = fdS_Fac;
%     sTxt_dSrate = ['Stretch and rate change: c = ' num2str(fdS_rate) ' , R_f =' num2str(fdS_Fac) ' , '...
%             ' Max. likelihood score = ' num2str(fProb_dSrate) ' , BIC = ' num2str(fBic_dSrate)]
% case 8
%     [fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_loglikelihood_dMdSrate(mFirstCatalog, mSecondCatalog);
%     plot_mls3p(mLikeli_all(:,1), mLikeli_all(:,2), mLikeli_all(:,3), mLikeli_all(:,4));
%     fdM = fdM_all;
%     fdS = fdS_all;
%     fRf = fFac_all;
%     sTxt_dSdMrate = ['Shift, Stretch and Rate change: dM = ' num2str(fdM_all) ' , c = ' num2str(fdS_all) ' , R_f =' num2str(fFac_all) ' , '...
%             ' Max. likelihood score = ' num2str(fProb_all) ' , BIC = ' num2str(fBic_all)]
otherwise
    errordlg('No model chosen','Model error');
    return;
end
% Plot model
plot_svmodel(fdM, fdS, fRf, mFirstCatalog, mSecondCatalog);
% [vFMD, vNonCFMD] = calc_FMD(mFirstCatalog);
% [fProbMin, fMcBest] = calc_McCdf(mFirstCatalog, 0.1);
% [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mFirstCatalog, vFMD,fMcBest);
% [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mFirstCatalog, 0.1);
% vPoly = [-1*fBValue fAValue];
% fBFunc = 10.^(polyval(vPoly, vMagnitudes));
% % Determine all Bics and show
% [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange(mFirstCatalog, mSecondCatalog);
% [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM(mFirstCatalog, mSecondCatalog);
% [fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch(mFirstCatalog, mSecondCatalog);
% [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate(mFirstCatalog, mSecondCatalog);
% [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate(mFirstCatalog, mSecondCatalog);
% [fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_loglikelihood_stretch_rate(mFirstCatalog, mSecondCatalog);
% [fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans(mFirstCatalog, mSecondCatalog);
% [fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_loglikelihood_dMdSrate(mFirstCatalog, mSecondCatalog);
%
%
% vBic = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
