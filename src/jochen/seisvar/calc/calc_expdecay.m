function F = calc_expdecay(vX, vXdata)
%
% Compute exponential decay
F = vX(1).*exp(-vX(2).*vXdata);
