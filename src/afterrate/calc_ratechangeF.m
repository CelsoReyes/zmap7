function [rc] = calc_ratechangeF(mycat,time,timef,bootloops,ZG.maepi)
    % function [rc] = calc_ratechangeF(mycat,time,timef,bootloops,ZG.maepi);
    % ----------------------------------------------------------------
    % Determines ratechanges within aftershock sequences for defined time window
    %
    % Input parameters:
    %   mycat       earthquake catalog
    %   time_as     delay times (days)
    %   step        number of quakes to determine forecast period
    %   time        learning period
    %   timeF       forecast period
    %   bootloops   Number of bootstraps
    %   ZG.maepi       Mainsock values
    %
    % Output parameters:
    %   rc      Matrix containing: time, absdiff, sigma, numreal, nummod,
    %           pval, pvalstd, cval, cvalstd, kval, kvalstd, t_forecast, fMc
    %
    % Info: Version for ZMAP, original function by ratechange.m by S. Neukomm May 27, 2002
    % J. Woessner
    % last update: 09.07.03

    % if min(time_as) >= 1
    %     rc = [];
    %     return
    % end

    % Initialize
    rc = [];
    % fMc0 = mcwithtime(mycat,time_as,7);
    %
    % %time = mintime;
    %
    % % determination of magnitude of completeness
    % if time < 7
    %     fMc = mcwithtime(mycat,time_as,time);
    % else
    %     fMc = fMc0;
    % end
report_this_filefun(mfilename('fullpath'));
    date_matlab = datenum(mycat.Date);
    date_main = datenum(ZG.maepi.Date);
    time_aftershock = date_matlab-date_main;

    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = mycat.subset(l);

    % Estimation of Omori parameters from learning period
    l = tas <= time;% & mycat.Magnitude >= fMc;
    time_as=tas(l);
    % [pval, pvalstd, cval, cvalstd, kval, kvalstd, loopout] = brutebootF(time_as, bootloops);
    % Calculate uncertainties and mean values of p,c,and k
    [pval, pvalstd, cval, cvalstd, kval, kvalstd, loopout] = brutebootloglike(time_as,bootloops);
    % Calculate p,c,k for real dataset
    [pval, cval, kval] = bruteforceloglike(sort(time_as));
    pval = round(100*pval)/100;
    cval = round(100*cval)/100;
    kval = round(10*kval)/10;

    [H,P,KSSTAT,fRMS] = calc_llkstest(time_as, pval, cval, kval);
    if H==1
        rc = [NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
        return
    end

    if isnan(pval) == 0
        lf = tas <= time+timef ;
        time_asf= [tas(lf) ];
        %     nummod = length(time_asf); % forecasted number of aftershocks in time window
        if pval == 1
            pv = 1-10^(-6);
        else
            pv = pval;
        end

        cumnrf = (1:length(time_asf))';
        cumnr_modelf = [];
        for i=1:length(time_asf)
            if pval ~= 1
                cm = kval/(pval-1)*(cval^(1-pval)-(time_asf(i)+cval)^(1-pval));
            else
                cm = kval*log(time_asf(i)/cval+1);
            end
            cumnr_modelf = [cumnr_modelf; cm];
        end
        %     t_forecast = (-nummod*(pv-1)/kval+(time+cval)^(1-pv))^(1/(1-pv))-cval; % forecast interval
        %     if isreal(t_forecast) == 1 & t_forecast > time
        %         if t_forecast > max(time_as)
        %             return
        %         end
        %l = time_as <= t_forecast & mycat.Magnitude >= fMc & time_as >= time;
        %l = tas <= time+timef;
        % Find amount of events in forecast period for modeled data
        nummod = max(cumnr_modelf)-cumnr_modelf(length(time_as));
        % Find amount of  events in forecast period for observed data
        l = time_asf <=time+timef & time_asf > time;
        numreal = sum(l); % observed number of aftershocks
        absdiff = numreal-nummod;

        % calculate uncertainty sigma in forecasted number of aftershocks by Fehlerfortpflanzungsgesetz
        %time1 = t_forecast;
        time1 = time+timef;
        mpm1 = 1-pv;
        t1c = time1+cval;
        t0c = time+cval;
        sigma = (((-t1c^mpm1+t0c^mpm1)/(pv-1)*kvalstd)^2+...
            (kval/(pv-1)*(-t1c^mpm1*mpm1/t1c+t0c^mpm1*mpm1/t0c)*cvalstd)^2+...
            (kval/(pv-1)*(t1c^mpm1*log(t1c)+t1c^mpm1/(pv-1)-t0c^mpm1*log(t0c)-t0c^mpm1/(pv-1))*pvalstd)^2)^0.5;

        %rc = [rc; time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd t_forecast fMc];

        % Compute 2nd moment of forecasted number of events at time
        for j = 1:length(loopout(:,1))
            cumnr = (1:length(time_asf))';
            cumnr_model = [];
            pvalb = loopout(j,1);
            cvalb = loopout(j,2);
            kvalb = loopout(j,3);
            for i=1:length(time_asf)
                if pval ~= 1
                    cm = kvalb/(pvalb-1)*(cvalb^(1-pvalb)-(time_asf(i)+cvalb)^(1-pvalb));
                else
                    cm = kvalb*log(time_asf(i)/cvalb+1);
                end
                cumnr_model = [cumnr_model; cm];
            end
            loopout(j,4) = max(cumnr_model);
        end
        fStdBst = calc_StdDev(loopout(:,4));
        rc = [time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd fStdBst];
    else
        rc = [NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
    end
