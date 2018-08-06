function [result]=gui_NodeCalcOmori(params,mCatalog)
    % gui_NodeCalcOmori  calculate Omori parameters and further informative parameters
    %
    % [result]=gui_NodeCalcOmori(params,mCatalog)
    % --------------------------------------------------------
    %
    % Incoming variables:
    % mCatalog     : current earthquake catalog
    % params       : See gui_CalcOmori for parameters
    %
    % Outgoing variable:
    % result
    %
    % Author: J. Woessner
    % j.woessner@sed.ethz.ch
    % updated: 16.02.2005

    % Create catalog after split time (aftershock sequence)
    vSel = (params.fTstart <= mCatalog.Date & mCatalog.Date < params.fTstart+params.fTimePeriodDays);
    mCatAf = mCatalog.subset(vSel);
    timef = 0; % this is used for rate change calculations
    nMod = 1; % Omori law computation
    % Compute Omori law
    fTime = params.fTimePeriodDays;
    [result] = calc_Omoriparams(mCatAf,fTime,timef,params.fBstnum,params.mMainshock,nMod);
    % Number of events in aftershock sequence
    [nYAf, nXAf] = size(mCatAf);
    result.nNumAf = nYAf;

    % Compute backgroundrate [year] or use given
    if ~params.bTimeBgr
        fBgrate = params.fBgrate;
        vSel = (params.fTstart-params.fTimeBgr <= params.mCatalog.Date & params.mCatalog.Date < params.fTstart);
        mCatBgr = params.mCatalog.subset(vSel);
    else
        % Create catalog before split time (background)
        vSel = (params.fTstart-params.fTimeBgr <= mCatalog.Date & mCatalog.Date < params.fTstart);
        mCatBgr = mCatalog.subset(vSel);
        if isempty(mCatBgr)
            fBgrate = params.fBgrate;
        elseif (length(mCatBgr(:,1)) == 1)
            fBgrate = 1/params.fTimeBgr;
        else
            fBgrate = length(mCatBgr(:,1))/(max(mCatBgr(:,3)) - min(mCatBgr(:,3)));
        end
    end
    % Background seismicity rate per year
    result.fBgrate = fBgrate;
    % Logarithmic
    result.fLog10Bgrate = log10(fBgrate);
    % Number of events in background seismicity
    [nYBgr, nXBgr] = size(mCatBgr);
    result.nNumBgr = nYBgr;

    % Compute length of aftershock sequence; pck-values fitted to original data
    [fTafseq] = calc_Afseqlength(result.pval1,result.cval1,result.kval1,fBgrate); %years
    % Af Seismicity rate per year
    result.fLog10Tafseq = log10(fTafseq); %was days(blah), which only makes sense if fTafseq was in days

    % Compute length of aftershock sequence; pck-values bootstrapped
    [fTafseqmean] = calc_Afseqlength(result.pmean1,result.cmean1,result.kmean1,fBgrate); %years
    result.fTafseqmean = fTafseqmean; %was days(blah), which only makes sense if fTafseq was in days

    % Number of events
    nY = mCatalog.Count;
    result.nNumEvents = nY;
    % Log EQ density
    result.fLogEqdens = log10(nY/(params.fRadius^2*pi));

