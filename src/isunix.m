function yn = isunix()
    %ISUNIX	True for UNIX operating systems.

    %	Copyright (c) 1984-94 by The MathWorks, Inc.

    % report_this_filefun(mfilename('fullpath'));

    c = computer;
    yn = 1;
    if strcmp(c(1:2),'PC') ||  strcmp(c(1:2),'MA')
        yn = 0;
    elseif strcmp(c(1:2),'VA')
        if strcmp(c(1:7),'VAX_VMS')
            yn = 0;
        end
    end
