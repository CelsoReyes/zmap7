function prtm(hpop)
    % function to print output form GenAS either to printer or postscript file
    % (see call from gogenas.m)
    %

    report_this_filefun(mfilename('fullpath'));

    val = get(hpop,'Value');
    if val == 2
        print
    elseif val == 3
        print -dpsc genas.ps
        disp('  Plot saved as poscript file genas.ps ...');
    end



