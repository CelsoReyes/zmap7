function [vDrate] = calc_InterpBgrate(mGrid,fMmin)
% function [vDrate] = calc_InterpBgrate(mGrid,fMmin)
% --------------------------------------------------
% Get background rates from a Frankel model on the grid points of a rate
% change grid. Sums the rates for magnitudes larger than fMmin
%
% Incoming:
% mGrid : X-Y grid to interpolate on ([Lon Lat])
% fMmin : Minimum magnitude (generally the same as Mc)
%
% Outgoing:
% vDrate : Vector of DAILY seismicity rates
%
% last update: 09.07.2004
% jochen.woessner@sed.ethz.ch

% Load Frankel model with daily background rate
% Contains variable nullRates :[Lonmin Lonmax Latmin Latmax Dpethmin Depthmax Magmin Magmax DailyRate
% Weight]

% Load CFS file
[sFilename, sPathname] = uigetfile('*.mat', 'Pick Frankel DailyRate MAT-file');
sHelp = [sPathname sFilename];
sFile = [sFilename(1:length(sFilename)-4)];
load(sHelp)

% Loop over grid node positions
for nCnt = 1:length(mGrid(:,1))
    fXcoord = mGrid(nCnt,1);
    fYcoord = mGrid(nCnt,2);
    vSel = (fXcoord >= nullRates(:,1) & fXcoord < nullRates(:,2) &...
        fYcoord >= nullRates(:,3) & fYcoord < nullRates(:,4) & fMmin > nullRates(:,7));
    if ~isempty(nullRates(vSel,9))
        fAllSumMagRate = max(cumsum(nullRates(vSel,9)));
        vDrate(nCnt) = fAllSumMagRate;
    else
        vDrate(nCnt) = nan;
    end
end

