function [p_, sdp_, c_, sdc_, dk_, sdk_, rja, rjb] = mypval2m(eqDates,eqMags, datestyle, valeg2, CO, minThreshMag)
    
    % MYPVAL2M  calculate the parameters of the modified Omori Law
    %
    %
    % this function is a modification of a program by Paul Raesenberg
    % that is based on Programs by Carl Kisslinger and Yoshi Ogata.
    %
    % function finds the maximum liklihood estimates of p,c and k, the
    % parameters of the modifies Omori equation
    % it also finds the standard deviations of these parameters
    %
    % Input: Dates from Earthquake Catalog of an Aftershock Sequence
    %        datestyle : 'date' or 'days'
    %           'date' : uses absolute dates
    %           'days' : uses days since big event
    %
    % Output: p c k values of the modified Omori Law with respective
    %         standard deviations
    %
    % datestyle 'days', (goal : maps or cross-sections);
    % datetyle 'date' (goal: determination of parameters in Omori formula for a certain set of data - the
    %one for which the Cumulative Number of earthquakes in time is displayed in the window
    %"Cumulative number").
    %
    %The parameter CO establishes whether to use a fix c value. In the case c=0, ts must be
    % different from 0, otherwise there is non-determination in origin.
    %
    % mypval2m                            Bogdan Enescu

    global pc nn pp nit t ieflag isflag
    global cstep pstep ts tt eps1 eps2 pcheck
    global loopcheck
    global p sdp c sdc dk sdk
    
    %report_this_filefun();
    ZG=ZmapGlobal.Data;
    %set some errors
    eps1=.001;
    eps2=.001;
    
    %Set the parameters starting values
    %The program works for fairly arbitrary given initial values.
    PO=1.1;
    if valeg2 >= 0
        CO=0.1;
    end
    
    %set the initial step size
    pstep=.05;
    cstep=.05;
    pp=PO;
    pc=CO;
    nit=0;
    ieflag=false;
    isflag=false;
    pcheck=false;
    
    %
    rja=nan;
    rjb=nan;
    %Build timecatalog
    
    assert(isa(eqDates,'datetime'))
    assert(~isempty(eqDates),'Pcat cannot be empty');
    
    switch datestyle
        case 'date'
            t = eqDates; %DATE
        case 'days'
            t = days(eqDates - ZG.maepi.Date(1)) + datetime(0,0,0); % forced to be a datetime
        otherwise
            error('invalid numerical choice.')
    end
    
    ts = min(t); % first event time
    tt = max(t); % last event time
    nn = length(t); %nEvents
    
    if (valeg2 >= 0)
        pc = max(pc, 0.0);
    end
    %Loop begins here
    %call of function who calculates parameters
    
    lastwarn('');
    warning('off','MATLAB:illConditionedMatrix');
    if (valeg2 >= 0)
        MIN_CSTEP = 0.0001; 
        MIN_PSTEP = 0.0001;
        [loopcheck, c, p, dk, sdc, sdp, sdk]=ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, false,'kpc');
    else
        MIN_PSTEP = 0.0001;
        [loopcheck, c, p, dk, sdc, sdp, sdk]=ploop_c_and_p_calcs([], MIN_PSTEP, false, 'kp');
    end
    
    warning('on','MATLAB:illConditionedMatrix');
    if ~isempty(lastwarn)
        disp(['warnings were given. ' lastwarn]);
    end
    
    %loopcheck
    
    if loopcheck<500
        %round values on two digits
        p=round(p, -2);
        sdp=round(sdp, -2);
        c=round(c, -3);
        
        if (valeg2 >= 0)
            sdc=round(sdc, -3);
        else
            sdc = nan;
        end
        %%
        % added my MCG 7/01 to calculate R&J a & b -- a is not
        % corrected for completeness as in ASPAR
        %%
        
        %%
        % compute average magnitude above cutoff - to calc max like b
        % and then a from k (dk) and b
        %%
        magi = eqMags >= minThreshMag & eqMags <= 6.1 ;
        magz = eqMags(magi);
        amag = sum(magz) / numel(magz);
        
        rjb = .4343/(amag-minThreshMag+.05);
        % NOTE, uses first maepi value
        rja = log10(dk) - rjb * (ZG.maepi.Magnitude(1) - min(eqMags));
        dk=round(dk, -2);
        sdk= round(sdk, -2);
    else
        [p, sdp, c, sdc, dk, sdk, rja, rjb] = deal(nan);
    end
    [p_, sdp_, c_, sdc_, dk_, sdk_] = deal(p, sdp, c, sdc, dk, sdk);
end
