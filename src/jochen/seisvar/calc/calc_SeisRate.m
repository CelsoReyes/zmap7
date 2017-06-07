function [fRateDay, fRateYear] = calc_SeisRate(mCatalog,fMc)
% function [fRateDay, fRateYear] = calc_SeisRate(mCatalog,fMc)
% ------------------------------------------------------------
% Calculate seismicity rates for M>=Mc
%
% Incoming:
% mCatalog : Earthquake catalog
% fMc      : Minimum magnitude or magnitude of completeness
%
% Outgoing
% fRateDay  : Daily rate based on yearly estimate
% fRateYear : Yearly rate of earthquakes (overall guess)
%
% J. Woessner, jowoe@gps.caltech.edu

% Cut catalog
vSel = (mCatalog(:,6) >= fMc);
mCatalog = mCatalog(vSel,:);

% Rates
% Yearly
fRateYear = length(mCatalog(:,1))/(max(mCatalog(:,3))-min(mCatalog(:,3)));

% Daily
fRateDay = fRateYear/365;


