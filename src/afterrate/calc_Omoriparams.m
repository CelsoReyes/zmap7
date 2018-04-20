function [mResult] = calc_Omoriparams(mycat,time,timef,bootloops,maepi,nMod)
    % calc_Omoriparams Determines Omori law parameter for one specific model and uncertainties using the bootstrap method
    %
    % [mResult] = calc_Omoriparams(mycat,time,timef,bootloops,maepi,nMod);
    % Input parameters:
    %   mycat           earthquake catalog
    %   time_as     delay times (days)
    %   step        number of quakes to determine forecast period
    %   time        learning period [days as duration]
    %   timef       forecast period: Set timef=0, anyway it is forced to 0 [days]
    %   bootloops   Number of bootstraps
    %   ZG.maepi       Mainshock values
    %   nMod        Model for aftershock sequence
    %
    % Output parameters:
    %   mResult    Structure containing p-, c-, and k-values, mean bootstrap p,c,k-values and their uncertainties
    %
    % J. Woessner
    % updated: 11.03.04
    % 2017 Celso Reyes

    %TODO fix the time periods from decyear to days or dates
    report_this_filefun();
    timef = days(0); % This is needed since no forecast is calculated here!! JW

    % Warning off for fmincon
    % warning off;

    % Initialize
    mResult = [];

    if ~ensure_mainshock()
        return
    end
    % Define aftershock times
    date_matlab = mycat.Date;
    date_main = ZG.maepi.Date;
    time_aftershock = date_matlab - date_main;

    % Select biggest aftershock earliest in time, but more than 1 day after mainshock
    fDay = days(1);% Time not considered to find biggest aftershock
    vSel = (mycat.Date > ZG.maepi.Date+fDay) & mycat.Date<= ZG.maepi.Date+days(time);
    mCat = mycat.subset(vSel);
    
    if isempty(mCat)
        vSel = (mycat.Date <= ZG.maepi.Date+days(time));
        mCat = mycat.subset(vSel);
    end

    vSel = mCat.Magnitude == max(mCat.Magnitude);
    vBigAf = mCat.Subset(vSel);
    if length(mCat(vSel,1)) > 1
        [~,is] = sort(vBigAf.Date);
        vBigAf = vBigAf.subset(is);
        vBigAf = vBigAf.subset(1); % grab first only?
    end
    if isempty(vBigAf)
        disp('help');
    end
    date_biga = vBigAf.Date;
    fT1 = date_biga - date_main; % Time of big aftershock

    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = mycat.subset(l);

    % Estimation of Omori parameters from learning period
    l = tas <= time;
    time_as=tas(l);
    % Times up to the forecast time
    lf = tas <= time+timef ;
    time_asf= tas(lf);
    time_asf=sort(time_asf);

    % Calculate fits of different models
    mRes = [];
    % Modified Omori law (pck)
    if nMod == 1
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (pckk)
    elseif nMod == 2
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (ppckk)
    elseif nMod == 3
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    else % MOL with secondary aftershock (ppcckk)
        nMod = 4;
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    end %END if nMod

    % Model to use for bootstrapping as of lowest AIC to observed data
    mResult.nMod = mRes(1,1);
    mResult.pval1= mRes(1,2); mResult.pval2= mRes(1,3);
    mResult.cval1= mRes(1,4); mResult.cval2= mRes(1,5);
    mResult.kval1= mRes(1,6); mResult.kval2= mRes(1,7);

    % Goodness of fit test of the fit to the observed data
    [mResult.H,mResult.P,mResult.KSSTAT,mResult.fRMS] = calc_llkstest_a2(time_as,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod);

    % Calculate uncertainty and mean values of p,c,and k
    [mMeanModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1,nMod);
    mResult.pmean1 = mMeanModF(1,1); mResult.pmeanStd1 = mStdL(1,1);
    mResult.pmean2 = mMeanModF(1,3); mResult.pmeanStd2 = mStdL(1,2);
    mResult.cmean1 = mMeanModF(1,5); mResult.cmeanStd1 = mStdL(1,3);
    mResult.cmean2 = mMeanModF(1,7); mResult.cmeanStd2 = mStdL(1,4);
    mResult.kmean1 = mMeanModF(1,9); mResult.kmeanStd1 = mStdL(1,5);
    mResult.kmean2 = mMeanModF(1,11); mResult.kmeanStd2 = mStdL(1,6);

