function F = calc_normalCDF(vX, vXdata)
% function F = calc_normalCDF(vX, vXdata);
% ----------------------------------------
% Compute CDF of normal probability distribution for diverse parameters; use as function in lsqcurvefit (or equivalent) to find
% best fitting parameters
%
% Distribution parameters:
% vX(1) : mu
% vX(2) : sigma
%
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% updated: 11.06.04

F = normcdf(vXdata,vX(1),vX(2));
% Check F on NAN
if isnan(F(1))
    F = zeros(length(F),1);
    warning('Probabilities set to zero')
end
