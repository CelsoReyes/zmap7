function [rc,numreal,nummod,sigma] = calc_optrc(a,time_as,t0,t1,bootloops,maepi)
    % function [rc,numreal,nummod,sigma] = calc_optrc(a,time_as,t0,t1,bootloops,maepi);
    % -------------------------------------------------
    %
    % Determines ratechanges within aftershock sequences
    % within given time interval
    %
    % Input parameters:
    %   a           earthquake catalog
    %   time_as     delay times
    %   t0,t1       begin/end of analysis interval
    %   bootloops   number of bootstrap loops
    %
    % Output parameters:
    %   rc          relative rate change
    %   numreal     observed nr. of aftershocks
    %   nummod      forecasted nr. of aftershocks
    %   sigma       uncertainty of forecast
    %
    % Samuel Neukomm / Jochen Woessner
    % last update: Feb 25, 2004

report_this_filefun(mfilename('fullpath'));
    warning off

    [fMc] = calc_Mc(a, 1, 0.1)+0.2;
    l = a.Magnitude >= fMc;
    a = a.subset(l);
    time_as = time_as(l);

    time_as = sort(time_as);
    time_asf = time_as;
    if size(a,2) == 9
        date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),0);
    else
        date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),maepi(10));
    end
    l = time_as <= t0;
    time_as = time_as(l);
    a = a.subset(l);
    l = time_asf <= t1;
    time_asf = time_asf(l);
    time = t0; timef = t1-t0;

    if length(time_as) < 100 % at least 100 events in learning period
        rc = NaN; numreal = NaN; nummod = NaN; sigma = NaN;
        return
    end

    % Select biggest aftershock earliest in time, but more than 1 day after mainshock
    fDay = 1;
    ft_c=fDay/365; % Time not considered to find biggest aftershock
    vSel = (a.Date > maepi(:,3)+ft_c & a.Date<= maepi(:,3)+time/365);
    if sum(vSel) == 0
        rc = NaN; numreal = NaN; nummod = NaN; sigma = NaN;
        return
    end
    mCat = a.subset(vSel);
    vSel = mCat(:,6) == max(mCat(:,6));
    vBigAf = mCat(vSel,:);
    if length(mCat(:,1)) > 1
        vSel = vBigAf(:,3) == min(vBigAf(:,3));
        vBigAf = vBigAf(vSel,:);
    end
    if size(a,2) == 9
        date_biga = datenum(floor(vBigAf(3)),vBigAf(4),vBigAf(5),vBigAf(8),vBigAf(9),0);
    else
        date_biga = datenum(floor(vBigAf(3)),vBigAf(4),vBigAf(5),vBigAf(8),vBigAf(9),vBigAf(10));
    end
    fT1 = date_biga - date_main; % Time of big aftershock

    [loopout] = brutebootloglike_a2_opt(time_as, time_asf, bootloops,fT1);

    if isnan(loopout) == 0
        fStdBst = calc_StdDev(loopout(:,9));

        % calculate rate change
        nr_forecast = mean(loopout(:,9));
        nr_learn = mean(loopout(:,10));
        nummod = nr_forecast-nr_learn;
        l = time_asf <=time+timef & time_asf > time;
        numreal = sum(l);
        fRc_Bst = (numreal-nummod)/fStdBst;
    else
        rc = NaN; numreal = NaN; nummod = NaN; sigma = NaN;
        return
    end

    if nummod < 10
        rc = NaN; numreal = NaN; nummod = NaN; sigma = NaN;
        return
    end

    %%%%%%%%%%%%%%%%
    sigma = fStdBst;
    rc = fRc_Bst;
    numreal = numreal;
    nummod = nummod;
    %%%%%%%%%%%%%%%%
