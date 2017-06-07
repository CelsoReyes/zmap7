function [vRate,vNcumev] = calc_SeisRateDietrich(fTmax,fDsigma0,mStressStep,fBgrate, fAsigma, fStressRate0, bPlot)
% function [vRate,vNcumev] = calc_SeisRateDietrich(fTmax,fDt,fDsigma0,mStressStep,fBgrate, fAsigma, fStressRate0, bPlot)
% -------------------------------------------------------------------------
% Compute DAILY seismicity rate from rate and state theory and cumulative
% number. Plot if wanted.
% Reference: J. Dietrich, JGR, Vol. 99, No. B2, 1994
%
% Incoming
% fTmax : Maximum time [days after mainshock]
% fDsigma0 : CFS change due to mainshock [bar], e.g. 3
% mStressStep : Matrix containing time and amount of significant stress
%               steps, e.g [30 0.4; 50 0.2] with [time after mainshock; bar]
%               Leave empty for no secondary shocks: []
% fBgrate : Daily rate of background seismicity, e.g  0.01 [1/d]
% fAsigma : A*sigma, fault constitutive parameter times normal stress, e.g.
%           0.5 [bar]
% bPlot   : 0 = no plot, 1=plot
%
% Outgoing:
% vRate : daily rate
% vNcumev : Cumulative number of events
%
% last update: 09.07.2004
% jochen.woessner@sed.ethz.ch

% Time vector [days]
fDt = 1;
vTime = [0:fDt:fTmax];
vTime = vTime';

% Initial state variables (t=0)
vGamma0(1) = 1/fStressRate0;
vGamma1(1) = vGamma0(1);
vGamma2(1) = vGamma1(1)*exp(-fDsigma0/fAsigma);

if isempty(mStressStep)
    mStressStep = [0 fDsigma0];
    fStressStep = fDsigma0;
end

for nCnt = 2:1:length(vTime)
    vGamma0(nCnt) = vGamma2(nCnt-1);
    % State variable (Equation B17)
    vGamma1(nCnt) = (vGamma0(nCnt)-1/fStressRate0)*exp(-fDt*fStressRate0/fAsigma)+1/fStressRate0;
    % Get CFS step
    vSel = (vTime(nCnt) == mStressStep(:,1));
    fStressStep = mStressStep(vSel,2);
    if ~isempty(fStressStep) %vTime(nCnt) == mStressStep(1,1)
        fDsigma = fStressStep; %mStressStep(1,2);
    else
        fDsigma = 0;
    end
    % State variable (Equation B11)
    vGamma2(nCnt) = vGamma1(nCnt)*exp(-fDsigma/fAsigma);
    % Rate
    vRate(nCnt) = fBgrate/(vGamma2(nCnt)*fStressRate0);
end

% Cumulative number of events
vNcumev = cumsum(vRate);

%% Plotting
if ~exist('bPlot','var')
    bPlot = 0;
end

if bPlot == 1
    figure_w_normalized_uicontrolunits('Name','Seismicity rates - Rate and state')
    subplot(3,1,1)
    loglog(vTime,vRate,'Color',[0 0 0],'Linewidth',2);
    %xlabel('Time [days after mainshock]','FontSize',12,'Fontweight','bold');
    ylabel('Daily rate of earthquakes','FontSize',12,'Fontweight','bold');
    set(gca,'Linewidth',2,'FontSize',10,'Fontweight','bold');


    subplot(3,1,2)
    plot(vTime,vNcumev,'Color',[0 0 0],'Linewidth',2)
    %xlabel('Time [days after mainshock]','FontSize',12,'Fontweight','bold');
    ylabel('Cumumaltive # of EQ','FontSize',12,'Fontweight','bold');
    set(gca,'Linewidth',2,'FontSize',10,'Fontweight','bold');

    subplot(3,1,3)
    plot(vTime,vGamma2,'Color',[0 0 0],'Linewidth',2)
    xlabel('Time [days after mainshock]','FontSize',12,'Fontweight','bold');
    ylabel('State variable \gamma','FontSize',12,'Fontweight','bold');
    set(gca,'Linewidth',2,'FontSize',10,'Fontweight','bold');

    set(gcf,'Pos',[386.00        270.00        694.00        730.0])
end
