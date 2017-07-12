function infoz(var1)
    %slapinfo.m                        A.Allmann
    %function to make an info window for various routines
    %
    %
    global slapinfo p1

    report_this_filefun(mfilename('fullpath'));

    if var1==1               %first call in P-Value window

        % This is the info window text
        %
        ttlStr='Help Window                                 ';

        hlpStr1=...
            ['                                                             '
            'No help available on this topic. Please                      '
            'consult the manual or contact stefan@giseis.alaska.edu       '
            '                                                             '];

    elseif var1 == 2                 % second help message

        ttlStr='Stress Tensor Inversion Resuls              ';

        hlpStr1=...
            ['                                                             '
            'This is a polar projection of the Stress Tensor Inversion    '
            'results, using Gepards and Forsyths (1984) technique.        '
            'Show in black are the best fitting stress directions,        '
            'The red. yellow and blue symbols indicate the 95% confidence '
            'region. The histogrom in the corner shows the distribution   '
            'of R values in this data-set.                                '
            '                                                             '];


    end

    % display the message
    zmaphelp(ttlStr,hlpStr1)
