function  [fLikelihoodRatio, fRank_H, fRank_N] = Rtest(vLambdaH, vLambdaN, vObservedQuakes, vSimulatedQuakes)
%
%   [LLR,rank1,rank2] = Rtest(lamda1, lamda2, nquake, nsquake, weight)
%   lamda is a vector or poisson rates, one for each of n cells
%   nquake is a vector whose elements are the observed number of events in each cell
%   nsquake is a matrix of column vectors of simulated numbers of events per cell
%
%   make sure lamda1,lamda2,wieght, and nquake  are a column vectors;
%
% [n,m]=size(lamda1);if  n == 1; lamda1 = lamda1'; end
% [n,m]=size(lamda2);if  n == 1; lamda2 = lamda2'; end
% [n,m]=size(weight);if  n == 1; weight = weight'; end
% [n,m]=size(nquake);if  n == 1; nquake = nquake'; end
%

% Evaluate likelihoods for real catalog
fLikelihood_H = sum(calc_logpoisspdf(vObservedQuakes, vLambdaH));
fLikelihood_N = sum(calc_logpoisspdf(vObservedQuakes, vLambdaN));

% Score of simulation of test hypothesis, relative to observed
fLikelihood_Sim_H = sum(calc_logpoisspdf(vSimulatedQuakes, vLambdaH)) - fLikelihood_H;
fRank_H = sum(fLikelihood_Sim_H < 0);

% Score of simulation of test hypothesis, relative to observed
fLikelihood_Sim_N = sum(calc_logpoisspdf(vSimulatedQuakes, vLambdaN)) - fLikelihood_N;
fRank_N = sum(fLikelihood_Sim_N < 0);

% Compute the overall result (test hypothesis over null hypothesis)
fLikelihoodRatio = (fLikelihood_Sim_H - fLikelihood_Sim_N);
