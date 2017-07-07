function [rc] = calc_ratechange(a,time_as,step,mintime, maxtime,timestep)
    % function [rc] = calc_ratechange(a,time_as,step,mintime,maxtime,timestep);
    % ----------------------------------------------------------------
    % Determines ratechanges within aftershock sequences
    %
    % Input parameters:
    %   a           earthquake catalog
    %   time_as     delay times (days)
    %   step        number of quakes to determine forecast period
    %   mintime     tart time
    %   maxtime     maximal time at which Omori parameters are calculated
    %   timestep    Timesteps between learning periods
    %
    % Output parameters:
    %   rc      Matrix containing: time, absdiff, sigma, numreal, nummod,
    %           pval, pvalstd, cval, cvalstd, kval, kvalstd, t_forecast, fMc
    %
    % Info: Version for ZMAP, original function by ratechange.m by S. Neukomm May 27, 2002
    % J. Woessner
    % last update: 09.07.03

    if min(time_as) >= 1
        rc = [];
        return
    end

    fMc0 = mcwithtime(a,time_as,7);

    rc = [];
    time = mintime;
    while time <= maxtime

        % determination of magnitude of completeness
        if time < 7
            fMc = mcwithtime(a,time_as,time);
        else
            fMc = fMc0;
        end

        % estimation of Omori parameters
        l = time_as <= time & a.Magnitude >= fMc;
        [pval, pvalstd, cval, cvalstd, kval, kvalstd, loopout] = bruteboot(time_as(l));

        if isnan(pval) == 0
            nummod = step; % forecasted number of aftershocks
            if pval == 1
                pv = 1-10^(-6);
            else
                pv = pval;
            end

            t_forecast = (-nummod*(pv-1)/kval+(time+cval)^(1-pv))^(1/(1-pv))-cval; % forecast interval
            if isreal(t_forecast) == 1  &&  t_forecast > time
                if t_forecast > max(time_as)
                    return
                end

                l = time_as <= t_forecast & a.Magnitude >= fMc & time_as >= time;
                numreal = sum(l); % observed number of aftershocks
                absdiff = numreal-nummod;

                % calculate uncertainty sigma in forecasted number of aftershocks
                time1 = t_forecast; mpm1 = 1-pv; t1c = time1+cval; t0c = time+cval;
                sigma = (((-t1c^mpm1+t0c^mpm1)/(pv-1)*kvalstd)^2+...
                    (kval/(pv-1)*(-t1c^mpm1*mpm1/t1c+t0c^mpm1*mpm1/t0c)*cvalstd)^2+...
                    (kval/(pv-1)*(t1c^mpm1*log(t1c)+t1c^mpm1/(pv-1)-t0c^mpm1*log(t0c)-t0c^mpm1/(pv-1))*pvalstd)^2)^0.5;

                rc = [rc; time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd t_forecast fMc];
            end
        end
        time = time+timestep;
    end
