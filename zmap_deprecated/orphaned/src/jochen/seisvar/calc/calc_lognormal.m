function F = calc_lognormal(vX, vXdata)
% function F = calc_lognormal(vX, vXdata);
% ----------------------------------------
% Compute lognormal CDF for diverse parameters; use as function in lsqcurvefit (or equivalent) to find
% best fitting parameters
%
% Distribution parameters:
% vX(1) : mu
% vX(2) : sigma
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 18.11.02

F = logncdf(vXdata,vX(1),vX(2));
