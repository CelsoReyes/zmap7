function [result]=sv_NodeCalcSchuster(params,mCatalog)
% function [result]=sv_NodeCalcSchuster(params,mCatalog)
% ----------------------------------------------------
% Function to calculate Schuster's test and fast Mc (not EMR method)
% estimates; calculates also uncertainties for Schuster's test
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
% result.fMcSch      : magnitude of completeness using Schusters method
% result.flogProbSch : log10(Probability) to obtain vector of length >= R from a random walkout
% result.v1Sigma     : 1Sigma (16 and 84 percentiles) for probability to obtain vector of length >= R
%                      from a random walkout from bootstrapping the catalog times
% result.flogv1Sigma : 1Sigma (16 and 84 percentiles) for log10(probability) to obtain vector of length >= R
%                      from a random walkout from bootstrapping the catalog times
% result.v1Srange    : 1Sigma range (84-16 percentile)
% result.flogv1Srange: 1Sigma log10 range (84-16 percentile)
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 17.04.03

% Init variable
result=[];

% Determine Mc by maximum curvature
nCalculateMC = 1;
result.fMc_max = calc_Mc(mCatalog, nCalculateMC);
if isempty(result.fMc_max)
    result.fMc_max = NaN;
end

% Determine Mc by goodness of fit 90%
nCalculateMC = 3;
result.fMc_90 = calc_Mc(mCatalog, nCalculateMC);
if isempty(result.fMc_90)
    result.fMc_90 = NaN;
end

% Determine Mc by goodness of fit 95%
nCalculateMC = 4;
result.fMc_95 = calc_Mc(mCatalog, nCalculateMC);
if isempty(result.fMc_95)
    result.fMc_95 = NaN;
end

% Determine Mc by best combination
nCalculateMC = 5;
result.fMc_com = calc_Mc(mCatalog, nCalculateMC);
if isempty(result.fMc_com)
    result.fMc_com = NaN;
end


% % Mc determination by modelling entire magnitude range using a NORMAL CDF
% [mResult result.fProbMcNorm result.fMcNorm fMu fSigma mDatPredBest vPredBest result.fBvalue] = calc_McCdfnormal(mCatalog, params.fBinning);
%
% if (isempty(result.fProbMcNorm) | isempty(result.fMcNorm))
%     result.fProbMcNorm = NaN;
%     result.fMcNorm = NaN;
% end
% if (isempty(result.fBvalue))
%     result.fBvalue = NaN;
% end

% Mc determination by Schuster
[mResult fMcSch,  fProbability] =  calc_SchusterMc(mCatalog,0.3);
[mWalkout fR95 fProbSch PHI,  R] = calc_Schusterwalk(mCatalog);
try
    result.fMcSch = fMcSch;
    result.flogProbSch = log10(fProbSch);
catch
    result.fMcSch = NaN;
    result.flogProbSch = NaN;
end

% Determine uncertainty of Schuster test
[vPerc v1Sigma,  fStdProb] = calc_BstSchuster(mCatalog,params.fBinning,params.fBstnum);
try
    result.v1Sigma = v1Sigma;
    result.flogv1Sigma = log10(v1Sigma);
    result.v1Srange = (v1Sigma(1,2) - v1Sigma(1,1));
    result.flogv1Srange = log10(result.v1Srange);
catch
    result.fv1Sigma= NaN;
    result.flogv1Sigma = [NaN NaN];
    result.v1Srange = NaN;
    result.flogv1Srange = NaN;
end
