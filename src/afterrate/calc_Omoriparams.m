function [mResult] = calc_Omoriparams(a,time,timef,bootloops,maepi,nMod)
    % function [mResult] = calc_Omoriparams(a,time,timef,bootloops,maepi,nMod);
    % ----------------------------------------------------------------
    % Determines Omori law parameter for one specific model and uncertainties using the bootstrap method
    %
    % Input parameters:
    %   a           earthquake catalog
    %   time_as     delay times (days)
    %   step        number of quakes to determine forecast period
    %   time        learning period
    %   timef       forecast period: Set timef=0, anyway it is forced to 0
    %   bootloops   Number of bootstraps
    %   maepi       Mainshock values
    %   nMod        Model for aftershock sequence
    %
    % Output parameters:
    %   mResult    Structure containing p-, c-, and k-values, mean bootstrap p,c,k-values and their uncertainties
    %
    % J. Woessner
    % last update: 11.03.04

report_this_filefun(mfilename('fullpath'));
    % Set timef=0;
    if timef ~= 0
        timef = 0; % This is needed since no forecast is calculated here!! JW
    end

    % Warning off for fmincon
    warning off;

    % Initialize
    mResult = [];

    % Define aftershock times
    date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),zeros(size(a,1),1));
    date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),0);
    time_aftershock = date_matlab-date_main;

    % Select biggest aftershock earliest in time, but more than 1 day after mainshock
    fDay = 1;
    ft_c=fDay/365; % Time not considered to find biggest aftershock
    vSel = (a(:,3) > maepi(:,3)+ft_c & a(:,3)<= maepi(:,3)+time/365);
    mCat = a(vSel,:);
    [nY,nX]=size(mCat);
    if nY == 0
        clear mCat;
        vSel = (a(:,3)<= maepi(:,3)+time/365);
        mCat = a(vSel,:);
    end

    vSel = mCat(:,6) == max(mCat(:,6));
    vBigAf = mCat(vSel,:);
    if length(mCat(vSel,1)) > 1
        [s,is] = sort(vBigAf(:,3));
        vBigAf = vBigAf(is(:,1),:) ;
        %vSel = vBigAf(:,3) == min(vBigAf(:,3));
        vBigAf = vBigAf(1,:);
    end
    if isempty(vBigAf)
        disp('help');
    end
    date_biga = datenum(floor(vBigAf(3)),vBigAf(4),vBigAf(5),vBigAf(8),vBigAf(9),0);
    fT1 = date_biga - date_main; % Time of big aftershock

    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = a(l,:);

    % Estimation of Omori parameters from learning period
    l = tas <= time;
    time_as=tas(l);
    % Times up to the forecast time
    lf = tas <= time+timef ;
    time_asf= [tas(lf) ];
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
