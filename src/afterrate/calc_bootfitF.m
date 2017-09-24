function [output] = calc_bootfitF(mycat,time,timef,bootloops,maepi)
    % calc_bootfitF Plots Ncum observed vs. Ncum modeled for specified time windows
    %
    % [output] = calc_bootfitF(mycat,time,timef,bootloops,maepi);
    %
    % Input variables:
    % mycat     : earthquake catalog
    % time      : learning period fo fit Omori parameters
    % timef     : forecast period
    % bootloops : Number of bootstraps
    % ZG.maepi     : mainshock
    % Output variables:
    % output    : [pval pstd cval cstd kval kstd sigma fStdBst fRc_Flaw fRc_Bst]

    % S.Neukomm / S.Wiemer / J.Woessner

    % Surpress warnings from fmincon
    % warning off;
    report_this_filefun(mfilename('fullpath'));

    date_matlab = datenum(mycat.Date);
    date_main = datenum(ZG.maepi.Date);
    time_aftershock = date_matlab-date_main;

    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = mycat.subset(l);

    l = tas <= time;
    time_as=tas(l);


    % Calculate uncertainties and mean values of p,c,and k
    [pval, pstd, cval, cstd, kval, kstd, loopout] = brutebootloglike(tas(l),bootloops);
    % Calculate p,c,k for real dataset
    [pval, cval, kval] = bruteforceloglike(sort(time_as));
    pval = round(100*pval)/100;
    cval = round(100*cval)/100;
    kval = round(10*kval)/10;

    if isnan(pval) == 0

        figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Forecast aftershock occurence')
        loopout = [loopout , loopout(:,1)*0];

        % Times up to the forecast time
        lf = tas <= time+timef ;
        time_asf= [tas(lf) ];
        time_asf=sort(time_asf);

        % Compute the confidence limits
        for j = 1:length(loopout(:,1))

            cumnr = (1:length(time_asf))'; cumnr_model = [];
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
            plot(time_asf,cumnr_model,'color',[0.8 0.8 0.8]);
            loopout(j,4) = max(cumnr_model);
            hold on
            %drawnow
        end
        % 2nd moment of bootstrap number of forecasted number of events
        fStdBst = calc_StdDev(loopout(:,4));

        % now plot the forecast ...
        cumnrf = (1:length(time_asf))'; cumnr_modelf = [];
        for i=1:length(time_asf)
            if pval ~= 1
                cm = kval/(pval-1)*(cval^(1-pval)-(time_asf(i)+cval)^(1-pval));
            else
                cm = kval*log(time_asf(i)/cval+1);
            end
            cumnr_modelf = [cumnr_modelf; cm];
        end
        pf1 =  plot(time_asf,cumnr_modelf,'g-.','Linewidth',2);
        hold on
        pf2 =  plot(time_asf,cumnrf, 'b-','Linewidth',2);

        % plot the best fit
        cumnr = (1:length(time_as))'; cumnr_model = [];
        for i=1:length(time_as)
            if pval ~= 1
                cm = kval/(pval-1)*(cval^(1-pval)-(time_as(i)+cval)^(1-pval));
            else
                cm = kval*log(time_as(i)/cval+1);
            end
            cumnr_model = [cumnr_model; cm];
        end
        time_as=sort(time_as);
        cumnr_model=sort(cumnr_model);
        p1 = plot(time_as,cumnr_model,'r','Linewidth',2);
        hold on

        p2 = plot(time_as,cumnr,'b','Linewidth',2);

        % Plot observed events in forecast period from endpoint of modeled events in learning period
        vSel = time_asf >= max(time_as);
        vCumnr_forecast = cumnrf(vSel,:);
        vTime_forecast = time_asf(vSel,:);
        % Difference of modelled and observed number of events at time_as
        fDiff_timeas = cumnr_modelf(length(time_as))-cumnrf(length(time_as));
        vCumnr_forecast = vCumnr_forecast+fDiff_timeas;
        pf3 = plot(vTime_forecast, vCumnr_forecast,'m-.','Linewidth',2);


        %     [Y, in] = sort(loopout(:,4));
        %     %n5Conf = round(0.05*length(loopout))
        %     %Y = find(in == n5Conf);
        %     %Y = find(in == 5);
        %     loops = loopout(in,:);
        %     n5Conf = floor(min((find(round(loops(:,4))==round(prctile(loops(:,4),5))))));
        %     %n5Conf = round(0.05*length(loops));
        %     pvalb = loops(n5Conf,1);
        %     cvalb = loops(n5Conf,2);
        %     kvalb = loops(n5Conf,3);
        %
        %     cumnr = (1:length(time_as))'; cumnr_model = [];
        %     for i=1:length(time_as)
        %         if pval ~= 1
        %             cm = kvalb/(pvalb-1)*(cvalb^(1-pvalb)-(time_as(i)+cvalb)^(1-pvalb));
        %         else
        %             cm = kvalb*log(time_as(i)/cvalb+1);
        %         end
        %         cumnr_model = [cumnr_model; cm];
        %     end
        %
        %     %plot(time_as,cumnr_model,'k--','Linewidth',1);
        %
        %     %n95Conf = round(0.95*length(loopout));
        %     %Y = find(in == n95Conf);
        %     %loops = loopout(in,:);
        %     n95Conf = ceil(max(find(round(loops(:,4))==round(prctile(loops(:,4),95)))));
        %     %n95Conf = round(0.95*length(loops));
        %     pvalb = loops(n95Conf,1);
        %     cvalb = loops(n95Conf,2);
        %     kvalb = loops(n95Conf,3);
        %     cumnr = (1:length(time_as))'; cumnr_model = [];
        %     for i=1:length(time_as)
        %         if pval ~= 1
        %             cm = kvalb/(pvalb-1)*(cvalb^(1-pvalb)-(time_as(i)+cvalb)^(1-pvalb));
        %         else
        %             cm = kvalb*log(time_as(i)/cvalb+1);
        %         end
        %         cumnr_model = [cumnr_model; cm];
        %     end
        %     %pc = plot(time_as,cumnr_model,'k--','Linewidth',1);

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
        nummod = max(cumnr_modelf)-cumnr_modelf(length(time_as));
        % Find amount of  events in forecast period for observed data
        l = time_asf <=time+timef & time_asf > time;
        numreal = sum(l); % observed number of aftershocks
        fRc_Flaw = (numreal-nummod)/sigma;
        fRc_Bst = (numreal-nummod)/fStdBst;
        pstdstring = num2str(round(100*pstd)/100);
        cstdstring = num2str(round(100*cstd)/100);
        kstdstring = num2str(round(10*kstd)/10);
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
        plot([max(time_as) max(time_as)],[0 yy(2)],'k-.')
    else
        disp('no result')
    end

    output = [pval pstd cval cstd kval kstd sigma fStdBst fRc_Flaw fRc_Bst];

