function [rc] = calc_rcloglike_a2(mycat,time,timef,bootloops,mainshock_date)
    % CALC_RCLOGLIKE_A2 Determines ratechanges within aftershock sequences for a time window using
    % log likelihood estimation procedures; defines the best model using the corrected AIC and
    % calculates uncertainties for the fitted parameters
    %
    % [rc] = CALC_RCLOGLIKE_A2(mycat,time,timef,bootloops,mainshock_date);
    % ----------------------------------------------------------------
    % Input parameters:
    %   mycat       earthquake catalog
    %   % time_as     delay times (duration) [was days]
    %   step        number of quakes to determine forecast period
    %   time        learning period (duration) [days]
    %   timeF       forecast period (duration) [days]
    %   bootloops   Number of bootstraps
    %   mainshock_date   date of mainshock
    %
    % Output parameters:
    %   rc      Struct containing results. See the end of the function
    %
    % J. Woessner
    
    report_this_filefun();
    % Warning off for fmincon
    % warning off;
    
    % Initialize
    rc = [];
    
    
    % Define aftershock times
    date_matlab = datenum(mycat.Date);
    if ~ensure_mainshock()
        return
    end
    date_main = datenum(mainshock_date);
    time_aftershock = date_matlab-date_main;
    
    % Aftershock catalog
    vSel1 = time_aftershock(:) > 0;
    tas = time_aftershock(vSel1);
    eqcatalogue = mycat.subset(vSel1);
    
    % Estimation of Omori parameters from learning period
    l = tas <= time;
    time_as = tas(l);
    % Times up to the forecast time
    lf = tas <= time + timef ;
    time_asf = tas(lf);
    time_asf = sort(time_asf);
    
    % Select biggest aftershock earliest in time, but more than 1 day after
    % mainshock and in learning period
    mAfLearnCat = eqcatalogue(l,:);
    fDay = 1; %days
    vSel = (mAfLearnCat.Date > mainshock_date + days(fDay)) & mAfLearnCat.Date <= mainshock_date+days(time);
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
    
    %% Calculate fits of different models
    
    mRes = nan(4,9);
    
    % Modified Omori law (pck)
    nMod = OmoriModel.pck;
    [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes(1,:) = [nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    
    % MOL with secondary aftershock (pckk)
    nMod = OmoriModel.pckk;
    [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes(2,:) = [nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    
    % MOL with secondary aftershock (ppckk)
    nMod = OmoriModel.ppckk;
    [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes(3,:) = [nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    
    % MOL with secondary aftershock (ppcckk)
    nMod = OmoriModel.ppcckk;
    [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes(4,:) = [nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    
    % Select best fitting model by AIC
    vSel = (mRes(:,8)==min(mRes(:,8)));
    mRes = mRes(vSel,:);
    if length(mRes(:,1)) > 1
        vSel = (mRes(:,1)==min(mRes(:,1)));
        mRes = mRes(vSel,:);
    end
    % Model to use for bootstrapping as of lowest AIC to observed data
    nMod = OmoriModel(mRes(1,1));
    pval1= mRes(1,2); pval2= mRes(1,3);
    cval1= mRes(1,4); cval2= mRes(1,5);
    kval1= mRes(1,6); kval2= mRes(1,7);
    
    % Goodness of fit test of the fit to the observed data
    [rc.H,rc.P,rc.KSSTAT,rc.fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod);
    
    % Calculate uncertainty and mean values of p,c,and k
    [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1,nMod);
    pmed1 = mMedModF(1,1); 
    pmedStd1 = mStdL(1,1);
    pmed2 = mMedModF(1,3); 
    pmedStd2 = mStdL(1,2);
    cmed1 = mMedModF(1,5); 
    cmedStd1 = mStdL(1,3);
    cmed2 = mMedModF(1,7); 
    cmedStd2 = mStdL(1,4);
    kmed1 = mMedModF(1,9); 
    kmedStd1 = mStdL(1,5);
    kmed2 = mMedModF(1,11); 
    kmedStd2 = mStdL(1,6);
    
    %rc = [time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd fStdBst];
    if isnan(pval1) || isnan(pval2)
        rc.time = nan; 
        rc.absdiff = nan;
        rc.numreal = nan; 
        rc.nummod = nan;
        rc.pval1 = nan; 
        rc.pval2 = nan;
        rc.cval1 = nan; 
        rc.cval2 = nan;
        rc.kval1 = nan; 
        rc.kval2 = nan;
        rc.pmed1 =  nan; 
        rc.pmedStd1 =  nan;
        rc.cmed1 =  nan; 
        rc.cmedStd1 = nan;
        rc.kmed1 = nan; 
        rc.kmedStd1 = nan;
        rc.pmed2 =  nan; 
        rc.pmedStd2 =  nan;
        rc.cmed2 =  nan; 
        rc.cmedStd2 = nan;
        rc.kmed2 = nan; 
        rc.kmedStd2 = nan;
        rc.fStdBst = nan; 
        rc.nMod = nan;
        rc.fTBigAf = nan;
        return
    end
    
    % Calculate forecast for median model
    cumnrf = (1:length(time_asf))';
    cumnr_modelf = [];
    
    cm = OmoriModel.doForecast(nMod, time_asf, pmed1, cmed1, kmed1, fT1, kmed2, pmed2, cmed2);
    
    time_asf=sort(time_asf);
    cumnr_modelf=sort(cumnr_modelf);
    
    % Find amount of events in forecast period for modeled data
    nummod = max(cumnr_modelf)-cumnr_modelf(length(time_as));
    % Find amount of  events in forecast period for observed data
    l = (time_asf <= time + timef) & (time_asf > time);
    numreal = sum(l); % observed number of aftershocks
    absdiff = numreal-nummod;
    
    % Compute 2nd moment of forecasted number of events at end of forecast period
    pv1=loopout(:,1);
    pv2=loopout(:,2);
    cv1=loopout(:,3);
    cv2=loopout(:,4);
    kv1=loopout(:,5);
    kv2=loopout(:,6);
    
    cm = OmoriModel.doForecast(nMod, time_asf, pv1, cv1, kv1, fT1, kv2, pv2, cv2);
    loopout(:,9) = max(cm); % each column of cm is an itteration
    
    % 2nd moment of bootstrap number of forecasted number of events
    fStdBst = std(loopout(:,9),1,'omitnan');
    
    % Results
    rc.time = time; 
    rc.absdiff = absdiff;
    rc.numreal = numreal; 
    rc.nummod = nummod;
    rc.pval1 = pval1; 
    rc.pval2 = pval2;
    rc.cval1 = cval1; 
    rc.cval2 = cval2;
    rc.kval1 = kval1; 
    rc.kval2 = kval2;
    rc.pmed1 =  pmed1; 
    rc.pmedStd1 =  pmedStd1;
    rc.cmed1 =  cmed1; 
    rc.cmedStd1 = cmedStd1;
    rc.kmed1 = kmed1; 
    rc.kmedStd1 = kmedStd1;
    rc.pmed2 =  pmed2; 
    rc.pmedStd2 =  pmedStd2;
    rc.cmed2 =  cmed2; 
    rc.cmedStd2 = cmedStd2;
    rc.kmed2 = kmed2; 
    rc.kmedStd2 = kmedStd2;
    rc.fStdBst = fStdBst; 
    rc.nMod = nMod;
    rc.fTBigAf = fT1;
    
end

function run_model(nMod, tb)
    % JUST STARTED... 
    if nargin == 1
        tb = table('Size', [1,9],...
            'VariableTypes', {'string','float','float','float','float','float','float','float','float'}) 
    end
    tb(height(tb)+1,2:9) = bruteforceloglike_a2(time_as,fT1,nMod);
    [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    mRes(1,:) = [nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
end