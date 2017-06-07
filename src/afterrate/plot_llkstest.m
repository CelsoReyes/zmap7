function plot_llkstest(a,time,timef,bootloops,maepi)
    % function plot_llkstes(a,time,timef,bootloops,maepi);
    % --------------------------------------------------
    % Plots Ncum observed vs. Ncum modeled for specified time windows
    % with choosing the model for the learning period and performs a KS-Test
    %
    % Input variables:
    % a         : earthquake catalog
    % time      : learning period fo fit Omori parameters
    % timef     : forecast period
    % bootloops : Number of bootstraps
    % maepi     : mainshock
    %
    % J.Woessner
    % last update: 20.07.04

    % Surpress warnings from fmincon
    warning off;

    %[m_main, main] = max(a(:,6));
    date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),zeros(size(a,1),1));
    date_main = datenum(floor(maepi(3)),maepi(4),maepi(5),maepi(8),maepi(9),0);
    time_aftershock = date_matlab-date_main;

    % Aftershock catalog
    vSel1 = time_aftershock(:) > 0;
    tas = time_aftershock(vSel1);
    eqcatalogue = a(vSel1,:);

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
    fDay = 1;
    ft_c=fDay/365; % Time not considered to find biggest aftershock
    vSel = (mAfLearnCat(:,3) > maepi(:,3)+ft_c & mAfLearnCat(:,3)<= maepi(:,3)+time/365);
    mCat = mAfLearnCat(vSel,:);
    vSel = mCat(:,6) == max(mCat(:,6));
    vBigAf = mCat(vSel,:);
    if length(mCat(:,1)) > 1
        vSel = vBigAf(:,3) == min(vBigAf(:,3));
        vBigAf = vBigAf(vSel,:);
    end

    date_biga = datenum(floor(vBigAf(3)),vBigAf(4),vBigAf(5),vBigAf(8),vBigAf(9),0);
    fT1 = date_biga - date_main; % Time of big aftershock


    % Calculate p,c,k for dataset
    prompt  = {'Enter model number (1:pck, 2:pckk, 3:ppckk, 4:ppcckk:'};
    title   = 'Model selection for fitting aftershock sequence';
    lines= 1;
    def     = {'1'};
    answer  = inputdlg(prompt,title,lines,def);
    nMod = str2double(answer{1});

    % Calculate uncertainty and mean values of p,c,and k
    [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1,nMod);
    pmed1 = mMedModF(1,1);
    pmed2 = mMedModF(1,3);
    cmed1 = mMedModF(1,5);
    cmed2 = mMedModF(1,7);
    kmed1 = mMedModF(1,9);
    kmed2 = mMedModF(1,11);


    % Compute model according to model choice
    if nMod == 1
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    elseif nMod == 2
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    elseif nMod == 3
        [pval1, pval2, cval1, cval2, kval1, kval2 , fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    else
        [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(time_as,fT1,nMod);
    end

    % Start plotting
    figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Aftershock modelling fit')

    % Plot the forecast ...
    cumnrf = (1:length(time_as))';
    cumnr_modelf = [];
    if nMod == 1
        for i=1:length(time_as)
            if pval1 ~= 1
                cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1));
            else
                cm = kval1*log(time_as(i)/cval1+1);
            end
            cumnr_modelf = [cumnr_modelf; cm];
        end % END of FOR on length(time_as)
    else
        for i=1:length(time_as)
            if time_as(i) <= fT1
                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1));
                else
                    cm = kval1*log(time_as(i)/cval1+1);
                end
                cumnr_modelf = [cumnr_modelf; cm];
            else
                if (pval1 ~= 1 & pval2 ~= 1)
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_as(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_as(i)-fT1+cval2)^(1-pval2));
                else
                    cm = kval1*log(time_as(i)/cval1+1) + kval2*log((time_as(i)-fT1)/cval2+1);
                end
                cumnr_modelf = [cumnr_modelf; cm];
            end %END of IF on fT1
        end % End of FOR length(time_as)
    end % End of if on nMod
    time_as=sort(time_as);
    cumnr_modelf=sort(cumnr_modelf);

    pf1 =  plot(time_as,cumnr_modelf,'g-.','Linewidth',2);
    hold on
    pf2 =  plot(time_as,cumnrf, 'b-','Linewidth',2);
    paf = plot(fT1, 0,'h','MarkerFaceColor',[1 1 0],'MarkerSize',12,'MarkerEdgeColor',[0 0 0] );

    % Calculate KSTEST2 as a measure of the goodness of fit
    [H,P,KSSTAT] = kstest2(cumnr_modelf,cumnrf)

    % Calculate RMS
    i=(1:1:length(time_as))';
    fRMS = (sum((i-cumnr_modelf).^2)/length(i))^0.5;

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
    fRMS = round(100*fRMS)/100;

    % Get Y limits for positioning texts
    yy = get(gca,'ylim');

    if nMod == 1
        string1=['p = ' num2str(pval1) '; c = ' num2str(cval1) '; k = ' num2str(kval1) ];
        string3=['pm = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km = ' num2str(kmed1) '+-' num2str(mStdL(1,5))];
        text(max(time_asf)*0.05,yy(2)*0.9,string1,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.8,string3,'FontSize',10);
    elseif nMod == 2
        string1=['p = ' num2str(pval1) '; c = ' num2str(cval1) '; k1 = ' num2str(kval1) '; k2 = ' num2str(kval2) ];
        string3=['pm = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km1 = ' num2str(kmed1) '+-' num2str(mStdL(1,5)) '; km2 = ' num2str(kmed2) '+-' num2str(mStdL(1,6))];
        text(max(time_asf)*0.05,yy(2)*0.9,string1,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.8,string3,'FontSize',10);
    elseif nMod == 3
        string1=['p1 = ' num2str(pval1) '; c = ' num2str(cval1) '; k1 = ' num2str(kval1) ];
        string2=['p2 = ' num2str(pval2) '; k2 = ' num2str(kval2) ];
        string3=['pm1 = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km1 = ' num2str(kmed1) '+-' num2str(mStdL(1,5))];
        string4=['pm2 = ' num2str(pmed2) '+-' num2str(mStdL(1,2)) '; km2 = ' num2str(kmed2) '+-' num2str(mStdL(1,6))];
        text(max(time_asf)*0.05,yy(2)*0.9,string1,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.85,string2,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.8,string3,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.75,string4,'FontSize',10);
    else
        string1=['p1 = ' num2str(pval1) '; c1 = ' num2str(cval1) '; k1 = ' num2str(kval1) ];
        string2=['p2 = ' num2str(pval2) '; c2 = ' num2str(cval2) '; k2 = ' num2str(kval2) ];
        string3=['pm1 = ' num2str(pmed1) '+-' num2str(mStdL(1,1)) '; cm1 = ' num2str(cmed1) '+-' num2str(mStdL(1,3)) '; km1 = ' num2str(kmed1) '+-' num2str(mStdL(1,5))];
        string4=['pm2 = ' num2str(pmed2) '+-' num2str(mStdL(1,2)) '; cm2 = ' num2str(cmed2) '+-' num2str(mStdL(1,4)) '; km2 = ' num2str(kmed2) '+-' num2str(mStdL(1,6))];
        text(max(time_asf)*0.05,yy(2)*0.9,string1,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.85,string2,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.8,string3,'FontSize',10);
        text(max(time_asf)*0.05,yy(2)*0.75,string4,'FontSize',10);
    end
    string=['H = ' num2str(H) ' P = ' num2str(P) ' KS-Statistic) = ' num2str(KSSTAT)];
    text(max(time_asf)*0.05,yy(2)*0.1,string,'FontSize',10);
    sAIC = ['AIC = ' num2str(fAIC)];
    text(max(time_asf)*0.05,yy(2)*0.05,sAIC,'FontSize',10);
    sRMS = ['RMS = ' num2str(fRMS)];
    text(max(time_asf)*0.05,yy(2)*0.15,sRMS,'FontSize',10);
    % Legend
    sModel = ['Model ' num2str(nMod)];
    legend([pf2 pf1 paf],'Data',sModel,'Sec. AF','location','Best');


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

    sModel1 = ['Info: Best model is ' num2str(nMod)];
    text(max(time_asf)*0.05,yy(2)*0.2,sModel1,'FontSize',10);
    % Figure settings
    set(gca,'FontSize',12,'Fontweight','bold','Linewidth',2)
    xlabel('Time [Days after mainshock]','FontSize',12,'Fontweight','bold')
