function [fTmax, mRes] = calc_ChTime(mCatalog, fTimeWindow)
% [fTmax, mRes] = calc_ChTime(mCatalog, fTimeWindow)
% -------------------------------------------------------
% Function to identify times of maximum changes of seismicity in time using
% the absolute difference of the non-cumulative FMD in successive time windows
%
% Incoming:
% mCatalog    : EQ catalog
% fTimeWindow : Length of moving time window in dec. years
%
% Outgoing variable:
% fTmax : Time of maximum change
% mRes : Matrix containing time and absoulte changes
%
% J. Woessner
% last update: 21.01.2004

mRes = [];

% Initialize
fMinTime = min(mCatalog(:,3));
fMaxTime = max(mCatalog(:,3));
fTimePeriod = fMaxTime-fMinTime;

% Minimum bin
fMinBin = roundn(min(mCatalog(:,6)),-1);
fMaxBin = roundn(max(mCatalog(:,6)),-1);

% Seismicity of catalog normalized to time period
nNumevents = max(length(mCatalog(:,1)));
fNum = nNumevents/fTimePeriod;

% Starttime
fTime = fMinTime;

while fTime < fMaxTime-2*fTimeWindow
    vSel = (mCatalog(:,3) >= fTime & mCatalog(:,3) < fTime+fTimeWindow);
    nNumper = max(length(mCatalog(vSel,1)));
    fNumper = nNumper/fTimeWindow;
    fChTime = fNumper/fNum; % Relative change of entire data

    % Change in FMD
    [vFMD1, vBin1] = hist(mCatalog(vSel,6),fMinBin:0.1:fMaxBin);
    vSel2 = (mCatalog(:,3) >= fTime+fTimeWindow & mCatalog(:,3) < fTime+2*fTimeWindow);
    [vFMD2, vBin2] = hist(mCatalog(vSel2,6),fMinBin:0.1:fMaxBin);
    fChFMD = max(cumsum(abs(vFMD2-vFMD1)));


    mRes = [mRes; fTime fNumper fChTime fChFMD];

    % Shift time by half window width
    fTime = fTime+0.1; %fTimeWindow/10;
end

% Maximum positive change
vSel = (mRes(:,4) == max(mRes(:,4)));
mMax = mRes(vSel,:);
fTmax = mRes(vSel,1);

figure
hPlot1=plot(mRes(:,1),mRes(:,4)/mean(mRes(:,4)),'Color',[0 0 0],'Linewidth',2)
% sTitle = ['Time of maximum change: ' num2str(fTmax)]
% hTit=title(sTitle)
xlabel('Time [dec. year]','FontSize',12,'Fontweight','bold')
ylabel('Normalized \Delta_{FMD}','FontSize',12,'Fontweight','bold')
set(gca,'FontSize',12,'Fontweight','bold','Linewidth',2)
%set(hTit,'FontSize',12,'Fontweight','bold')
