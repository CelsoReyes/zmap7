function [mLMagsig, mHMagsig, fLZmax, fLZmean, fLZmin, fHZmax, fHZmean, fHZmin] = calc_Magsig(mCat1, mCat2 , fPeriod1, fPeriod2, fBinning)
% function [mLMagsig, mHMagsig, fLZmax, fLZmean, fLZmin, fHZmax, fHZmean, fHZmin] =
%           calc_Magsig(mCat1, mCat2 , fPeriod1, fPeriod2, fBinning);
%-----------------------------------------------------------------------------------
% Calculate the magnitude signature
%
% Incoming variables:
% mCat1: EQ catalog period 1 (background)
% mCat2: EQ catalog period 2 (foreground)
% fPeriod1 : Length of time period 1 in dec. days
% fPeriod2 : Length of time period 2 in dec. days
% fBinning : Time length of bins in dec. years
%
% Outgoing variables:
% mLMagsig : Matrix of magnitude signature "and below"
% mHMagsig : Matrix of magnitude signature "and above"
% fLZmax   : maximum z-value of mLMagsig
% fHZmax   : maximum z-value of mHMagsig
% fLZmean  : mean z-value of mLMagsig
% fHZmean  : mean z-value of mHMagsig
% fLZmin   : minimum z-value of mLMagsig
% fHZmin   : minimum z-value of mHMagsig
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 07.10.02

% report_this_filefun(mfilename('fullpath'));
% Track changes:

%% Intialize
%% Binnings of time periods
vBinPer1 = min(mCat1(:,3)):fBinning:max(mCat1(:,3));
vBinPer2 = min(mCat2(:,3)):fBinning:max(mCat2(:,3));


fMinMag = floor(min([min(mCat1(:,6)) min(mCat2(:,6))]));
fMaxMag = ceil(max([max(mCat1(:,6)) max(mCat2(:,6))]));
vLMagsig = zeros(size(fMinMag:0.1:fMaxMag));
vHMagsig = zeros(size(fMinMag:0.1:fMaxMag));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Loop over all magnitude bands
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wai = waitbar(0,'Please wait...');
% set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Percent completed');
% nmag = length(mmin:0.1:mmax);
 nStep = 0;

for i = fMinMag:0.1:fMaxMag
%     waitbar(nStep/length(vLMagsig));
    nStep = nStep+1;
    % disp(i)
    %%%%% START computation Magnitude signature for "magnitude and below"
    %% Datata selection
    vSel1 = mCat1(:,6) <= i;
    mTmpCat1 = mCat1(vSel1,:);
    vSel2 = mCat2(:,6) <= i;
    mTmpCat2 = mCat2(vSel2,:);
    if (isempty(mTmpCat1) | isempty(mTmpCat2))
        vLMagsig(nStep) = NaN;
        %disp('Not enough data');
    else
        [vCum_TPer1, vBinPer1] = hist(mTmpCat1(:,3),vBinPer1);     %    background
        [vCum_TPer2, vBinPer2] = hist(mTmpCat2(:,3),vBinPer2);     %    foreground
        fMean1 = mean(vCum_TPer1(1:length(vBinPer1)));
        fMean2 = mean(vCum_TPer2(1:length(vBinPer2)));
        fVar1 = cov(vCum_TPer1(1:length(vBinPer1)));
        fVar2 = cov(vCum_TPer2(1:length(vBinPer2)));
        if sqrt(fVar1/length(vBinPer1)+fVar2/length(vBinPer2)) > 0
            vLMagsig(nStep) = (fMean1 - fMean2)/(sqrt(fVar1/length(vBinPer1)+fVar2/length(vBinPer2)));
        end
    end; % Check on emptiness
    %%%%% END computation Magnitude signature "magnitudes and below"
    %%%%% START  computation Magnitude signature "magnitudes and above"
    %% Datata selection
    vSel1 = mCat1(:,6) >= i;
    mTmpCat1 = mCat1(vSel1,:);
    vSel2 = mCat2(:,6) >= i;
    mTmpCat2 = mCat2(vSel2,:);
    if (isempty(mTmpCat1) | isempty(mTmpCat2))
        vHMagsig(nStep) = NaN;
        %disp('Not enough data');
    else
        [vCum_TPer1, vBinPer1] = hist(mTmpCat1(:,3),vBinPer1);     %    background
        [vCum_TPer2, vBinPer2] = hist(mTmpCat2(:,3),vBinPer2);     %    foreground
        fMean1 = mean(vCum_TPer1(1:length(vBinPer1)));
        fMean2 = mean(vCum_TPer2(1:length(vBinPer2)));
        fVar1 = cov(vCum_TPer1(1:length(vBinPer1)));
        fVar2 = cov(vCum_TPer2(1:length(vBinPer2)));
        if sqrt(fVar1/length(vBinPer1)+fVar2/length(vBinPer2)) > 0
            vHMagsig(nStep) = (fMean1 - fMean2)/(sqrt(fVar1/length(vBinPer1)+fVar2/length(vBinPer2)));
        end
    end; % Check on emptiness
end; % End for i
% close(wai); % Close waitbar

%% Max, mean, min values for "and below"
vMagnitudes = fMinMag:0.1:fMaxMag;
mLMagsig = [vLMagsig' vMagnitudes'];
[fLZmax, nIndMax] = max(mLMagsig(:,1));
[fLZmin, nIndMin] = min(mLMagsig(:,1));
vLZmax = mLMagsig(nIndMax,:);
vLZmin = mLMagsig(nIndMin,:);
vSel = ~isnan(mLMagsig(:,1));
mLMagsigTmp = mLMagsig(vSel,:);
fLZmean = mean(mLMagsigTmp(:,1));

%% Max, mean, min values for "and above"
mHMagsig = [vHMagsig' vMagnitudes'];
[fHZmax, nIndMax] = max(mHMagsig(:,1));
[fHZmin, nIndMin] = min(mHMagsig(:,1));
vHZmax = mHMagsig(nIndMax,:);
vHZmin = mHMagsig(nIndMin,:);
vSel= ~isnan(mHMagsig(:,1));
mHMagsigTmp = mHMagsig(vSel,:);
fHZmean = mean(mHMagsigTmp(:,1));
