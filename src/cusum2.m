function ci =  cusum(cat)

    report_this_filefun(mfilename('fullpath'));

    % This function calculates the CUMSUm function (Page 1954).
    %


    m  = cat(:,6);
    me = mean(m);
    i = (1:1:length(m));
    ci = cumsum(m)' - i.*me;


