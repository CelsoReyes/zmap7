function [rc] = calc_rcloglike_a2(mycat,time,timef,bootloops,ZG.maepi)
    % function [rc] = calc_rcloglike_a2(mycat,time,timef,bootloops,ZG.maepi);
    % ----------------------------------------------------------------
    % Determines ratechanges within aftershock sequences for defined time window using log likelihood estimation
    % procedures; defines the best model using the corrected AIC and calculates uncertainties for the fitted
    % parameters
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
    %   rc      See results at the end of the script
    %
    % J. Woessner

report_this_filefun(mfilename('fullpath'));
    % Warning off for fmincon
    %warning off;

    % Initialize
    rc = [];


    % Define aftershock times
    date_matlab = datenum(mycat.Date);
    date_main = datenum(ZG.maepi.Date);
    time_aftershock = date_matlab-date_main;

    % Aftershock catalog
    vSel1 = time_aftershock(:) > 0;
    tas = time_aftershock(vSel1);
    eqcatalogue = mycat.subset(vSel1);

    % Estimation of Omori parameters from learning period
    l = tas <= time;
    time_as=tas(l);
    % Times up to the forecast time
    lf = tas <= time+timef ;
    time_asf= [tas(lf) ];
    time_asf=sort(time_asf);

    % Select biggest aftershock earliest in time, but more than 1 day after
    % mainshock and in learning period
    mAfLearnCat = eqcatalogue(l,:);
    fDay = 1; %days
    vSel = (mAfLearnCat.Date > ZG.maepi.Date + days(fDay) & mAfLearnCat.Date<= ZG.maepi.Date+days(time);
    mCat = mAfLearnCat.subset(vSel);
    vSel = mCat.Magnitude == max(mCat.Magnitude);
    vBigAf = mCat(vSel,:);
    if sum(vSel) > 1
        vBigAf.sort('Date')
        vBigAf = vBigAf.subset(1);
    end
    date_biga = datenum(vBigAf.Date);
    % Time of big aftershock
    fT1 = date_biga - date_main;

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

    % Goodness of fit test of the fit to the observed data
    [rc.H,rc.P,rc.KSSTAT,rc.fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod);

    % Calculate uncertainty and mean values of p,c,and k
    [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1,nMod);
    pmed1 = mMedModF(1,1); pmedStd1 = mStdL(1,1);
    pmed2 = mMedModF(1,3); pmedStd2 = mStdL(1,2);
    cmed1 = mMedModF(1,5); cmedStd1 = mStdL(1,3);
    cmed2 = mMedModF(1,7); cmedStd2 = mStdL(1,4);
    kmed1 = mMedModF(1,9); kmedStd1 = mStdL(1,5);
    kmed2 = mMedModF(1,11); kmedStd2 = mStdL(1,6);

    %rc = [time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd fStdBst];

    if (isnan(pval1) == 0 & isnan(pval2) == 0)

        % Calculate forecast for median model
        cumnrf = (1:length(time_asf))';
        cumnr_modelf = [];
        if nMod == 1
            for i=1:length(time_asf)
                if pmed1 ~= 1
                    cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1));
                else
                    cm = kmed1*log(time_asf(i)/cmed1+1);
                end
                cumnr_modelf = [cumnr_modelf; cm];
            end % END of FOR on length(time_asf)
        else
            for i=1:length(time_asf)
                if time_asf(i) <= fT1
                    if pmed1 ~= 1
                        cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1));
                    else
                        cm = kmed1*log(time_asf(i)/cmed1+1);
                    end
                    cumnr_modelf = [cumnr_modelf; cm];
                else
                    if (pmed1 ~= 1 & pmed2 ~= 1)
                        cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1))+ kmed2/(pmed2-1)*(cmed2^(1-pmed2)-(time_asf(i)-fT1+cmed2)^(1-pmed2));
                    elseif (pmed1 ~= 1  &&  pmed2 == 1)
                        cm = kmed1/(pmed1-1)*(cmed1^(1-pmed1)-(time_asf(i)+cmed1)^(1-pmed1))+ kmed2*log((time_asf(i)-fT1)/cmed2+1);
                    elseif (pmed1 == 1  &&  pmed2 ~= 1)
                        cm =kmed1*log(time_asf(i)/cmed1+1) + kmed2/(pmed2-1)*(cmed2^(1-pmed2)-(time_asf(i)-fT1+cmed2)^(1-pmed2));
                    else
                        cm = kmed1*log(time_asf(i)/cmed1+1) + kmed2*log((time_asf(i)-fT1)/cmed2+1);
                    end
                    cumnr_modelf = [cumnr_modelf; cm];
                end %END of IF on fT1
            end % End of FOR length(time_asf)
        end % End of if on nMod
        time_asf=sort(time_asf);
        cumnr_modelf=sort(cumnr_modelf);

        % Find amount of events in forecast period for modeled data
        nummod = max(cumnr_modelf)-cumnr_modelf(length(time_as));
        % Find amount of  events in forecast period for observed data
        l = time_asf <=time+timef & time_asf > time;
        numreal = sum(l); % observed number of aftershocks
        absdiff = numreal-nummod;

        % Compute 2nd moment of forecasted number of events at end of forecast period
        for j = 1:length(loopout(:,1))
            cumnr = (1:length(time_asf))';
            cumnr_model = [];
            pval1t = loopout(j,1);
            pval2t = loopout(j,2);
            cval1t = loopout(j,3);
            cval2t = loopout(j,4);
            kval1t = loopout(j,5);
            kval2t = loopout(j,6);
            if nMod == 1
                for i=1:length(time_asf)
                    if pval1 ~= 1
                        cm = kval1t/(pval1t-1)*(cval1t^(1-pval1t)-(time_asf(i)+cval1t)^(1-pval1t));
                    else
                        cm = kval1t*log(time_asf(i)/cval1t+1);
                    end
                    cumnr_model = [cumnr_model; cm];
                end % END of FOR on length(time_asf)
                loopout(j,9) = max(cumnr_model);
            else
                for i=1:length(time_asf)
                    if time_asf(i) <= fT1
                        if pval1t ~= 1
                            cm = kval1t/(pval1t-1)*(cval1t^(1-pval1t)-(time_asf(i)+cval1t)^(1-pval1t));
                        else
                            cm = kval1t*log(time_asf(i)/cval1t+1);
                        end
                        cumnr_model = [cumnr_model; cm];
                    else
                        if (pval1t ~= 1 & pval2t ~= 1)
                            cm = kval1t/(pval1t-1)*(cval1t^(1-pval1t)-(time_asf(i)+cval1t)^(1-pval1t))+ kval2t/(pval2t-1)*(cval2t^(1-pval2t)-(time_asf(i)-fT1+cval2t)^(1-pval2t));
                        elseif (pval1t ~= 1  &&  pval2t == 1)
                            cm = kval1t/(pval1t-1)*(cval1t^(1-pval1t)-(time_asf(i)+cval1t)^(1-pval1t))+ kval2t*log((time_asf(i)-fT1)/cval2t+1);
                        elseif (pval1t == 1  &&  pval2t ~= 1)
                            cm = kval1t*log(time_asf(i)/cval1t+1) + kval2t/(pval2t-1)*(cval2t^(1-pval2t)-(time_asf(i)-fT1+cval2t)^(1-pval2t));
                        else
                            cm = kval1t*log(time_asf(i)/cval1t+1) + kval2t*log((time_asf(i)-fT1)/cval2t+1);
                        end
                        cumnr_model = [cumnr_model; cm];
                    end %END of IF on fT1
                end % End of FOR length(time_asf)
                loopout(j,9) = max(cumnr_model);
            end % End of if on nMod
        end
        % 2nd moment of bootstrap number of forecasted number of events
        fStdBst = calc_StdDev(loopout(:,9));

        % Results
        rc.time = time; rc.absdiff = absdiff;
        rc.numreal = numreal; rc.nummod = nummod;
        rc.pval1 = pval1; rc.pval2 = pval2;
        rc.cval1 = cval1; rc.cval2 = cval2;
        rc.kval1 = kval1; rc.kval2 = kval2;
        rc.pmed1 =  pmed1; rc.pmedStd1 =  pmedStd1;
        rc.cmed1 =  cmed1; rc.cmedStd1 = cmedStd1;
        rc.kmed1 = kmed1; rc.kmedStd1 = kmedStd1;
        rc.pmed2 =  pmed2; rc.pmedStd2 =  pmedStd2;
        rc.cmed2 =  cmed2; rc.cmedStd2 = cmedStd2;
        rc.kmed2 = kmed2; rc.kmedStd2 = kmedStd2;
        rc.fStdBst = fStdBst; rc.nMod = nMod;
        rc.fTBigAf = fT1;
    else
        rc.time = nan; rc.absdiff = nan;
        rc.numreal = nan; rc.nummod = nan;
        rc.pval1 = nan; rc.pval2 = nan;
        rc.cval1 = nan; rc.cval2 = nan;
        rc.kval1 = nan; rc.kval2 = nan;
        rc.pmed1 =  nan; rc.pmedStd1 =  nan;
        rc.cmed1 =  nan; rc.cmedStd1 = nan;
        rc.kmed1 = nan; rc.kmedStd1 = nan;
        rc.pmed2 =  nan; rc.pmedStd2 =  nan;
        rc.cmed2 =  nan; rc.cmedStd2 = nan;
        rc.kmed2 = nan; rc.kmedStd2 = nan;
        rc.fStdBst = nan; rc.nMod = nan;
        rc.fTBigAf = nan;
    end
