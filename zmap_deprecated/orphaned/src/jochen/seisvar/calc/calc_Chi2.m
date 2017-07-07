function [fChi2, fChi2_sig90, fChi2_sig95, fChi2_sig99, nPoissDeg] = calc_Chi2(mCatalog)
% [fChi2, fChi2_sig90, fChi2_sig95, fChi2_sig99, nPoissDeg] = calc_Chi2(mCatalog);
%---------------------------------------------------------------------------------------
% Function to determine the Poissonian distribution of a catalog using a Chi^2-test
% Reference: J. Taubenheimer, Statistische Auswertung geophys. und meteorol. Daten, 1969
%
% Nullhypothesis: The observed frequency of Eqs in the time-intervall (100) are Poissonian distributed.
% Incoming variables:
% mCatalog : EQ catalog in ZMAP format
%
% Outgoing variables:
% fChi2 : Chi^2-Test value
% fChi2_sig90 : Significance level 90%
% fChi2_sig95 : Significance level 95%
% fChi2_sig99 : Significance level 95%
% nPoissDeg   : Significance level of rejection of Nullhypothesis.
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 18.09.02

% Track changes:
% 22.08.02: Added nXsize >= 20 to if-statement; Sets nPoissDeg = Nan
% 18.09.02: Changed help on nPoissDeg; Fixed binning interval nBin = 100

% Remember: Insert check for radius events at fixed number of events
%%% Track of Variables
% nBin : Number of binning intervalls
% vEvents     : Amount of events in time interval
% vBinloc     : Bin locations in dec. time
% vEventsort  : vEvents sorted ascending
% vBinlocsort : Bin locations
% fLambda     : Lambda for theoretical poissonian distribution; average amount of eqs per 100 days
% vTheopoissprob : Theoretical poissonian probability
% vFreqEvents : Observed frequency of eqs / time interval
% vTheoFreq   : Theoretical frequency of eqs / time intervall
% fChi2 : Chi^2-Test value
[nXsize, nYsize] = size(mCatalog);

if (~isempty(mCatalog) & nXsize >= 20)
    mFreq = [];
    mFreqLow = [];
    mFreqHigh = [];
    vSumSmallFreq =[];
    %%% Determine theoretical Possonian distribution
    nBin = 100;
    [vEvents,vBinloc]=histogram(mCatalog(:,3),nBin);
    [vEventsort,vBinlocsort]=sort(vEvents);
    fLambda=poissfit(vEventsort);
    vTheoPoissdist = poisspdf(vEventsort,fLambda);
    vTheoEvents = length(mCatalog(:,3))*vTheoPoissdist;

    % Determine frequency of eqs per time interval
    for nEqs = 1:(max(vEvents)+1)
        vSel = (vEvents == (nEqs-1));
        vTmp1 = vEvents(vSel);
        vFreqEvents(nEqs) = length(vTmp1); % Observed frequency of eqs / time interval
        vNoEvents(nEqs) = nEqs-1;
        %% Theoretical frequency
        if nEqs > 100 % factorial(170) is maximum!!!!! 100 is arbitrary setting
            vTheoPoissprob(nEqs) = 0;
        else
            vTheoPoissprob(nEqs) = (fLambda^(nEqs-1))*exp(-fLambda)/factorial(nEqs-1);
        end
        vTheoFreq(nEqs) = vTheoPoissprob(nEqs) * nBin; % Theoretical frequency of eqs / time intervall
    end % End for nEqs

    %%% Select frequencies with less than or equal 5 Eqs per time intervall
    mFreq = [vNoEvents' vFreqEvents' vTheoFreq'];
    mFreqPlotTmp = mFreq;
    vSel = (mFreq(:,3) > 5);
    mFreqTmp = mFreq(vSel,:);
    mSmallFreq = mFreq(~vSel,:);
    if length(mSmallFreq(:,1)) == 1
        mFreq = [mFreqTmp; mSmallFreq];
    else
        vSumSmallFreq = max(cumsum(mSmallFreq),[],3); % Determines sum of frequencies for time intervals with less than 5 Eqs in it
        mFreq = [mFreqTmp; vSumSmallFreq];
    end

    %%% Determine Chi^2-Value
    vChi2 = ((mFreq(:,2)-mFreq(:,3)).^2)./mFreq(:,3);
    fChi2 = max(cumsum(vChi2));
    %% Degree of freedom: -2 because Lambda comes from theoret. distribution
    fChi2DegFree = length(mFreq(:,1))-2;
    %% Significance levels to determine deviance from Null hypothesis
    fChi2_sig90=chi2inv(0.90,fChi2DegFree);
    fChi2_sig95=chi2inv(0.95,fChi2DegFree);
    fChi2_sig99=chi2inv(0.99,fChi2DegFree);
else
    fChi2 = NaN;
    fChi2DegFree = NaN;
    fChi2_sig90=NaN;
    fChi2_sig95=NaN;
    fChi2_sig99=NaN;
end % END IF on mCatalog

% % %%%% Chi2-Test rejection significance level
nPoissDeg = 0;
if isnan(fChi2)
    nPoissDeg = NaN;
else
    fSign = 0.999;
    while fSign >= 0
        fSig = chi2inv(fSign,fChi2DegFree);
        if fChi2 >= fSig
            nPoissDeg = fSign;
            break;
        end
        fSign = fSign - 0.001;
    end
end
