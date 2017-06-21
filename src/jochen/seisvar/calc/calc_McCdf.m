function [fProbMin, fMcBest] = calc_McCdf(mCatalog, fBinning)
% function [fProbMin, fMcBest] = calc_McCdf(mCatalog, fBinning);
% --------------------------------------------------------------
% Determine Mc using maximum likelihood score
% Fitting non-cumulative frequency magnitude distribution above and below Mc:
% below: Cumulative lognormal density function
% above: Gutenberg-Richter law
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Binning interval, usually 0.1
%
% Outgoing variables:
% fProbMin   : Maximum likelihood score of best Mc
% fMcBest    : Best estimated magnitude of completeness
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 21.11.02

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
        vNCumTmp  = [fNCumTmp vNCum];
        vN = abs(diff(vNCumTmp));
        %     % Normalizea-value
        %fAValue = fAValue./fPeriod1;
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
