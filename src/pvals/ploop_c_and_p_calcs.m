function ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, trackLoop, stdevcall)
    % loop for calculating c and p values
    % if cstep is empty, then neither cstep or err1 will be calculated
    % sdevcall will contain 'kpc', 'kp', or 'kp~' to determine how kcp_stdevs behaves
    % -  'kpc' will calculate the k, p, and c errors
    % - 'kp' calculates only the k & p errors
    % - 'kp~' also calculates the k & p errors, but in a 3x matrix
    %   where the results for c are ignored
    % all these options exist because that is how they were
    % implemented by the ploop functions
    
    % ploop parts attributed to A.Allmann and B. Enescu
    % routines deconstructed & merged by C. Reyes 2017
    
    global p tt pc loop nn pp
    global nit t
    global err1x err2x  % previous errors
    global ieflag isflag %error small enough, step small enough
    global pk qp
    global err1 err2
    global cstep pstep
    global ts eps1 eps2
    global pcheck
    global loopcheck
    global sdk sdp sdc
    
    
    % pp = initial p = 1.1
    % nn = length of catalog (# of events)
    % tt = end time (last event)
    % ts = start time (1st event)
    % pc = initial c???
    % t  = time of each event (a vector)
    
    if pp==1.0
        pp=1.001;
    end
    
    if trackLoop
        loop=loop+1;
    end
    loopcheck=loopcheck+1;
    nit=nit+1;
    
    qp=1-pp;
    pk=(qp*nn)/((tt+pc)^qp-(ts+pc)^qp);
    
    update_cof_and_cog(pk, qp, ts, pc)
    
    if ~isempty(MIN_CSTEP) % kludgy! but still reduces lines tremendously
        err1 = c_err(pk, pc, tt, pp);
        ieflag = ieflag || abs(err1)< eps1 ;
        isflag = isflag || cstep <=MIN_CSTEP;
    end
    err2 = p_err(t, pc, pk, qp, tt, ts);
    
    ieflag = ieflag || ( abs(err2) <  eps2); % errors small enough
    isflag = isflag || ( pstep <= MIN_PSTEP); % steps small enough
    
    %stop searching if errors or steps are small enough
    if ieflag || isflag
        update_aa_bb_for_unknown_reasons(tt, ts, pp, pc);
        switch stdevcall
            case 'kpc'
                [sdk, sdp, sdc] = kcp_stdevs();
            case 'kp'
                [sdk, sdp] = kcp_stdevs();
            case 'kp~'
                [sdk, sdp, ~] = kcp_stdevs();
        end
        pcheck = 1;
        return
    else
        if trackLoop
            [cstep, pc, loop] = take_cstep(MIN_CSTEP, cstep, preverr, ts, pc, nit, err1, loop);
        else
            [cstep, pc, ~] = take_cstep(MIN_CSTEP, cstep, preverr, ts, pc, nit, err1, []);
        end
        [pstep, pp] = take_pstep(MIN_PSTEP, pp, pstep, preverr, nit, err2);
    end
    
    if ~isempty(MIN_CSTEP)
        err1x=err1;
    end
    err2x=err2;
    
    if loopcheck<500
        ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, trackLoop, stdevcall);
    else
        p= pp;
    end
    
end



