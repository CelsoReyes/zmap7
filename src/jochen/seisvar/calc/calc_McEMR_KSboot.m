function [fMls, fMc, fStd_Mc, fMu, fSigma, fBvalue, fStd_B, fAvalue, fStd_A, bH, fPval, fKsstat,mResult] = calc_McEMR_KSboot(mCatalog, fBinning, nBst, nMethod)
    % Determine Mc using bootstrap approach
    % [fMls, fMc, fStd_Mc, fMu, fSigma, fBvalue, fStd_B, fAvalue, fStd_A, bH, fPval, fKsstat, mResult] = calc_McEMR_KSboot(mCatalog, fBinning, nBst, nMethod);
    % ---------------------------------------------------------------------------------------------------------------------------------------
    % The KS-Test is used to verify if the EMR-model for the bootstrap Mc
    % results in a good-fit (0) or not (1) at 0.05 significance level.
    %
    % Incoming variables:
    % mCatalog   : EQ catalog
    % fBinning   : Binning interval, usually 0.1
    % nBst       : Number of bootstrap samples
    % nMethod    : Method to compute Mc
    %
    % Outgoing variables:
    % mResult     : Solution matrix including
    %               vProbability: maximum likelihood score
    %               vMc         : Mc values
    %               vX_res      : mu (of normal CDF), sigma (of normal CDF), residuum, exitflag
    %               vNmaxBest   : Number of events in lowest magnitude bin considered complete
    %               vABValue    : a and b-value
    % fMls       : minimum maximum likelihood score --> best Mc
    % fMc        : Best estimated magnitude of completeness (bootstrap mean)
    % fStd_Mc    : 2nd moment for Mc from bootstrap
    % fBvalue        : b-value
    % fStd_B         : 2nd moment for b-value from bootstrap
    % fAvaulue       :a-value
    % fStd_A         : 2nd moment fora-value from bootstrap
    % bH             : Kolmogorov-Smirnov-Test acceptance (0) or rejection (1)
    %                  at 0.05 significance level
    % fPval          : p-value of the Kolmogorov-Smirnov-Test
    % fKsstat        : Test statistic of the Kolmogorov-Smirnov-Test
    %
    % J. Woessner: woessner@seismo.ifg.ethz.ch
    % updated: 11.02.04
    
    
    % Initialize
    vProbability = [];
    vMc = [];
    vABValue =[];
    mFitRes = [];
    vX_res = [];
    vNCumTmp = [];
    mDataPred = [];
    vPredBest = [];
    vDeltaBest = [];
    vX_res = [];
    vNmaxBest = [];
    mResult=[];
    mDatPredBest = [];
    
    % Calcultate Mc by bootstrap approach
    [fMc, fStd_Mc, fBvalueb, fStd_B, fAvalueb, fStd_A, vMcboot, mBvalue] = calc_McBboot(mCatalog, fBinning, nBst, nMethod);
    
    % Set starting value for Mc loop and LSQ fitting procedure
    fMcTry= calc_Mc(mCatalog, McMethods.MaxCurvature);
    fSmu = abs(fMcTry/2);
    fSSigma = abs(fMcTry/4);
    if (fSmu > 1)
        fSmu = fMcTry/10;
        fSSigma = fMcTry/20;
    end
    
    % Determine exact time period
    fPeriod1 = max(mCatalog.Date) - min(mCatalog.Date);
    
    % Determine max. and min. magnitude
    fMaxMag = ceil(10 * max(mCatalog.Magnitude)) / 10;
    
    
    % Calculate FMD for original catalog
    [vFMDorg, vNonCFMDorg, fmdbins] = calc_FMD(mCatalog);
    % convert answer back to this file's expectations...
    vFMDorg = [fmdbins'; vFMDorg'] % as rows
    vNonCFMDorg = [fmdbins'; vNonCFMDorg'];

    fMinMag = min(vNonCFMDorg(1,:));
    
    fMc = roundn(fMc,-1);
    vFMD = vFMDorg;
    vNonCFMD = vNonCFMDorg;
    vNonCFMD = fliplr(vNonCFMD);
    % Calculate a and b-value for GR-law and distribution vNCum
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
    if (length(mCatalog.Longitude(vSel)) >= 20)
        [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog.Magnitude(vSel), fBinning);
        % Normalize to time period
        vFMD(2,:) = vFMD(2,:)./fPeriod1; % ceil taken out
        vNonCFMD(2,:) = vNonCFMD(2,:)./fPeriod1; % ceil removed
        % Compute quantity of earthquakes by power law
        fMaxMagFMD = max(vNonCFMD(1,:));
        fMinMagFMD = min(vNonCFMD(1,:));
        vMstep = [fMinMagFMD:0.1:fMaxMagFMD];
        vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number
        
        % Compute non-cumulative numbers vN
        fNCumTmp = 10^(fAValue-fBValue*(fMaxMagFMD+0.1));
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
        %         % Check for zeros in observed data
        vSelCheck = (mDataTest(:,3) == 0);
        mDataTest = mDataTest(~vSelCheck,:);
        % Choices of normalization
        fNmax = mDataTmp(1,3); % Frequency of events in Mc bin
        %fNmax = max(mDataTest(:,3));  % Use maximum frequency of events in bins below Mc
        %fNmax = mDataTest(length(mDataTest(:,1)),3); % Use frequency of events at bin Mc-0.1 -> best fit
        if (~isempty(isempty(fNmax)) &&  ~isnan(fNmax) & fNmax ~= 0 & length(mDataTest(:,1)) > 4)
            mDataTest(:,3) = mDataTest(:,3)/fNmax; % Normalize datavalues for fitting with CDF
            % Move to M=0 to fit with lsq-algorithm
            fMinMagTmp = min(mDataTest(:,2));
            mDataTest(:,2) = mDataTest(:,2)-fMinMagTmp;
            % Curve fitting: Non cumulative part below Mc
            options = optimset;
            %options = optimset('Display','off','Tolfun',1e-7,'TolX',0.0001,'MaxFunEvals', 100000,'MaxIter',10000);
            options = optimset('Display','off','Tolfun',1e-5,'TolX',0.001,'MaxFunEvals', 1000,'MaxIter',1000);
            [vX, resnorm, resid, exitflag, output, lambda, jacobian]=lsqcurvefit(@calc_normalCDF,[fSmu  fSSigma], mDataTest(:,2), mDataTest(:,3),[],[],options);
            mDataTest(:,1) = normcdf(mDataTest(:,2), vX(1), vX(2))*fNmax;
            if (length(mDataTest(:,2)) > length(vX(1,:)))
                %% Confidence interval determination
                % vPred : Predicted values of lognormal function
                % vPred+-delta : 95% confidence level of true values
                [vPred,delta] = nlpredci(@calc_normalCDF,mDataTest(:,2),vX, resid, jacobian);
            else
                vPred = NaN;
                delta = NaN;
            end; % END: This section is due for errors produced with datasets less long than amount of parameters in vX
            % Results of fitting procedure
            mFitRes = [mFitRes; vX resnorm exitflag];
            % Move back to original magnitudes
            mDataTest(:,2) = mDataTest(:,2)+fMinMagTmp;
            % Set data together
            mDataTest(:,3) = mDataTest(:,3)*fNmax;
            mDataPred = [mDataTest; mDataTmp];
            % Denormalize to calculate probabilities
            mDataPred(:,1) = round(mDataPred(:,1).*fPeriod1);
            mDataPred(:,3) = mDataPred(:,3).*fPeriod1;
            vProb_ = calc_log10poisspdf2(mDataPred(:,3), mDataPred(:,1)); % Non-cumulative
            
            % Sum the probabilities
            fProbability = (-1) * sum(vProb_);
            vProbability = [vProbability; fProbability];
            % Move magnitude back
            mDataPred(:,2) = mDataPred(:,2)+fMinMag;
            vMc = [vMc; fMc];
            vABValue = [vABValue; fAValue fBValue];
            
            % Keep values
            vDeltaBest = [vDeltaBest; delta];
            vX_res = [vX_res; vX resnorm exitflag];
            vNmaxBest = [vNmaxBest; fNmax];
            
            % Keep best fitting model
            if (fProbability == min(vProbability))
                vDeltaBest = delta;
                vPredBest = [mDataTest(:,2) vPred*fNmax*fPeriod1 delta*fNmax*fPeriod1]; % Gives back uncertainty
                %fMc+fMinMag : Test procedure
                mDatPredBest = [mDataPred];
            end
        else
            %disp('Not enough data');
            % Setting values
            fProbability = NaN;
            fMc = NaN;
            vX(1) = NaN;
            vX(2) = NaN;
            resnorm = NaN;
            exitflag = NaN;
            delta = NaN;
            vPred = [NaN NaN NaN];
            fNmax = NaN;
            fAValue = NaN;
            fBValue = NaN;
            vProbability = [vProbability; fProbability];
            vMc = [vMc; fMc];
            vX_res = [vX_res; vX resnorm exitflag];
            %             vDeltaBest = [vDeltaBest; NaN];
            %             vPredBest = [vPredBest; NaN NaN NaN];
            vNmaxBest = [vNmaxBest; fNmax];
            vABValue = [vABValue; fAValue fBValue];
        end; % END of IF fNmax
    end; % END of IF length(mCatalog.Longitude(vSel))
    
    
    
    % Result matrix
    mResult = [mResult; vProbability vMc vX_res vNmaxBest vABValue];
    
    % Find best estimate, excluding the case of mResult all NAN
    if  ~isempty(min(mResult))
        if ~isnan(min(mResult(:,1)))
            vSel = find(min(mResult(:,1)) == mResult(:,1));
            fMc = min(mResult(vSel,2));
            fMls = min(mResult(vSel,1));
            fMu = min(mResult(vSel,3));
            fSigma = min(mResult(vSel,4));
            fAvalue = min(mResult(vSel,8));
            fBvalue = min(mResult(vSel,9));
        else
            fMc = NaN;
            fMls = NaN;
            fMu = NaN;
            fSigma = NaN;
            fAvalue = NaN;
            fBvalue = NaN;
        end
    else
        fMc = NaN;
        fMls = NaN;
        fMu = NaN;
        fSigma = NaN;
        fAvalue = NaN;
        fBvalue = NaN;
    end
    
    % Reconstruct vector of magnitudes from model for Period 1
    try
        vMag = [];
        mModelFMD = [round(mDatPredBest(:,1)) mDatPredBest(:,2)];
        vSel = (mModelFMD(:,1) ~= 0); % Remove bins with zero frequency of zero events
        mData = mModelFMD(vSel,:);
        for nCnt=1:length(mData(:,1))
            fM = repmat(mData(nCnt,2),mData(nCnt,1),1);
            vMag = [vMag; fM];
        end
        % Calculate KS-Test
        [bH,fPval,fKsstat] = kstest2(roundn(mCatalog.Magnitude,-1),roundn(vMag,-1),0.05,0);
    catch
        bH = NaN;
        fPval = NaN;
        fKsstat = NaN;
    end
end