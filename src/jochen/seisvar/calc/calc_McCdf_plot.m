function [fProbMin, fMcBest, vX_res, fNmaxBest, mDatPredBest] =calc_McCdf_plot(mCatalog, fBinning)
% function calc_McCdf_plot(mCatalog, fBinning);
% --------------------------------------------
% Determine Mc using maximum likelihood score
% Fitting cumulative frequency magnitude distribution above and below Mc:
% below Mc with Cumulative density function
% above: Gutenberg-Richter law
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
mFitRes = [];
vX_res = [];
vNCumTmp = [];
mDataPred = [];

% Cut catalog for magnitudes M >= 0
vSel0 = (mCatalog(:,6) >= 0);
mCatalog = mCatalog(vSel0,:);
mCat = mCatalog;

% Determine exact time period
fPeriod1 = max(mCatalog(:,3)) - min(mCatalog(:,3));

% Determine max. and min. magnitude
fMinMag = floor(min(mCatalog(:,6)));
% if fMinMag > 0
%     fMinMag = 0;
% end
fMaxMag = ceil(10 * max(mCatalog(:,6))) / 10;


%Calculate FMD for original catalog
[vFMDorg, vNonCFMDorg] = calc_FMDMag(mCatalog);
%    vNonCFMD = fliplr(vNonCFMD);
for fMc =fMinMag:0.1:fMaxMag-1
    vFMD = vFMDorg;
    vNonCFMD = vNonCFMDorg;
    vNonCFMD = fliplr(vNonCFMD);
    mCatalog = mCat;
    % Calculate a and b-value for GR-law and distribution vNCum
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
    [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog(vSel,:), fBinning)
    % Normalize to time period
    vFMD(2,:) = ceil(vFMD(2,:)./fPeriod1);
    vNonCFMD(2,:) = ceil(vNonCFMD(2,:)./fPeriod1);
    % Compute quantity of earthquakes by power law
    vMstep = [fMinMag:0.1:fMaxMag];
    vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number

    %     % Calculate lower part
    %     vSel2 = (mCatalog(:,6) < fMc);
    %     [vEv,vMags,vEv_sum,vEv_sum_rev,vMags_rev]=calc_cumulsum(mCatalog(vSel2,:));
    %     mCumasc = [vMags' vEv_sum']; % Cumulative sum N = sum(M) with Mi <= M
    %     vSelMag = (vMags >= fMinMag & vMags <= fMaxMag);
    %     mCumasc = mCumasc(vSelMag,:);
    %     figure_w_normalized_uicontrolunits(10)
    %     semilogy(vMags, vEv,'bo',vMags,vEv_sum,'r^', vMags_rev, vEv_sum_rev,'k*')
    %     pause
    % Compute non-cumulative numbers vN
    fNCumTmp = 10^(fAValue-fBValue*(fMaxMag+0.1));
    vNCumTmp  = [fNCumTmp vNCum];
    vN = abs(diff(vNCumTmp));
    %     % Normalizea-value
    fAValue = fAValue./fPeriod1;
    % Normlize vN
    vN = vN./fPeriod1;
    % Data selection
    % Adjust magnitude ranges of vN and vNonCFMD
    vSelM = (vNonCFMD(1,:) >= fMinMag)
    vNonCFMD = vNonCFMD(:,vSelM);
    mData = [vN' vNonCFMD'] % Non cumulative
    %mData = [vN' mCumasc];
    vSel = (mData(:,2) >= fMc);
    mDataTest = mData(~vSel,:);
    % For cutted catalog move lowest magnitude to 0
    mDataTest(:,2) = mDataTest(:,2)-fMinMag;
    mDataTmp = mData(vSel,:);
    fNmax = max(mDataTest(:,3));
    if (~isempty(fNmax) & ~isnan(fNmax) & fNmax ~= 0 & length(mDataTest(:,1) > 4))
        mDataTest(:,3) = mDataTest(:,3)/fNmax; % Normalize datavalues for fitting with CDF
        % Curve fitting: Non cumulative part below Mc
        options = optimset;
        options = optimset('Display','iter','Tolfun',1e-5,'TolX',0.001,'MaxFunEvals', 100000);
        [vX, resnorm, resid, exitflag, output, lambda, jacobian]=lsqcurvefit(@calc_lognormal,[0.1 0.1], mDataTest(:,2), mDataTest(:,3));
        mDataTest(:,1) = logncdf(mDataTest(:,2), vX(1), vX(2))*fNmax;
        if (length(mDataTest(:,2)) > length(vX(1,:)))
            %% Confidence interval
            [vPred,delta] = nlpredci(@calc_lognormal,mDataTest(:,2),vX, resid, jacobian);
        else
            vPred = nan;
            delta = nan;
        end
 % For cutted catalog move lowest magnitude back to what it is
        mDataTest(:,2) = mDataTest(:,2)+fMinMag;
        figure_w_normalized_uicontrolunits(310)
        plot(mDataTest(:,2),vPred)
        hold on
        plot(mDataTest(:,2), mDataTest(:,3),'+r')
        plot(mDataTest(:,2),vPred + delta,'--g')
        plot(mDataTest(:,2),vPred - delta,'--g')
        hold off;
        xlabel('Magnitude')
        ylabel('CDF fit')
        % Use different inline functions
        %     vFun = inline('expcdf(vXdata,vX(1))', 'vX', 'vXdata');
        %     [vX, resnorm, resid, exitflag, output, lambda, jacobian]=lsqcurvefit(vFun,1, mDataTest(:,2), mDataTest(:,3));
        %     mDataTest(:,1) = expcdf(mDataTest(:,2), vX(1))*fNmax;
        %       vFun = inline('normcdf(vXdata,vX(1),vX(2))', 'vX', 'vXdata');
        %      [vX, resnorm, resid, exitflag, output, lambda, jacobian]=lsqcurvefit(vFun,[1.8 2], mDataTest(:,2), mDataTest(:,3));
        %      mDataTest(:,1) = normcdf(mDataTest(:,2), vX(1), vX(2))*fNmax;
        vX
        mFitRes = [mFitRes; vX resnorm exitflag];
        %% Set data together
        mDataTest(:,3) = mDataTest(:,3)*fNmax;
        mDataPred = [mDataTest; mDataTmp];
        %    mDataPred(:,1) = cumsum(mDataPred(:,1)); % Create cumulative sum for model
        %    [mCumasc mDataPred]
        % vProb_ = calc_log10poisspdf(vNonCFMD(2,:)', ceil(mDataPred(:,1))); % Non-cumulative
        vProb_ = calc_log10poisspdf(mDataPred(:,3), ceil(mDataPred(:,1))); % Non-cumulative
        %vProb_ = calc_log10poisspdf(mDataTest(:,3), ceil(mDataTest(:,1))); % Non-cumulative
        % Sum the probabilities
        fProbability = (-1) * sum(vProb_);
        vProbability = [vProbability; fProbability];
        vMc = [vMc; fMc];
        vABValue = [vABValue; fAValue fBValue];

        figure_w_normalized_uicontrolunits(200)
        subplot(3,1,1)
        %plot(vFactor, exp(vFactor)-1);
        plot(mDataTest(:,2), mDataTest(:,1),'-r', mDataTest(:,2), mDataTest(:,3), '*')
        ylabel('CDF fit');
        sTitle = ['Test: Mc = ', num2str(fMc)];
        title(sTitle);
        %     hold on;
        %     plot(vMags, vEv_sum, 'g^')
        %     %plot(vNonCFMD(1,:)', vNonCFMD(2,:),'g^')
        %     hold off;
        %     %figure_w_normalized_uicontrolunits(300)
        subplot(3,1,2)
        %     semilogy(vMags,vEv_sum,'g^',mDataPred(:,2),mDataPred(:,1),'o')
        plot(vNonCFMD(1,:)', vNonCFMD(2,:)', '^', vNonCFMD(1,:)', vN, '*', vNonCFMD(1,:)',mDataPred(:,1),'o')
        ylabel('NonCumFMD fit')
        subplot(3,1,3)
        mTmp = flipud(mDataPred);
        mTmp(:,1) = cumsum(mTmp(:,1));
        mTmp(:,3) = cumsum(mTmp(:,3));
        semilogy(mTmp(:,2), mTmp(:,1),'ro',mTmp(:,2), mTmp(:,3),'g*',vMstep, vNCum./fPeriod1)
        xlabel('Magnitude')
        ylabel('FMD fit')


        if (fProbability == min(vProbability))
            vPredBest = vPred*fNmax;
            vDeltaBest = delta;
            mDat = mDataTest;
            vNBest = vN;
            fMcBest = fMc;
            mDatPredBest = mDataPred;
            vX_res = [vX resnorm exitflag];
            fNmaxBest = fNmax
        end
    else
        fProbMin = nan;
        fMcBes = nan;
    end; % END of IF fNmax
    % Clear variables
    vNCumTmp = [];
    mModelDat = [];
    vNCum = [];
    vSel = [];
    mDataTest = [];
    mDataPred = [];
    %pause
end; % END of FOR fMc
figure_w_normalized_uicontrolunits(400)
plot(vMc, vProbability,'*');
xlabel('Mc')
ylabel('MLS')
figure_w_normalized_uicontrolunits(410)
plot(mDat(:,2),vPredBest)
hold on;
plot(mDat(:,2), mDat(:,3),'+r')
sTitlestr = ['mu = ' num2str(vX(1)) ', sigma = ' num2str(vX(2))];
title(sTitlestr)
% plot(mDat(:,2),vPredBest + vDeltaBest,'--g')
% plot(mDat(:,2),vPredBest - vDeltaBest,'--g')
hold off;
figure_w_normalized_uicontrolunits(420)
semilogy(vNonCFMD(1,:)', vNonCFMD(2,:)', '^', vNonCFMD(1,:)', vNBest, '*', vNonCFMD(1,:)',mDatPredBest(:,1),'o')
% sTitlestr = ['N = ' num2str(vX(1)) ' * exp( ' num2str(vX(2)) ' * M) at ' num2str(fMcBest)];
sTitlestr = ['Mc = ' num2str(fMcBest)];
title(sTitlestr)
xlabel('Magnitude')

% Result matrix
mResult = [vProbability vMc vABValue mFitRes]
