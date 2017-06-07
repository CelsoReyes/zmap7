function plot_optfit(a,time,timef,bootloops,maepi)
    % function plot_optfit(a,time,timef,bootloops,maepi);
    % ---------------------------------------------------
    % Plots Ncum observed vs. Ncum modeled for specified time windows
    %
    % Input variables:
    % a         : earthquake catalog (Complete in magnitude!)
    % time      : learning period fo fit Omori parameters
    % timef     : forecast period
    % bootloops : Number of bootstraps
    % maepi     : mainshock
    %
    % Samuel Neukomm
    % last update: 01.03.04

    warning off;

    [fMc] = calc_Mc(a, 1, 0.1)+0.2;
    l = a(:,6) >= fMc;
    a = a(l,:);

    if size(a,2) == 9
        date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),zeros(size(a,1),1));
        date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),0);
    else
        date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),a(:,10));
        date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),maepi(10));
    end
    time_aftershock = date_matlab-date_main;
    % Select biggest aftershock earliest in time, but more than 1 day after mainshock
    fDay = 1;
    ft_c=fDay/365; % Time not considered to find biggest aftershock
    vSel = (a(:,3) > maepi(:,3)+ft_c & a(:,3)<= maepi(:,3)+time/365);
    mCat = a(vSel,:);
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

    % Aftershock times
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = a(l,:);

    % time_as: Learning period
    l = tas <= time;
    time_as = tas(l);
    time_as = sort(time_as);
    if length(time_as) < 100 % at least 100 events in learning period
        return
    end

    % Times up to the forecast time
    lf = tas <= time+timef ;
    time_asf= [tas(lf) ];
    time_asf=sort(time_asf);

    figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Forecast aftershock occurence')
    hold on

    n = length(time_as);
    loopout = []; nCnt = 0;

    for j = 1:bootloops
        clear newtas
        randnr = ceil(rand(n,1)*n);
        i = (1:n)';
        newtas(i,:) = time_as(randnr(i),:); % bootstrap sample

        % Calculate fits of different models
        mRes = [];
        % Modified Omori law (pck)
        nMod = 1; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (pckk)
        nMod = 2; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (ppckk)
        nMod = 3; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (ppcckk)
        nMod = 4; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
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
        [H,P,KSSTAT,fRMS] = calc_llkstest_a2(newtas,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod);
        if H == 1
            nCnt = nCnt + 1;
            if nCnt/bootloops >= 0.5
                return
            end

        else
            cumnr_model = [];

            if nMod == 1
                for i=1:length(time_asf)
                    if pval1 ~= 1
                        nrmod = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                    else
                        nrmod = kval1*log(time_asf(i)/cval1+1);
                    end
                    cumnr_model = [cumnr_model; nrmod];
                end % END of FOR on length(time_asf)

                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_asf)+cval1)^(1-pval1));
                    cl = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_as)+cval1)^(1-pval1));
                else
                    cm = kval1*log(max(time_asf)/cval1+1);
                    cl = kval1*log(max(time_as)/cval1+1);
                end
            else
                for i=1:length(time_asf)
                    if time_asf(i) <= fT1
                        if pval1 ~= 1
                            nrmod = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                        else
                            nrmod = kval1*log(time_asf(i)/cval1+1);
                        end
                        cumnr_model = [cumnr_model; nrmod];
                    else
                        if (pval1 ~= 1 & pval2 ~= 1)
                            nrmod = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_asf(i)-fT1+cval2)^(1-pval2));
                        elseif (pval1 ~= 1  &&  pval2 == 1)
                            nrmod = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1))+ kval2*log((time_asf(i)-fT1)/cval2+1);
                        elseif (pval1 == 1  &&  pval2 ~= 1)
                            nrmod = kval1*log(time_asf(i)/cval1+1)+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_asf(i)-fT1+cval2)^(1-pval2));
                        else
                            nrmod = kval1*log(time_asf(i)/cval1+1) + kval2*log((time_asf(i)-fT1)/cval2+1);
                        end
                        cumnr_model = [cumnr_model; nrmod];
                    end %END of IF on fT1
                end % End of FOR length(time_asf)

                if (pval1 ~= 1 & pval2 ~= 1)
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_asf)+cval1)^(1-pval1)) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_asf)-fT1+cval2)^(1-pval2));
                    cl = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_as)+cval1)^(1-pval1)) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_as)-fT1+cval2)^(1-pval2));
                elseif (pval1 ~= 1  &&  pval2 == 1)
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_asf)+cval1)^(1-pval1)) + kval2*log((max(time_asf)-fT1)/cval2+1);
                    cl = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_as)+cval1)^(1-pval1)) + kval2*log((max(time_as)-fT1)/cval2+1);
                elseif (pval1 == 1  &&  pval2 ~= 1)
                    cm = kval1*log(max(time_asf)/cval1+1) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_asf)-fT1+cval2)^(1-pval2));
                    cl = kval1*log(max(time_as)/cval1+1) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_as)-fT1+cval2)^(1-pval2));
                else
                    cm = kval1*log(max(time_asf)/cval1+1) + kval2*log((max(time_asf)-fT1)/cval2+1);
                    cl = kval1*log(max(time_as)/cval1+1) + kval2*log((max(time_as)-fT1)/cval2+1);
                end
            end % End of if on nMod
            loopout = [loopout; pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL, cm, cl, nMod];
            pfloop = plot(time_asf,cumnr_model,'color',[0.8 0.8 0.8]);
        end % End of KS-Test
    end

    % 2nd moment of bootstrap number of forecasted number of events
    fStdBst = calc_StdDev(loopout(:,9));

    % plot observed number in learning period
    cumnrf = (1:length(time_asf))';
    cumnr = (1:length(time_as))';
    p2 = plot(time_as,cumnr,'b','Linewidth',2,'Linestyle','--');

    % Plot observed events in forecast period from endpoint of modeled events in learning period
    vSel = time_asf >= max(time_as);
    vCumnr_forecast = cumnrf(vSel,:);
    vTime_forecast = time_asf(vSel,:);
    % Difference of modelled and observed number of events at time_as
    fDiff_timeas = mean(loopout(:,10))-cumnrf(length(time_as));
    vCumnr_forecast = vCumnr_forecast+fDiff_timeas;
    pf3 = plot(vTime_forecast, vCumnr_forecast,'m-.','Linewidth',2);

    xlim([0 max(time_asf)]);
    xlabel('Delay time [days]')
    ylabel('Cumulative number of aftershocks')

    % Plot standard deviation from bootstrap
    ps2=errorbar(max(time_asf),mean(loopout(:,9)),fStdBst,fStdBst);
    set(ps2,'Linewidth',2,'Color',[1 0 0])

    % calculate rate change
    nr_forecast = mean(loopout(:,9));
    nr_learn = mean(loopout(:,10));
    nummod = nr_forecast-nr_learn;
    l = time_asf <= time+timef & time_asf > time;
    numreal = sum(l);
    fRc_Bst = (numreal-nummod)/fStdBst;

    % Set line for learning period
    yy = get(gca,'ylim');
    plot([max(time_as) max(time_as)],[0 yy(2)],'k-.')
    string=['\sigma = ' num2str(fStdBst) '; RC = ' num2str(fRc_Bst) ];
    text(max(time_asf)*0.15,yy(2)*0.15,string,'FontSize',10);

    legend([p2 pf3 min(ps2)],'data','observed','\sigma (Bst)','location', 'NorthWest');
