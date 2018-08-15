function [ mSynCat, vMain] = calc_SynCat(nNbkg,vSynCat,nSynCat_,nSynMode, vAfter,vEtas,mCatalog,bPSQ,vPSQ,mPSQ)
    % calculates a synthetic catalog with a backgroundrate based number of earthquakes in the catalog of the period before starting date.
    %
    % Example: [mSynCat, vMain] = calc_SynCat(2500,2.5,2.5,8,100,'January 1,1980','December 31,1990',6.5,1,0,a);
    %
    % This function (calc_SynCat) calculates a synthetic catalog with a
    % backgroundrate based number of earthquakes in the catalog of the period
    % before starting date. This function is doing the following:
    % 1) creates a synthetic catalog with background rate based on input parameters.
    % 2) calculate omori-type aftershock and add this to the background catalog,
    % that was created by the properties of the inputbackground catalog. Therefore
    % the program package ETESProject by karen Felzer was used.
    %
    % Author: van Stiphout, Thomas
    % Email: vanstiphout@sed.ethz.ch
    % Created: 2. Mar 2007
    % Changed: -
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Variables
    % Input:
    % nNbkg         Number of events in background catalog during assigned period
    % vSynCat       Vektor with contraints on synthetic catalog
    %                   1-4: fMinLon fMaxLon fMinLat fMaxLat in degree
    %                   5-6: fMinDepth fMaxDepth  in km
    %                   7-8: fMinTime fMaxTime (duration of catalog)
    %                   9:   fRate Reduction of earthquakes for entire catalog
    %                          (0.75 = 25% reduction) in period (fT-fTw) - fT
    %                   10:  fBValue           b-value of the catalog
    %                   11:  fMc Magnitude of Completness (minimum Magnitude in Catalog)
    %                   12:  fIncMagnitude increment steps
    % nSynCat_      1: only backgorund, 2: background + ETAS
    % nSynMode      Type of synthetic catalog 0:homogeneous distr; 1:based
    %                on real catalog 2:hypocenter based on real catalog, magnitude and focal
    %                time is randomly computed
    % vAfter        Definition/Constraints for Aftershocks
    %                   1: Mmin: Minimum earthquake magnitude to report and simulate
    %                   2: MminR: Minimum earthquake magnitude for reporting
    %                       in the output catalog
    %                   3: maxm: Maximum earthquake magnitude
    %                   4: DMax: Maximum distance for aftershocks
    %                   5: magb: Cutoff magnitude for the point source vs. plane source
    %                       representation of the mainshock
    % vEtas         Parameters for ETAS:[CX, P, A] standard=[0.095, 1.34, 0.008]
    % mCatalog      Declustered catalog needed only for nSynMode=1
    % bPSQ          with (1) or without (0) PSQ
    % vPSQ          values for PSQ (lon, lat, N, Tw, T)
    %
    % Output:
    % SynCat Simulated ETES catalog [yr lon lat month day mag depth hrs min sec]
    % vMain            Vector with assignments if main (true) or aftershock (false)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % initialize:
    clear FaultParam;
    
    % background:
    fBValue=vSynCat(10);
    fMc=vSynCat(11);
    fInc=vSynCat(12);
    fMinLat=vSynCat(3);
    fMaxLat=vSynCat(4);
    fMinLon=vSynCat(1);
    fMaxLon=vSynCat(2);
    fMinDepth=vSynCat(5);
    fMaxDepth=vSynCat(6);
    nRchange=vSynCat(9);
    [fYr1, nMn1, nDay1, nHr1, nMin1, nSec1]=decyear2mat(vSynCat(7));
    [fYr2, nMM2, nDD2, nHH2, nMN2, nSS2]=decyear2mat(vSynCat(8));
    
    
    % vAfter
    Mmin=vAfter(1);
    MminR=vAfter(2);
    maxm=vAfter(3);
    DMax=vAfter(4);
    magb=vAfter(5);
    FaultParam=[0 0 0 0 0 0 0];
    
    % vEtas
    CX=vEtas(1);
    P=vEtas(2);
    A=vEtas(3);
    
    switch nSynCat_
        case 1
            % create background rate
            mSynCat=syn_catalog(nNbkg, fBValue, fMc, fInc, fMinLat,fMaxLat,...
                fMinLon,fMaxLon,fMinDepth,fMaxDepth, fYr1,fYr2,nSynMode,...
                mCatalog);
            if bPSQ
                mSynCat=sr_makePSQ(mSynCat,vPSQ(2),vPSQ(3),vPSQ(4),...
                    vPSQ(1),mPSQ);
            end
            %       mSynCat(:,1)=mSynCat(randperm(size(mSynCat,1))',1);
            vMain=ones(nNbkg,1);
        case 2   % create background rate + ETAS
            nNbkgA=floor(nNbkg/(1+nRchange)*1);
            nNbkgB=ceil(nNbkg/(1+nRchange)*nRchange);
            if nRchange == 1
                mCat=syn_catalog(nNbkg, fBValue, fMc, fInc, fMinLat,fMaxLat,...
                    fMinLon,fMaxLon,fMinDepth,fMaxDepth, fYr1,fYr2,nSynMode,...
                    mCatalog);
            else
                mCatA=syn_catalog(nNbkgA, fBValue, fMc, fInc, fMinLat,fMaxLat,...
                    fMinLon,fMaxLon,fMinDepth,fMaxDepth,fYr1,(fYr1+fYr2)/2,...
                    nSynMode,mCatalog);
                mCatB=syn_catalog(nNbkgB, fBValue, fMc, fInc, fMinLat,fMaxLat,...
                    fMinLon,fMaxLon,fMinDepth,fMaxDepth,(fYr1+fYr2)/2,fYr2,...
                    nSynMode,mCatalog);
                mCat=[mCatA;mCatB];
            end
            %         mCat(:,1)=mCat(randperm(size(mCat,1))',1);
            [Y,Idx]=sort(mCat(:,3),1);
            mCat=mCat(Idx,:);
            if bPSQ
                mCat=sr_makePSQ(mCat,vPSQ(2),vPSQ(3),vPSQ(4),...
                    vPSQ(1),mPSQ);
            end
            mCat1=[fix(mCat(:,3)) mCat(:,4) mCat(:,5) mCat(:,8) mCat(:,9) rand(size(mCat,1),1)*60 mCat(:,2) mCat(:,1) mCat(:,7) mCat(:,6)];
            %         mCat1(:,1)=mCat1(:,1)-(max(mCat1(:,1))-min(mCat1(:,1)));
            %  [N,Mmax,catalog,IDAll,HistoryAll] = ETESProject2(cat1,RateGrid2,0.095,1.34,0.008,Mmin,MminR,maxm,DMax,sYr1,sYr2,6.5,FaultParam)
            [N,Mmax,catalog,IDAll,HistoryAll] = ETESProject3(mCat1,vEtas,vAfter,fYr1,fYr2,FaultParam);
            
            mSynCat(:,1) = catalog(:,8); % lon
            mSynCat(:,2) = catalog(:,7);  % lat
            mSynCat(:,3) = catalog(:,1);  % years
            mSynCat(:,4) = catalog(:,2);  % month
            mSynCat(:,5) = catalog(:,3);  % day
            mSynCat(:,6) = catalog(:,10); % mag
            mSynCat(:,7) = catalog(:,9);  % depth
            mSynCat(:,8) = catalog(:,4);  % hours
            mSynCat(:,9) = catalog(:,5);  % minutes
            mSynCat(:,10) = catalog(:,6);  % seconds
            
            mSynCat(:,3) = decyear([mSynCat(:,3) mSynCat(:,4) mSynCat(:,5) ...
                mSynCat(:,8) mSynCat(:,9) mSynCat(:,10)]); % yrs decimal
            size(mSynCat)
            vMain=(catalog(:,12)==0);
    end
    % disp('cat fertig')
end
