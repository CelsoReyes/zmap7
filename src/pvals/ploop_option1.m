function ploop_option1()
    %ploop_option1.m                          A.Allmann
    %
    %function to calculate the parameters of p-value
    %calls itself with different parameters for different loops in programm
    % heavily modified and functionalized by C Reyes 2017
    report_this_filefun(mfilename('fullpath'));
    MIN_CSTEP = 0.000001;
    MIN_PSTEP = 0.00001;
    
    ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');
    
    return
end