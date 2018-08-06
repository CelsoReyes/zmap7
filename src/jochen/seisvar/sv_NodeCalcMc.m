function [result]=sv_NodeCalcMc(params,mCatalog)
% SV_NODECALCMC calculate Mc using several different methods
%
% [result]=sv_NodeCalcMc(params, mCatalog)
%
% Incoming variables:
% mCatalog     : current earthquake catalog
% params       : See sv_calcMc for parameters
%
% Outgoing variable:
% result.fMc_max    : magnitude of completeness using maximum cuvature approach
% result.fMc_90     : magnitude of completeness using GR-law fit at 90% goodness fit level
% result.fMc_95     : magnitude of completeness using GR-law fit at 95% goodness fit level
% result.fMc_com    : magnitude of completeness using GR-law fit at 90% goodness fit level,
%                     GR-law fit at 95% goodness fit level, and maximum cuvature approach
% result.fMc_EMR    : Mc using normal CDF and GR-law
% result.fMc_shi    : Mc by b-value uncertainty Shi & Bolt
% result.fMc_Bst     : Mean Mc from bootstrapping (Method depends on params.fBstMethod)
% result.fStd_Mc     : 2nd moment of Mc distribution
% result.fBvalue_Bst : Mean b-value from bootstrapping (Method depends on params.fBstMethod)
% result.fStd_B      : 2nd moment of b-value distribution
% result.fAvalue_Bst : Meana-value from bootstrapping (Method depends on params.fBstMethod)
% result.fStd_A      : 2nd moment of a-value distribution
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% updated: 10.06.03

% Init variable
result=[];

% Determine Mc by maximum curvature
result.fMc_max = calc_Mc(mCatalog, McMethods.FixedMc);
if isempty(result.fMc_max)
    result.fMc_max = NaN;
end

% Determine Mc by goodness of fit 90%
result.fMc_90 = calc_Mc(mCatalog, McMethods.Mc90);
if isempty(result.fMc_90)
    result.fMc_90 = NaN;
end

% Determine Mc by goodness of fit 95%
result.fMc_95 = calc_Mc(mCatalog, McMethods.Mc95);
if isempty(result.fMc_95)
    result.fMc_95 = NaN;
end

% Determine Mc by best combination
result.fMc_com = calc_Mc(mCatalog, McMethods.McBestCombo);
if isempty(result.fMc_com)
    result.fMc_com = NaN;
end

% Determine Mc by EMR-method
[~, ~, result.fMc_EMR, ~, ~, ~, ~, ~,...
        ~, result.bH, result.fPval, ~] = calc_McEMR_kstest(mCatalog.Magnitude,max(mCatalog.Date) - min(mCatalog.Date), params.fBinning);
%[result.fMc_EMR, fBvalue, fAvalue, fMu, fSigma] = calc_McEMR(mCatalog, params.fBinning);
if isempty(result.fMc_EMR)
    result.fMc_EMR = NaN;
end

% Determine Mc by b-value uncertainty Shi & Bolt
nWindowSize = 5;
[fMc_shi, ~, ~, ~] = calc_Mcdueb(mCatalog.Magnitude, params.fBinning, nWindowSize, params.nMinimumNumber);
result.fMc_shi = fMc_shi;
if isempty(result.fMc_shi)
    result.fMc_shi = NaN;
end

% Case of calculations with bootstrapping
if params.bBstnum
    % Mc bootstrap and uncertainty
    % EMR method
    % nCalculateMC=params.fBstMethod;
 %   [result.fMc_Bst, result.fStd_Mc, result.fBvalue_Bst, result.fStd_B, result.fAvalue_Bst, result.fStd_A, vMc, mBvalue] = calc_McBboot(mCatalog, params.fBinning, params.fBstnum, nCalculateMC);
    [~, result.fMc_Bst, result.fStd_Mc, ~, ~, result.fBvalue_Bst, result.fStd_B, result.fAvalue_Bst, result.fStd_A,...
            result.bH_Bst, result.fPval_Bst, ~,~] = calc_McEMR_KSboot(mCatalog, params.fBinning, params.fBstnum,params.fBstMethod);
end
