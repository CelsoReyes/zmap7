function [fMshift, fProbability, fBic, mProblikelihood] = calc_loglikelihood_dM_Mc(mCat1, mCat2)
% function [fMshift, fProbability, fBic, mProblikelihood] = calc_loglikelihood_dM_Mc(mCat1, mCat2);
% ----------------------------------------------------------------------------------------------
% Calculate log-likelihood estimation of magnitude shift dM between to periods
%
% Incoming variable
% mCat1 : EQ catalog period 1 (Catalog to be modified)
% mCat2 : EQ catalog period 2 (Observed catalog)
%
% Outgoing variable
% fProbability : log-likelihood probabilty
% fMshift      : Magnitude shift with the lowest  max. lieklihood score
% fBic         : Bayesian Information Criterion value
% mProblikelihood : Solution matrix shift and likelihood score
%
% Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
% last update: 28.10.02

% Initialize
vProbability = [];
vMc = [];
vABValue =[];
mFitRes = [];
vX_res = [];
vNCumTmp = [];
mDataPred = [];
mProblikelihood = [];
vfProbability = [];
vMshift = [];
fBinning = 0.1;

% Cut catalog for magnitudes M >= 0
mCatalog = [mCat1; mCat2];
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

% Calculate FMD for original catalog
[vFMDorg, vNonCFMDorg] = calc_FMD(mCatalog);
for fMc =fMinMag:0.1:fMaxMag-1
    vFMD = vFMDorg;
    vNonCFMD = vNonCFMDorg;
    vNonCFMD = fliplr(vNonCFMD);
    mCatalog = mCat;
    % Calculate a and b-value for GR-law and distribution vNCum
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
    if (length(mCatalog(vSel,1)) >= 20)
        [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog(vSel,:), fBinning);
        % Normalize to time period
        vFMD(2,:) = ceil(vFMD(2,:)./fPeriod1);
        vNonCFMD(2,:) = ceil(vNonCFMD(2,:)./fPeriod1);
        % Compute quantity of earthquakes by power law
        vMstep = [fMinMag:0.1:fMaxMag];
        vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number

        % Compute non-cumulative numbers vN
        fNCumTmp = 10^(fAValue-fBValue*(fMaxMag+0.1));
        vNCumTmp  = [vNCum fNCumTmp];
        vN = abs(diff(vNCumTmp));
        %     % Normalizea-value
        fAValue = fAValue./fPeriod1;
        % Normlize vN
        vN = vN./fPeriod1;
        % Data selection
        % Adjust magnitude ranges of vN and vNonCFMD
        vSelM = (vNonCFMD(1,:) >= fMinMag);
        vNonCFMD = vNonCFMD(:,vSelM);
        mData = [vN' vNonCFMD']; % Non cumulative
        vSel = (mData(:,2) >= fMc);
        mDataTest = mData(~vSel,:);
        fNmax = max(mDataTest(:,3));
        % For cutted catalog move lowest magnitude to 0
        mDataTest(:,2) = mDataTest(:,2)-fMinMag;
        if (~isempty(fNmax) & ~isnan(fNmax) & fNmax ~= 0 & length(mDataTest(:,1) > 4))
            mDataTest(:,3) = mDataTest(:,3)/fNmax; % Normalize datavalues for fitting with CDF
            mDataTmp = mData.subset(vSel);
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
            end; % END: This section is due for errors produced with datasets less long than amount of parameters in vX
            % For cutted catalog move lowest magnitude back to what it is
            mDataTest(:,2) = mDataTest(:,2)+fMinMag;
            % Results of fitting procedure
            mFitRes = [mFitRes; vX resnorm exitflag];
            %% Set data together
            mDataTest(:,3) = mDataTest(:,3)*fNmax;
            mDataPred = [mDataTest; mDataTmp];
            %%%% Now search dM for best fitting model
            mCat1Mod = mDataPred;
            for fMshift = -0.5:0.1:0.5
                % Apply shift
                mCat1Mod(:,6) = mCat1Mod(:,6)+fMshift;
                % Initialize values
                fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
                fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);

                [vPredFMD,vBin1] = hist(mCat1Mod(:,6),0:0.1:fMaxMag);
                [vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
                % Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
                vPredFMD = ceil(vPredFMD./fPeriod1);
                vObsFMD = ceil(vObsFMD./fPeriod2);

                % Calculate the likelihoods for both models
                vProb_ = calc_log10poisspdf(vObsFMD', vPredFMD');
                % Sum the probabilities
                fProbability = (-1) * sum(vProb_);
                vfProbability = [vfProbability; fProbability];
                vMshift = [vMshift; fMshift];
                mCat1Mod = mCat1;
            end
            vProb_ = calc_log10poisspdf(mDataPred(:,3), ceil(mDataPred(:,1))); % Non-cumulative
            % Sum the probabilities
            fProbability = (-1) * sum(vProb_);
            vProbability = [vProbability; fProbability];
            vMc = [vMc; fMc];
            vABValue = [vABValue; fAValue fBValue];
            % Keep best fitting model
            if (fProbability == min(vProbability))
                fProbMin = fProbability;
                vPredBest = vPred*fNmax;
                vDeltaBest = delta;
                mDat = mDataTest;
                vNBest = vN;
                fMcBest = fMc;
                mDatPredBest = mDataPred;
                vX_res = [vX resnorm exitflag];
                fNmaxBest = fNmax;
            end
        else
            fProbMin = nan;
            fMcBes = nan;
        end; % END of IF fNmax
    end; % END of IF length(mCatalog(vSel,1))

    % Clear variables
    vNCumTmp = [];
    mModelDat = [];
    vNCum = [];
    vSel = [];
    mDataTest = [];
    mDataPred = [];
end; % END of FOR fMc
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Initialize
% mProblikelihood = [];
% vfProbability = [];
% vMshift = [];
% fBinning = 0.1;
%
% % Determine exact time period
% fPeriod1 = max(mCat1(:,3)) - min(mCat1(:,3));
% fPeriod2 = max(mCat2(:,3)) - min(mCat2(:,3));
%
% % Calculate Mc for the two periods
% [fProbMin1, fMcBest1] = calc_McCdf(mCat1, fBinning);
% [fProbMin2, fMcBest2] = calc_McCdf(mCat2, fBinning);
%
% mCat1Mod = mCat1;
%
% for fMshift = -0.5:0.1:0.5
%     % Apply shift
%     mCat1Mod(:,6) = mCat1Mod(:,6)+fMshift;
%     % Initialize values
%     fMinMag = min([min(mCat1Mod(:,6)) min(mCat2(:,6))]);
%     fMaxMag = max([max(mCat1Mod(:,6)) max(mCat2(:,6))]);
%
%     [vPredFMD,vBin1] = hist(mCat1Mod(:,6),0:0.1:fMaxMag);
%     [vObsFMD,vBin2] = hist(mCat2(:,6),0:0.1:fMaxMag);
%     % Time normalization and round due to Poisson distribution calculation in calc_log10poisspdf
%     vPredFMD = ceil(vPredFMD./fPeriod1);
%     vObsFMD = ceil(vObsFMD./fPeriod2);
%
%     % Calculate the likelihoods for both models
%     vProb_ = calc_log10poisspdf(vObsFMD', vPredFMD');
%     % Sum the probabilities
%     fProbability = (-1) * sum(vProb_);
%     vfProbability = [vfProbability; fProbability];
%     vMshift = [vMshift; fMshift];
%     mCat1Mod = mCat1;
% end
%
% %%% Find the minimum loglikelihodd score: if the minimum score is obtained several times, calculate MEAN
% %%% of the magnitude shift
% vdMloglikeli = [vfProbability vMshift];
% vSel = (vdMloglikeli == min(vdMloglikeli(:,1)));
% vdMloglikeli = vdMloglikeli(vSel,:);
% if length(vdMloglikeli(:,1)) > 1
%     fProbability = min(vdMloglikeli(:,1));
%     fMshift = mean(vdMloglikeli(:,2));
% else
%     fProbability = vdMloglikeli(:,1);
%     fMshift = vdMloglikeli(:,2);
% end
% % Solution matrix
% mProblikelihood = [vMshift vfProbability];
%
% %% Bayesian Information Criterion (BIC)
% nDegFree = 1; % Magnitude shift is the degree of freedom
% n_samples = length(mCat1(:,6));
% fBic = 2*fProbability + 2*log(n_samples)*nDegFree;
