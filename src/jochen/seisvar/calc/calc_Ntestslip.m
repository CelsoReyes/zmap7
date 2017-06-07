function [rNtest] = calc_Ntestslip(vXsec,vDepth,mCatalog,rSlip,nNumSim,fMinSlip,fMaxSlip,sSampMet)
% function [rNtest] = calc_Ntestslip(vXsec,vDepth,mCatalog, rSlip,nNumSim,,fMinSlip,fMaxSlip,sSampMet)
% ---------------------------------------------------------------------------------------------------------------------------------
% Function to compute N-Test between aftershock location and slip-distribution values
%
% Incoming:
% vXsec    : Vector containing the x-coordinates of the events from mCatalog along stirke of the slip-distribution cross-section
% vDepth   : EQ catalog depth vector
% mCatalog : EQ catalog containing cross section locations
% rSlip    : Data from Finite-Source database by M,Mai
% nNumSim  : Number of Monte Carlo simulations
% fMinSlip : Percentage of slip to select events
% fMaxSlip : Percentage of slip to select events
% sSampMet : Data sampling method sting: 'resample' (default), 'linear', 'inversion'
%
% Output:
% rNtest : Record of variables
%
% last update: J. Woessner

if ~exist('sSampMet','var')
    sSampMet = ['resample'];
end

%%% Define slip sampling method
switch lower(sSampMet)
case {'linear'}
    mSlip = rSlip.linear;
case {'inversion'}
    mSlip = rSlip.inversion;
otherwise
    mSlip = rSlip.resample;
end

% Dimension, hypocenter, top depth of fault, maximum slip
dim = rSlip.dmLW;
hypo = [rSlip.hypX rSlip.hypZ];
htop = rSlip.htop;
fDmax = rSlip.Dmax;

[lz,lx] = size(mSlip);
W = dim(1); L = dim(2);
dz = W/lz;
dx = L/lx;

%%% calculate Mw,Mo for mSlip distribution
[Mo,Mw] = fmomentN(mSlip,dim);

%%% set up axis
zax = linspace(0,W,lz);
xax = linspace(0,L,lx);
%% Adjusts for blind fault and dip
zax = htop+zax*sin(radians(rSlip.dip));

% Select catalog in dimensions of slip distribution
vSel = (vDepth <= W & vXsec <= L);

% Determine slip-value at aftershock location by linear interpolation
vSlip = interp2(xax,zax,mSlip,vXsec(vSel),vDepth(vSel),'linear');

% Determine number of events with fMinSlip <= slip < fMaxSlip
vSel1 = (vSlip >= fMinSlip*fDmax & vSlip < fMaxSlip*fDmax);
rNtest.nInBound = length(vSlip(vSel1,1));

% Container
vNtest = [];
% Initialize the random number generator
rand('state',sum(100*clock))

% Monte-Carlo simulation
for nCnt = 1:1:nNumSim
    % Create random aftershock locations from uniform distribution
    [nY,nX] = size(vXsec(vSel));
    vDepthRand = rand(nY,1)*W; % Depth distribution
    vXsecRand = rand(nY,1)*L; % Distance along strike distribution
    vRandSlip = interp2(xax,zax,mSlip,vXsecRand,vDepthRand,'linear');
    % Determine number of events with fMinSlip <= slip < fMaxSlip
    vSel2 = (vRandSlip >= fMinSlip*fDmax & vRandSlip < fMaxSlip*fDmax);
    nInBoundRand = length(vRandSlip(vSel2,1));
    % Store number of events
    vNtest = [vNtest; nInBoundRand];
end

% Compute fraction of cases that slip values of real aftershock locations
% are less or equal (fAlpha) or larger (fBeta) than those from randomized catalogs
vSel = (vNtest <= rNtest.nInBound);
rNtest.fAlpha = length(vNtest(vSel,1))/nNumSim;
rNtest.fBeta = length(vNtest(~vSel,1))/nNumSim;

% Store some important values of the distribution
rNtest.vNtest = sort(vNtest);
rNtest.nNumSim = nNumSim;
rNtest.fMean = mean(vNtest);
rNtest.fStd = calc_StdDev(vNtest);

% Compute nInBound normalized by standard deviation
rNtest.fNormStand = (rNtest.nInBound-rNtest.fMean)/rNtest.fStd;

% Plot result
plot_Ntestslip(rNtest,'L');

% subplot(212)
% [vFreq, vXval]=histogram(vNtest);
% histogram(vNtest)
% ylabel('Frequency','Fontweight','bold')
% xlabel('L','Fontweight','bold')
% hold on;
% plot([rNtest.nInBound rNtest.nInBound],[0 ceil(max(vFreq))],'r','Linewidth',2)
% set(gca,'Linewidth',1.5,'Fontweight','bold','box','on','XTick',vXtick,'visible','on')

