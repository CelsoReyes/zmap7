function [result]=sv_NodeCalc(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC, vCluster, bDecluster, fMcOrg, fBValueOrg, bSeisModel)
% function [result]=sv_NodeCalc(mCatalog, fSplitTime, bTimeperiod, fTimePeriod, nCalculateMC, vCluster, bDecluster, fMcOrg, fBValueOrg, bSeisModel)
% -------------------------------------------------------------------------------------------------------------------------------------------------
% Function to calculate absolute difference of number of events between
% to time periods of an earthquake catalog normalized to a year
% Incoming variables:
% mCatalog     : current earthquake catalog
% fSplitTime   : Splitting time
% bTimePeriod  : Use specific time period to compare (1) or from beginning till end of catalog (0)
% fTimePeriod  : Time period in days to be compared before and after fSplitTime
% nCalculateMC : Number for Method of Mc determination
% vCluster     : Vector of cluster numbers
% bDecluster   : Decluster catalog or not
% fMcOrg       : Mc of entire catalog
% fBValueOrg   : b-value of entire catalog
% bSeisModel   : Method to model seismicity varation: 0 - b-value fittng, 1 - grid search
%
% Outgoing variable:
% result.dNdiffsum      : total difference of number of events in the two time periods
% result.fMc            : magnitude of completeness for entire catalog
% result.fMcFirstPeriod : magnitude of completeness for first period defined
% result.fMcSecondPeriod : magnitude of completeness for second period defined
% result.fdMc            : Difference in Mc: Mc(Per1)-Mc(Per2)
% result.fMshift         : Simple magnitude shift
% result.fMshiftFit      : Goodness of fit in percent to modeling second period with simple magnitude shift of first period
% result.fMshiftSig      : Simple magnitude shift at 99% significance level of z-statistic
% result.fFactorHi       : Mean rate factor for EQ >= Mc(Per1) between two periods
% result.fPerHi          : Percental seismicity change
% result.fFactorLow      : Mean rate factor for EQ < Mc(Per1) between two periods
% result.fPerLow         : Percental seismicity change
% result.fMRateFit       : Goodness of fit by modeling second period with rate factor multiplication of first period
% result.fMshiftCom      : Magnitude shift combined with stretch
% result.fStretch        : Magnitude stretch
% result.fMTransFit      : Goodness of fit by modeling second period manipulating the first period
% result.fdMag           : Magnitude shift for a M=1 EQ using result.fMshiftCom and result.fStretch
% result.mModelCat       : Magnitude alternation for a magnitude M=1 EQ
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 01.11.02
% Changes:
% 19.08.02: Replaced  fcumulsum.m with calc_cumulsum.m
% 08.10.02: Deleted return at the end.


% Changes:
% 19.08.02: Replaced  fcumulsum.m with calc_cumulsum.m
% 08.10.02: Deleted return at the end.

% Init variable
result=[];
fTimePeriod =fTimePeriod/365;

if bDecluster == 1
    % Determine degree of Poissonian distribution using Chi^2-Test
    [result.fChi2 result.fChi2_sig90 result.fChi2_sig95 result.Chi2_sig99 result.nPoissDeg]= calc_Chi2(mCatalog);
    vSel = (vCluster(:,1) > 0);
    mCatalogDecl = mCatalog(~vSel,:);
    [result.fChi2_Dec result.fChi2_sig90_Dec result.fChi2_sig95_Dec result.Chi2_sig99_Dec...
            result.nPoissDeg_Dec]= calc_Chi2(mCatalogDecl);
    % Determine degree of Clustering
    [result.fClusterDeg] = calc_ClusterDeg(mCatalog, vCluster);
elseif (bSeisModel == 1)
    % Create the catalogs for the two time peiods
    [result.mFirstCatalog, result.mSecondCatalog, result.fFirstPeriodExact, result.fSecondPeriodExact, result.fFirstPeriod,...
            result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, bTimePeriod, fTimePeriod);

    %% Determination of difference between two time periods normalized to year
    [dEv_val dMags dEv_valsum dEv_valsum_rev,  dMags_rev] = calc_cumulsum(result.mFirstCatalog);
    [dEv_val2 dMags2 dEv_valsum2 dEv_valsum_rev2,  dMags_rev2] = calc_cumulsum(result.mSecondCatalog);
    result.dNdiff = max(dEv_val2)/result.fSecondPeriodExact-max(dEv_val)/result.fFirstPeriodExact; % Normalization
    result.dNdiffsum = cumsum(result.dNdiff');
    %result.dNdiffsumVal = result.dNdiffsum(length(result.dNdiffsum));

    % Determine Mc for entire catalog, two time periods and difference in Mc
    result.fMc = calc_Mc(mCatalog, nCalculateMC);
    if isempty(result.fMc)
        result.fMc = NaN;
    end
    result.fMcFirstPeriod = calc_Mc(result.mFirstCatalog, nCalculateMC);
    if isempty(result.fMcFirstPeriod)
        result.fMcFirstPeriod = NaN;
    end
    result.fMcSecondPeriod = calc_Mc(result.mSecondCatalog, nCalculateMC);
    if isempty(result.fMcSecondPeriod)
        result.fMcSecondPeriod = NaN;
    end
    result.fdMc = result.fMcSecondPeriod - result.fMcFirstPeriod;

    % Determine simple magnitude shift and Goodness of Fit
    [result.fMshift result.fMshiftFit] = calc_Magshift(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, nCalculateMC);
    if isempty(result.fMshift)
        result.fMshift = NaN;
        result.fMshiftFit = NaN;
    end
    % Determine significant Mshift at 99% level
    [mLMagsig mHMagsig fLZmax fLZmean fLZmin fHZmax fHZmean,  fHZmin] =...
        calc_Magsig(result.mFirstCatalog, result.mSecondCatalog , result.fFirstPeriodExact, result.fSecondPeriodExact, 0.1);
    if ((fLZmax >= 2.57 & fHZmin <= -2.57) | fLZmin <= -2.57 & fHZmax >= 2.57)
        result.fMshiftSig = result.fMshift;
    else
        result.fMshiftSig = NaN;
    end
    % Determine rate factors and percentage change of EQ for M<Mc and M>=Mc
    [result.fFactorHi fStdHi fResHi result.fPerHi result.fFactorLow fStdLow fResLow result.fPerLow result.fMRateFit]...
        = calc_ratefac(result.mFirstCatalog, result.mSecondCatalog, fTimePeriod, fTimePeriod,...
        result.fMcFirstPeriod, result.fMcSecondPeriod);
    [result.fMshiftCom result.fStretch result.fMTransFit result.fARate] = calc_Shiftstretch(mCatalog, fSplitTime, bTimePeriod,...
        fTimePeriod, nCalculateMC, fMcOrg, fBValueOrg);
    %% Magnitude fit for a magnitude M=1 EQ
    result.fdMag = 1+((result.fStretch-1)+result.fMshiftCom); % Theoretical map
    result.mModelCat = result.mFirstCatalog;
    result.mModelCat(:,6) = result.fStretch.*result.mModelCat(:,6)+result.fMshiftCom;
else
    % Create the catalogs for the two time peiods
    [result.mFirstCatalog, result.mSecondCatalog, result.fFirstPeriodExact, result.fSecondPeriodExact, result.fFirstPeriod,...
            result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, bTimePeriod, fTimePeriod, bTimePeriod, fTimePeriod);

    %% Determination of difference between two time periods normalized to year
    [dEv_val dMags dEv_valsum dEv_valsum_rev,  dMags_rev] = calc_cumulsum(result.mFirstCatalog);
    [dEv_val2 dMags2 dEv_valsum2 dEv_valsum_rev2,  dMags_rev2] = calc_cumulsum(result.mSecondCatalog);
%     result.dNdiff = max(dEv_val2)/result.fSecondPeriodExact-max(dEv_val)/result.fFirstPeriodExact; % Normalization
    result.dNdiff = max(dEv_valsum2)/result.fSecondPeriodExact-max(dEv_valsum)/result.fFirstPeriodExact;
    result.dNdiffsum = max(cumsum(result.dNdiff'));
    %result.dNdiffsumVal = result.dNdiffsum(length(result.dNdiffsum));
    if isempty(result.dNdiff)
        result.dNdiff = NaN;
    end
    if isempty(result.dNdiffsum)
        result.dNdiffsum = NaN;
    end
    % Determine Mc for entire catalog, two time periods and difference in Mc
    result.fMc = calc_Mc(mCatalog, nCalculateMC);
    if isempty(result.fMc)
        result.fMc = NaN;
    end
    result.fMcFirstPeriod = calc_Mc(result.mFirstCatalog, nCalculateMC);
    if isempty(result.fMcFirstPeriod)
        result.fMcFirstPeriod = NaN;
    end
    result.fMcSecondPeriod = calc_Mc(result.mSecondCatalog, nCalculateMC);
    if isempty(result.fMcSecondPeriod)
        result.fMcSecondPeriod = NaN;
    end
    result.fdMc = result.fMcSecondPeriod - result.fMcFirstPeriod;

    % Mc determination by grid search
    %[result.fProbMcGrid result.fMcGrid] = calc_McGridN(mCatalog,0.1);
    [result.fProbMcGrid result.fMcGrid] = calc_McCdf2(mCatalog,0.1)
    if (isempty(result.fProbMcGrid) | isempty(result.fMcGrid))
        result.fProbMcGrid = NaN;
        result.fMcGrid = NaN;
    end
    %% Use data only above completeness
    %fMinMc = min([result.fMcFirstPeriod result.fMcSecondPeriod]);
    %     vSel1 = (result.mFirstCatalog(:,6) >= result.fMcFirstPeriod);
    %     vSel2 = (result.mSecondCatalog(:,6) >= result.fMcFirstPeriod);
    %     result.mFirstCatalog = result.mFirstCatalog(vSel1,:);
    %     result.mSecondCatalog = result.mSecondCatalog(vSel2,:);

    %% Seismicity variation modelling
    %!!!!! NO MODELS WITH STRETCH ALLOWED !!!!!!!!!!!!!!!!!!!!!!!!!
    %%% Maximum likelihood scores and BICs
    [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange2(result.mFirstCatalog, result.mSecondCatalog);
    [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM2(result.mFirstCatalog, result.mSecondCatalog);
    %[fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch(result.mFirstCatalog, result.mSecondCatalog);
    [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(result.mFirstCatalog, result.mSecondCatalog);
    [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(result.mFirstCatalog, result.mSecondCatalog);
    %[fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_loglikelihood_stretch_rate(result.mFirstCatalog, result.mSecondCatalog);
    %[fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans(result.mFirstCatalog, result.mSecondCatalog);
    %[fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_loglikelihood_dMdSrate(result.mFirstCatalog, result.mSecondCatalog);


    %vBic = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate; fBic_Trans; fBic_dSrate; fBic_all];
    vBic = [fBic_nochange; fBic_dM;  fBic_Rate; fBic_dMrate];
    [result.nType] = find(vBic == min(vBic));
    %% Initialize result
    result.fdM = nan; % Shift
    result.fdS = nan; % Stretch
    result.fRf = nan; % rate factor
    if length(result.nType) > 1
        vBic;
        result.nModelChoice = NaN;
    elseif length(result.nType) == 0
        result.nModelChoice = nan;
    else
        switch result.nType
        case 1
            result.nModelChoice = 1;
            %     result.fdM = 0; % Shift
            %     result.fdS = 1; % Stretch
            %     result.fRf = 1; % rate factor
        case 2
            result.nModelChoice = 2;
            result.fdM = fdM;
%         case 3
%             result.nModelChoice = 3;
%             result.fdS = fS;
        case 3
            result.nModelChoice = 3;
            result.fRf = fFac;
        case 4
            result.nModelChoice = 4;
            result.fdM = fdM_rate;
            result.fRf = fdM_Fac;
%         case 6
%             result.nModelChoice = 6;
%             result.fdM = fdM_st;
%             result.fdS = fStretch;
%         case 7
%             result.nModelChoice = 7;
%             result.fdS = fdS_rate;
%             result.fRf = fdS_Fac;
%         case 8
%             result.nModelChoice = 8;
%             result.fdM = fdM_all;
%             result.fdS = fdS_all;
%             result.fRf = fFac_all;
        otherwise
            disp('Something is equal');
        end; % END of Switch result.Type
    end;% END of IF result.Type
end; % END of IF bSeismodel
end % End of IF bDecluster
