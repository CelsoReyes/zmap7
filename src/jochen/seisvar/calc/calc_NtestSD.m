function [rNtest] = calc_NtestSD(vXsec,vDepth,mCatalog,rSlip,rStress,nNumSim,fMinStress,fMaxStress,bFig)
% function [rNtest] = calc_NtestSD(vXsec,vDepth,mCatalog,rSlip,rStress,nNumSim,fMinStress,fMaxStress,bFig)
% --------------------------------------------------------------------------------------------------------
% Function to compute N-Test between aftershock location and stress-drop-distribution values
% Convention: negative stress drop is stress increase
%
% Incoming:
% vXsec    : Vector containing the x-coordinates of the events from mCatalog along strike of the
%            slip-distribution cross-section
% vDepth   : EQ catalog depth vector
% mCatalog : EQ catalog containing cross section locations
% rStress  :
% rSlip    : Data from Finite-Source database by M,Mai
% nNumSim  : Number of Monte Carlo simulations
% fMinStress : Minimum stress-drop [bar]
% fMaxStress : Maximum stress-drop [bar]
% bFig       : Boolean 0: show plot (default), 1: no plot
%
% Output:
% rNtest : Record of variables
% rNtest.fAlpha   : Fraction of cases that slip values of real aftershock locations
%                   are less or equal than those from randomized catalogs
% rNtest.fBeta    : Fraction of cases that slip values of real aftershock locations
%                   are larger than those from randomized catalogs
% rNtest.vNtest   : Vector of number of events in stress bounds
% rNtest.nNumSim  : Amount of Monte Carlo simulations
% rNtest.fMean    : Mean of  vNtest
% rNtest.fStd     : Standard deviation of vNtest
% rNtest.fNormStand : Deviation of number of events in stress bounds for original catalog compared to
%                     distribution from randomized locations normalized to standard deviation

% last update: J. Woessner

% Check on figure
if ~exist('bFig','var')
    bFig = 0;
end

% Dimension, hypocenter, top depth of fault, maximum slip
dim = rSlip.dmLW;
hypo = [rSlip.hypX rSlip.hypZ];
htop = rSlip.htop;

[lz,lx] = size(rStress.SDsc);
W = dim(1); L = dim(2);
% dz = W/lz;
% dx = L/lx;
%%% set up axis
zax = rStress.wax;
xax = rStress.lax;
zax = htop+zax*sin(radians(rSlip.dip));

% Select catalog in dimensions of slip distribution
vSel = (vDepth <= W & vXsec <= L);

% Determine slip-value at aftershock location by linear interpolation
vStress = interp2(xax,zax,rStress.SDsc,vXsec(vSel),vDepth(vSel),'linear');

% Determine number of events with fMinStress <= slip < fMaxStress
vSel1 = (vStress >= fMinStress & vStress < fMaxStress);
rNtest.nInBound = length(vStress(vSel1,1));

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
    vRandStress = interp2(xax,zax,rStress.SDsc,vXsecRand,vDepthRand,'linear');
    % Determine number of events with fMinStress <= slip < fMaxStress
    vSel2 = (vRandStress >= fMinStress & vRandStress < fMaxStress);
    nInBoundRand = length(vRandStress(vSel2,1));
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
if bFig == 0
    plot_Ntestslip(rNtest,'L');
end
