function plot_bootfitloglike_a2(mycat,time,timef,bootloops,maepi)
    % Plots Ncum (observed vs. modeled) for specified time windows (choose model for the learning period)
    %
    % plot_bootfitloglike_a2(mycat,time,timef,bootloops,ZG.maepi);
    % --------------------------------------------------
    % Plots Ncum observed vs. Ncum modeled for specified time windows
    % with choosing the model for the learning period
    % Input variables:
    % mycat         : earthquake catalog
    % time      : learning period fo fit Omori parameters [days]
    % timef     : forecast period [days]
    % bootloops : Number of bootstraps
    % ZG.maepi     : mainshock
    %
    % J.Woessner, S. Wiemer

%FIXME mCat ZG.maepi still treated as arrays
report_this_filefun();
    % Surpress warnings from fmincon
    % warning off;

    if ~ensure_mainshock()
        return
    end
    date_matlab = datenum(mycat.Date);
    date_main = datenum(ZG.maepi.Date);
    time_aftershock = date_matlab-date_main;

% Select biggest aftershock earliest in time, but more than 1 day after mainshock
    fDay = 1; %days
    vSel = (mycat.Date > ZG.maepi.Date + days(fDay)) & mycat.Date<= ZG.maepi.Date+days(time);
    mCat = mycat.subset(vSel);
    vSel = mCat.Magnitude == max(mCat.Magnitude);
    vBigAf = mCat(vSel,:);
    if sum(vSel) > 1
        vBigAf.sort('Date')
        vBigAf = vBigAf.subset(1);
    end
    date_biga = datenum(vBigAf.Date);
    fT1 = date_biga - date_main; % Time of big aftershock


    % Aftershock times
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = mycat.subset(l);

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
    % see OmoriModel for enumaration details

    MOL_models = sort(enumeration('OmoriModel'));

    mRes = [];
    % Modified Omori law (pck)

    for nMod=1:numel(MOL_models) % do this for each model
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as, fT1, MOL_models(nMod));
        mRes(nMod,:) = [nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
    end

    % Select best fitting model by AIC
    vSel = (mRes(:,8)==min(mRes(:,8)));
    mRes = mRes(vSel,:);
    if length(mRes(:,1)) > 1
        vSel = (mRes(:,1)==min(mRes(:,1)));
        mRes = mRes(vSel,:);
    end
    % Model to use for bootstrapping as of lowest AIC to observed data
    nMod = OmoriModel(mRes(1,1));
    pval1= mRes(1,2); 
    pval2= mRes(1,3);
    cval1= mRes(1,4); 
    cval2= mRes(1,5);
    kval1= mRes(1,6); 
    kval2= mRes(1,7);

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

    % Start plotting
    if (~isnan(pval1) && ~isnan(pval2))

        figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Forecast aftershock occurence')
        loopout(:,end+1) = 0; % add a column

        pval1s = loopout(:,1);
        pval2s = loopout(:,2);
        cval1s = loopout(:,3);
        cval2s = loopout(:,4);
        kval1s = loopout(:,5);
        kval2s = loopout(:,6);
        
        cumnr_model = OmoriModel.doForecast(nMod, time_asf, pval1s, cval1s, kval1s, fT1, kval2s, pval2s, cval2s);
        
        loopout(:,9)=max(cumnr_model);
        
        pfloop = plot(time_asf,cumnr_model,'color',[0.8 0.8 0.8]);
        set(gca,'NextPlot','add')
        
        warning('This uses only the last values')
        % 2nd moment of bootstrap number of forecasted number of events
        fStdBst = std(loopout(:,9),1,'omitnan');
        %
        % Plot the forecast ...
        cumnrf = (1:length(time_asf))';
        
        cumnr_modelf = OmoriModel.doForecast(nMod, time_asf, pval1s(end), cval1s(end), kval1s(end), fT1, kval2s(end), pval2s(end), cval2s(end));
        
        time_asf=sort(time_asf);
        cumnr_modelf=sort(cumnr_modelf);

        pf1 =  plot(time_asf,cumnr_modelf,'g-.','Linewidth',2);
        set(gca,'NextPlot','add')
        %pf2 =  plot(time_asf,cumnrf, 'b-','Linewidth',2);
        %
        % Plot the  fit to the observed data
        % Cumulative number of observed events
        cumnr = (1:length(time_as))';
        cumnr_model = [];
        cumnr_model= OmoriModel.doForecast(nMod, time_as, pval1s(end), cval1s(end), kval1s(end), fT1, kval2s(end), pval2s(end), cval2s(end));
        
        
        time_as=sort(time_as);
        cumnr_model=sort(cumnr_model);
        p1 = plot(time_as,cumnr_model,'r','Linewidth',2,'Linestyle','--');
        set(gca,'NextPlot','add');
        p2 = plot(time_as,cumnr,'b','Linewidth',2,'Linestyle','--');

        % Plot the forecast from median value
        cumnr_modelmed = [];
        cumnr_modelmed= OmoriModel.doForecast(nMod, time_asf, pmed1, cmed1, kmed1, fT1, kmed2, pmed2, cmed2);
        
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
        pval1 = round(pval1,2);
        pval2 = round(pval2,2);
        cval1 = round(cval1,3);
        cval2 = round(cval2,3);
        kval1 = round(kval1,1);
        kval2 = round(kval2,1);
        pmed1 = round(pmed1,2); mStdL(1,1) = round(mStdL(1,1),2);
        pmed2 = round(pmed2,2); mStdL(1,2) = round(mStdL(1,2),2);
        cmed1 = round(cmed1,3); mStdL(1,3) = round(mStdL(1,3),3);
        cmed2 = round(cmed2,3); mStdL(1,4) = round(mStdL(1,4),3);
        kmed1 = round(kmed1,1); mStdL(1,5) = round(mStdL(1,5),2);
        kmed2 = round(kmed2,1); mStdL(1,6)= round(mStdL(1,6),2);
        fAIC = round(fAIC,2);
        fStdBst = round(fStdBst,2);
        fRc_Bst = round(fRc_Bst,2);

        % Set line for learning period
        yy = get(gca,'ylim');
        plot([max(time_as) max(time_as)],[0 yy(2)],'k-.')
        textX = max(time_asf)*0.1;
        textY = @(z) yy(2)* z;
        
        switch nMod
            case OmoriModel.pck
                string1 = sprintf('p = %g; c = %g; k = %g', pval1, cval1, kval1);
                string3 = sprintf('pm = %g+-%g; cm = %g+-%g; km = %g+-%g', mped1, mStdL(1,1), cmed1, mStdL(1,3), kmed1, mStdL(1,5));
                % string3=['pm = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km = ' num2str(kmed1) '+-' num2str(mStdL(1,5))];
                text(textX,textY(0.9),string1,'FontSize',8);
                text(textX,textY(0.8),string3,'FontSize',8);
            case  OmoriModel.pckk
                string1 = sprintf('p = %g; c = %g; k1 = %g; k2 = %g', pval1, cval1, kval1, kval2);
                string3 = sprintf('pm = %g+-%g; cm = %g+-%g; km1 = %g+-%g; km2 = %g+-%g',...
                    mped1, mStdL(1,1), cmed1, mStdL(1,3), kmed1, mStdL(1,5), kmed2, mStdL(1,6));
                text(textX,textY(0.9),string1,'FontSize',8);
                text(textX,textY(0.8),string3,'FontSize',8);
            case OmoriModel.ppckk
                string1 = sprintf('p1 = %g; c = %g; k1 = %g', pval1, cval1, kval1);
                string2 = sprintf('p2 = %g; k2 = %g', pval2, kval2);
                string3 = sprintf('pm1 = %g+-%g; cm = %g+-%g; km1 = %g+-%g', mped1, mStdL(1,1), cmed1, mStdL(1,3), kmed1, mStdL(1,5));
                string4 = sprintf('pm2 = %g+-%g; km2 = %g+-%g', mped2, mStdL(1,2), kmed2, mStdL(1,6));
                text(textX,textY(0.9),string1,'FontSize',8);
                text(textX,textY(0.85),string2,'FontSize',8);
                text(textX,textY(0.8),string3,'FontSize',8);
                text(textX,textY(0.75),string4,'FontSize',8);
            case OmoriModel.ppcckk
                string1 = sprintf('p1 = %g; c1 = %g; k1 = %g', pval1, cval1, kval1);
                string2 = sprintf('p2 = %g; c2 = %g; k2 = %g', pval2, cval2, kval2);
                string3 = sprintf('pm1 = %g+-%g; cm1 = %g+-%g; km1 = %g+-%g', mped1, mStdL(1,1), cmed1, mStdL(1,3), kmed1, mStdL(1,5));
                string4 = sprintf('pm2 = %g+-%g; cm2 = %g+-%g; km2 = %g+-%g', mped2, mStdL(1,2), cmed2, mStdL(1,4), kmed2, mStdL(1,6));
                text(textX,textY(0.9),string1,'FontSize',8);
                text(textX,textY(0.85),string2,'FontSize',8);
                text(textX,textY(0.8),string3,'FontSize',8);
                text(textX,textY(0.75),string4,'FontSize',8);
        end
        string=sprintf('\sigma(Bst) = %g Rc = %g',fStdBst, fRc_Bst);%' Rc(Obfit) = ' num2str(fRc_Bst2)];
        text(textX,yy(2)*0.1,string,'FontSize',8);
        
        sAIC = sprintf('AIC = %g',fAIC);
        text(textX,yy(2)*0.05,sAIC,'FontSize',8);
        
        paf = plot(fT1, 0,'h','MarkerFaceColor',[1 1 0],'MarkerSize',12,'MarkerEdgeColor',[0 0 0] );
        sGoodfit = sprintf('KS Test: H = %g, KS statistic = %g P value = %g; RMS = %g', H, KSSTAG, P,fRMS);
        text(textX,yy(2)*0.15,sGoodfit,'FontSize',8);
        % Legend
        legend([p2 p1 pf1 pf3 pmedmod min(ps2) paf],'data','model to data','forecast','observed', 'Mean Bst-model', '\sigma (Bst)','Sec. AF', 'location', 'Best');
    else
        disp('no result')
    end

