function [fProbability, fMc] = calc_McGridN(mCatalog, fBinning)
% [fProbability, fMc] = function calc_McGridN(mCatalog, fBinning);
% --------------------------------------------
% Determine Mc using maximum likelihood score fitting  non-cumulative
% frequency magnitude distribution above and below Mc:
% below Mc with an exponential function: M = c*exp(d*M)
% above: Gutenberg-Richter law
% Normalized version !!!!
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Binning interval, usually 0.1
%
% Outgoing variables:
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 16.11.02

% Initialize
vProbability = [];
vMc = [];
vABValue =[];
vX_res = [];
vNCumTmp = [];

% Determine exact time period
fPeriod1 = max(mCatalog(:,3)) - min(mCatalog(:,3));

% Determine max. and min. magnitude
fMinMag = floor(min(mCatalog(:,6)));
if fMinMag > 0
    fMinMag = 0;
end
fMaxMag = ceil(10 * max(mCatalog(:,6))) / 10;

% % Time normalization
% vFMD(2,:) = ceil(vFMD(2,:)./fPeriod1);
% vNonCFMD(2,:) = ceil(vNonCFMD(2,:)./fPeriod1);

%fMc = calc_Mc(mCatalog, nCalculateMC)
for fMc = 0.8:0.1:2
    % Calculate FMD for original catalog
    [vFMD, vNonCFMD] = calc_FMD(mCatalog);
    vNonCFMD = fliplr(vNonCFMD);
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
    [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog(vSel,:), fBinning);
    vFMD(2,:) = ceil(vFMD(2,:)./fPeriod1);
    vNonCFMD(2,:) = ceil(vNonCFMD(2,:)./fPeriod1);
    % Compute quantity of earthquakes by power law
    vMstep = [fMinMag:0.1:fMaxMag];
    vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number
    % Compute non-cumulative numbers vN
    fNCumTmp = 10^(fAValue-fBValue*(fMaxMag+0.1));
    vNCumTmp  = [vNCum fNCumTmp];
    %vNonCFMD(2,:) = ceil(vNonCFMD(2,:)./fPeriod1);
    vN = abs(diff(vNCumTmp));
    %     % Normalizea-value
    fAValue = fAValue./fPeriod1;
    % Normlize vN
    vN = vN./fPeriod1;
    mData = [vN' vNonCFMD'];
    vSel = (mData(:,2) >= fMc);
    mDataTest = mData(~vSel,:);
    mDataTmp = mData.subset(vSel);
    % Curve fitting: Non cumulative part below Mc
    options = optimset;
    options = optimset('Display','off','Tolfun',1e-6,'TolX',0.0001);
    [vX, resnorm, resid, exitflag]=lsqcurvefit(@calc_expdecay2,[0 1], mDataTest(:,2), mDataTest(:,3));
    mDataTest(:,1) = vX(1).*exp(vX(2).*mDataTest(:,2))-1;
    vX_res = [vX_res; vX resnorm exitflag];
    %% Set data together
    mDataTest = [mDataTest; mDataTmp];
    vProb_ = calc_log10poisspdf(vNonCFMD(2,:)', ceil(mDataTest(:,1)));
     % Sum the probabilities
    fProbability = (-1) * sum(vProb_);
    vProbability = [vProbability; fProbability];
    vMc = [vMc; fMc];
    vABValue = [vABValue; fAValue fBValue];
    % Clear variables
    vNCumTmp = [];
    mModelDat = [];
    vNCum = [];
    vSel = [];
    mDataTest = [];
end
mResult = [vProbability vMc vABValue vX_res];
vSel = (mResult == min(mResult(:,1)));
mResult = mResult(vSel,:);
if length(mResult(:,1)) > 1
    fProbability = max(mResult(:,1));
    fMc = max(mResult(:,2));
else
    fProbability = mResult(1,1);
    fMc = mResult(1,2);
end

% figure_w_normalized_uicontrolunits(400)
% plot(vMc, vProbability,'*');
