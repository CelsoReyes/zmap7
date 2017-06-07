function [mResult, mResult2]=calc_pwtime(a,fMinTime, fMaxTime, fTstep, timef,bootloops,maepi, nMod)
% function [mResult] = calc_pwtime(a,fMinTime, fMaxTime, fTstep, timef,bootloops,maepi, nMod);
% -------------------------------------------------------------------------
% Calculate and plot p,c,k-value evolution with time
%
% Input variables:
% a         : earthquake catalog
% fMinTime  : Starting time after mainshock to calculate Omori-parameters
%             in days
% fMaxTime  : End time after mainshock to calculate Omori-parameters
%             in days
% fTstep    : Time step length fMinTime:fTstep:fMaxTime [days]
% timef     : dummy for forecast period, usually =1
% bootloops : Number of bootstraps
% maepi     : mainshock
% nMod      : Models to fit aftershock sequence
%
% j.woessner@sed.ethz.ch
% last update: 29.09.2004

% Surpress warnings from fmincon
warning off;

% Initialize
mResult = [];
mResult2 = [];

% Time loop
for time = fMinTime:fTstep:fMaxTime
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
    eqcatalogue = a(l,:);

    % time_as: Learning period
    l = tas <= time;
    time_as=tas(l);
    if length(time_as) > 50

        % Times up to the forecast time
        lf = tas <= time+timef ;
        time_asf= [tas(lf) ];
        time_asf=sort(time_asf);


        % Calculate uncertainty and mean values of p,c,and k
        [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1,nMod);
        pmed1 = mMedModF(1,1);
        pstd1 = mMedModF(1,2);
        pmed2 = mMedModF(1,3);
        pstd2 = mMedModF(1,4);
        cmed1 = mMedModF(1,5);
        cstd1 = mMedModF(1,6);
        cmed2 = mMedModF(1,7);
        cstd2 = mMedModF(1,8);
        kmed1 = mMedModF(1,9);
        kstd1 = mMedModF(1,10);
        kmed2 = mMedModF(1,11);
        kstd2 = mMedModF(1,12);

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


        % Calculate aftershock sequence ...
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
                end; %END of IF on fT1
            end; % End of FOR length(time_as)
        end; % End of if on nMod
        time_as=sort(time_as);
        cumnr_modelf=sort(cumnr_modelf);


        % Calculate KSTEST2 as a measure of the goodness of fit
        [H,P,KSSTAT] = kstest2(cumnr_modelf,cumnrf);

        % Calculate RMS
        i=(1:1:length(time_as))';
        fRMS = (sum((i-cumnr_modelf).^2)/length(i))^0.5;

        % Result matrix
        mResult = [mResult; time pval1 pval2 cval1 cval2 kval1 kval2 fAIC fL H P KSSTAT fRMS];
        mResult2 = [mResult2; pmed1 pstd1 pmed2 pstd2 cmed1 cstd1 cmed2 cstd2 kmed1 kstd1 kmed2 kstd2];
    else
        mResult = [mResult; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
        mResult2 = [mResult2; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ];
    end % ENDIF on length(time_as)
end % FOR time

%save Result_pwtime.mat mResult mResult2;

% figure_w_normalized_uicontrolunits('tag','p-value time series', 'visible','on')
% hPplot4 = plot(mResult(:,1),mResult2(:,1));
% hold on
% hPplot=plot(mResult(:,1),mResult(:,2),'-k','Linewidth',2)
% hPplot2 = plot(mResult(:,1),mResult2(:,1)+mResult2(:,2));
% hPplot3 = plot(mResult(:,1),mResult2(:,1)-mResult2(:,2));
% set(hPplot2,'Linestyle','--','Linewidth',2,'Color',[0.5 0.5 0.5]);
% set(hPplot3,'Linestyle','--','Linewidth',2,'Color',[0.5 0.5 0.5]);
% set(hPplot4,'Linestyle','--','Linewidth',2,'Color',[0.5 0.5 0.5]);
% set(hPplot,'Linewidth',2)
% xlabel('Time after mainshock [days]','Fontweight','bold','FontSize',12)
% ylabel('p-value','Fontweight','bold','FontSize',12)
% set(gca,'Fontweight','bold','FontSize',12,'Box','on','Tickdir','out')

% Smoothing the plot
nWindowSize = 5;
figure_w_normalized_uicontrolunits('tag','p-value time series smooth', 'visible','on')
mPmean = filter(ones(1,nWindowSize)/nWindowSize,1,mResult2(:,1));
mPmean(1:nWindowSize,1)=mResult2(1:nWindowSize,1);
mPstd1 = filter(ones(1,nWindowSize)/nWindowSize,1,mResult2(:,2));
mPstd1(1:nWindowSize,1)=mResult2(1:nWindowSize,2);

mP = filter(ones(1,nWindowSize)/nWindowSize,1,mResult(:,2));
mP(1:nWindowSize,1)=mResult(1:nWindowSize,2);
% Plotting
hp1=plot(mResult(:,1),mPmean,'--','Linewidth',2,'Color',[0.3 0.3 0.3]);
hold on;
hp2=plot(mResult(:,1),mPmean-mPstd1,'-.','Linewidth',2,'Color',[0.5 0.5 0.5]);
plot(mResult(:,1),mPmean+mPstd1,'-.','Linewidth',2,'Color',[0.5 0.5 0.5]);
hPplot=plot(mResult(:,1),mResult(:,2),'-k','Linewidth',2)
ylabel('p-value','Fontweight','bold','FontSize',12)
% xlim([(min(mResult(:,1))) (max(mResult(:,1)))])
% ylim([floor(min(mP(:,1))) ceil(max(mP(:,1)))])
xlabel('Time / [days after main shock]','Fontweight','bold','FontSize',12)
l1=legend([hp1 hp2 hPplot],'p-value (mean)','\sigma p','p-value');
set(l1,'Fontweight','bold')
set(gca,'Fontweight','bold','FontSize',10,'Linewidth',2,'Tickdir','out')
