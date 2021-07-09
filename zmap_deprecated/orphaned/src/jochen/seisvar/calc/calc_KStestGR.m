function [fAlpha, fDmax] = calc_KStestGR(mCatalog, fBinning, fBValue, fMc)
% [mAlphaVal] = calc_KStestGR(mCatalog, fBinning, fBValue)
% ------------------------------------------------------------------------
% Calculate Koglomorov-Smirnov-test with constant b-value
% Reference for equations to calculate the statistics nD:
% Y.Y. Kagan, Accuracy of modern global earthquake catalogs, Physics of the Earth and Planetary Interiors
% 4179, 1-37, 2002
%
% Incoming variables:
% mCatalog : Earthquake catalog
% fBinning : Binning interval
% fBValue  : Fix b-value
%
% Outgoing variables:
% mAlphaVal(:,1) : Significance level Alpha according to ascending magnitudes
% mAlphaVal(:,2) : Ascending magnitudes
%
% Author: J. Woessner
% last update: 25.03.03

% Initialize
mAlphaVal = [];
vD = [];

% Select data above Mc
vSel = (mCatalog(:,6) >= fMc);
mCatalog = mCatalog(vSel,:);

% Set fix values
fMaxMag = ceil(10 * max(mCatalog(:,6))) / 10;
fMinMag = (round(min(mCatalog(:,6)*10)))/10;
vMag = fMinMag:0.1:fMaxMag;

% Using Bath's law : see Reference Console
% Beta-value
fBeta = log(10)*fBValue;

% Probability density function
% vPdf = fBeta*exp(-fBeta*(vMag-fMc))
%
% % Cumulative density function
% vCdf = cumsum(vPdf);
% %vCdf = vCdf/max(vCdf);
% vCdf = [vCdf; vMag];
% vCdf = vCdf';

% CDF theoretically
vCdf = (1-exp(-fBeta*(vMag-fMc)))./(1-exp(-fBeta*(fMaxMag-2-fMc)));
vCdf = [vCdf; vMag];
vCdf = vCdf';

% Use Kagan 2002 approach
% Sort catalog with ascending magnitude
[mCatSorted,vIndex] = sort(mCatalog(:,6));
mCat = mCatalog(vIndex(:,1),:);

% Calulate statistic fD = max_(1=<k=<N)((k/N-F(M_k)
nEvents = length(mCat(:,1));
vkEvent = 1:length(mCat(:,1));
vkEvent = vkEvent/nEvents;
vkEvent = vkEvent';
for nE = 1:nEvents
    % Find probability of theoretical distribution for event k with magnitude Mk
    try
        vSel = (vCdf(:,2) == (round(mCat(nE,6)*10))/10);
        fD = max(nE/nEvents-vCdf(vSel,1));
        vD = [vD; fD];
    catch
        fD = nan;
        vD = [vD; fD];
    end
end
fDmax = max(vD);
fAlpha = exp(-2*nEvents*(fDmax+1/(6*nEvents))^2);
% vAlpha = exp(-2*nEvents.*(vD+1/(6*nEvents)).^2)
% disp('v')
