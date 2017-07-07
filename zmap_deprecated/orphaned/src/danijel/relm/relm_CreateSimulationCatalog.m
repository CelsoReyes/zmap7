function [vSimulatedQuakes] = relm_CreateSimulationCatalog(nTotalNumberQuakes, vLambda)
% function [vSimulatedQuakes] = relm_CreateSimulationCatalog(nTotalNumberQuakes, vLambda)
% ---------------------------------------------------------------------------------------
% Creates artificial set of earthquakes per space/magnitude bin based on the given total
%   number of events and the probabilities for each bin, assuming poissonian occurence.
%
% Input parameters:
%   nTotalNumberQuakes    Total number of earthquakes to be distributed over the space/magnitude
%                         bins according to the given probabilites
%   vLambda               Vector of expected numbers of earthquakes per space/magnitude bin
%
% Output parameters:
%   vSimulatedQuakes      Vector of simulated earthquakes per space/magnitude bin
%
% Danijel Schorlemmer & Dave D. Jackson
% October 10, 2002

% Get the number of space/magnitude bins
nNumberBins = length(vLambda);
% Create random numbers for the simulation
mRandom = rand(nTotalNumberQuakes, 1);
% Create the normalized cumulative lambda vector
vNCLambda = cumsum(vLambda)/sum(vLambda);
% Create a vector with lambda-bin limits
vLambdaEdges = [0, vNCLambda'];
% Create the simulated events per space/magnitude bin
vSimulatedQuakes = histc(mRandom, vLambdaEdges, 1);
% Strips off last row of zeros put in by histc
vSimulatedQuakes = vSimulatedQuakes(1:nNumberBins,:);
