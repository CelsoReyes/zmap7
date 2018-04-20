function [params] = bc_calc(params)
% function [result] = pf_calcinput(params)
% ----------------------------------------
% Calculation of b-values for the probabilistic forecast test.
%
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon           Polygon (defined by ex_selectgrid)
%   params.caNodeIndices      Cell-array with index-catalogs per grid node of mPolygon
%   params.nMinimumNumber     Minimum number of earthquakes per node
%   params.fSplitTime         Time at which the catalog will be split
%   params.bLearningPeriod    Fix duration of the learning period (1 = fix, 0 = use catalog from start)
%   params.fLearningPeriod    Duration of the learning period
%   params.bForecastPeriod    Fix duration of the forecasting period (1 = fix, 0 = use catalog till end)
%   params.fForecastPeriod    Duration of the forecasting period
%   params.nCalculateMC       Method to calculate magnitude of completeness (see also: help calc_Mc)
%
% Output parameters:
%   Same as input parameters including
%   result.mBValueGrid        Matrix of calculated b-values
%   result.vcsBGridNames      Strings describing the values in mValueGrid
%
% Danijel Schorlemmer
% July 5, 2002

report_this_filefun();

nNumberNodes_ = length(params.mPolygon(:,1));

mValueGrid_ = [];

for nNode_ = 1:nNumberNodes_
  %disp(['Calculating node ' num2str(nNode_) ' of ' num2str(nNumberNodes_)]);
  %save('node.mat', 'nNode_');
  % Create node catalog
  mNodeCatalog_ = params.mCatalog(params.rOptions.caNodeIndices{nNode_}, :);
  % Create the sub node-catalogs for the different mechanisms
  mSSCatalog_ = bc_SelectMechanism(mNodeCatalog_, 1, params.fGamma);
  mTHCatalog_ = bc_SelectMechanism(mNodeCatalog_, 2, params.fGamma);
  mNRCatalog_ = bc_SelectMechanism(mNodeCatalog_, 3, params.fGamma);
  % Compute the b-values for the node catalogs
  [fBValueSS_, fStdDevSS_, fMcSS_, vDummy, nNumberSS_] = ...
    calc_BandMc(mSSCatalog_, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning, ...
      params.rOptions.bConstrainMc, params.rOptions.fMcMin, params.rOptions.fMcMax);
  [fBValueTH_, fStdDevTH_, fMcTH_, vDummy, nNumberTH_] = ...
    calc_BandMc(mTHCatalog_, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning, ...
      params.rOptions.bConstrainMc, params.rOptions.fMcMin, params.rOptions.fMcMax);
  [fBValueNR_, fStdDevNR_, fMcNR_, vDummy, nNumberNR_] = ...
    calc_BandMc(mNRCatalog_, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning, ...
      params.rOptions.bConstrainMc, params.rOptions.fMcMin, params.rOptions.fMcMax);

  % Compute additional values
  fBNRMinusSS_ = fBValueNR_ - fBValueSS_;
  fBSSMinusTH_ = fBValueSS_ - fBValueTH_;
  fBNRMinusTH_ = fBValueNR_ - fBValueTH_;

  [dA, fUtsuNRSS_, vDummy] = calc_Utsu(fBValueNR_, fBValueSS_, nNumberNR_, nNumberSS_);
  [dA, fUtsuSSTH_, vDummy] = calc_Utsu(fBValueSS_, fBValueTH_, nNumberSS_, nNumberTH_);
  [dA, fUtsuNRTH_, vDummy] = calc_Utsu(fBValueNR_, fBValueTH_, nNumberNR_, nNumberTH_);

  fUtsuNRSS_ = log10(fUtsuNRSS_);
  fUtsuSSTH_ = log10(fUtsuSSTH_);
  fUtsuNRTH_ = log10(fUtsuNRTH_);

%   [fBValueFirst_, fStdDevFirst_, fMcFirst_, fAValue, N1] = ...
%     calc_BandMc(mNodeCatalog_, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning, ...
%       params.rOptions.bConstrainMc, params.rOptions.fMcMin, params.rOptions.fMcMax);
%   if isnan(fBValueFirst_)
%     fRecurrenceTime6 = nan;
%     fRecurrenceTime6Log = nan;
%     fProbability6 = nan;
%     fProbability6Log = nan;
%     fRecurrenceTime6Overall = nan;
%     fRecurrenceTime6OverallLog = nan;
%     fProbability6Overall = nan;
%     fProbability6OverallLog = nan;
%   else
%     fRecurrenceTime6 = (params.fEndFirstPeriod - params.fStartFirstPeriod)./(10^(fAValue - 6 * fBValueFirst_));
%     fRecurrenceTime6Log = log10(fRecurrenceTime6);
%     fProbability6 = 1 - poisscdf(0, (1/fRecurrenceTime6));
%     fProbability6Log = log10(fProbability6);
%     fRecurrenceTime6Overall = (params.fEndFirstPeriod - params.fStartFirstPeriod)./(10^(fAValue - 6 * fBValueOverall_));
%     fRecurrenceTime6OverallLog = log10(fRecurrenceTime6Overall);
%     fProbability6Overall = 1 - poisscdf(0, (1/fRecurrenceTime6Overall));
%     fProbability6OverallLog = log10(fProbability6Overall);
%   end
%   if isnan(fBValueFirst_)
%     fMcWhereBFirst_ = nan;
%   else
%     fMcWhereBFirst_ = fMcFirst_;
%   end
%   % Compute thea-value at Mc for first node catalog
%   nNumQuakes_ = sum(mNodeCatalog_(:,6) >= fMcFirst_);
%   fAnnualRate_ = nNumQuakes_/(params.fEndFirstPeriod - params.fStartFirstPeriod);
%   fAValueFirst_ = log10(fAnnualRate_);
%   if isnan(fBValueFirst_)
%     fAValueWhereBFirst_ = nan;
%   else
%     fAValueWhereBFirst_ = fAValueFirst_;
%   end
%   % Bootstrap the error in b-value
%   if params.bBootstrapFirst
%     [fBootStdDevBFirst_, fBootStdDevMcFirst_, uDummy1_, uDummy2_, vBValuesFirst_] = ...
%       calc_BootstrapB(mNodeCatalog_, params.nNumberBootstrapsFirst, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning);
%   end
%
%   % Create node catalog for the second catalog
%   mNodeCatalog_ = params.mSecondCatalog(params.rOptions.caSecondNodeIndices{nNode_}, :);
%   % Compute b-value for second node catalog
%   [fBValueSecond_, fStdDevSecond_, fMcSecond_, uDummy1_, N2] = ...
%     calc_BandMc(mNodeCatalog_, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning, ...
%       params.rOptions.bConstrainMc, params.rOptions.fMcMin, params.rOptions.fMcMax);
%   if isnan(fBValueSecond_)
%     fMcWhereBSecond_ = nan;
%   else
%     fMcWhereBSecond_ = fMcSecond_;
%   end
%   % Compute thea-value at Mc for first node catalog
%   nNumQuakes_ = sum(mNodeCatalog_(:,6) >= fMcFirst_);
%   fAnnualRate_ = nNumQuakes_/(params.fEndSecondPeriod - params.fStartSecondPeriod);
%   fAValueSecond_ = log10(fAnnualRate_);
%   if isnan(fBValueSecond_)
%     fAValueWhereBSecond_ = nan;
%   else
%     fAValueWhereBSecond_ = fAValueSecond_;
%   end
%   % Bootstrap the error in b-value
%   if params.bBootstrapSecond
%     [fBootStdDevBSecond_, fBootStdDevMcSecond_, uDummy1_, uDummy2_, vBValuesSecond_] = ...
%       calc_BootstrapB(mNodeCatalog_, params.nNumberBootstrapsSecond, params.rOptions.nMinimumNumber, params.rOptions.nCalculateMC, params.rOptions.fBinning);
%   end
%   % Calculate the difference in b-value
%   if (~isnan(fBValueFirst_)) & (~isnan(fBValueSecond_))
%     fDeltaBValue_ = fBValueSecond_ - fBValueFirst_;
%   else
%     fDeltaBValue_ = nan;
%   end
%   if params.bBootstrapFirst
%     fDiffSigma_ = fDeltaBValue_/fBootStdDevBFirst_;
%     fAbsDiffSigma_ = abs(fDiffSigma_);
%   end
%   % Calculate the difference ina-value
%   if (~isnan(fAValueWhereBFirst_)) & (~isnan(fAValueWhereBSecond_))
%     fDeltaAValue_ = fAValueWhereBSecond_ - fAValueWhereBFirst_;
%   else
%     fDeltaAValue_ = nan;
%   end
%   % Calculate Utsu's test
%   if (~isnan(fBValueFirst_)) & (~isnan(fBValueSecond_))
%     N = N1 + N2;
%     dA = -2*N*log(N) + 2*N1*log(N1+(N2*fBValueFirst_/fBValueSecond_)) + 2*N2*log(N2+(N1*fBValueSecond_/fBValueFirst_)) - 2;
%     fProbUtsu = exp(-dA/2 - 2);
%     fProbRamon = exp(-dA/2 - 1);
%     fProbUtsu = log10(fProbUtsu);
%     fProbRamon = log10(fProbRamon);
%   else
%     fProbUtsu = nan;
%     fProbRamon = nan;
%   end
%   % Compute the significance of not being stationary
%   if params.bBootstrapFirst
%     if (~isnan(fBValueFirst_)) & (~isnan(fBValueSecond_)) & params.bBootstrapFirst & params.bBootstrapSecond
%       [fProbability_, fProb12_, fProb21_] = st_probability(fBValueFirst_, vBValuesFirst_, fBValueSecond_, vBValuesSecond_);
%     else
%       fProbability_ = nan;
%       fProb12_ = nan;
%       fProb21_ = nan;
%     end
%   end
  % Store the results
%   if (params.bBootstrapFirst & params.bBootstrapSecond)
    mValueGrid_ = [mValueGrid_; fBValueSS_ fMcSS_ nNumberSS_ ...
        fBValueTH_, fMcTH_ nNumberTH_ ...
      fBValueNR_ fMcNR_ nNumberNR_ ...
   fBNRMinusSS_ fBSSMinusTH_ fBNRMinusTH_ ...
   fUtsuNRSS_ fUtsuSSTH_ fUtsuNRTH_];
%   elseif (params.bBootstrapFirst & ~params.bBootstrapSecond)
%     mValueGrid_ = [mValueGrid_; fBValueFirst_ fStdDevFirst_ fAValueFirst_ fAValueWhereBFirst_ fMcFirst_ fMcWhereBFirst_ fRecurrenceTime6 fRecurrenceTime6Log fProbability6 fProbability6Log ...
%       fRecurrenceTime6Overall fRecurrenceTime6OverallLog fProbability6Overall fProbability6OverallLog ...
%       fBootStdDevBFirst_ fBootStdDevMcFirst_ fBValueSecond_ fStdDevSecond_ fAValueSecond_ fAValueWhereBSecond_ fMcSecond_ fMcWhereBSecond_ fDeltaBValue_ ...
%       fDiffSigma_ fAbsDiffSigma_ fDeltaAValue_ fProbUtsu fProbRamon];
%   elseif (~params.bBootstrapFirst & params.bBootstrapSecond)
%     mValueGrid_ = [mValueGrid_; fBValueFirst_ fStdDevFirst_ fAValueFirst_ fAValueWhereBFirst_ fMcFirst_ fMcWhereBFirst_ fRecurrenceTime6 fRecurrenceTime6Log fProbability6 fProbability6Log ...
%       fRecurrenceTime6Overall fRecurrenceTime6OverallLog fProbability6Overall fProbability6OverallLog ...
%       fBValueSecond_ fStdDevSecond_ fAValueSecond_ fAValueWhereBSecond_ fMcSecond_ fMcWhereBSecond_ fBootStdDevBSecond_ ...
%       fBootStdDevMcSecond_ fDeltaBValue_ fDeltaAValue_ fProbUtsu fProbRamon];
%   else
%     mValueGrid_ = [mValueGrid_; fBValueFirst_ fStdDevFirst_ fAValueFirst_ fAValueWhereBFirst_ fMcFirst_ fMcWhereBFirst_ fRecurrenceTime6 fRecurrenceTime6Log fProbability6 fProbability6Log ...
%       fRecurrenceTime6Overall fRecurrenceTime6OverallLog fProbability6Overall fProbability6OverallLog ...
%       fBValueSecond_ fStdDevSecond_ fAValueSecond_ fAValueWhereBSecond_ fMcSecond_ fMcWhereBSecond_ fDeltaBValue_ fDeltaAValue_ fProbUtsu fProbRamon];
%   end
end % of for
% Create the description-strings for the output-window
% if (params.bBootstrapFirst & params.bBootstrapSecond)
  params.vcsGridNames = cellstr(char('b-value (SS)', 'Mc (SS)', 'Number (SS)', ...
    'b-value (TH)', 'Mc (TH)', 'Number (TH)', ...
    'b-value (NR)', 'Mc (NR)', 'Number (NR)', ...
    'NR-SS', 'SS-TH', 'NR-TH', ...
    'NR-SS (Utsu)', 'SS-TH (Utsu)', 'NR-TH (Utsu)'));
% elseif (params.bBootstrapFirst & ~params.bBootstrapSecond)
%   params.vcsGridNames = cellstr(char('b-value (1st period)', 'Std.-dev. (Shi/Bolt) of b (1st period)', ...
%     'annuala-value @ Mc (1st period)', 'annuala-value @ Mc where b computed (1st period)', 'Mc (1st period)', 'Mc where b computed (1st period)', ...
%     'Recurrence time for M=6', 'Log of Recurrence time for M=6', 'Annual probability for M=6', 'Log of annual probability for M=6', ...
%     'Recurrence time for M=6 (Overall b)', 'Log of Recurrence time for M=6 (Overall b)', 'Annual probability for M=6 (Overall b)', 'Log of annual probability for M=6 (Overall b)', ...
%     'Std.-dev. (Bootstrap) of b (1st period)', 'Std.-dev. (Bootstrap) of Mc (1st period)', 'b-value (2nd period)', 'Std.-dev. (Shi/Bolt) of b (2st period)', ...
%     'annuala-value @ Mc (2nd period)', 'annuala-value @ Mc where b computed (2nd period)', 'Mc (2nd period)', 'Mc where b computed (2nd period)', ...
%     'b-value difference', 'b-value difference in sigma', 'b-value difference in sigma (absolute value)', 'a-value difference', 'Utsu test - Log probability', ...
%     'Utsu test - Log Probability (Adjusted by Ramon)'));
% elseif (~params.bBootstrapFirst & params.bBootstrapSecond)
%   params.vcsGridNames = cellstr(char('b-value (1st period)', 'Std.-dev. (Shi/Bolt) of b (1st period)', ...
%     'annuala-value @ Mc (1st period)', 'annuala-value @ Mc where b computed (1st period)', 'Mc (1st period)', 'Mc where b computed (1st period)', ...
%     'Recurrence time for M=6', 'Log of Recurrence time for M=6', 'Annual probability for M=6', 'Log of annual probability for M=6', ...
%     'Recurrence time for M=6 (Overall b)', 'Log of Recurrence time for M=6 (Overall b)', 'Annual probability for M=6 (Overall b)', 'Log of annual probability for M=6 (Overall b)', ...
%     'b-value (2nd period)', 'Std.-dev. (Shi/Bolt) of b (2st period)', 'annuala-value @ Mc (2nd period)', 'annuala-value @ Mc where b computed (2nd period)', ...
%     'Mc (2nd period)', 'Mc where b computed (2nd period)', 'Std.-dev. (Bootstrap) of b (2nd period)', 'Std.-dev. (Bootstrap) of Mc (2nd period)', ...
%     'b-value difference', 'annuala-value difference', 'Utsu test - Log probability', 'Utsu test - Log Probability (Adjusted by Ramon)'));
% else
%   params.vcsGridNames = cellstr(char('b-value (1st period)', 'Std.-dev. (Shi/Bolt) of b (1st period)', ...
%     'annuala-value @ Mc (1st period)', 'annuala-value @ Mc where b computed (1st period)', 'Mc (1st period)', 'Mc where b computed (1st period)', ...
%     'Recurrence time for M=6', 'Log of Recurrence time for M=6', 'Annual probability for M=6', 'Log of annual probability for M=6', ...
%     'Recurrence time for M=6 (Overall b)', 'Log of Recurrence time for M=6 (Overall b)', 'Annual probability for M=6 (Overall b)', 'Log of annual probability for M=6 (Overall b)', ...
%     'b-value (2nd period)', 'Std.-dev. (Shi/Bolt) of b (2st period)', 'annuala-value @ Mc (2nd period)', 'annuala-value @ Mc where b computed (2nd period)', ...
%     'Mc (2nd period)', 'Mc where b computed (2nd period)', 'b-value difference', 'annuala-value difference', ...
%     'Utsu test - Log probability', 'Utsu test - Log Probability (Adjusted by Ramon)'));
% end
params.mValueGrid = mValueGrid_;


% nNumberNodes = length(caNodeIndices);
%
% % Init result matrix
% mValueGrid = zeros(nNumberNodes, 4);
%
% for nNode_ = 1:nNumberNodes
%   % Create node catalog for the first catalog
%   mNodeCatalog_ = mCatalog(caNodeIndices{nNode_}, :);
%   [fBValue, fStdDev, fMc, fAValue] = calc_BandMc(mNodeCatalog_, nMinimumNumber, nCalculateMC);
%
%       fRecurrenceTime =(teb - t0b)./(10.^(fAValue-6*fBValue));
%   if isempty(fRecurrenceTime)
%     fRecurrenceTime = nan;
%   end
%   mValueGrid(nNode_,:) = [fBValue fStdDev fMc fRecurrenceTime];
% end % of for
% % Create the description-strings for the output-window
% vcsGridNames = cellstr(char('b-value', 'Std. dev. of b-value', 'Magnitude of completeness', 'Recurrence Time'));
