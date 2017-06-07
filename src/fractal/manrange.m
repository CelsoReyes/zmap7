%
% Organizes the choice between Automatic and Manual fixed range in the
% fdpara.m, timparain.m, and dcparain.m files.
%
%
%
%
% This code is responsable for the activation of the range popupmenu in the
% fractal dimension parameter input window. It is called from parain.m,
% dcprarain.m,
% Francesco Pacchiani 1/2000
%
if range == 1

    set(tx3, 'color', 'w');
    set(tx4, 'color', 'w');
    set(tx5, 'color', 'w');
    set(tx6, 'color', 'w');
    radm = [];
    rasm = [];

elseif range == 2

    set(input3, 'enable', 'on');
    set(input4, 'enable', 'on');
    set(tx3, 'color', 'k');
    set(tx4, 'color', 'k');
    set(tx5, 'color', 'k');
    set(tx6, 'color', 'k');

elseif range == 3

    set(tx3, 'color', 'w');
    set(tx4, 'color', 'w');
    set(tx5, 'color', 'w');
    set(tx6, 'color', 'w');
    radm = [];
    rasm = [];

end

