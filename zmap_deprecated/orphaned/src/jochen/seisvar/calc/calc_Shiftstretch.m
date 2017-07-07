function [fMshift, fStretch, fMTransFit, fARate] = calc_Shiftstretch(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC, fMcOrg, fBValueOrg)
% function [fMshift, fStretch, fMTransFit] = plot_Shiftstretch(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC, fMcOrg, fBValueOrg)
% ----------------------------------------------------------------------------------------------------------------------------------------------
% Function to calculate shift and stretch: Mnew = c*Mold+ dM;
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% bTimePeriod   : Use catalog from beginning to end (0), use time periods (1)
% fSplitTime   : Splittime of catalog
% fTimePeriod  : Time period in decimal years
% nCalculateMC : Method to determine Mc (1-5 see help calc_Mc)
% fMcOrg       : Mc of entire catalog
%
% Outgoing variable:
% fMshift    : magnitude shift
% fStretch   : stretch factor
% fMTransFit : Goodness of fit by modeling second period manipulating the first period
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 09.10.02

% Track of changes:
% 21.08.02: Solved stability  problem (Error: vFMD(1,1) index exceeds matrix dimension) by adding
%           ~isempty(vFMD) & ~isempty(vFMDSecond) into if statement
% 03.10.02: Still little problems with mRes

% Track variables
% fProbability: log likelihood score

global fProbability

[mFirstCatalog, mSecondCatalog, fFirstPeriodExact, fSecondPeriodExact, fFirstPeriod,...
        result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, bTimePeriod, fTimePeriod);
% Time periods for normalization
if bTimePeriod == 0
    fPeriod1 = (max(mFirstCatalog(:,3))-min(mFirstCatalog(:,3)));
    fPeriod2 = (max(mSecondCatalog(:,3))-min(mSecondCatalog(:,3)));
else
    fPeriod1 = fTimePeriod;
    fPeriod2 = fTimePeriod;
end

% Create the frequency magnitude distribution vectors for the two time
% periods and entire catalog
[vFMD, vNonCFMD] = calc_FMD(mFirstCatalog);
[vFMDSecond, vNonCFMDSecond] = calc_FMD(mSecondCatalog);

% Calculate magnitude of completeness
fMc = calc_Mc(mFirstCatalog, nCalculateMC);
fMcSecond = calc_Mc(mSecondCatalog, nCalculateMC);

if (~isempty(fMc) & ~isempty(fMcSecond) & ~isnan(fMc) & ~isnan(fMcSecond) & ~isempty(vFMD) & ~isempty(vFMDSecond))
    % First period
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mFirstCatalog, vFMD, fMc);
    % Calculate the b-value etc. for M > Mc
    [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemagMag(mFirstCatalog(vSel,:));
    vPoly = [-1*fBValue fAValue];
    fBFunc = 10.^(polyval(vPoly, vMagnitudes));
    %% Second period
    [nIndexLoSecond, fMagHiSecond, vSelSecond, vMagnitudesSecond] = fMagToFitBValue(mSecondCatalog, vFMDSecond, fMcSecond);
    % Calculate the b-value etc. for M > Mc
    [fMeanMagSecond, fBValueSecond, fStdDevSecond, fAValueSecond] = calc_bmemagMag(mSecondCatalog(vSelSecond,:));
    vPolySecond = [-1*fBValueSecond fAValueSecond];
    fBFuncSecond = 10.^(polyval(vPolySecond, vMagnitudesSecond));
    % Determine magnitude shift
    fMintercept = 1/fBValueSecond*(fAValueSecond-log10(vFMD(2,nIndexLo)));
    fMshift = fMintercept - vFMD(1,nIndexLo);

    sPer1 = ['Period 1: a = ' num2str(fAValue) ' const. b = ' num2str(fBValue) ' Mc = ' num2str(fMc)];
    sPer2 = ['Period 2: a = ' num2str(fAValueSecond) ' const. b = ' num2str(fBValueSecond)...
            ' Mc = ' num2str(fMcSecond)];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Max. likelihood estimations for a and b using different methods for the
    %% SECOND time period

    % Model 1: Variable a and b-value
    mControlM1 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1];
    [fBValue2M1, fAValue2M1] = calc_MaxLikelihoodABCombined(mSecondCatalog, mControlM1, 0);
    fP_modelM1 = fProbability;
    nDegFreeM1 = 2;
    sMod1 = ['Model 1: a = ' num2str(fAValue2M1) ' b = ' num2str(fBValue2M1)];

    % Model 2: Variable a, const. b-value from max. likelihood estimation of
    % first period
    vSel = (mSecondCatalog(:,6) >= fMcSecond);
    mSecondComp = mSecondCatalog(vSel,:);
    if isempty(mSecondComp)
        disp('oo');
    end
    fBValue2M2 = fBValue;
    mControlM2 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1];
    [fAValue2M2] = calc_MaxLikelihoodA_org(mSecondComp, mControlM2, fBValue2M2, 0);
    % [fAValue2M2] = calc_MaxLikelihoodA(mSecondComp, fBValue2M2)
    fP_modelM2 = fProbability;
    nDegFreeM2 = 1;
    sMod2 = ['Model 2: a = ' num2str(fAValue2M2) ' const. b = ' num2str(fBValue)];

    % Model 3:

    % Model 4: Variable a, const. b-value from max. likelihood estimation of of
    % entire catalog
    vSel = (mSecondCatalog(:,6) >= fMcSecond);
    mSecondComp = mSecondCatalog(vSel,:);
    mControlM4 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1];
    [fAValue2M4] = calc_MaxLikelihoodA_org(mSecondComp, mControlM4, fBValueOrg, 0);
    % [fAValue2M4] = calc_MaxLikelihoodA(mSecondComp, fBValueOrg);
    fBValue2M4 = fBValueOrg;
    fP_modelM4 = fProbability;
    nDegFreeM4 = 1;
    sMod4 = ['Model 4: a = ' num2str(fAValue2M4) ' const. b = ' num2str(fBValueOrg)];

    % Model 5: Variable a, const. b-value from max. likelihood estimation of b
    % from second period
    vSel = (mSecondCatalog(:,6) >= fMcSecond);
    mSecondComp = mSecondCatalog(vSel,:);
    mControlM5 = [min(mSecondCatalog(:,3)) fMcSecond fMcSecond 0.1];
    [fAValue2M5] = calc_MaxLikelihoodA_org(mSecondComp, mControlM5, fBValueSecond, 0);
    % [fAValue2M4] = calc_MaxLikelihoodA(mSecondComp, fBValueOrg);
    fBValue2M5 = fBValueSecond;
    fP_modelM5 = fProbability;
    nDegFreeM5 = 1;
    sMod5 = ['Model 5: a = ' num2str(fAValue2M5) ' const. b = ' num2str(fBValue2M5)];


    % Bayesian Information Criteria (BIC) for model decision
    % Take the one with the highest BIC value
    %n_samples = length(fMcSecond:0.1:ceil(max(mSecondCatalog(:,6))));
    n_samples = length(mSecondCatalog(:,6));
    fBIC_1 = 2*fP_modelM1 + 2*log(n_samples)*nDegFreeM1;
    fBIC_2 = 2*fP_modelM2 + 2*log(n_samples)*nDegFreeM2;
    %     fBIC_3 = 2*fP_modelM3 + 2*log(n_samples)*nDegFreeM3;
    fBIC_4 = 2*fP_modelM4 + 2*log(n_samples)*nDegFreeM4;
    fBIC_5 = 2*fP_modelM5 + 2*log(n_samples)*nDegFreeM5;
    sBIC = ['Model comparison: Model 1 BIC: ' num2str(fBIC_1) ';    Model 2 BIC: ' num2str(fBIC_2) '; '...
            ' Model 4 BIC: ' num2str(fBIC_4) ' Model 5 BIC: ' num2str(fBIC_5)];

    %% Stretch factors from b-value ratios
    fStretchM1 = fBValue/fBValue2M1;
    fStretchM2 = fBValue/fBValue;
    %     fStretchM3 = fBValue/fBValue2M3;
    fStretchM4 = fBValue/fBValueOrg;
    fStretchM5 = fBValue/fBValue2M5;

    %% Result - Matrix
    mRes = [];
    mRes = [mRes; fAValue2M1 fBValue2M1 fBIC_1 fStretchM1; fAValue2M2 fBValue2M2 fBIC_2 fStretchM2];
    mRes = [mRes; fAValue2M4 fBValue2M4 fBIC_4 fStretchM4; fAValue2M5 fBValue2M5 fBIC_5 fStretchM5];

    vSel2 = min(find(mRes(:,3) == min(mRes(:,3))));
    vBestModel = mRes(vSel2,:)

    %% Magnitude Shift and stretch for the best model
    fMshift = vBestModel(:,4)*( vBestModel(:,1)- fAValue)/fBValue;
    fStretch = vBestModel(:,4);
    %%% Rate factor froma-value ratio
    fARate = vBestModel(1,1)/fAValue;

else
    disp('fMc, fMcSecond or vFMD / vFMDSecond not derivable');
    fMshift=NaN;
    fStretch = NaN;
end


%%% Goodness of fit determination using formula from Wiemer & Wyss (BSSA, 2000)
mCatModel = mFirstCatalog;
mCatModel(:,6) = fStretch.*mCatModel(:,6)+fMshift;
[vEv_val2 vMags2 vEventsum2 vEvsum_rev2,  vMags_rev2] =calc_cumulsum(mSecondCatalog);
[vEv_valMod vMagsMod vEventsumMod vEvsum_revMod,  vMags_revMod] =calc_cumulsum(mCatModel);
fMTransFit  = sum(abs(vEventsum2-vEventsumMod))/sum(vEventsum2);
fMTransFit = 100-fMTransFit*100;
