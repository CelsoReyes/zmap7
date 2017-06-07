function calc_bootfitrms_a2(a,time,timef,bootloops,maepi)
    % function calc_bootfitrms_a2(a,time,timef,bootloops,maepi);
    % --------------------------------------------------
    % Plots Ncum observed vs. Ncum modeled for specified time windows
    %
    % Input variables:
    % a         : earthquake catalog
    % time      : learning period fo fit Omori parameters
    % timef     : forecast period
    % bootloops : Number of bootstraps
    % maepi     : mainshock

    % S.Neukomm/ S.Wiemer / J.Woessner
    % last update: 04.08.03

report_this_filefun(mfilename('fullpath'));
    % Surpress warnings from fmincon
    warning off;

    %[m_main, main] = max(a(:,6));
    date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),zeros(size(a,1),1));
    date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),0);
    time_aftershock = date_matlab-date_main;

    % Select biggest aftershock earliest in time, but more than 1 day after mainshock
    fDay = 1;
    ft_c=fDay/365; % Time not considered to find biggest aftershock
    vSel = (a(:,3) > maepi(:,3)+ft_c & a(:,3)<= maepi(:,3)+time/365);
    mCat = a(vSel,:);
    vSel = mCat(:,6) == max(mCat(:,6));
    vBigAf = mCat(vSel,:)
    if length(mCat(:,1)) > 1
        vSel = vBigAf(:,3) == min(vBigAf(:,3));
        vBigAf = vBigAf(vSel,:);
    end

    date_biga = datenum(floor(vBigAf(3)),vBigAf(4),vBigAf(5),vBigAf(8),vBigAf(9),0);
    fT1 = date_biga - date_main; % Time of big aftershock

    % Aftershock times
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = a(l,:);

    l = tas <= time;
    time_as=tas(l);

    % Calculate uncertainty and mean values of p,c,and k
    %[pval, pstd, cval, cstd, kval, kstd, loopout] = brutebootloglike_a2(tas(l),bootloops,fT1)
    % Calculate p,c,k for dataset
    nMod = 1;
    %nMod = 2
    if nMod == 1

        [pval1, pval2, cval1, cval2, kval1, kval2] = bruteforcerms_a2(time_as,fT1,nMod)

        pval1 = round(100*pval1)/100;
        cval1 = round(100*cval1)/100;
        kval1 = round(10*kval1)/10;
        kval2 = round(10*kval2)/10;

    else
        [pval1, pval2, cval1, cval2, kval1, kval2] = bruteforcerms_a2(time_as,fT1,nMod)
        pval1 = round(100*pval1)/100;
        pval2 = round(100*pval2)/100;
        cval1 = round(100*cval1)/100;
        cval2 = round(100*cval2)/100;
        kval1 = round(10*kval1)/10;
        kval2 = round(10*kval2)/10;
    end

    if (isnan(pval1) == 0 & isnan(pval2) == 0)

        figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Forecast aftershock occurence')
        %     pval1 = 0.9;
        %     pval2 = 0.9;
        %     cval1 = 0.2;
        %     cval2 = 0.2;
        %     kval1 = 1000;
        %     kval2 = 2000;
        %loopout = [loopout , loopout(:,1)*0];

        %     % Times up to the forecast time
        %     lf = tas <= time+timef ;
        %     time_asf= [tas(lf) ];
        %     time_asf=sort(time_asf);
        %

        %
        %     % Compute the confidence limits
        %     for j = 1:length(loopout(:,1));
        %
        %         cumnr = (1:length(time_asf))'; cumnr_model = [];
        %         pvalb = loopout(j,1);
        %         cvalb = loopout(j,2);
        %         kvalb = loopout(j,3);
        %         for i=1:length(time_asf)
        %             if pval ~= 1
        %                 cm = kvalb/(pvalb-1)*(cvalb^(1-pvalb)-(time_asf(i)+cvalb)^(1-pvalb));
        %             else
        %                 cm = kvalb*log(time_asf(i)/cvalb+1);
        %             end
        %             cumnr_model = [cumnr_model; cm];
        %         end
        %         plot(time_asf,cumnr_model,'color',[0.8 0.8 0.8]);
        %         loopout(j,4) = max(cumnr_model);
        %         hold on
        %         %drawnow
        %     end
        %     % 2nd moment of bootstrap number of forecasted number of events
        %     fStdBst = calc_StdDev(loopout(:,4));
        %
        %     % now plot the forecast ...
        %     cumnrf = (1:length(time_asf))'; cumnr_modelf = [];
        %     for i=1:length(time_asf)
        %         if pval ~= 1
        %             cm = kval/(pval-1)*(cval^(1-pval)-(time_asf(i)+cval)^(1-pval));
        %         else
        %             cm = kval*log(time_asf(i)/cval+1);
        %         end
        %         cumnr_modelf = [cumnr_modelf; cm];
        %     end
        %     pf1 =  plot(time_asf,cumnr_modelf,'g-.','Linewidth',2);
        %     hold on
        %     pf2 =  plot(time_asf,cumnrf, 'b-','Linewidth',2);
        %
        % plot the best fit
        % Cumulative number of pbserved events
        cumnr = (1:length(tas))';
        cumnr_model = [];

        for i=1:length(tas)
            if tas(i) <= fT1
                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(tas(i)+cval1)^(1-pval1));
                else
                    cm = kval1*log(tas(i)/cval1+1);
                end
                cumnr_model = [cumnr_model; cm];
            else
                if (pval1 ~= 1 & pval2 ~= 1)
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(tas(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(tas(i)-fT1+cval2)^(1-pval2));
                else
                    cm = kval1*log(tas(i)/cval1+1) + kval2*log((tas(i)-fT1)/cval2+1);
                end
                cumnr_model = [cumnr_model; cm];
            end
        end
        tas=sort(tas);
        cumnr_model=sort(cumnr_model);
        p1 = plot(tas,cumnr_model,'r','Linewidth',2);
        hold on

        p2 = plot(tas,cumnr,'b','Linewidth',2,'Linestyle','--');
        %     string=['p = ' num2str(pval) '+-' num2str(pstd) '; c = ' num2str(cval) '+-' num2str(cstd) '; k = ' num2str(kval) '+-' num2str(kstd)];
        %     title(string)
        %
        %     % Plot observed events in forecast period from endpoint of modeled events in learning period
        %     vSel = time_asf >= max(time_as);
        %     vCumnr_forecast = cumnrf(vSel,:);
        %     vTime_forecast = time_asf(vSel,:);
        %     % Difference of modelled and observed number of events at time_as
        %     fDiff_timeas = cumnr_modelf(length(time_as))-cumnrf(length(time_as));
        %     vCumnr_forecast = vCumnr_forecast+fDiff_timeas;
        %     pf3 = plot(vTime_forecast, vCumnr_forecast,'m-.','Linewidth',2);
        %
        %
        % %     [Y, in] = sort(loopout(:,4));
        % %     %n5Conf = round(0.05*length(loopout))
        % %     %Y = find(in == n5Conf);
        % %     %Y = find(in == 5);
        % %     loops = loopout(in,:);
        % %     n5Conf = floor(min((find(round(loops(:,4))==round(prctile(loops(:,4),5))))));
        % %     %n5Conf = round(0.05*length(loops));
        % %     pvalb = loops(n5Conf,1);
        % %     cvalb = loops(n5Conf,2);
        % %     kvalb = loops(n5Conf,3);
        % %
        % %     cumnr = (1:length(time_as))'; cumnr_model = [];
        % %     for i=1:length(time_as)
        % %         if pval ~= 1
        % %             cm = kvalb/(pvalb-1)*(cvalb^(1-pvalb)-(time_as(i)+cvalb)^(1-pvalb));
        % %         else
        % %             cm = kvalb*log(time_as(i)/cvalb+1);
        % %         end
        % %         cumnr_model = [cumnr_model; cm];
        % %     end
        % %
        % %     %plot(time_as,cumnr_model,'k--','Linewidth',1);
        % %
        % %     %n95Conf = round(0.95*length(loopout));
        % %     %Y = find(in == n95Conf);
        % %     %loops = loopout(in,:);
        % %     n95Conf = ceil(max(find(round(loops(:,4))==round(prctile(loops(:,4),95)))));
        % %     %n95Conf = round(0.95*length(loops));
        % %     pvalb = loops(n95Conf,1);
        % %     cvalb = loops(n95Conf,2);
        % %     kvalb = loops(n95Conf,3);
        % %     cumnr = (1:length(time_as))'; cumnr_model = [];
        % %     for i=1:length(time_as)
        % %         if pval ~= 1
        % %             cm = kvalb/(pvalb-1)*(cvalb^(1-pvalb)-(time_as(i)+cvalb)^(1-pvalb));
        % %         else
        % %             cm = kvalb*log(time_as(i)/cvalb+1);
        % %         end
        % %         cumnr_model = [cumnr_model; cm];
        % %     end
        % %     %pc = plot(time_as,cumnr_model,'k--','Linewidth',1);
        %
        %     xlabel('Time [days]')
        %     ylabel('Cumulative number of aftershocks')
        %     xlim([0 max(time_asf)]);
        %
        %
        %     % calculate uncertainty sigma in forecasted number of aftershocks by
        %     % error propagation law
        %     time1 = time+timef;
        %     if pval == 1
        %         pv = 1-10^(-6);
        %     else
        %         pv = pval;
        %     end
        %     mpm1 = 1-pv;
        %     t1c = time1+cval;
        %     t0c = time+cval;
        %     sigma = (((-t1c^mpm1+t0c^mpm1)/(pv-1)*kstd)^2+...
        %         (kval/(pv-1)*(-t1c^mpm1*mpm1/t1c+t0c^mpm1*mpm1/t0c)*cstd)^2+...
        %         (kval/(pv-1)*(t1c^mpm1*log(t1c)+t1c^mpm1/(pv-1)-t0c^mpm1*log(t0c)-t0c^mpm1/(pv-1))*pstd)^2)^0.5;
        %     % Plot standard deviation error propagation law
        %     ps1=errorbar(max(time_asf),max(cumnr_modelf),sigma,sigma);
        %     set(ps1,'Linewidth',4,'Color',[0 1 0])
        %     % Plot standard deviation from bootstrap
        %     ps2=errorbar(max(time_asf),max(cumnr_modelf),fStdBst,fStdBst);
        %     set(ps2,'Linewidth',2,'Color',[1 0 0])
        %
        %     legend([p2 p1 pf1 pf3 min(ps1) min(ps2)],'data','model','forecast','observed','\sigma (Epl)','\sigma (Bst)',0)
        %
        %     % Title
        %     % Rate change from error propagation law
        %     % Find amount of events in forecast period for modeled data
        %     nummod = max(cumnr_modelf)-cumnr_modelf(length(time_as));
        %     % Find amount of  events in forecast period for observed data
        %     l = time_asf <=time+timef & time_asf > time;
        %     numreal = sum(l); % observed number of aftershocks
        %     fRc_Flaw = (numreal-nummod)/sigma;
        %     fRc_Bst = (numreal-nummod)/fStdBst;
        %     string=['p = ' num2str(pval) '+-' num2str(pstd) '; c = ' num2str(cval) '+-' num2str(cstd) '; k = ' num2str(kval) '+-' num2str(kstd)];
        %     title(string)
        %     string=['\sigma(Epl) = ' num2str(sigma) '; \sigma(Bst) = ' num2str(fStdBst)];
        %     text(0.25,100,string)
        %     % Set line for learning period
        %     yy = get(gca,'ylim');
        %     plot([max(time_as) max(time_as)],[0 yy(2)],'k-.')
    else
        disp('no result')
    end
