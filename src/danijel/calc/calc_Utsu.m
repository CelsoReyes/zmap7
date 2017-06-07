function [dA, fProbEqual, fProbDifferent] = calc_Utsu(fB1, fB2, nN1, nN2)
% function [dA, fProbEqual, fProbDifferent] = calc_Utsu(fB1, fB2, nN1, nN2)
% -------------------------------------------------------------------------
% Computes the Utsu test (probabilities) for two b-value populations
%
% Input parameters:
%   fB1             b-value of first population
%   fB2             b-value of second population
%   nN1             samplesize of first population
%   nN2             samplesize of second population
%
% Output parameters:
%   dA              Difference of AIC
%   fProbEqual      Probability of stationarity (favoring stationarity)
%   fProbDifferent  Probability of stationarity (favoring non-stationarity)
%
% Danijel Schorlemmer
% November 27, 2003

% Helper
nN = nN1 + nN2;
% Difference in AIC
dA = -2*nN*log(nN) + 2*nN1*log(nN1+(nN2*fB1/fB2)) + 2*nN2*log(nN2+(nN1*fB2/fB1)) - 2;
% Probabilities
fProbDifferent = exp(-dA/2 - 2);
fProbEqual = exp(-dA/2 - 1);
