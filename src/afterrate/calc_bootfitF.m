function [output] = calc_bootfitF(catTimes,time,timef,bootloops,mainshockTime)
    % calc_bootfitF Plots Ncum observed vs. Ncum modeled for specified time windows
    %
    % [output] = calc_bootfitF(catTimes,time,timef,bootloops,maepi);
    %
    % Input variables:
    % catTimes     : earthquake catalog times  [datetime vector]
    % time      : learning period fo fit Omori parameters [duration or days]
    % timef     : forecast period [duration or days]
    % bootloops : Number of bootstraps
    % mainshockTime : mainshock time [datetime]
    % Output variables:
    % output    : [pval pstd cval cstd kval kstd sigma fStdBst fRc_Flaw fRc_Bst]
    %
    % S.Neukomm / S.Wiemer / J.Woessner

    % Surpress warnings from fmincon
    % warning off;
    report_this_filefun(mfilename('fullpath'));
    asset(mainshockTime.Count == 1, 'Expected a single aftershock, not %d events', mainshockTime.Count);
    if ~isduration(timef), timef=days(timef);end
    if ~isduration(time), time=days(time);end
    timeAfterShock = catTimes - mainshockTime;
    timeAfterShock = sort(timeAfterShock); % all following times will be sorted
    
    isAfter = catTimes > mainshockTime;
    tas = timeAfterShock(isAfter);
    duringLearnPeriod = tas <= time;
    learningEventTimes=tas(duringLearnPeriod);


    % Calculate uncertainties and mean values of p,c,and k
    [pval, pstd, cval, cstd, kval, kstd, loopout] = brutebootloglike(learningEventTimes,bootloops);
    
    % Calculate p,c,k for real dataset
    [pval, cval, kval] = bruteforceloglike(learningEventTimes);
    pval = round(pval,2);
    cval = round(cval,2);
    kval = round(kval,1);

    if ~isnan(pval)

        figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Forecast aftershock occurence')
        % Times up to the forecast time
        time_asf= tas(tas <= time+timef);
        time_asf=time_asf;

        %% vectorized version. asssumes everything in columns
        pvalb = loopout.pval;
        cvalb = loopout.cval;
        kvalb = loopout.kval;
        tic
        
        %% define the functions that will be used in all the following loops
        modfun=get_confidence_function(pval);
        
        conf_lims = modfun(pvalb,cvalb,kvalb,time_asf);
        loopout.maxes=max(conf_lims,[],2);
        
        plot(time_asf, conf_lims, 'color',[0.8 0.8 0.8]);
        hold on
        toc
        %{
        %% old double-loop version, to be replaced
        % Compute the confidence limits
        tic
        for j = 1:size(loopout,1) % loop through each row
            cumnr_model = [];
            pvalb = loopout(j,1);
            cvalb = loopout(j,2);
            kvalb = loopout(j,3);
            
            for i=1:length(time_asf)
                cm=modfun(pvalb,cvalb,kvalb,time_asf);
                cumnr_model = [cumnr_model; cm];
            end
            plot(time_asf,cumnr_model,'color',[0.8 0.8 0.8]);
            loopout(j,4) = max(cumnr_model);
            hold on
            %drawnow
        end
        toc
        %% temp test.  Remove and then comment out the above loops once it is shown to work!
        assert(isequal(loopout(:,4),conf_lims));
        % end temp test.
        %}
        
        %% done with the above replacemtns
        % 2nd moment of bootstrap number of forecasted number of events
        fStdBst = calc_StdDev(loopout.maxes);

        % now calculate the forecast ...        
        %% this is the vectorized version ...
        
        cumnr_modelf = modfun(pval,cval,kval,time_asf);
        
        %% which replaces this...
        cumnrf = (1:length(time_asf))'; 
        cumnr_modelf = [];
        for i=1:length(time_asf)
            cm = modfun(pval,cval,kval,time_asf(i));
            cumnr_modelf = [cumnr_modelf; cm];
        end
        
        %%
        % plot the best fit
        nLearnEvents = length(learningEventTimes);
        
        %% this can be vectorized
        cumnr_model = modfun(pval,cval,kval,learningEventTimes);
        %{
        cumnr_model = [];
        for i=1:nLearnEvents
            cm = modfun(pval,cval,kval,learningEventTimes(i));  % note this is NOT time_asf
            cumnr_model = [cumnr_model; cm];
        end
        %}
        cumnr_model=sort(cumnr_model);

        % to Plot observed events in forecast period from endpoint of modeled events in learning period
        isAfterLearning = time_asf >= max(learningEventTimes);
        vCumnr_forecast = cumnrf(isAfterLearning,:);
        vTime_forecast = time_asf(isAfterLearning,:);
        
        % Difference of modelled and observed number of events at learningEventTimes
        fDiff_timeas = cumnr_modelf(nLearnEvents)-cumnrf(nLearnEvents);
        vCumnr_forecast = vCumnr_forecast + fDiff_timeas;
        
        %% plot stuff
        
        pf1 =  plot(time_asf, cumnr_modelf,'g-.','Linewidth',2);
        hold on
        pf2 =  plot(time_asf, cumnrf, 'b-','Linewidth',2);

        
        p1 = plot(learningEventTimes,cumnr_model,'r','Linewidth',2);
        hold on

        p2 = plot(learningEventTimes, 1:nLearnEvents ,'b','Linewidth',2);
        
        pf3 = plot(vTime_forecast, vCumnr_forecast ,'m-.','Linewidth',2);

        xlabel('Time [days]')
        ylabel('Cumulative number of aftershocks')
        xlim([0 max(time_asf)]);


        % calculate uncertainty sigma in forecasted number of aftershocks by
        % error propagation law
        time1 = time+timef;
        if pval == 1
            pv = 1-10^(-6);
        else
            pv = pval;
        end
        mpm1 = 1-pv;
        t1c = time1+cval;
        t0c = time+cval;
        sigma = (((-t1c^mpm1+t0c^mpm1)/(pv-1)*kstd)^2+...
            (kval/(pv-1)*(-t1c^mpm1*mpm1/t1c+t0c^mpm1*mpm1/t0c)*cstd)^2+...
            (kval/(pv-1)*(t1c^mpm1*log(t1c)+t1c^mpm1/(pv-1)-t0c^mpm1*log(t0c)-t0c^mpm1/(pv-1))*pstd)^2)^0.5;
        % Plot standard deviation error propagation law
        ps1=errorbar(max(time_asf),max(cumnr_modelf),sigma,sigma);
        set(ps1,'Linewidth',4,'Color',[0 1 0])
        % Plot standard deviation from bootstrap
        ps2=errorbar(max(time_asf),max(cumnr_modelf),fStdBst,fStdBst);
        set(ps2,'Linewidth',2,'Color',[1 0 0])

        legend([p2 p1 pf1 pf3 min(ps1) min(ps2)],'data','model','forecast','observed','\sigma (Epl)','\sigma (Bst)','location','Best')

        % Title
        % Rate change from error propagation law
        % Find amount of events in forecast period for modeled data
        nummod = max(cumnr_modelf)-cumnr_modelf(nLearnEvents);
        % Find amount of  events in forecast period for observed data
        l = time_asf <=time+timef & time_asf > time;
        numreal = sum(l); % observed number of aftershocks
        fRc_Flaw = (numreal-nummod)/sigma;
        fRc_Bst = (numreal-nummod)/fStdBst;
        pstdstring = num2str(round(pstd,2));
        cstdstring = num2str(round(cstd,2));
        kstdstring = num2str(round(kstd,1));
        string=['p = ' num2str(pval) '+-' pstdstring '; c = ' num2str(cval) '+-' cstdstring '; k = ' num2str(kval) '+-' kstdstring];
        title(string)
        yy = get(gca,'ylim');
        xx = get(gca,'xlim');
        string=['\sigma(Epl) = ' num2str(sigma,3) '; \sigma(Bst) = ' num2str(fStdBst,3)];
        text(xx(2)/10,yy(2)/8,string)
        string=['Rc(Epl) = ' num2str(fRc_Flaw,3) '; Rc(Bst) = ' num2str(fRc_Bst,3)];
        text(xx(2)/10,yy(2)/16,string)
        % Set line for learning period
        yy = get(gca,'ylim');
        plot([max(learningEventTimes) max(learningEventTimes)],[0 yy(2)],'k-.')
    else
        disp('no result')
    end

    output = [pval pstd cval cstd kval kstd sigma fStdBst fRc_Flaw fRc_Bst];

