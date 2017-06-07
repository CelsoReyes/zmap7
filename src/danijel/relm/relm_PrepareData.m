function [vLambdaH, vLambdaN, vNumberQuake] = relm_PrepareData(vRatesH, vRatesN, fMagThreshold)
% function [vLambdaH, vLambdaN, vNumberQuake] = relm_PrepareData(vRatesH, vRatesN, fMagThreshold)
% -----------------------------------------------------------------------------------------------
% Data preparation for the different tests for the RELM framework
%
% Input parameters:
%   vRatesH         Matrix with rates of the test hypothesis
%   vRatesN         Matrix with rates of the null hypothesis
%   fMagThreshold   Magnitude threshold (Use only bins with magnitude >= threshold
%
% Output paramters:
%   vLambdaH        Vector containing expected rates for the test hypothesis
%   vLambdaN        Vector containing expected rates for the null hypothesis
%   vNumberQuake    Vector containing the observed numbers of events
%
% Copyright (C) 2002-2006 by Danijel Schorlemmer & David D. Jackson
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the
% Free Software Foundation, Inc.,
% 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

% Get the lower magnitude-limits per bin
vMagMin = vRatesH(:,7);
% Get the weightings per bins
vWeightH = vRatesH(:,10);
vWeightN = vRatesN(:,10);
% Compute the combined weighting
vWeightCombined = vWeightH .* vWeightN .* (vMagMin >= fMagThreshold);

% Select the rows to be used
vSel = (vWeightCombined > 0);
vRatesH = vRatesH(vSel,:);
vRatesN = vRatesN(vSel,:);

% Get the necessary data from the rate matrices and weight them properly
vWeight = vWeightCombined(vSel);
vNumberQuake = vWeight .* vRatesH(:,11);
vLambdaH = vWeight .* vRatesH(:,9);
vLambdaN = vWeight .* vRatesN(:,9);

