% Script : theo_seisvar.m
% ------------------------
% Demonstrate theoretical basis of magnitude shifts, stretches and rate changes
% !! Choose Parkfield data or Synthetic data
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 28.10.02

% Initialize
vBic = [];

%%% Create theoretical shifts
mCat = a;

% bChoice : Data choice; 1 Parkfield, 0 Synthetic
bChoice = 0;
if bChoice == 1
    % %%% Use Parkfield data
    vSel = (a(:,3) >= 1980.33 & a(:,3) < 1983.33 & 0.5 <= a(:,6) & a(:,6) < 1.5);
    mCat1 = a(vSel,:);
%     mCat2 = mCat1;
    % Copy of time period 1980.33-1983.32 to 1983.33-1986.32
%     mCat2(:,3) = mCat1(:,3)+3;
    vSel2 = (a(:,3) >= 1983.33 & a(:,3) < 1988.33  & 0.5 <= a(:,6) & a(:,6) < 1.5);
    mCat2 = a(vSel2,:);

else
    %% Use synthetic data
    mCat1 = mCat;
    mCat2 = mCat;
    mCat2(:,3) = mCat2(:,3)+6;
end

%%%%%%% Manipulation of dataset
% Magnitude shift by 0.3, all magnitudes
 mCat2(:,6) = mCat2(:,6)+0.3;

% Magnitude shift by 0.3, magnitudes 1.5-2.5
% vSel = (mCat2(:,6) >=1.5 & mCat2(:,6) <= 2.5);
% mCat2(vSel,6) = mCat2(vSel,6)+0.3;

% % Magnitude shift by 0.3, magnitudes above 1.5
% vSel = (mCat2(:,6) >=1.5 );
% mCat2(vSel,6) = mCat2(vSel,6)+0.3;

% Magnitude stretch with factor 1.2, all magnitudes
% mCat2(:,6) = 1.3.*mCat2(:,6);

% Magnitude stretch with factor 1.2, magnitudes above 1.5
% vSel = (mCat2(:,6) >=1.5);
% mCat2(vSel,6) = 1.2.*mCat2(vSel,6);

% Magnitude stretch with factor 1.2, in magnitude band above 1.5 - 2.5
% vSel = (mCat2(:,6) >=1.5 & mCat2(:,6) <= 2.5 );
% mCat2(vSel,6) = 1.2.*mCat2(vSel,6);

% Magnitude transformation
% mCat2(:,6) = mCat2(:,6).*1.2+0.2;

% %% Rate increase in 2nd period in magnitude band 1.5-2.5
% vSel2 = (mCat2(:,6) >= 1.5 & mCat2(:,6) <= 2.5);
% mCat2Tmp = mCat2(vSel2,:);
% mCat2 = [mCat2; mCat2Tmp];

% %% Rate increase in 2nd period in magnitude band above 1.5
% vSel2 = (mCat2(:,6) >= 1.5);
% mCat2Tmp = mCat2(vSel2,:);
% mCat2 = [mCat2; mCat2Tmp];

% %% Rate increase in 2nd period in entire magnitude band
%mCat2 = [mCat2; mCat2];

%% Rate decrease in 2nd period in magnitude and 1.5-2.5 simulated by increase in 1st period
% vSel1 = (mCat1(:,6) >= 1.5 & mCat1(:,6) <= 2.5);
% mCat1Tmp = mCat1(vSel1,:);
% mCat1 = [mCat1; mCat1Tmp];


%%% Combinations
% % %% Rate increase in 2nd period in magnitude band 1.5-2.5 and shift
% vSel2 = (mCat2(:,6) >= 1.5 & mCat2(:,6) <= 2.5);
% mCat2Tmp = mCat2(vSel2,:);
% mCat2 = [mCat2; mCat2Tmp];
% vSel = (mCat2(:,6) >=1.5 & mCat2(:,6) <= 2.5);
% mCat2(vSel,6) = mCat2(vSel,6)+0.3;


% % Paste catalog together
mCat = [mCat1; mCat2];

% Time periods for mormalization
fPeriod1 = (max(mCat1(:,3))-min(mCat1(:,3)));
fPeriod2 = (max(mCat2(:,3))-min(mCat2(:,3)));

% Plot non-cumulative FMD and shift
figure_w_normalized_uicontrolunits('tag','noncum','Name','FMDs');
[mEv_val mMags mEv_valsum mEv_valsum_rev,  mMags_rev] = calc_cumulsum(mCat1);
[mEv_val2 mMags2 mEv_valsum2 mEv_valsum_rev2,  mMags_rev2] = calc_cumulsum(mCat2);
subplot(2,1,1);
plot(mMags,mEv_val,'-o',mMags2,mEv_val2,'-*');
set(gca, 'Xlim', [0 ceil(max(mCat(:,6)))]);
subplot(2,1,2);
semilogy(mMags,mEv_valsum,'-o','Color',[0 0 1])
hold on;
semilogy(mMags2,mEv_valsum2,'-*','Color',[0 0.5 0])
set(gca, 'Xlim', [0 ceil(max(mCat(:,6)))],'Ylim', [0 ceil(max(mEv_valsum2))],'Yscale', 'linear');
xlabel('Magnitude');

% Plot histogram difference
[vMag1,vBin1]=histogram(mCat1(:,6),0:0.1:max(mCat(:,6)));
[vMag2,vBin2]=histogram(mCat2(:,6),0:0.1:max(mCat(:,6)));
vMag1 = vMag1./fPeriod1;
vMag2 = vMag2./fPeriod2;
figure_w_normalized_uicontrolunits('tag','Bindifference','Name','Magnitude bin difference plot');
bar(vBin2,vMag2-vMag1);
set(gca, 'Xlim', [0 ceil(max(mCat(:,6)))]);
xlabel('Magnitude');
ylabel('Normalized difference in magnitude bins (Per2-Per1)');

% Parkfield
%[mLMagsig, mHMagsig, fLZmax, fLZmean, fLZmin, fHZmax, fHZmean, fHZmin] = plot_MagsigShow(mCat1, mCat2 , 3, 3, 0.1,0.3)
%% Synthetic catalog
[mLMagsig, mHMagsig, fLZmax, fLZmean, fLZmin, fHZmax, fHZmean, fHZmin] = plot_MagsigShow(mCat1, mCat2 , 6, 6, 0.1,0.3)
newt2 = mCat;
Cum_timeplot

% if bChoice == 1
%     % Parkfield
%     [fMshift] = test_Magshift(mCat, 1983.33, 0, 1, 5);
% else
%     % Synthetic catalog
%     [fMshift] = test_Magshift(mCat, 2002, 0, 6, 3);
% end

%%% Maximum likelihood scores and BICs
[fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans(mCat1, mCat2);
[fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch(mCat1, mCat2);
[fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate(mCat1, mCat2);
[fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM(mCat1, mCat2);
[fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate(mCat1, mCat2);
[fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_loglikelihood_stretch_rate(mCat1, mCat2);
[fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_loglikelihood_dMdSrate(mCat1, mCat2);


vBic = [fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
[fIndice] = find(vBic == min(vBic));
if length(fIndice) > 1
    vBic
else
    % Initialize values for model plotting
    fdMs = nan; % Shift
    fdS = nan; % Stretch
    fRf = nan; % rate factor
    switch fIndice
    case 1
        plot_mls1p(mLikeli_dM(:,1), mLikeli_dM(:,2), 1);
        fdMs = fdM;
        sTxt_dM = ['Simple magnitude shift: dM = ' num2str(fdM) ' , '...
                ' Max. likelihood score = ' num2str(fProb_dM) ' , BIC = ' num2str(fBic_dM)]
    case 2
        plot_mls1p(mLikeli_dS(:,1), mLikeli_dS(:,2), 2);
        fdS = fS;
        sTxt_stretch = ['Magnitude stretch: c = ' num2str(fS) ' , '...
                ' Max. likelihood score = ' num2str(fProb_stretch) ' , BIC = ' num2str(fBic_stretch)]
    case 3
        plot_mls1p(mLikeli_Rate(:,1), mLikeli_Rate(:,2), 3);
        fRf = fFac;
        sTxt_rate = ['Rate change: R_f = ' num2str(fFac) ' , '...
                ' Max. likelihood score = ' num2str(fProb_Rate) ' , BIC = ' num2str(fBic_Rate)]
    case 4
        plot_mls2p(mLikeli_dMrate(:,1), mLikeli_dMrate(:,2), mLikeli_dMrate(:,3),3);
        fdM = fdM_rate;
        fRf = fdM_Fac;
        sTxt_dMrate = ['Magnitude shift and rate change: dM = ' num2str(fdM_rate) ' , R_f =' num2str(fdM_Fac) ' , '...
                ' Max. likelihood score = ' num2str(fProb_dM) ' , BIC = ' num2str(fBic_dMrate)]
    case 5
        plot_mls2p(mLikeli_Trans(:,1), mLikeli_Trans(:,2), mLikeli_Trans(:,3), 1);
        fdM = fdM_st;
        fdS = fStretch;
        sTxt_Trans = ['Magnitude transformation: c = ' num2str(fStretch) ' , dM_st = ' num2str(fdM_st) ' , '...
                ' Max. likelihood score = ' num2str(fProb_Trans) ' , BIC = ' num2str(fBic_Trans)]
    case 6
        plot_mls2p(mLikeli_dSrate(:,1), mLikeli_dSrate(:,2), mLikeli_dSrate(:,3), 2);
        fdS = fdS_rate;
        fRf = fdS_Fac;
        sTxt_dSrate = ['Stretch and rate change: c = ' num2str(fdS_rate) ' , R_f =' num2str(fdS_Fac) ' , '...
                ' Max. likelihood score = ' num2str(fProb_dSrate) ' , BIC = ' num2str(fBic_dSrate)]
    case 7
        plot_mls3p(mLikeli_all(:,1), mLikeli_all(:,2), mLikeli_all(:,3), mLikeli_all(:,4));
        fdM = fdM_all;
        fdS = fdS_all;
        fRf = fFac_all;
        sTxt_dSdMrate = ['Shift, Stretch and Rate change: dM = ' num2str(fdM_all) ' , c = ' num2str(fdS_all) ' , R_f =' num2str(fFac_all) ' , '...
                ' Max. likelihood score = ' num2str(fProb_all) ' , BIC = ' num2str(fBic_all)]
    otherwise
        disp('Something is equal');
    end
    % Plot model
    plot_svmodel(fdM, fdS, fRf, mCat1, mCat2);
end
