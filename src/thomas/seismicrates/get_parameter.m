function [params]=get_parameter
    % This function contains all the parameters needed for sr_startZ.m, sr_calcZ.m, etc.
    %
    % Example: params=get_parameter()
    %
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Author:
    % van Stiphout, Thomas, vanstiphout@sed.ethz.ch
    %
    % Created on 16.08.2007
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    report_this_filefun();
    
    params.sFile            = '08012402-test.mat'; %filename for result matrix
    params.nLimit           = 500;
    params.rContainer       = 'rContainer';
    % load catalog to work with (can also be selected later
    load 'TaiwanMc24.mat';
    if ~exist('mCatalog')
        mCatalog=a; clear a;
    end
    params.mCatalog         = mCatalog;
    params.mCatRef          = params.mCatalog;
    % params.mDeltaHypo     = [params.mCatalog(:,11) params.mCatalog(:,11) params.mCatalog(:,12)] ;
    % params.mDeltaMag      = [params.mCatalog(:,13)];
    params.fMc=3.0;
    
    % params.mDeltaMag      = params.mCatalog(:,13);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    params.nSynCat          = SynthTypes.none;       
    % 0: Real Catalog (no synsthetic catalog calculated
    % 1: Synthetic Catalog of background rate
    % 2: Synthetic Catalog with ETAS
    
    params.bHypo            = false; % performing simulation for  hypocenter uncertainties?
    %params.mDeltaHypo      = [params.mCatalog(:,11) params.mCatalog(:,11) params.mCatalog(:,12)] ;
    params.mDeltaHypo       = [];
    if isempty(params.mDeltaHypo)
        params.mHypo        = [1 1 3];
    end
    params.bMag=false;  % performing sumulation for magnitude uncertainties
    %params.mDeltaMag       = [params.mCatalog(:,13)];
    params.mDeltaMag        = [];
    if isempty(params.mDeltaMag)
        params.mMag         = [0.1];
    end
    
    params.nMCS             = 1;               % number of simulation for hypocenter and/or magnitude and/or declustering
    
    params.nMode            = 2;              % 0:Declustering, 1: only Rates, 2:Declustering and Rates
    params.bDeclus          = true;            % Only in Case nMode = 1 : 0:Load Declusterd Catalog, 1:no declustering
    params.nSimul           = 1;              % No of Simulation for MCS - have to be 1 at the moment
    params.nDeclusMode      = DeclusterTypes.Reasenberg_cluster200x;   % Applied declustering algorithm
    
    if params.nMode~=1
        % parameter range for reasenberg declustering (nDeclusMode=4)
        % Taumin, Taumax, P1, Xk, Xmeff, Rfact, Err, Derr
        %    params.mReasenParam=[[1 1];[10 10];[0.95 0.95];[0.5 0.5];...
        %        [1.8 1.8];[10 10];[2 2];[4 4]];
        params.mReasenParam=[[0.5 2.5];[03 15];[0.90 0.99];[0.0 1.0];...
            [2.4 2.7];[05 20];[2 2];[4 4]];
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % parameter for rate change calculation
    params.fTstart              = 1994.5;            %  Start Time for z-Value calculation
    params.fT                   = 1997.2;                 % Time cut of years
    % time window length in years
    % params.vTw=[4]';
    params.vTw                  = [2.5 ]';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Gridding
    params.bMap                 = true;     % working in map view
    params.nGriddingMode        = 0;        % 0:Constant number,1:Constant radius,2:Rectangle mode
    params.bGridEntireArea      = true;     % Grid entire region (1) or no (0)
    params.fSpacingHorizontal   = [];       % Grid spacing latitude
    params.fSpacingDepth        = [];       % Grid spacing longitude
    params.fSizeRectHorizontal  = [];       % Rectangular selection instead radius params.fRadius
    params.fSizeRectDepth       = [];       % Rectangular selection instead radius params.fRadius
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for Synthetic catalog
    if params.nSynCat ~= SynthTypes.none
        params.mSynCatRef       = params.mCatalog;
        params.nSynCatSize      = 20000;
        params.nMaxCatSize      = 100000; % limit for calculation of z-values
        params.nSynMode         = 1;     % type of synthetic catalog background rate 0: homogeneously distributed
        % hypocenters; 1: take real catalog and permute time only
        % and location (+/-5km) 2: permute hypocenters and
        % create new focal Time,Mag
        
        params.bPSQ             = false;  % with or without PSQ
        % nPSQtype (1=radius, 2=poly), Tw, T, Reduction of earthquakes
        %  (0.75 = 25% reduction)
        params.vPSQ             = [2 4.5 1992.3 0.5];
        if params.vPSQ(1)==1
            % lon, lat, volume
            params.mPSQ         = [-116.5 34 200];
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
        else
            disp('PSQ Type is not correct!');
        end
        
        % Vektor with contraints on synthetic catalog
        params.vSynCat=[...
            -118.2, -114.5, 32.1, 36.1,...  % 1-4: fMinLon fMaxLon fMinLat fMaxLat in degree
            0 40, ...                       % 5-6: fMinDepth fMaxDepth  in km
            params.fTstart-(params.fT-params.fTstart)/2, params.fT,...  % 7-8: fMinTime fMaxTime (duration of catalog)
            1, ...                          % 9: fRate Reduction of earthquakes for entire catalog
            1, ...                          % 10:  fBValue           b-value of the catalog
            params.fMc, ...                 % 11:  fMc Magnitude of Completness (minimum Magnitude in Catalog)
            0.1...                          % 12:  fIncMagnitude increment steps
            ]';
        
        % Definition/Constraints for Aftershocks
        % 1: Mmin: Minimum earthquake magnitude to report and simulate
        % 2: MminR: Minimum earthquake magnitude for reporting in the output
        % catalog
        % 3: maxm: Maximum earthquake magnitude
        % 4: DMax: Maximum distance for aftershocks
        % 5: magb: Cutoff magnitude for the point source vs. plane source
        %representation of the mainshock
        params.vAfter       = [params.vSynCat(11), params.vSynCat(11), 8, 100, 9];
        
        % Parameters for ETAS : [CX, P, A] standard =[0.095, 1.34, 0.008]
        params.vEtas        = [0.095, 1.34, 0.008];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Sampling
    % Time steps in days
    params.vTbin            = [floor((params.fT-params.fTstart)/days(100))]';
    %params.vTbin=14;
    % No of Events per sample
    params.vN               = [150]';
    params.nMinimumNumber   = 50;        % Minimum Number of events if working with
    % constant radius
    params.fRadius          = 80;               % Radius (if working with constant radius
    params.fMaxRadius       = 50;           % Max Radius if working with constant N
    params.fBinning         = 0.1;             % Bin size for magnitude binning
    params.fTimePeriodDays  = days(365);          % Period lengths to be compared in days
    
    params.vLonLim          = [119.5 122.5];   % boundary of polygon for GRID
    params.vLatLim          = [22 25];         % boundary of polygon for GRID
    params.fdLon            = 0.1;                 % grid values in x-direction (longitude)
    params.fdLat            = 0.1;                 % grid values in y-direction (latitude)
    [params.mPolygon,params.vX,params.vY,params.vUsedNodes]=calc_Polygon(params.vLonLim, ...
        params.vLatLim,params.fdLon,params.fdLat);
end