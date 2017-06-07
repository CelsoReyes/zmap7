function [rResult] = relm_RTest(vRatesH, vRatesN, nNumberSimulation, fMagThreshold, bDrawFigure)
% function [rResult] = relm_RTest(vRatesH, vRatesN, nNumberSimulation, fMagThreshold, bDrawFigure)
% ------------------------------------------------------------------------------------------------
% Computation of the R-test for the RELM framework
%
% Input parameters:
%   vRatesH                       Matrix with rates of the test hypothesis
%   vRatesN                       Matrix with rates of the null hypothesis
%   nNumberSimulation             Number of random simulations
%   fMagThreshold                 Magnitude threshold (Use only bins with magnitude >= threshold
%   bDrawFigure                   Draw the cumulative density plot after testing (default: off)
%
% Output paramters:
%   rRelmTest.fAlpha              Alpha-value of the cumulative density
%   rRelmTest.fBeta               Beta-value of the cumulative density
%   rRelmTest.vSimValues_H        Vector containing the sorted simulated numbers of events for the test hypothesis
%   rRelmTest.vSimValues_N        Vector containing the sorted simulated numbers of events for the null hypothesis
%   rRelmTest.nNumberSimulation   Number of random simulations
%   rRelmTest.fObservedData       Observed total number of events
%   rRelmTest.fRank_11            Number of log-likelihoods < 0 of simulations based on test hypothesis according to test hypothesis
%   rRelmTest.fRank_12            Number of log-likelihoods < 0 of simulations based on test hypothesis according to null hypothesis
%   rRelmTest.fRank_21            Number of log-likelihoods < 0 of simulations based on null hypothesis according to test hypothesis
%   rRelmTest.fRank_22            Number of log-likelihoods < 0 of simulations based on null hypothesis according to null hypothesis
%
% Danijel Schorlemmer & Dave D. Jackson
% October 8, 2002

% Exit on empty rate matrices
if isempty(vRatesH)  ||  isempty(vRatesN)
  rRelmTest.fAlpha = nan;
  rRelmTest.fBeta = nan;
  rRelmTest.vSimValues_H = nan;
  rRelmTest.vSimValues_N = nan;
  rRelmTest.nNumberSimulation = nan;
  rRelmTest.fObservedData = nan;
  rRelmTest.fRank_11 = nan;
  rRelmTest.fRank_12 = nan;
  rRelmTest.fRank_21 = nan;
  rRelmTest.fRank_22 = nan;
  return;
end

if ~exist('bDrawFigure')
  bDrawFigure = 0;
end

% Get the necessary data from the rate matrices and weight them properly
[vLambdaH, vLambdaN, vObservedQuakes] = relm_PrepareData(vRatesH, vRatesN, fMagThreshold);
nNumberQuake = sum(vObservedQuakes);

% Simulate catalogs according to test hypothesis and evaluate likelihood scores
% of simulations and real catalog using given rates of the two hypotheses
try
  % Init
  rResult.vSimValues_H = [];
  rResult.fRank_11 = 0;
  rResult.fRank_12 = 0;
  % Evaluate likelihoods for real catalog
  fLikelihood_H = sum(calc_logpoisspdf(vObservedQuakes, vLambdaH));
  fLikelihood_N = sum(calc_logpoisspdf(vObservedQuakes, vLambdaN));
  % Loop over the simulations
  for nCnt = 1:nNumberSimulation
    % Create simulated events
    vSimulatedQuakes = relm_CreateSimulationCatalog(nNumberQuake, vLambdaH);
    % Score of simulation of test hypothesis, relative to observed
    fLikelihood_Sim_H = sum(calc_logpoisspdf(vSimulatedQuakes, vLambdaH)) - fLikelihood_H;
    rResult.fRank_11 = rResult.fRank_11 + (fLikelihood_Sim_H < 0);
    % Score of simulation of test hypothesis, relative to observed
    fLikelihood_Sim_N = sum(calc_logpoisspdf(vSimulatedQuakes, vLambdaN)) - fLikelihood_N;
    rResult.fRank_12 = rResult.fRank_12 + (fLikelihood_Sim_N < 0);
    % Compute the overall result (test hypothesis over null hypothesis)
    fLikelihoodRatio = (fLikelihood_Sim_H - fLikelihood_Sim_N);
    % Store the simulation result
    rResult.vSimValues_H = [rResult.vSimValues_H; fLikelihoodRatio];
  end
  rResult.vSimValues_H = sort(rResult.vSimValues_H);
catch
  rResult.vSimValues_H = nan;
  rResult.fRank_11 = nan;
  rResult.fRank_12 = nan;
end

% Simulate catalogs according to null hypothesis and evaluate likelihood scores
% of simulations and real catalog using given rates of the two hypotheses
try
  % Init
  rResult.vSimValues_N = [];
  rResult.fRank_21 = 0;
  rResult.fRank_22 = 0;
  % Evaluate likelihoods for real catalog
  fLikelihood_H = sum(calc_logpoisspdf(vObservedQuakes, vLambdaH));
  fLikelihood_N = sum(calc_logpoisspdf(vObservedQuakes, vLambdaN));
  % Loop over the simulations
  for nCnt =1:nNumberSimulation
    % Create simulated events
    vSimulatedQuakes = relm_CreateSimulationCatalog(nNumberQuake, vLambdaN);
    % Score of simulation of test hypothesis, relative to observed
    fLikelihood_Sim_H = sum(calc_logpoisspdf(vSimulatedQuakes, vLambdaH)) - fLikelihood_H;
    rResult.fRank_21 = rResult.fRank_21 + (fLikelihood_Sim_H < 0);
    % Score of simulation of test hypothesis, relative to observed
    fLikelihood_Sim_N = sum(calc_logpoisspdf(vSimulatedQuakes, vLambdaN)) - fLikelihood_N;
    rResult.fRank_22 = rResult.fRank_22 + (fLikelihood_Sim_N < 0);
    % Compute the overall result (test hypothesis over null hypothesis)
    fLikelihoodRatio = (fLikelihood_Sim_H - fLikelihood_Sim_N);
    % Store the simulation result
    rResult.vSimValues_N = [rResult.vSimValues_N; fLikelihoodRatio];
  end
  rResult.vSimValues_N = sort(rResult.vSimValues_N);
catch
  rResult.vSimValues_N = nan;
  rResult.fRank_21 = nan;
  rResult.fRank_22 = nan;
end

% Evalute the alpha- and beta-value and store necessary values in result-structure
rResult.fAlpha = sum(rResult.vSimValues_N > 0)/nNumberSimulation;
rResult.fBeta = sum(rResult.vSimValues_H < 0)/nNumberSimulation;
rResult.nNumberSimulation = nNumberSimulation;
rResult.fObservedData = 0;

% Plot the figure
if bDrawFigure
  relm_PaintCumPlot(rResult, 'LLR');
end


