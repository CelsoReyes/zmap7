function [mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = plot_McCdfnormal(mCatalog, fBinning)
% function [mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = plot_McCdfnormal(mCatalog, fBinning);
% -----------------------------------------------------------------------------------------------------
% Same as calc_McCdfnormal with plotting the fitting steps and the final result
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Binning interval, usually 0.1
%
% Outgoing variables:
% mResult     : Solution matrix including
%               vProbability: maximum likelihood score
%               vMc         : Mc values
%               vX_res      : mu (of normal CDF), sigma (of normal CDF), residuum, exitflag
%               vNmaxBest   : Number of events in lowest magnitude bin considered complete
%               vABValue    : a and b-value
% fMls       : minimum maximum likelihood score --> best Mc
% fMc        : Best estimated magnitude of completeness
% mDatPredBest   : Matrix of non-cumulative FMD [Prediction, magnitudes, original distribution]
% vPredBest      : Matrix of non-cumulative FMD below Mc [magnitude, prediction, uncertainty of prediction]
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 10.02.03


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

% Determine exact time period
fPeriod1 = max(mCatalog(:,3)) - min(mCatalog(:,3));

% Determine max. and min. magnitude
fMaxMag = ceil(10 * max(mCatalog(:,6))) / 10;


% Set starting value for Mc loop and LSQ fitting procedure
fMcTry= calc_Mc(mCatalog,1);
fSmu = fMcTry/2;
fSSigma = fMcTry/4;
if (fSmu > 1)
    fSmu = fMcTry/10;
    fSSigma = fMcTry/20;
end
fMcBound = fMcTry;

% Calculate FMD for original catalog
[vFMDorg, vNonCFMDorg] = calc_FMD(mCatalog);
fMinMag = min(vNonCFMDorg(1,:));

%% Shift to positive values
if fMinMag ~= 0
    fMcBound = fMcTry-fMinMag;
end

% Loop over Mc-values
for fMc = fMcBound-0.4:0.1:fMcBound+0.4
    fMc = round(fMc*10)/10;
    vFMD = vFMDorg;
    vNonCFMD = vNonCFMDorg;
    vNonCFMD = fliplr(vNonCFMD);
    % Calculate a and b-value for GR-law and distribution vNCum
    [nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
    if (length(mCatalog(vSel,1)) >= 20)
        [fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog(vSel,:), fBinning);
        % Normalize to time period
        vFMD(2,:) = vFMD(2,:)./fPeriod1;
        vNonCFMD(2,:) = vNonCFMD(2,:)./fPeriod1;
        % Compute quantity of earthquakes by power law
        fMaxMagFMD = max(vNonCFMD(1,:));
        fMinMagFMD = min(vNonCFMD(1,:));
        vMstep = [fMinMagFMD:0.1:fMaxMagFMD];
        vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number

        % Compute non-cumulative numbers vN from GR-law
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
        mDataTmp = mData(vSel,:);
        % Check for zeros in observed data
%         vSelCheck = (mDataTest(:,3) == 0);
%         mDataTest = mDataTest(~vSelCheck,:);
        % Choices of normalization
        fNmax = mDataTmp(1,3); % Frequency of events in Mc bin
        %fNmax = max(mDataTest(:,3));  % Use maximum frequency of events in bins below Mc
        %fNmax = mDataTest(length(mDataTest(:,1)),3); % Use frequency of events at bin Mc-0.1 -> best fit
        %fNmax = (mDataTest(length(mDataTest(:,1)),3)+mDataTmp(1,3))/2;
        if (~isempty(fNmax) & ~isnan(fNmax) & fNmax ~= 0 & length(mDataTest(:,1)) > 4)
            mDataTest(:,3) = mDataTest(:,3)/fNmax; % Normalize datavalues for fitting with CDF
            % Move to M=0 to fit with lsq-algorithm
            fMinMagTmp = min(mDataTest(:,2));
            mDataTest(:,2) = mDataTest(:,2)-fMinMagTmp;
            % Curve fitting: Non cumulative part below Mc
            options = optimset;
            %options = optimset('Display','off','Tolfun',1e-5,'TolX',0.0001,'MaxFunEvals', 100000,'MaxIter',10000);
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
            %% Set data together
            mDataTest(:,3) = mDataTest(:,3)*fNmax;
            mDataPred = [mDataTest; mDataTmp];
            % Denormalize to calculate probabilities
            mDataPred(:,1) = round(mDataPred(:,1).*fPeriod1);
            mDataPred(:,3) = mDataPred(:,3).*fPeriod1;
            vProb_ = calc_log10poisspdf2(mDataPred(:,3), mDataPred(:,1)); % Non-cumulative
            %vPro_ = calc_log10poisspdf(mDataPred(:,3), mDataPred(:,1)); % Non-cumulative
            % Sum the probabilities
            fProbability = (-1) * sum(vProb_);
            vProbability = [vProbability; fProbability];
            % Move magnitude back
            mDataPred(:,2) = mDataPred(:,2)+fMinMag;
            vMc = [vMc; fMc+fMinMag];
            vABValue = [vABValue; fAValue fBValue];

             % Keep values
            vDeltaBest = [vDeltaBest; delta];
            vX_res = [vX_res; vX resnorm exitflag];
            vNmaxBest = [vNmaxBest; fNmax];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Plot routines
            if exist('cdfit_fig','var') &  ishandle(cdfit_fig)
                set(0,'Currentfigure',cdfit_fig);
            else
                cdfit_fig=figure_w_normalized_uicontrolunits('tag','cdfit','Name','Fitting CDF','Units','normalized','Nextplot','add',...
                    'Numbertitle','off','visible','on');
                cdfit_axs=axes('tag','ax_cdfit','Nextplot','add','box','off');
            end

            set(gcf,'tag','cdfit');
            subplot(3,1,1); % Fitting curve and original data => Mc
            plot(mDataTest(:,2)+fMinMag, mDataTest(:,1),'-r', mDataTest(:,2)+fMinMag, mDataTest(:,3), '*')
            hold on;
            plot(mDataTest(:,2)+fMinMag, mDataTest(:,1)+delta*fNmax,'--g',mDataTest(:,2)+fMinMag, mDataTest(:,1)-delta*fNmax,'--g');
            hold off;
            ylabel('CDF fit');
            sTitle = ['Test: Mc = ', num2str(fMc+fMinMag)];
            title(sTitle);
            subplot(3,1,2); % Non-cumulative data, Non-cumulative data from GR-law, Non-cumulative data predicted with normal CDF
            plot(vNonCFMD(1,:)'+fMinMag, vNonCFMD(2,:)'.*fPeriod1, '^b', vNonCFMD(1,:)'+fMinMag, vN.*fPeriod1, '*g', mDataPred(:,2),mDataPred(:,1),'or')
            ylabel('NonCumFMD fit')
            subplot(3,1,3); % Cumlative data, cumulative data from GR-law, cumulative data predicted with normal CDF
            mTmp = flipud(mDataPred);
            mTmp(:,1) = cumsum(mTmp(:,1));
            mTmp(:,3) = cumsum(mTmp(:,3));
            semilogy(mTmp(:,2), mTmp(:,1),'ro',mTmp(:,2), mTmp(:,3),'g*',vMstep+fMinMag, vNCum./fPeriod1)
            xlabel('Magnitude')
            ylabel('FMD fit')
            drawnow;
            %pause
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

             % Keep best fitting model for plotting
            if (fProbability == nanmin(vProbability))
                vDeltaBest = delta;
                vPredBest = [mDataTest(:,2)+fMinMag vPred*fNmax*fPeriod1 delta*fNmax*fPeriod1]; % Gives back uncertainty
                vNBest = vN;
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
            vMc = [vMc; fMc+fMinMag];
            vX_res = [vX_res; vX resnorm exitflag];
            vDeltaBest = [vDeltaBest; delta];
            vPredBest = [vPredBest; vPred*fNmax];
            vNmaxBest = [vNmaxBest; fNmax];
            vABValue = [vABValue; fAValue fBValue];
        end % END of IF fNmax
    end % END of IF length(mCatalog(vSel,1))


    % Clear variables
    vNCumTmp = [];
    mModelDat = [];
    vNCum = [];
    vSel = [];
    mDataTest = [];
    mDataPred = [];
end % END of FOR fMc

if isempty(vProbability)
    disp('Not enough data');
    return;
end

mResult = [mResult; vProbability vMc vX_res vNmaxBest vABValue];

% Find best estimate, excluding the case of mResult all NAN
if  ~isempty(nanmin(mResult))
    if ~isnan(nanmin(mResult(:,1)))
        vSel = find(nanmin(mResult(:,1)) == mResult(:,1));
        fMc = min(mResult(vSel,2));
        fMls = min(mResult(vSel,1));
        fMu = min(mResult(vSel,3));
        fSigma = min(mResult(vSel,4));
    else
        fMc = NaN;
        fMls = NaN;
        fMu = NaN;
        fSigma = NaN;

    end
else
    fMc = NaN;
    fMls = NaN;
    fMu = NaN;
    fSigma = NaN;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot result
% Plot MLS vs. Mc
figure_w_normalized_uicontrolunits('tag','mlsmc','Name','MLS vs. Mc','Units','normalized','Nextplot','add',...
                    'Numbertitle','off','visible','on');
plot(vMc, vProbability,'Marker','s','MarkerFaceColor',[0.5 0.5 0.5],'Markersize',8');
xlabel('Mc');
ylabel('MLS');
sTitlestr = ['Minimum MLS at Mc = ' num2str(fMc)];
title(sTitlestr);

% Plot Best fitting CDF vs. magnitude
figure_w_normalized_uicontrolunits('tag','best_cdfit','Name','CDF fit','Units','normalized','Nextplot','add',...
                    'Numbertitle','off','visible','on');
plot(vPredBest(:,1),vPredBest(:,2))
hold on;
%plot(mDat(:,2)+fMinMag, mDat(:,3)*fNmax*fPeriod1,'+r')
plot(mDatPredBest(:,2),mDatPredBest(:,1),'o',mDatPredBest(:,2), mDatPredBest(:,3),'<');
sTitlestr = ['mu = ' num2str(fMu) ', sigma = ' num2str(fSigma)];
title(sTitlestr)
plot(vPredBest(:,1),vPredBest(:,2)+vPredBest(:,3),'--g')
plot(vPredBest(:,1),vPredBest(:,2)-vPredBest(:,3),'--g')
xlabel('Magnitude');
ylabel('Non-cumulative FMD');
hold off;

% Plot Non-cumulative distribution, original and predicted
figure_w_normalized_uicontrolunits('tag','ncumdist','Name','Best model','Units','normalized','Nextplot','add',...
                    'Numbertitle','off','visible','on');
semilogy(vNonCFMDorg(1,:)', vNonCFMDorg(2,:)', '^', vNonCFMD(1,:)', vNBest.*fPeriod1, '*', mDatPredBest(:,2),mDatPredBest(:,1),'o')
xlim = ([min(mDatPredBest(:,2)) max(mDatPredBest(:,2))]);
sTitlestr = ['Mc = ' num2str(fMc) ' using Normal CDF fitting'];
title(sTitlestr)
xlabel('Magnitude');
ylabel('Non-cumulative FMD');
drawnow;
