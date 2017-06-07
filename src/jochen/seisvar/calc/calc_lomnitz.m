function F = calc_lomnitz(vX, vXdata)
% function F = calc_lomnitz(vX, vXdata);
% --------------------------------------
% Compute Lomnitz-Adler equation, an improved version of the Gutenberg-Richter
% formula for maximum magnitudes
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 15.11.02

F = vX(1)-vX(2)*vXdata-vX(3)*10.^(vX(2)*vXdata);
