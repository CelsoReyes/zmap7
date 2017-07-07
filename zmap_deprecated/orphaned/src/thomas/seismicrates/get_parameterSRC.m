function [params]=get_parameterSRC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Example: params=get_parameter
%
% This function contains all the parameters needed for sr_startZ.m,
% sr_calcZ.m, etc.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author:
% van Stiphout, Thomas, vanstiphout@sed.ethz.ch
%
% Created on 16.08.2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('~/zmap/src/thomas/seismicrates/get_parameterSRC');

params.sFile='08041405-NoDeclus.mat'; %ilename for result matrix
% params.sFile='08041401-Nodeclus.mat'; %ilename for result matrix
params.nLimit=500;
params.rContainer='rContainer';
% load catalog to work with (can also be selected later
params.sFilename='anss-1975-19923-Mc18-Landers-declus.mat';
eval(sprintf('load %s', params.sFilename));
if ~exist('mCatalog')
    mCatalog=a; clear a;
end
params.mCatalog=mCatalog;
params.mCatRef=params.mCatalog;
% params.mDeltaHypo=[params.mCatalog(:,11) params.mCatalog(:,11) params.mCatalog(:,12)] ;
% params.mDeltaMag=[params.mCatalog(:,13)];
params.fMc=2.0;

% params.mDeltaMag=params.mCatalog(:,13);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.nSynCat=1;       % 0: Real Catalog (no synsthetic catalog calculated
                        % 1: Synthetic Catalog of background rate
                        % 2: Synthetic Catalog with ETAS

params.bHypo=false ; % performing simulation for  hypocenter uncertainties?
%params.mDeltaHypo=[params.mCatalog(:,11) params.mCatalog(:,11) params.mCatalog(:,12)] ;
params.mDeltaHypo=[];
if isempty(params.mDeltaHypo)
    params.mHypo=[1 1 3];
end
params.bMag=true ;  % performing sumulation for magnitude uncertainties
%params.mDeltaMag=[params.mCatalog(:,13)];
params.mDeltaMag=[];
if isempty(params.mDeltaMag)
    params.mMag=[0.5];
end

params.nMCS=1000;               % number of simulation for hypocenter and/or magnitude and/or declustering

params.nMode=1;              % 0:Declustering, 1: only Rates, 2:Declustering and Rates
params.nSimul=1;              % No of Simulation for MCS - have to be 1 at the moment
params.nDeclusMode=4;   % Applied declustering algorithm
                        % 1: Reasenberg Matlab
                        % 2: Gardner Knopoff
                        % 3: Stochastic
                        % 4: Reasenberg Cluster2000 (fortran)
                        % 5: Marsan
                        % 6: cluster GK written by Annemarie
                        % 7: cluster Uhrhammer written by Annemarie
                        % 8: cluster Utsu written by Annemarie


if params.nMode~=1
        % parameter range for reasenberg declustering (nDeclusMode=4)
    % Taumin, Taumax, P1, Xk, Xmeff, Rfact, Err, Derr
%    params.mReasenParam=[[1 1];[10 10];[0.95 0.95];[0.5 0.5];...
%        [1.8 1.8];[10 10];[2 2];[4 4]];
    params.mReasenParam=[[0.5 2.5];[03 15];[0.90 0.99];[0.0 1.0];...
        [1.8 2.0];[05 20];[2 2];[4 4]];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameter for rate change calculation
params.fTstart=1981;            %  Start Time for z-Value calculation
params.fT=1992.3;                 % Time cut of years
% time window length in years
% params.vTw=[4]';
params.vTw = [4 ]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sampling
% Time steps in days
params.vTbin=[floor((params.fT-params.fTstart)*365/100)]';
% No of Events per sample
params.vN=[200];
params.nMinimumNumber=100;        % Minimum Number of events if working with
                                 % constant radius
params.fRadius=25;               % Radius (if working with constant radius
params.fResolution=0;           % Max km if N, min N if R
params.fBinning=0.1;             % Bin size for magnitude binning
params.fTimePeriod=365;          % Period lengths to be compared in days

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gridding
params.bMap=1;                             % working in map view
params.nGriddingMode=1;            % 0:Constant number,1:Constant radius,2:Rectangle mode
params.bGridEntireArea=1;       % Grid entire region (1) or no (0)
params.fSpacingHorizontal=[];  % Grid spacing latitude
params.fSpacingDepth=[];       % Grid spacing longitude
params.fSizeRectHorizontal=[];  % Rectangular selection instead radius params.fRadius
params.fSizeRectDepth=[];       % Rectangular selection instead radius params.fRadius

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for Synthetic catalog
if params.nSynCat~=0
    params.mSynCatRef=params.mCatalog;
    params.nSynCatSize=10000;
    params.nMaxCatSize=100000; % limit for calculation of z-values
    params.nSynMode=1;     % type of synthetic catalog background rate 0: homogeneously distributed
    % hypocenters; 1: take real catalog and permute time % and location
    % (+/-5km) 2: permute hypocenters and create new focal Time,Mag

    params.bPSQ=true;  % with or without PSQ
    % nPSQtype (1=N nearest events, 2=poly, 3=fixed radius (km)), Tw, T, Reduction of earthquakes
    %  (0.75 = 75% reduction)
    params.vPSQ=[1 4 1992.3 0];
    if params.vPSQ(1)==1
        % lon, lat, volume
        params.mPSQ=[-116.4 34.3 500];
    elseif params.vPSQ(1)==2
        % size of polygon (if nPSQtype=2, give Polygon)
        params.mPSQ=  [   [-116.5 34.25];
                         [-116.5 34.42];
                         [-116.3 34.42];
                         [-116.3 34.25]];
%[[-116.5000   34.1200];
%                      [-116.7000   34.2500];
%                      [-116.4000   34.4000];
%                      [-116.3000   34.3000]];
    else disp('PSQ Type is not correct!');
    end
    % Vektor with contraints on synthetic catalog
    % 1-4: fMinLon fMaxLon fMinLat fMaxLat in degree
    % 5-6: fMinDepth fMaxDepth  in km
    % 7-8: fMinTime fMaxTime (duration of catalog)
    % 9: fRate Reduction of earthquakes for entire catalog (0.75 = 25%
    % reduction) in period (fT-fTw) - fT
    % 10:  fBValue           b-value of the catalog
    % 11:  fMc Magnitude of Completness (minimum Magnitude in Catalog)
    % 12:  fIncMagnitude increment steps
    params.vSynCat=[-118.2, -114.5, 32.1, 36.1, 0 40, ...
        params.fTstart-(params.fT-params.fTstart)/2, params.fT,...  %
        1, 1, params.fMc, 0.1]';

    % Definition/Constraints for Aftershocks
    % 1: Mmin: Minimum earthquake magnitude to report and simulate
    % 2: MminR: Minimum earthquake magnitude for reporting in the output
    % catalog
    % 3: maxm: Maximum earthquake magnitude
    % 4: DMax: Maximum distance for aftershocks
    % 5: magb: Cutoff magnitude for the point source vs. plane source
    %representation of the mainshock
    params.vAfter=[params.vSynCat(11), params.vSynCat(11), 8, 100, 5];

    % Parameters for ETAS : [CX, P, A] standard =[0.095, 1.34, 0.008]
    params.vEtas=[0.095, 1.34, 0.008];
end


