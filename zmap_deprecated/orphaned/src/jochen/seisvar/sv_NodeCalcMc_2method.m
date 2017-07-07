function [result]=sv_NodeCalcMc_2methods(params,mCatalog)
% function [result]=sv_NodeCalcMc_2methods(params,mCatalog)
% ----------------------------------------------------
% Function to calculate Mc using different methods
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% params       : See sv_calcMc for parameters
%
% Outgoing variable:
% result.fMc_max     : magnitude of completeness using maximum cuvature approach
% result.fBValue_max : b-value for MAXC-method
% result.fStdDev_max : max. likeklihood stadard deviation
% result.fAValue_max :a-value for MAXC-method
% result.fMc_EMR     : Mc using normal CDF and GR-law
% result.fBvalue_EMR : b-value for EMR-method
% result.fAvalue_EMR :a-value
% result.bH_EMR      : KS-Test value for EMR-method
% result.fMc_Bst     : Mean Mc from bootstrapping (Method depends on params.fBstMethod)
% result.fStd_Mc     : 2nd moment of Mc distribution
% result.fBvalue_Bst : Mean b-value from bootstrapping (Method depends on params.fBstMethod)
% result.fStd_B      : 2nd moment of b-value distribution
% result.fAvalue_Bst : Meana-value from bootstrapping (Method depends on params.fBstMethod)
% result.fStd_A      : 2nd moment ofa-value distribution
%
% Author: J. Woessner
% jowoe@gps.caltech.edu
% last update: 24.02.2006

% Init variable
result=[];

% Determine Mc by maximum curvature
nCalculateMC = 1;
result.fMc_max = calc_Mc(mCatalog, nCalculateMC, params.fMcCorr);
if isempty(result.fMc_max)
    result.fMc_max = NaN;
    result.fBValue_max = NaN;
    result.fStdDev_max = NaN;
    result.fAValue_max = NaN;
else
    % Calculate b-value for max. curv.
    vSel = (mCatalog(:,6) >= result.fMc_max);
    if length(mCatalog(vSel,6) >= params.nMinimumNumber)
       [fMeanMag, result.fBValue_max, result.fStdDev_max, result.fAValue_max] =  calc_bmemag(mCatalog(vSel,:), params.fBinning);
    else
        result.fBValue_max = NaN;
        result.fStdDev_max = NaN;
        result.fAValue_max = NaN;
    end
end

% Determine Mc by EMR-method
[mResult, fMls, result.fMc_EMR, fMu, fSigma, mDatPredBest, vPredBest, result.fBvalue_EMR,...
        result.fAvalue_EMR, result.bH_EMR, result.fPval, fKsstat] = calc_McEMR_kstest(mCatalog, params.fBinning);
%[result.fMc_EMR, fBvalue, fAvalue, fMu, fSigma] = calc_McEMR(mCatalog, params.fBinning);
if isempty(result.fMc_EMR)
    result.fMc_EMR = NaN;
    result.fBvalue_EMR = NAN;
    result.fAvalue_EMR = NAN;
    result.bH_EMR = nan;
end

% Case of calculations with bootstrapping
if (params.bBstnum == 1)
    % Mc bootstrap and uncertainty
    if (params.fBstMethod == 6) % EMR method
        [fMls, result.fMc_Bst, result.fStd_Mc, fMu, fSigma, result.fBvalue_Bst, result.fStd_B, result.fAvalue_Bst, result.fStd_A,...
            result.bH_Bst, result.fPval_Bst, fKsstat,mResult] = calc_McEMR_KSboot(mCatalog, params.fBinning, params.fBstnum,params.fBstMethod);
    else %other methods
        [result.fMc_Bst, result.fStd_Mc, result.fBvalue_Bst, result.fStd_B, result.fAvalue_Bst, result.fStd_A, vMc, mBvalue] = calc_McBboot(mCatalog, params.fBinning, params.fBstnum, params.fBstMethod);
        result.bH_Bst = nan;
        result.fPval_Bst = nan;
    end
end
