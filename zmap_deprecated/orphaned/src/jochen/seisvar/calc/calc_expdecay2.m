function F = calc_expdecay2(vX, vXdata)
%
% Compute exponential decay combined with x^2 function
%F = vX(1)*exp(-vX(2)*vXdata)+vX(3)*exp(vX(4)*vXdata)
% F = vX(1)+vX(2).*vXdata+vX(3).*(vXdata).^2;
F = vX(1).*exp(vX(2).*vXdata);
