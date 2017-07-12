function [fAValue] = calc_AValueFixedB(mCatalog, fBValue)
% function [fAValue] = calc_AValueFixedB(mCatalog, fBValue)
% ---------------------------------------------------------
% Calculates the maximum likelihooda-value for a given
%   catalog and given b-value. The Catalog has to be complete
%   down to the smalles magnitude: Mc=Mmin
%
% Input parameters:
%   mCatalog    earthquake catalog (complete down to minimum magnitude)
%   fBValue     Predetermined b-value
%
% Output parameters:
%   fAValue     Maximum likelihooda-value
%
% Danijel Schorlemmer
% July 1, 2002

% Find minimum of negative log-likelihoods using helper function
[fAValue, vDummy, bExitFlag_] = fminbnd('calc_LogLikelihoodAValue', 0.01, 10, [], mCatalog, fBValue);

% If search doesn't converge, extrapolatea-value from magnitude of completeness
if bExitFlag_ ~= 1
  fMinMag_ = min(mCatalog.Magnitude);
  fAValue = log10(mCatalog.Count) + (fBValue * fMinMag_);
end
