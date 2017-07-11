function plot_bootfitloglike_a2(a,time,timef,bootloops,maepi)
    % function plot_bootfitloglike_a2(a,time,timef,bootloops,maepi);
    % --------------------------------------------------
    % Plots Ncum observed vs. Ncum modeled for specified time windows
    % with choosing the model for the learning period
    % Input variables:
    % a         : earthquake catalog
    % time      : learning period fo fit Omori parameters
    % timef     : forecast period
    % bootloops : Number of bootstraps
    % maepi     : mainshock
    %
    % J.Woessner, S. Wiemer
    % last update: 05.08.03

report_this_filefun(mfilename('fullpath'));
    % Surpress warnings from fmincon
    warning off;

    %[m_main, main] = max(ZG.a.Magnitude);
    date_matlab = datenum(ZG.a.Date.Year,ZG.a.Date.Month,ZG.a.Date.Day,ZG.a.Date.Hour,ZG.a.Date.Minute,zeros(size(a,1),1));
    date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),0);
    time_aftershock = date_matlab-date_main;
    % Select biggest aftershock earliest in time, but more than 1 day after mainshock
    fDay = 1;
    ft_c=fDay/365; % Time not considered to find biggest aftershock
    vSel = (ZG.a.Date > maepi(:,3)+ft_c & ZG.a.Date<= maepi(:,3)+time/365);
    mCat = ZG.a.subset(vSel);
    vSel = mCat(:,6) == max(mCat(:,6));
    vBigAf = mCat(vSel,:);
    if length(mCat(:,1)) > 1
        vSel = vBigAf(:,3) == min(vBigAf(:,3));
        vBigAf = vBigAf(vSel,:);
    end

    date_biga = datenum(floor(vBigAf(3)),vBigAf(4),vBigAf(5),vBigAf(8),vBigAf(9),0);
    fT1 = date_biga - date_main; % Time of big aftershock


    % Aftershock times
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = ZG.a.subset(l);

    % time_as: Learning period
    l = tas <= time;
    time_as=tas(l);

    % Times up to the forecast time
    lf = tas <= time+timef ;
    time_asf= [tas(lf) ];
    time_asf=sort(time_asf);

    % % Calculate p,c,k for dataset
    % prompt  = {'Enter model number (1:pck, 2:pckk, 3:ppckk, 4:ppcckk:'};
    % title   = 'Model selection for fitting aftershock sequence';
    % lines= 1;
    % def     = {'1'};
    % answer  = inputdlg(prompt,title,lines,def);
    % nMod = str2double(answer{1});
    % Calculate fits of different models
    mRes = [];
    % Modified Omori law (pck)
    nMod = 1; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    % MOL with secondary aftershock (pckk)
    nMod = 2; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    % MOL with secondary aftershock (ppckk)
    nMod = 3; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    % MOL with secondary aftershock (ppcckk)
    nMod = 4; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];

    % Select best fitting model by AIC
    vSel = (mRes(:,8)==min(mRes(:,8)));
    mRes = mRes(vSel,:);
    if length(mRes(:,1)) > 1
        vSel = (mRes(:,1)==min(mRes(:,1)));
        mRes = mRes(vSel,:);
    end
    % Model to use for bootstrapping as of lowest AIC to observed data
    nMod = mRes(1,1);
    pval1= mRes(1,2); pval2= mRes(1,3);
    cval1= mRes(1,4); cval2= mRes(1,5);
    kval1= mRes(1,6); kval2= mRes(1,7);

    % Calculate goodness of fit with KS-Test and RMS
    [H,P,KSSTAT,fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod);

    % Calculate uncertainty and mean values of p,c,and k
    [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1,nMod);
    pmed1 = mMedModF(1,1);
    pmed2 = mMedModF(1,3);
    cmed1 = mMedModF(1,5);
    cmed2 = mMedModF(1,7);
    kmed1 = mMedModF(1,9);
    kmed2 = mMedModF(1,11);


    % % Compute model according to model choice
    % if nMod == 1
    %     [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    % elseif nMod == 2
    %     [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    % elseif nMod == 3
    %     [pval1, pval2, cval1, cval2, kval1, kval2 , fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    % else
    %     [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    % end

    % Start plotting
    if (isnan(pval1) == 0 & isnan(pval2) == 0)

        figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Forecast aftershock occurence')
        loopout = [loopout , loopout(:,1)*0];

        % Time until end of forecast
        for j = 1:length(loopout(:,1))
            cumnr = (1:length(time_asf))';
            cumnr_model = [];
            pval1 = loopout(j,1);
            pval2 = loopout(j,2);
            cval1 = loopout(j,3);
            cval2 = loopout(j,4);
            kval1 = loopout(j,5);
            kval2 = loopout(j,6);
            if nMod == 1
                for i=1:length(time_asf)
                    if pval1 ~= 1
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                    else
                        cm = kval1*log(time_asf(i)/cval1+1);
                    end
                    cumnr_model = [cumnr_model; cm];
                end % END of FOR on length(time_asf)
                loopout(j,9) = max(cumnr_model);
            else
                for i=1:length(time_asf)
                    if time_asf(i) <= fT1
                        if pval1 ~= 1
                            cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                        else
                            cm = kval1*log(time_asf(i)/cval1+1);
                        end
                        cumnr_model = [cumnr_model; cm];
                    else
                        if (pval1 ~= 1 & pval2 ~= 1)
                            cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_asf(i)-fT1+cval2)^(1-pval2));
                        else
                            cm = kval1*log(time_asf(i)/cval1+1) + kval2*log((time_asf(i)-fT1)/cval2+1);
                        end
                        cumnr_model = [cumnr_model; cm];
                    end %END of IF on fT1
                end % End of FOR length(time_asf)
                loopout(j,9) = max(cumnr_model);
            end % End of if on nMod
            pfloop = plot(time_asf,cumnr_model,'color',[0.8 0.8 0.8]);
            hold on
            %drawnow
        end
        % 2nd moment of bootstrap number of forecasted number of events
        fStdBst = calc_StdDev(loopout(:,9));
        %
        % Plot the forecast ...
        cumnrf = (1:length(time_asf))';
        cumnr_modelf = [];
        if nMod == 1
            for i=1:length(time_asf)
                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                else
                    cm = kval1*log(time_asf(i)/cval1+1);
                end
                cumnr_modelf = [cumnr_modelf; cm];
            end % END of FOR on length(time_asf)
        else
            for i=1:length(time_asf)
                if time_asf(i) <= fT1
                    if pval1 ~= 1
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                    else
                        cm = kval1*log(time_asf(i)/cval1+1);
                    end
                    cumnr_modelf = [cumnr_modelf; cm];
                else
                    if (pval1 ~= 1 & pval2 ~= 1)
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_asf(i)-fT1+cval2)^(1-pval2));
                    else
                        cm = kval1*log(time_asf(i)/cval1+1) + kval2*log((time_asf(i)-fT1)/cval2+1);
                    end
                    cumnr_modelf = [cumnr_modelf; cm];
                end %END of IF on fT1
            end % End of FOR length(time_asf)
        end % End of if on nMod
        time_asf=sort(time_asf);
        cumnr_modelf=sort(cumnr_modelf);

        pf1 =  plot(time_asf,cumnr_modelf,'g-.','Linewidth',2);
        hold on
        %pf2 =  plot(time_asf,cumnrf, 'b-','Linewidth',2);
        %
        % Plot the  fit to the observed data
        % Cumulative number of observed events
        cumnr = (1:length(time_as))';
        cumnr_model = [];
        if nMod == 1
            for i=1:length(time_as)
                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1));
                else
                    cm = kval1*log(time_as(i)/cval1+1);
                end
                cumnr_model = [cumnr_model; cm];
            end % END of FOR on length(time_as)
        else
            for i=1:length(time_as)
                if time_as(i) <= fT1
                    if pval1 ~= 1
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1));
                    else
                        cm = kval1*log(time_as(i)/cval1+1);
                    end
                    cumnr_model = [cumnr_model; cm];
                else
                    if (pval1 ~= 1 & pval2 ~= 1)
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_as(i)-fT1+cval2)^(1-pval2));
                    elseif (pval1 ~= 1  &&  pval2 == 1)
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1))+ kval2*log((time_as(i)-fT1)/cval2+1);
                    elseif (pval1 == 1  &&  pval2 ~= 1)
                        cm = kval1*log(time_as(i)/cval1+1) + + kval2/(pval2-1)*(cval2^(1-pval2)-(time_as(i)-fT1+cval2)^(1-pval2));
                    else
                        cm = kval1*log(time_as(i)/cval1+1) + kval2*log((time_as(i)-fT1)/cval2+1);
                    end
                    cumnr_model = [cumnr_model; cm];
                end %END of IF on fT1
            end % End of FOR length(time_as)
        end % End of if on nMod
        time_as=sort(time_as);
        cumnr_model=sort(cumnr_model);
        p1 = plot(time_as,cumnr_model,'r','Linewidth',2,'Linestyle','--');
        hold on;
        p2 = plot(time_as,cumnr,'b','Linewidth',2,'Linestyle','--');

        % Plot the forecast from median value
        cumnr_modelmed = [];
        if nMod == 1
            for i=1:length(time_asf)
                if pval1 ~= 1
                    cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1));
                else
                    cm = kmed1*log(time_asf(i)/cmed1+1);
                end
                cumnr_modelmed = [cumnr_modelmed; cm];
            end % END of FOR on length(time_asf)
        else
            for i=1:length(time_asf)
                if time_asf(i) <= fT1
                    if pmed1 ~= 1
                        cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1));
                    else
                        cm = kmed1*log(time_asf(i)/cmed1+1);
                    end
                    cumnr_modelmed = [cumnr_modelmed; cm];
                else
                    if (pmed1 ~= 1 & pmed2 ~= 1)
                        cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1))+ kmed2/(pmed2-1)*(cmed2^(1-pmed2)-(time_asf(i)-fT1+cmed2)^(1-pmed2));
                    elseif (pmed1 ~= 1  &&  pmed2 == 1)
                        cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1))+ kmed2*log((time_asf(i)-fT1)/cmed2+1);
                    elseif (pmed1 == 1  &&  pmed2 ~= 1)
                        cm = kmed1*log(time_asf(i)/cmed1+1) + kmed2/(pmed2-1)*(cmed2^(1-pmed2)-(time_asf(i)-fT1+cmed2)^(1-pmed2));
                    else
                        cm = kmed1*log(time_asf(i)/cmed1+1) + kmed2*log((time_asf(i)-fT1)/cmed2+1);
                    end
                    cumnr_modelmed = [cumnr_modelmed; cm];
                end %END of IF on fT1
            end % End of FOR length(time_asf)
        end % End of if on nMod
        time_asf=sort(time_asf);
        cumnr_modelmed=sort(cumnr_modelmed);
        pmedmod =  plot(time_asf,cumnr_modelmed,'y-.','Linewidth',2);

        % Plot observed events in forecast period from endpoint of modeled events in learning period
        vSel = time_asf >= max(time_as);
        vCumnr_forecast = cumnrf(vSel,:);
        vTime_forecast = time_asf(vSel,:);
        % Difference of modelled and observed number of events at time_as
        fDiff_timeas = cumnr_modelmed(length(time_as))-cumnrf(length(time_as));
        vCumnr_forecast = vCumnr_forecast+fDiff_timeas;
        pf3 = plot(vTime_forecast, vCumnr_forecast,'m-.','Linewidth',2);

        xlabel('Time [days]')
        ylabel('Cumulative number of aftershocks')
        xlim([0 max(time_asf)]);

        % Plot standard deviation from bootstrap
        ps2=errorbar(max(time_asf),max(cumnr_modelmed),fStdBst,fStdBst);
        set(ps2,'Linewidth',2,'Color',[1 0 0])
        %
        %     % Title
        % Find amount of events in forecast period for modeled data
        nummod2 = max(cumnr_modelf)-cumnr_modelf(length(time_as));
        nummod = max(cumnr_modelmed)-cumnr_modelmed(length(time_as));
        %     % Find amount of  events in forecast period for observed data
        l = time_asf <=time+timef & time_asf > time;
        numreal = sum(l); % observed number of aftershocks
        %     fRc_Flaw = (numreal-nummod)/sigma;
        fRc_Bst2 = (numreal-nummod2)/fStdBst;
        fRc_Bst = (numreal-nummod)/fStdBst;

        % Round values for output
        pval1 = round(100*pval1)/100;
        pval2 = round(100*pval2)/100;
        cval1 = round(1000*cval1)/1000;
        cval2 = round(1000*cval2)/1000;
        kval1 = round(10*kval1)/10;
        kval2 = round(10*kval2)/10;
        pmed1 = round(100*pmed1)/100; mStdL(1,1) = round(100*mStdL(1,1))/100;
        pmed2 = round(100*pmed2)/100; mStdL(1,2) = round(100*mStdL(1,2))/100;
        cmed1 = round(1000*cmed1)/1000; mStdL(1,3) = round(1000*mStdL(1,3))/1000;
        cmed2 = round(1000*cmed2)/1000; mStdL(1,4) = round(1000*mStdL(1,4))/1000;
        kmed1 = round(10*kmed1)/10; mStdL(1,5) = round(100*mStdL(1,5))/100;
        kmed2 = round(10*kmed2)/10; mStdL(1,6)= round(100*mStdL(1,6))/100;
        fAIC = round(100*fAIC)/100;
        fStdBst = round(100*fStdBst)/100;
        fRc_Bst = round(100*fRc_Bst)/100;

        % Set line for learning period
        yy = get(gca,'ylim');
        plot([max(time_as) max(time_as)],[0 yy(2)],'k-.')
        if nMod == 1
            string1=['p = ' num2str(pval1) '; c = ' num2str(cval1) '; k = ' num2str(kval1) ];
            string3=['pm = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km = ' num2str(kmed1) '+-' num2str(mStdL(1,5))];
            text(max(time_asf)*0.1,yy(2)*0.9,string1,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.8,string3,'FontSize',8);
        elseif nMod == 2
            string1=['p = ' num2str(pval1) '; c = ' num2str(cval1) '; k1 = ' num2str(kval1) '; k2 = ' num2str(kval2) ];
            string3=['pm = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km1 = ' num2str(kmed1) '+-' num2str(mStdL(1,5)) '; km2 = ' num2str(kmed2) '+-' num2str(mStdL(1,6))];
            text(max(time_asf)*0.1,yy(2)*0.9,string1,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.8,string3,'FontSize',8);
        elseif nMod == 3
            string1=['p1 = ' num2str(pval1) '; c = ' num2str(cval1) '; k1 = ' num2str(kval1) ];
            string2=['p2 = ' num2str(pval2) '; k2 = ' num2str(kval2) ];
            string3=['pm1 = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km1 = ' num2str(kmed1) '+-' num2str(mStdL(1,5))];
            string4=['pm2 = ' num2str(pmed2) '+-' num2str(mStdL(1,2)) '; km2 = ' num2str(kmed2) '+-' num2str(mStdL(1,6))];
            text(max(time_asf)*0.1,yy(2)*0.9,string1,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.85,string2,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.8,string3,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.75,string4,'FontSize',8);
        else
            string1=['p1 = ' num2str(pval1) '; c1 = ' num2str(cval1) '; k1 = ' num2str(kval1) ];
            string2=['p2 = ' num2str(pval2) '; c2 = ' num2str(cval2) '; k2 = ' num2str(kval2) ];
            string3=['pm1 = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm1 = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km1 = ' num2str(kmed1) '+-' num2str(mStdL(1,5))];
            string4=['pm2 = ' num2str(pmed2) '+-' num2str(mStdL(1,2)) '; cm2 = ' num2str(cmed2) '+-' num2str(mStdL(1,4)) '; km2 = ' num2str(kmed2) '+-' num2str(mStdL(1,6))];
            text(max(time_asf)*0.1,yy(2)*0.9,string1,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.85,string2,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.8,string3,'FontSize',8);
            text(max(time_asf)*0.1,yy(2)*0.75,string4,'FontSize',8);
        end
        string=['\sigma(Bst) = ' num2str(fStdBst) ' Rc = ' num2str(fRc_Bst) ];%' Rc(Obfit) = ' num2str(fRc_Bst2)];
        text(max(time_asf)*0.1,yy(2)*0.1,string,'FontSize',8);
        sAIC = ['AIC = ' num2str(fAIC)];
        text(max(time_asf)*0.1,yy(2)*0.05,sAIC,'FontSize',8);
        paf = plot(fT1, 0,'h','MarkerFaceColor',[1 1 0],'MarkerSize',12,'MarkerEdgeColor',[0 0 0] );
        sGoodfit = ['KS Test: H = ' num2str(H) ', KS statistic = ' num2str(KSSTAT) ' P value = ' num2str(P) '; RMS = ' num2str(fRMS)];
        text(max(time_asf)*0.1,yy(2)*0.15,sGoodfit,'FontSize',8);
        % Legend
        legend([p2 p1 pf1 pf3 pmedmod min(ps2) paf],'data','model to data','forecast','observed', 'Mean Bst-model', '\sigma (Bst)','Sec. AF', 'location', 'Best');
    else
        disp('no result')
    end
