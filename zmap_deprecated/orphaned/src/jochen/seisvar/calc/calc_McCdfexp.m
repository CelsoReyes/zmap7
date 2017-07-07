function [fProbMin, fMcBest, vX_res, fNmaxBest, mDatPredBest] = calc_McCdfexp(mCatalog, fBinning)
% function [fProbMin, fMcBest, vX_res, fNmaxBest, mDatPredBest] = calc_McCdfexp(mCatalog, fBinning);
% -----------------------------------------------------------------------------------------------------
% Determine Mc using maximum likelihood score
% Fitting non-cumulative frequency magnitude distribution above and below Mc:
% below: Cumulative Exponetial density function
% above: Gutenberg-Richter law
% Data in mDatPredBest comes back normalized to time period!!!!!!!!!
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Binning interval, usually 0.1
%
% Outgoing variables:
% fProbMin   : Maximum likelihood score of best Mc
% fMcBest    : Best estimated magnitude of completeness
% vX_res     : Vector including mu, sigma, residuum, exitflag
% fNmaxBest  : Number of events in lowest magnitude bin considered complete
% mDatPred   : Matrix of non-cumulative FMD [Prediction, magnitudes, original distribution]
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 13.01.03


% Initialize
vProbability = [];
vMc = [];
vABValue =[];
mFitRes = [];
vX_res = [];
vNCumTmp = [];
mDataPred = [];

% Determine exact time period
fPeriod1 = max(mCatalog(:,3)) - min(mCatalog(:,3));

% Determine max. and min. magnitude
fMinMag = min(mCatalog(:,6));
fMaxMag = ceil(10 * max(mCatalog(:,6))) / 10;

%% Shift to positive values --> only for lognormal function necessary
if fMinMag ~= 0
    mCatalog(:,6) = mCatalog(:,6)-fMinMag;
end
% Calculate FMD for original catalog
[vFMDorg, vNonCFMDorg] = calc_FMD(mCatalog);
for fMc =0.1:0.1:fMaxMag-1
    vFMD = vFMDorg;
    vNonCFMD = vNonCFMDorg;
    vNonCFMD = fliplr(vNonCFMD);
    % Calculate a and b-value for GR-law and distribution vNCum
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
    if (length(mCatalog(vSel,1)) >= 20)
        [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog(vSel,:), fBinning);
        % Normalize to time period
        vFMD(2,:) = ceil(vFMD(2,:)./fPeriod1);
        vNonCFMD(2,:) = ceil(vNonCFMD(2,:)./fPeriod1);
        % Compute quantity of earthquakes by power law
        fMaxMag = max(vMagnitudes);
        vMstep = [0:0.1:fMaxMag];
        vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number

        % Compute non-cumulative numbers vN
        fNCumTmp = 10^(fAValue-fBValue*(fMaxMag+0.1));
        vNCumTmp  = [vNCum fNCumTmp ];
        vN = abs(diff(vNCumTmp));

        % Normalize vN
        vN = vN./fPeriod1;
        % Data selection
        % mData = Non-cumulative FMD values from GR-law and original data
        mData = [vN' vNonCFMD'];
        vSel = (mData(:,2) >= fMc);
        mDataTest = mData(~vSel,:);
        mDataTmp = mData.subset(vSel);
        % Choices of normalization
        %fNmax = mDataTmp(1,3) % Frequency of events in Mc bin
        %fNmax = max(mDataTest(:,3));  % Use maximum frequency of events in bins below Mc
        fNmax = mDataTest(length(mDataTest(:,1)),3); % Use frequency of events at bin Mc-0.1 -> best fit
        if (~isempty(fNmax) & ~isnan(fNmax) & fNmax ~= 0 & length(mDataTest(:,1)) > 4)
            mDataTest(:,3) = mDataTest(:,3)/fNmax; % Normalize datavalues for fitting with CDF
            % Curve fitting: Non cumulative part below Mc
            options = optimset;
            options = optimset('Display','off','Tolfun',1e-5,'TolX',0.001,'MaxFunEvals', 100000);
            [vX, resnorm, resid, exitflag, output, lambda, jacobian]=lsqcurvefit(@calc_expdecay,[1 1], mDataTest(:,2), mDataTest(:,3));
            mDataTest(:,1) = (vX(1).*exp(-vX(2).*mDataTest(:,2)))*fNmax;
            if (length(mDataTest(:,2)) > length(vX(1,:)))
                %% Confidence interval determination
                % vPred : Predicted values of lognormal function
                % vPred+-delta : 95% confidence level of true values
                [vPred,delta] = nlpredci(@calc_expdecay,mDataTest(:,2),vX, resid, jacobian);
            else
                vPred = nan;
                delta = nan;
            end; % END: This section is due for errors produced with datasets less long than amount of parameters in vX
            % Results of fitting procedure
            mFitRes = [mFitRes; vX resnorm exitflag];
            %% Set data together
            mDataTest(:,3) = mDataTest(:,3)*fNmax;
            mDataPred = [mDataTest; mDataTmp];
            %mDataPred(:,1) = ceil(mDataPred(:,1));
            vProb_ = calc_log10poisspdf2(mDataPred(:,3), mDataPred(:,1)); % Non-cumulative
            % Sum the probabilities
            fProbability = (-1) * sum(vProb_);
            vProbability = [vProbability; fProbability];
            % Move magnitude back
            mDataPred(:,2) = mDataPred(:,2)+fMinMag;
            vMc = [vMc; fMc+fMinMag];
            vABValue = [vABValue; fAValue fBValue];

            % Keep best fitting model
            if (fProbability == min(vProbability))
                fProbMin = fProbability;
                vPredBest = vPred*fNmax;
                vDeltaBest = delta;
                mDat = mDataTest;
                vNBest = vN;
                fMcBest = fMc+fMinMag; % only necessary for lognormal CDF
                mDatPredBest = mDataPred;
                vX_res = [vX resnorm exitflag];
                fNmaxBest = fNmax;
            end
        else
            fProbMin = nan;
            fMcBest = nan;
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

