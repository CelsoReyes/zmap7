function [fFactorHi, fStdHi, fResHi, fPerHi, fFactorLow, fStdLow, fResLow, fPerLow] = plot_ratefac(mCat1, mCat2, fPeriod1, fPeriod2, fMc1, fMc2)
% [fFactorHi, fStdHi, fResHi, fPerHi, fFactorLow, fStdLow, fResLow, fPerLow] = plot_ratefac(mCat1, mCat2, fPeriod1, fPeriod2, fMc1, fMc2)
% ---------------------------------------------------------------------------------------------------------------------------------------
% Determine rate factor between amount of events between two time periods, differentiated for EQ with M<Mc and M>=Mc.
% Mc = min(fMc1, fMc2);
% N(Per2) = fFac * N (Per1)
% fFac is determined as mean of the factors in the magnitude bins, using a binning of 0.1.A factor for
% magnitudes M<Mc and M>=Mc is determined to explore a difference.Magnitude bins with no earthquakes
% are not used.
%
% Incoming variables:
% mCat1 : EQ catalog period 1
% mCat2 : EQ catalog period 2
% fPeriod1 : Time length period 1 /[dec. year]
% fPeriod2 : Time length period 2 /[dec. year]
% fMc1 : Magnitude of completeness period 1
% fMc2 : Magnitude of completeness period 2
%
% Outgoing variable:
% fFactorHi : Mean rate factor for EQ with M>=Mc
% fStdLow   : Standard deviation of fFactorHi
% fResLow   : Residuum for model application
% fPerHi    : Total percentage of change for EQ with M>=Mc
% fFactorLow : Mean rate factor for EQ with M<Mc
% fStdHi   : Standard deviation offFactorLow
% fResHi   : Residuum for model application
% fPerLow  : Total percentage of change for EQ with M<Mc
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 26.09.02

% Track of changes:


% Initialization
vMaxMag = [max(mCat1(:,6)) max(mCat2(:,6))];
fMaxMag =  max(vMaxMag);
fMc = min([fMc1 fMc2]);

% Binning
%% EQ with M < Mc
vSel1 = (mCat1(:,6) < fMc);
vSel2 = (mCat2(:,6) < fMc);
mCat1Mc = mCat1(vSel1,:);
mCat2Mc = mCat2(vSel2,:);
[vMag1,vBin1]=histogram(mCat1Mc(:,6),0:0.1:fMaxMag);
[vMag1sort,vBin1sort]=sort(vMag1);
[vMag2,vBin2]=histogram(mCat2Mc(:,6),0:0.1:fMaxMag);
[vMag2sort,vBin2sort]=sort(vMag2);

%% EQ with M >= Mc
mCat1McHi = mCat1(~vSel1,:);
mCat2McHi = mCat2(~vSel2,:);
[vMag1Hi,vBin1Hi]=histogram(mCat1McHi(:,6),0:0.1:fMaxMag);
[vMag1Hisort,vBin1Hisort]=sort(vMag1Hi);
[vMag2Hi,vBin2Hi]=histogram(mCat2McHi(:,6),0:0.1:fMaxMag);
[vMag2Hisort,vBin2Hisort]=sort(vMag2Hi);

%% Overall percentage of change of EQs
fPerLow = length(mCat2Mc(:,1))/length(mCat1Mc(:,1));
fPerHi = length(mCat2McHi(:,1))/length(mCat1McHi(:,1));
fPerLow = 100*fPerLow-100;
fPerHi = 100*fPerHi-100;

% Estimate factor between rates
% Factor for values below Mc of Period 1
vMag1 = vMag1/fPeriod1; % Time normalization
vMag2 = vMag2/fPeriod2; % Time normalization
fRatioLow = vMag2./vMag1;
%vSelRat = 1 - (isnan(fRatioLow) + isinf(fRatioLow));
vSelRatLow = (~isnan(fRatioLow) & ~isinf(fRatioLow));
fFactorLow = mean(fRatioLow(vSelRatLow));
fStdLow = std(fRatioLow(vSelRatLow));
vMagModelow = vMag1*fFactorLow;
fResLow = sqrt(sum((vMag2-(vMagModelow)).^2)/length(vMag2)); % Residuum

% Factor for values above or equal Mc of background
vMag1Hi = vMag1Hi/fPeriod1; % Time normalization
vMag2Hi = vMag2Hi/fPeriod2; % Time normalization
fRatioHi = vMag2Hi./vMag1Hi;
%vSelRatHi = 1 - (isnan(fRatioHi) + isinf(fRatioHi));
vSelRatHi = (~isnan(fRatioHi) & ~isinf(fRatioHi));
fFactorHi = mean(fRatioHi(vSelRatHi));
fStdHi = std(fRatioHi(vSelRatHi));
% vSelStd = (fRatioHi <= (fFactorHi+fStdHi) & fRatioHi >= (fFactorHi-fStdHi));
% fFactorHi = mean(fRatioHi(vSelStd))
vMagModel = vMag1Hi*fFactorHi;
fResHi = sqrt(sum((vMag2Hi-(vMagModel)).^2)/length(vMag2Hi)); % Residuum



%% Figures
figure_w_normalized_uicontrolunits(300);
subplot(3,2,1);
bar(vBin1,vMag1)
ylabel('Period 1');
subplot(3,2,3);
bar(vBin2,vMag2)
ylabel('Period 2');
subplot(3,2,5);
bar(vBin2,vMag2-vMag1)
ylabel('Period 2 - Period 1');
subplot(3,2,2);
bar(vBin1Hi,vMag1Hi)
ylabel('Period 1');
subplot(3,2,4);
bar(vBin2Hi,vMag2Hi)
ylabel('Period 2');
subplot(3,2,6);
bar(vBin2Hi,vMag2Hi-vMag1Hi)
ylabel('Period2 - Period 1');


figure_w_normalized_uicontrolunits(400);
subplot(2,1,1);
bar(vBin1,vMag1*fFactorLow-vMag2);
ylabel('Period2 - Period 1');
subplot(2,1,2);
bar(vBin1,vMag1Hi*fFactorHi-vMag2Hi);
ylabel('Period2 - Period 1');
return
