%
% This code is responsible for the activation (enable, on) of the radius input
% in crcparain.m.
% Francesco Pacchiani 6/2000
%
%
if ic == 2

    set(input4, 'enable', 'on');
    set(tx6, 'color', 'k');

else

    set(input4, 'enable', 'off');
    set(tx6, 'color', 'w');

end
