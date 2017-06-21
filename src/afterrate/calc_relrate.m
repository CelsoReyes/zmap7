function [mRateChange] = calc_relrate(a,step,mintime, maxtime,timestep,bootloops)
    % function [mRateChange] = calc_relrate(a,step,mintime, maxtime,timestep,bootloops)
    % ----------------------------------------------------------------
    % Determines ratechanges in entire aftershock sequences
    % for further explanations see rcgrid.m and ratechange.m
    %
    % Incoming variables:
    % a       : earthquake catalog
    % step    : forecast period
    % mintime : Start time
    % maxtime : time after mainshock up to Omori parameters are fitted in the learning period
    % timestep : Timesteps for the learning period
    % bootloops: Number of bootstrap samples
    %
    % Outgoing variables
    % mRateChange : time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd t_forecast fMc
    %
    % J. Woessner: original function by S.Neukomm
    % last update: 03.07.03

    disp(['start: ' datestr(now)])

    % Surpress warnings from fmincon
    warning off;

    % Main event time and time after mainshock
    [m_main, main] = max(a.Magnitude);
    date_matlab = datenum(a.Date.Year,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,zeros(size(a,1),1));
    date_main = date_matlab(main);
    time_aftershock = date_matlab-date_main;

    %
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l); % Time of aftershocks
    eqcatalogue = a.subset(l); % Catalog of aftershocks

    l = eqcatalogue(:,6) >= 5;
    largeas = eqcatalogue(l,:);
    largetime = tas(l); % Time of largest aftershocks

    % Calculate Mc for time period
    [fMc0] = mcwithtime(eqcatalogue,tas,7);

    rc = [];
    time = mintime; %step = 50; maxtime = 50;
    while time <= maxtime

        if time < 7
            fMc = mcwithtime(eqcatalogue,tas,time);
        else
            fMc = fMc0;
        end
        l = tas <= time & eqcatalogue(:,6) >= fMc;
        [pval, pvalstd, cval, cvalstd, kval, kvalstd, loopout] = brutebootF(tas(l),bootloops);

        if isnan(pval) == 0
            nummod = step;
            if pval == 1
                pv = 1-10^(-6);
            else
                pv = pval;
            end
            t_forecast = (nummod*(1-pv)/kval+(time+cval)^(1-pv))^(1/(1-pv))-cval;
            if isreal(t_forecast) == 1  &&  t_forecast > time
                l = tas <= t_forecast & eqcatalogue(:,6) >= fMc & tas >= time;
                numreal = sum(l);
                absdiff = numreal-nummod;
                mpm1 = 1-pv; t1c = t_forecast+cval; t0c = time+cval;
                sigma = (((-t1c^mpm1+t0c^mpm1)/(pv-1)*kvalstd)^2+...
                    (kval/(pv-1)*(-t1c^mpm1*mpm1/t1c+t0c^mpm1*mpm1/t0c)*cvalstd)^2+...
                    (kval/(pv-1)*(t1c^mpm1*log(t1c)+t1c^mpm1/(pv-1)-t0c^mpm1*log(t0c)-t0c^mpm1/(pv-1))*pvalstd)^2)^0.5;
                rc = [rc; time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd t_forecast fMc];
                if t_forecast > max(tas)
                    time = maxtime;
                end
            end
        end
        time = time+timestep

    end
    disp(['end: ' datestr(now)])

    ratechange0 = rc;
    gridnode0 = eqcatalogue;

    if size(rc,1) > 0
        relchange = rc(:,2)./rc(:,3);

        figure_w_normalized_uicontrolunits('Name','p-,c- and k-value')
        subplot(3,1,1)
        plot(rc(:,1),rc(:,6),'k')
        hold
        plot(rc(:,1),rc(:,6)+rc(:,7),'r')
        plot(rc(:,1),rc(:,6)-rc(:,7),'r')
        title('pval/pstd')
        subplot(3,1,2)
        plot(rc(:,1),rc(:,8),'k')
        hold
        plot(rc(:,1),rc(:,8)+rc(:,9),'r')
        plot(rc(:,1),rc(:,8)-rc(:,9),'r')
        title('cval/cstd')
        subplot(3,1,3)
        plot(rc(:,1),rc(:,10),'k')
        hold
        plot(rc(:,1),rc(:,10)+rc(:,11),'r')
        plot(rc(:,1),rc(:,10)-rc(:,11),'r')
        title('kval/kstd')
        xlabel('Days')

        figure_w_normalized_uicontrolunits('tag','ratechange','Name','Rate change plot')
        % Create cumulative number with time
        vCumnum = (1:length(eqcatalogue(:,1)))';
        vTimedays = tas;
        mCumTime = [vTimedays vCumnum];
        vSel = (mCumTime(:,1) <= max(rc(:,1)));
        [AX,H1,H2]=plotyy(rc(:,1),relchange,mCumTime(vSel,1),mCumTime(vSel,2));
        hold
        plot(mCumTime(vSel,1),mCumTime(vSel,2),'-g')
        plot([min(rc(:,1)) max(rc(:,1))],[1 1],'r--');
        plot([min(rc(:,1)) max(rc(:,1))],[2 2],'r');
        plot([min(rc(:,1)) max(rc(:,1))],[-2 -2],'r');
        plot([min(rc(:,1)) max(rc(:,1))],[-1 -1],'r--');
        legend('Rel. rate change','Cum. Number','\sigma','2 \sigma','location','NorthWest');
        xlabel('Days');
        set(get(AX(1),'Ylabel'),'String','Sigma');
        set(get(AX(2),'Ylabel'),'String','Cum. number');
    else
        disp('no result')
    end
    mRateChange = rc;
