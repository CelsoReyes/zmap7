function [fChi2] = plot_chi2(mCatalog)
%
%---------------------------------------------------------------------------------------
% Function to determine the Poissonian distribution of a catalog
% using a Chi^2-test
% Reference: J. Taubenheimer, Statistische Auswertung geophys. und meteorol. Daten, 1969
%
% Incoming variables:
% mCatalog : EQ catalog in ZMAP format
%
% Outgoing variables:
% fChi2 : Chi^2-Test value
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 18.09.02

% Track changes:
% 18.09.02: Set binning interval nBin  to 100

%%% Track of Variables
% nBin        : Number of binning intervalls
% vEvents     : Amount of events in time interval
% vBinloc     : Bin locations in dec. time-
% vEventsort  : vEvents sorted ascending
% vBinlocsort : Bin locations
% fLambda     : Lambda for theoretical poissonian distribution; average amount of eqs per unit time interval
% vTheopoissprob : Theoretical poissonian probability
% vFreqEvents : Observed frequency of eqs / time interval
% vTheoFreq   : Theoretical frequency of eqs / time intervall
% fChi2 : Chi^2-Test value
% fChi2_sig90 : Significance level 90%
% fChi2_sig95 : Significance level 95%
% fChi2_sig99 : Significance level 95%

mFreq = [];
mFreqLow = [];
mFreqHigh = [];
%%% Determine theoretical Possonian distribution
nBin = 100;

[vEvents,vBinloc]=histogram(mCatalog(:,3),nBin);
[vEventsort,vBinlocsort]=sort(vEvents);
fLambda=poissfit(vEventsort)
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
mFreqTmp = mFreq(vSel,:); % Frequency N > 5
mSmallFreq = mFreq(~vSel,:); % Frequency N <= 5
[nXmSmallFreq, nYmSmallFreq]=size(mSmallFreq);
vSumSmallFreq = max(cumsum(mSmallFreq,3),[],3); % Determines sum of frequencies for time intervals with less than 5 Eqs in it
%%% Determine Chi^2-Value
% vSelChi = (mFreq(:,3) > 0.01);
% mChiFreq = mFreq(vSelChi,:);
% vChi2 = ((mChiFreq(:,2)-mChiFreq(:,3)).^2)./mChiFreq(:,3);
vChi2 = ((mFreq(:,2)-mFreq(:,3)).^2)./mFreq(:,3);
fChi2 = max(cumsum(vChi2));
%% Degree of freedom: -2 because Lambda comes from theoret. distribution
fChi2DegFree = length(mFreq)-2;
%% Significance levels to determine deviance from Null hypothesis
fChi2_sig90=chi2inv(0.90,fChi2DegFree);
fChi2_sig95=chi2inv(0.95,fChi2DegFree);
fChi2_sig99=chi2inv(0.99,fChi2DegFree);

%% Here starts the organization of the plot
mFreqPlot = mFreqPlotTmp; % Initialize
if ~isempty(vSumSmallFreq)
    mFreq = [mFreqTmp; vSumSmallFreq];
    %%%%%%%%% Search vectors of small theoretical frequencies
    if nXmSmallFreq > 1
        nCount = 1;
        while (mSmallFreq(nCount+1) - mSmallFreq(nCount)) == 1
            nCount = nCount+1;
        end % End of While
        if (mSmallFreq(1,1) == 0 & nCount > 1)
            mFreqLow = mSmallFreq(1:nCount,:);
            vMinBin = max(mFreqLow);
            mFreqLow = max(cumsum(mFreqLow));
            %mFreqLow(1,1) = mFreqLow(1,1)-1;
            mFreqLow(1,1) = vMinBin(1,1);
            [nIndice] = find(mFreqPlotTmp(:,1) == mSmallFreq(nCount+1));
            mFreqHigh = mFreqPlotTmp(nIndice:length(mFreqPlotTmp),:);
            mFreqHigh = max(cumsum(mFreqHigh));
            %mFreqHigh(1,1) = max(mFreqPlotTmp(:,1))+1;
            mFreqHigh(1,1) = nIndice-1;
            mFreqHigh(1,3) = 0;
            mFreqPlotTmp = mFreqPlotTmp(vMinBin(1,1)+2:nIndice-1,:);
            mFreqPlot = [mFreqLow; mFreqPlotTmp; mFreqHigh];
        else
            %[nIndice] = find(mFreqPlotTmp(:,1) == mSmallFreq(nCount+1));
            [nIndice] = min(find(mFreqPlotTmp(:,3) < 5));
            mFreqHigh = mFreqPlotTmp(nIndice:length(mFreqPlotTmp),:);
            mFreqHigh = max(cumsum(mFreqHigh));
            %mFreqHigh(1,1) = max(mFreqPlotTmp(:,1))+1;
            mFreqHigh(1,1) = nIndice;
            mFreqHigh(1,3) = 0;
            mFreqPlotTmp = mFreqPlotTmp(1:nIndice-1,:);
            mFreqPlot = [mFreqPlotTmp; mFreqHigh];
        end % END IF (mSmallFreq(1,1) == 0 & nCount > 1)
    elseif (length(mSmallFreq(:,1)) == 1  &&  mSmallFreq(1,1) == 0)
        mFreqPlot = [mSmallFreq; mFreqPlotTmp];
    else
        mFreqPlot = [mFreqPlotTmp; mSmallFreq];
    end % END IF length(mSmallFreq(:,1)) > 1
end % END IF ~isempty(vSumSmallFreq)


%%%% Plots
if exist('hd1_calc_chi2','var') & ishandle(hd1_calc_chi2)
    set(0,'Currentfigure',hd1_calc_chi2);
    disp('Figure exists');
else
    hd1_calc_chi2=figure_w_normalized_uicontrolunits('tag','fig_calc_chi2_theo','Name','Theoretical Poissonian distribution ',...
        'Units','normalized','Nextplot','add','Numbertitle','off');
end
subplot(3,1,1);
set(gca,'tag','ax1_calc_chi2_theo','Nextplot','replace','box','on');
axs1=findobj('tag','ax1_calc_chi2_theo');
axes(axs1(1));
bar(vBinloc,vEvents);
set(gca,'Xlim', [floor(min(vBinloc)) ceil(max(vBinloc))]);
xlabel('Time / [Dec. years]');
ylabel('Frequency');
subplot(3,1,2);
set(gca,'tag','ax1_calc_chi2_theo2','Nextplot','replace','box','on');
axs2=findobj('tag','ax1_calc_chi2_theo2');
axes(axs2(1));
histogram(vEventsort,0:length(vBinlocsort));
set(gca,'Xlim', [0 ceil(nBin)]);
hold on;
plot(mFreqPlot(:,1),mFreqPlot(:,3),'Color',[0 0.5 0]);
%bar(vBinlocsort,vEventsort);
%bar(vTheoEvents)
xlabel('Quantiy of Eqs');
ylabel('Freq. of Bins with N Eqs');
subplot(3,1,3);
set(gca,'tag','ax1_calc_chi2_theo3','Nextplot','replace','box','on');
axs3=findobj('tag','ax1_calc_chi2_theo3');
axes(axs3(1));
x= 1:1:length(vTheoPoissprob);
plot(x,vTheoPoissprob,'r');
hold on;
plot(vEventsort,vTheoPoissdist);
xlabel('Quantity of Eqs');
ylabel('Poiss. Prob.');
%%%%%%%%% Plot 2
if exist('hd2_calc_chi2','var') & ishandle(hd2_calc_chi2)
    set(0,'Currentfigure',hd2_calc_chi2);
    disp('Figure exists');
else
    hd2_calc_chi2=figure_w_normalized_uicontrolunits('tag','fig2_calc_chi2_theo','Name','Distribution ',...
        'Units','normalized','Nextplot','add','Numbertitle','off');
end
set(gca,'tag','ax3_calc_chi2','Nextplot','add','box','on','Visible','on');
axs5=findobj('tag','ax3_calc_chi2');
axes(axs5(1));
bar(mFreqPlot(:,3));
hold on;
hPatch = findobj(gca,'Type','patch');
set(hPatch,'FaceColor',[0 0.5 0],'EdgeColor','k');
hPatch1=bar(mFreqPlot(:,2));
ylabel('Frequency');
xlabel('EQ / Unit time');


fSign = 0.999;
while fSign > 0
    fSig = chi2inv(fSign,fChi2DegFree);
    if fChi2 > fSig
        nPoissDeg = fSign
        break;
    end
    fSign = fSign - 0.001;
end

%%%% Chi2-Test information for the user
% sInfostr1=['Chi^2 =' num2str(fChi2) ' not rejected. Rejection limit for 90% significance lies at ' num2str(fChi2_sig90)];
% if  fChi2 > fChi2_sig90
%     sInfostr1=['Chi^2 =' num2str(fChi2) ' rejected at 90% as Rejection limit = ' num2str(fChi2_sig90)];
% end
% if  fChi2 > fChi2_sig95
%     sInfostr1=['Chi^2 =' num2str(fChi2) ' rejected at 95% as Rejection limit = ' num2str(fChi2_sig95)];
% end
% if  fChi2 > fChi2_sig99
%     sInfostr1=['Chi^2 =' num2str(fChi2) ' rejected at 99% as Rejection limit = ' num2str(fChi2_sig99)];
% end
sInfostr1=['Significance level of rejecting the hypothesis that the earthquakes in the given'...
        ' catalog are poissonian distributed: Chi^2 =' num2str(nPoissDeg)];

msgbox(sInfostr1,'Chi^2-Test Information');
