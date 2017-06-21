function [p_, sdp_, c_, sdc_, dk_, sdk_, rja_, rjb_] = mypval2m(pcat)

    %mypval2m                            Bogdan Enescu
    % function to calculate the parameters of the modified Omori Law
    %
    % Last modification 5/2000

    % this function is a modification of a program by Paul Raesenberg
    % that is based on Programs by Carl Kisslinger and Yoshi Ogata.

    % function finds the maximum liklihood estimates of p,c and k, the
    % parameters of the modifies Omori equation
    % it also finds the standard deviations of these parameters

    % Input: Earthquake Catalog of an Aftershock Sequence

    % Output: p c k values of the modified Omori Law with respective
    %         standard deviations

    %The parameter valeg shows from where the routine has been called:
    %1 - called from bpvalgrid.m and pcrossnew.m (goal : maps or cross-sections); 2 - call from pvalcat, which in its turn is called
    %from timeplot.m (goal: determination of parameters in Omori formula for a certain set of data - the
    %one for which the Cumulative Number of earthquakes in time is displayed in the window
    %"Cumulative number").

    %The parameter valeg2 establishes which routine is called, ploop2 or ploop3.
    %The routine ploop3 considers a fix c value. In the case c=0, I have to have ts different from 0,
    %otherwise there is non-determination in origin.

    global valeg valeg2 CO valm1
    global pc nn pp nit t ieflag isflag maepi
    global cstep pstep ts tt eps1 eps2 pcheck
    global loopcheck
    global p sdp c sdc dk sdk
    global newt2

report_this_filefun(mfilename('fullpath'));

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
    ieflag=0;
    isflag=0;
    pcheck=0;

    %Build timecatalog

    if valeg == 1
        newcat2 = sortrows(pcat,3);
    elseif (valeg == 2  ||  valeg == 3)
        t = pcat;
        ts = min(t);
        tt = max(t);
        nn = length(t);
        if (valeg2 >= 0)
            if pc < 0 ; pc = 0.0; end
            %The following line should be commented if, in ploop2.m, A is commented and B not.
            %if pc <= ts; pc = ts + 0.05;end
        end
    end

    if (valeg == 1)
        [timpa] = timabs(newcat2);
        [timpar] = timabs(maepi);
        tmpar = timpar(1);
        t = (timpa-tmpar)/1440;
        ts = min(t);
        tt = max(t);
        nn = length(t);
        if (valeg2 >= 0)
            if pc < 0 ; pc = 0.0; end
            %The following line should be commented if, in ploop2.m, A is commented and B not.
            %if pc <= ts; pc = ts + 0.05;end
        end
    end

    %Loop begins here
    %call of function who calculates parameters

    loopcheck=0;
    if (valeg2 >= 0)
        ploop2(1);
    else
        ploop3(1);
    end

    %loopcheck

    if loopcheck<500
        %round values on two digits
        p=round(p*100)/100;
        sdp=round(sdp*100)/100;
        c=round(c*1000)/1000;
        if (valeg2 >= 0)
            sdc=round(sdc*1000)/1000;
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
        magi = newt2.Magnitude >= valm1 & newt2.Magnitude <= 6.1 ;
        magz = newt2(magi,6);
        amag = sum(magz)/length(magz);

        rjb = .4343/(amag-valm1+.05);
        rja = log10(dk) - rjb * (maepi(:,6) - min(newt2.Magnitude));


        dk=round(dk*100)/100;
        sdk= round(sdk*100)/100;
    else %if loopcheck
        %disp(['No result']);
        p = nan;
        sdp = nan;
        c= nan;
        sdc=nan;
        dk=nan;
        sdk= nan;
        rja = nan;
        rjb = nan;
    end

    p_=p;
    sdp_=sdp;
    c_=c;
    sdc_=sdc;
    dk_=dk;
    sdk_=sdk;
    rja_=rja;
    rjb_=rjb;
