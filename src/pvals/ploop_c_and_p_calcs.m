function [loopcheck, pc_, pp_, pk_, sdc, sdp, sdk] = ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, trackLoop, stdevcall)
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
    
    % TODO: get rid of all these globals!!@!!Q#RQR@!#R$@!
    global pc pp pk 
    global tt loop nn
    global nit t
    global err1x err2x  % previous errors
    global ieflag isflag %error small enough, step small enough
    global qp
    global err1 err2
    global cstep pstep
    global ts eps1 eps2
    global pcheck
    %global sdk sdp sdc
    
    loopcheck=0;
    
    % pp = initial p = 1.1
    % nn = length of catalog (# of events)
    % tt = end time (last event)
    % ts = start time (1st event)
    % pc = initial c???
    % t  = time of each event (a vector)
    while loopcheck < 500
        if ~isnumeric(t)
            %fprintf('t is a %s',class(t));
            % normalize all times to days after first event
            t = days(t - ts);
            tt = days(tt - ts);
            ts = days(ts - ts);
            %fprintf(' now t is a %s\n',class(t) );
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
        
    %p= pp;
    pp_=pp;
    pc_=pc;
    pk_=pk;
    
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

function [cstep, pc, loop] = take_cstep(MIN_CSTEP, cstep, preverr, ts, pc, nit, err1, loop)
    if isempty(MIN_CSTEP); return; end
    
    STEP_REDUCTIONFACTOR = 0.9;
    
    if nit>1
        %if error has changed sign,reduce the step size
        if ~same_sign(preverr,err1)  &&  cstep >= MIN_CSTEP
            cstep=cstep * STEP_REDUCTIONFACTOR;
        end
    end
    
    pc = pc - cstep * sign(err1); % move closer to zero
    
    dt=ts+pc;
    if dt <= 0
        pc=ts+cstep;
    end
    if ~isempty(loop) && loop == 30
        cstep=cstep * STEP_REDUCTIONFACTOR;
        loop=0;
    end
    
end

function [pstep, pp] = take_pstep(MIN_PSTEP, pp, pstep, preverr, nit, err2)
    %function to calculate the parameters of p-value
    if isempty(MIN_PSTEP); return; end
    STEP_REDUCTIONFACTOR = 0.9;
    
    if nit>1
        %if error has changed sign,reduce the step size
        if ~same_sign(preverr,err2) &&  pstep>= MIN_PSTEP
            pstep=pstep * STEP_REDUCTIONFACTOR;
        end
    end
    
    pp = pp - pstep * sign(err2); % move closer to zero
end


function [sdk, sdp, sdc] = kcp_stdevs()
    % calculate standard deviations for k, c, and p values
    %kcp_stdevs.m                          A.Allmann
    %
    %function to calculat the parameters of p-value
    %calls itself with different parameters for different loops in programm
    
    % TODO: get rid of all these globals!!@!!Q#RQR@!#R$@!
    
    global p c tt pc pp 
    global pk ts dk 
    
    te=tt;
    p=pp;
    c=pc;
    dk=pk;
    
    %case1
    f1=((te+c)^(-p+1))/(-p+1);
    h1=((ts+c)^(-p+1))/(-p+1);
    s(1)=(1/dk)*(f1-h1);
    
    %case2
    f2=((te+c)^(-p));
    h2=((ts+c)^(-p));
    s(2)=f2-h2;
    
    %case3
    
    
    f3=(-(te+c)^(-p+1))*(((log(te+c))/(-p+1))-(1/((-p+1)^2)));
    h3=(-(ts+c)^(-p+1))*(((log(ts+c))/(-p+1))-(1/((-p+1)^2))); 
    s(3)=f3-h3;
    
    %case4
    
    s(4)=s(2);
    
    %case5
    
    f5=((te+c)^(-p-1))/(p+1);
    h5=((ts+c)^(-p-1))/(p+1);
    s(5)=(-dk)*(p^2)*(f5-h5);
    
    %case6
    
    
    f6=((te+c)^(-p))*(((log(te+c))/(-p))-(1/(p^2)));
    h6=((ts+c)^(-p))*(((log(ts+c))/(-p))-(1/(p^2)));
    s(6)=(dk*p)*(f6-h6);
    
    %case7
    
    s(7)=s(3);
    
    %case8
    
    s(8)=s(6);
    
    %case9
    
    f10=((te+c)^(-p+1))*((log(te+c))^2)/(-p+1);
    f11=(2*((te+c)^(-p+1)))/((-p+1)^2);
    f12=(log(te+c))-(1/(-p+1));
    f9=f10-(f11*f12);
    
    h10=((ts+c)^(-p+1))*((log(ts+c))^2)/(-p+1);
    h11=(2*((ts+c)^(-p+1)))/((-p+1)^2);
    h12=(log(ts+c))-(1/(-p+1));
    h9=h10-(h11*h12);
    s(9)=(dk)*(f9-h9);
    
    
    %assign the values of s to the matrix A(i,j)
    %invert the matrix to calculate the standard deviation
    %for k,c,p .
    
    if nargout == 3
        A=[s(1) s(2) s(3); s(4) s(5) s(6); s(7) s(8) s(9)];

        A=inv(A);

        sdk=sqrt(A(1,1));
        sdc=sqrt(A(2,2));
        sdp=sqrt(A(3,3));
        
    elseif nargout == 2
        A=[s(1) s(3); s(3) s(9)];
        A=inv(A);
        sdk=sqrt(A(1,1));
        sdp=sqrt(A(2,2));
    else
        error('wrong number of output arguments');
    end
    
end