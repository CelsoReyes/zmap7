function loopcheck = ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, trackLoop, stdevcall)
    % loop for calculating c and p values
    % if cstep is empty, then neither cstep or err1 will be calculated
    % sdevcall will contain 'kpc', 'kp', or 'kp~' to determine how kcp_stdevs behaves
    % -  'kpc' will calculate the k, p, and c errors
    % - 'kp' calculates only the k & p errors
    % - 'kp~' also calculates the k & p errors, but in a 3x matrix
    %   where the results for c are ignored
    % all these options exist because that is how they were
    % implemented by the ploop functions
    
    % modified omori law:
    % n(t) = K /(t+c)^p
    % n(t) : frequency of aftershocks per unit time interval, 
    % K : the productivity of the sequence,
    % c : adjusts for missing earthquakes in the catalog 
    % p : how quickly the activity falls off to the constant background intensity. 
    % typically normaized to days
    %
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
    global sdk sdp sdc
    
    loopcheck=0;
    
    % pp = initial p = 1.1
    % nn = length of catalog (# of events)
    % tt = end time (last event)
    % ts = start time (1st event)
    % pc = initial c???
    % t  = time of each event (a vector)
    while loopcheck < 500
        if ~isnumeric(t)
            fprintf('t is a %s',class(t));
            % normalize all times to days after first event
            t = days(t - ts);
            tt = days(tt - ts);
            ts = days(ts - ts);
            fprintf(' now t is a %s\n',class(t) );
        end
        
        % preverr was never assigned anywhere
        preverr = 0.0;
        
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
            err1 = c_err(pk, pc, t, ts, tt, pp);
            ieflag = ieflag || abs(err1)< eps1 ;
            isflag = isflag || cstep <=MIN_CSTEP;
        end
        err2 = p_err(t, pc, pk, qp, tt, ts);
        
        ieflag = ieflag || ( abs(err2) <  eps2); % errors small enough
        isflag = isflag || ( pstep <= MIN_PSTEP); % steps small enough
        
        %stop searching if errors or steps are small enough
        if ieflag || isflag
            switch stdevcall
                case 'kpc'
                    [sdk, sdp, sdc] = kcp_stdevs();
                case 'kp'
                    [sdk, sdp] = kcp_stdevs();
                case 'kp~'
                    [sdk, sdp, ~] = kcp_stdevs();
            end
            pcheck = 1;
            break
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
        
    end
    p= pp;
end

%%
function cerr = c_err(pk, pc, t, ts, tt, pp)
    %c_err calculate c error
    qsum=pk*((1/(tt+pc)^pp)-(1/(ts+pc)^pp));
    psum=sum(1./(t+pc));
    cerr=qsum+pp*psum;
end

function perr = p_err(t, pc, pk, qp, tt, ts)
    %p_err calculate p error
    sumln=sum(log(t+pc));
    qsumln=pk/qp^2;
    qsumln=qsumln*(((tt+pc)^qp)*(1-qp*log(tt+pc))-((ts+pc)^qp)*(1-qp*log(ts+pc)));
    esumln=qsumln+sumln;
    perr=esumln;
end



