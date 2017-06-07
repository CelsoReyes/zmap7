%
% This code is responsable for the activation (enable, on) of the range editor in the
% fractal dimension parameter input window. It is called from fdparain.m,
% dcparain.m,
% Francesco Pacchiani 1/2000
%
if range == 2

    set(input2, 'enable', 'on');
    set(input3, 'enable', 'on');
    set(tx2, 'color', 'k');
    set(tx3, 'color', 'k');
    set(tx4, 'color', 'k');
    set(tx5, 'color', 'k');

else

    set(input2, 'enable', 'off');
    set(input3, 'enable', 'off');
    set(tx2, 'color', 'w');
    set(tx3, 'color', 'w');
    set(tx4, 'color', 'w');
    set(tx5, 'color', 'w');
    radm = [];
    rasm = [];

end

