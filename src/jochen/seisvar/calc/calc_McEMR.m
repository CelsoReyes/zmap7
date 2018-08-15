function [fMc, fBvalue, fAvalue, fMu, fSigma] = calc_McEMR(catalog, binInterval)
    % Determine Mc using Entire Magnitude Range (EMR)-method. Calculates also a- and b-value.
    % [fMc, fBvalue, fAvalue, fMu, fSigma] = calc_McEMR(catalog, binInterval);
    % -----------------------------------------------------------------------------------------------------
    % Determine Mc using EMR-method. Calculates also a- and b-value.
    % Fitting non-cumulative frequency magnitude distribution above and below Mc:
    % below: Cumulative NORMAL distribution function
    % above: Gutenberg-Richter law
    %
    % Incoming variables:
    % catalog   : EQ catalog
    % binInterval   : Binning interval, usually 0.1
    %
    % Outgoing variables:
    % fMc        : Best estimated magnitude of completeness
    % fBvalue    : b-value
    % fAvalue    : a-value
    % fMu        : mu-value of the normal CDF
    % fSigma     : sigma-values of the normal CDF
    %
    % J. Woessner: woessner@seismo.ifg.ethz.ch
    
    narginchk(2,2);
    
    % Initialize
    vProbability = [];
    vMc = [];
    vABValue =[];
    mFitRes = [];
    vDeltaBest = [];
    vX_res = [];
    vNmaxBest = [];
    mResult=[];
    
    % Determine exact time period
    timespan = years(max(catalog.Date) - min(catalog.Date)); % guessing it should be years
    
    % Set starting value for Mc loop and LSQ fitting procedure
    fMcTry= calc_Mc(catalog, McMethods.MaxCurvature);
    fSmu = abs(fMcTry/2);
    fSSigma = abs(fMcTry/4);
    if (fSmu > 1)
        fSmu = fMcTry/10;
        fSSigma = fMcTry/20;
    end
    fMcBound = fMcTry;
    
    % Calculate FMD for original catalog
    [vFMDorg, vNonCFMDorg] = calc_FMD(catalog.Magnitude);
    fMinMag = min(vNonCFMDorg(1,:));
    
    % %% Shift to positive values
    % if fMinMag ~= 0
    %     fMcBound = fMcTry-fMinMag;
    % end
    % Loop over Mc-values
    for fMc = round(fMcBound-0.4:0.1:fMcBound+0.4 , -1)
        vFMD = vFMDorg;
        vNonCFMD = vNonCFMDorg;
        vNonCFMD = fliplr(vNonCFMD);
        % Calculate a and b-value for GR-law and distribution vNCum
        %[nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(catalog, vFMD, fMc);
        [~, ~, vSel, ~] = fMagToFitBValue(catalog, vFMD, fMc);
        if (length(catalog.Longitude(vSel)) >= 20)
            %[ fBValue, fStdDev, fAValue] =  calc_bmemag(catalog.Magnitude(vSel), binInterval);
            [fBValue, ~, fAValue] =  calc_bmemag(catalog.Magnitude(vSel), binInterval);
            % Normalize to time period
            vFMD(2,:) = vFMD(2,:)./timespan; % ceil taken out
            vNonCFMD(2,:) = vNonCFMD(2,:)./timespan; % ceil removed
            % Compute quantity of earthquakes by power law
            fMaxMagFMD = max(vNonCFMD(1,:));
            fMinMagFMD = min(vNonCFMD(1,:));
            vMstep = fMinMagFMD:0.1:fMaxMagFMD;
            vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number
            
            % Compute non-cumulative numbers vN
            fNCumTmp = 10^(fAValue-fBValue*(fMaxMagFMD+0.1));
            vNCumTmp  = [vNCum fNCumTmp ];
            vN = abs(diff(vNCumTmp));
            
            % Normalize vN
            vN = vN./timespan;
            % Data selection
            % mData = Non-cumulative FMD values from GR-law and original data
            mData = [vN' vNonCFMD'];
            vSel = (mData(:,2) >= fMc);
            mDataTest = mData(~vSel,:);
            mDataTmp = mData(vSel,:);
            % Check for zeros in observed data
            vSelCheck = (mDataTest(:,3) == 0);
            mDataTest = mDataTest(~vSelCheck,:);
            % Choices of normalization
            fNmax = mDataTmp(1,3); % Frequency of events in Mc bin
            
            if (~isempty(isempty(fNmax)) &&  ~isnan(fNmax) & fNmax ~= 0 & length(mDataTest(:,1)) > 4)
                mDataTest(:,3) = mDataTest(:,3)/fNmax; % Normalize datavalues for fitting with CDF
                % Move to M=0 to fit with lsq-algorithm
                fMinMagTmp = min(mDataTest(:,2));
                mDataTest(:,2) = mDataTest(:,2)-fMinMagTmp;
                % Curve fitting: Non cumulative part below Mc
                options = optimset;
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
                end % END: This section is due for errors produced with datasets less long than amount of parameters in vX
                % Results of fitting procedure
                mFitRes = [mFitRes; vX resnorm exitflag];
                % Move back to original magnitudes
                mDataTest(:,2) = mDataTest(:,2)+fMinMagTmp;
                % Set data together
                mDataTest(:,3) = mDataTest(:,3)*fNmax;
                mDataPred = [mDataTest; mDataTmp];
                % Denormalize to calculate probabilities
                mDataPred(:,1) = round(mDataPred(:,1).*timespan);
                mDataPred(:,3) = mDataPred(:,3).*timespan;
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
                    vPredBest = [mDataTest(:,2) vPred*fNmax*timespan delta*fNmax*timespan]; % Gives back uncertainty
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
            end % END of IF fNmax
        end % END of IF length(catalog.Longitude(vSel))
        
        
        % Clear variables
        vNCumTmp = [];
        mModelDat = [];
        vNCum = [];
        vSel = [];
        mDataTest = [];
        mDataPred = [];
    end % END of FOR fMc
    % Result matrix
    mResult = [mResult; vProbability vMc vX_res vNmaxBest vABValue];
    
    % Find best estimate, excluding the case of mResult all NAN
    if  ~isempty(nanmin(mResult)) && ~isnan(nanmin(mResult(:,1)))
        vSel = find(nanmin(mResult(:,1)) == mResult(:,1));
        fMc = min(mResult(vSel,2));
        %fMls = min(mResult(vSel,1));
        fMu = min(mResult(vSel,3));
        fSigma = min(mResult(vSel,4));
        fAvalue = min(mResult(vSel,8));
        fBvalue = min(mResult(vSel,9));
    else
        fMc = NaN;
        %fMls = NaN;
        fMu = NaN;
        fSigma = NaN;
        fAvalue = NaN;
        fBvalue = NaN;
    end
end
