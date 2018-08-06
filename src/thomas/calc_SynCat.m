function [ mSynCat, vMain] = calc_SynCat(nNbkg,Mmin,MminR,maxm,DMax,sYr1,sYr2,magb, nSynCat_)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: [mSynCat, vMain] = calc_SynCat(2500,2.5,2.5,8,100,'January 1,1980','December 31,1990',6.5,1);
%
% This function (calc_SynCat) calculates a synthetic catalog with a
% backgroundrate based number of  earthquakes in the catalog of the period
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
% nNbkg          Number of events in background catalog during assigned period
% Mmin            Minimum magnitude in Catalog
% MminR          Minimal magnitude of aftershocks
% maxm           Maximal magnitude of aftershocks
% DMax            Maximal distance of afterhock to mainshock
% sYr1              Starting Time for ETES-Catalog
% sYr2              Ending Time for ETES-Catalog
% magb            Magnitude treshhold above earthquake is not anymore a point process
% nSynCat_       1: only backgorund, 2: background + ETAS
% Output:
% SynCat Simulated ETES catalog [yr lon lat month day mag depth hrs min sec]
% vMain            Vector with assignments if main (true) or aftershock (false)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize:
clear FaultParam;

% background:
fBValue=1;
fMc=Mmin;
fInc=0.1;
fMinLat=32;
fMaxLat=36;
fMinLon=-121;
fMaxLon=-115;
fMinDepth=0;
fMaxDepth=40;
[nYY, nMM, nDD, nHH, nMN, nSS]=datevec(sYr1);
fYr1=nYY;
[nYY, nMM, nDD, nHH, nMN, nSS]=datevec(sYr2);
fYr2=nYY;
fYr0=fYr1-(fYr2-fYr1);
FaultParam=[0 0 0 0 0 0 0];
load UniformRateSynGrid.mat
CX=0.095;
P=1.34;
A=0.008;
magb=9;
nRchange=1

switch nSynCat_
    case 1
        % create background rate
        mSynCat = syn_catalog(nNbkg, fBValue, fMc, fInc, fMinLat,fMaxLat,fMinLon,fMaxLon,fMinDepth,fMaxDepth, fYr1,fYr2);
        % [mNewCatalog] = syn_catalog(nNumberEvents, fBValue, fMc, fInc, fMinLat, fMaxLat,
        %                                      fMinLon, fMaxLon, fMinDepth, fMaxDepth, fMinTime, fMaxTime)
        mSynCat(:,1)=mSynCat(randperm(size(mSynCat,1))',1);
        vMain=ones(nNbkg,1);
    case 2   % create background rate + ETAS
        nNbkgA=floor(nNbkg/(1+nRchange)*1)
        nNbkgB=ceil(nNbkg/(1+nRchange)*nRchange)
        if nRchange == 1
            mCat = syn_catalog(nNbkg, fBValue, fMc, fInc, fMinLat,fMaxLat,fMinLon,fMaxLon,fMinDepth,fMaxDepth, fYr1,fYr2);
        else
            mCatA=syn_catalog(nNbkgA, fBValue, fMc, fInc, fMinLat,fMaxLat,fMinLon,fMaxLon,fMinDepth,fMaxDepth,fYr1,(fYr1+fYr2)/2);
            mCatB=syn_catalog(nNbkgB, fBValue, fMc, fInc, fMinLat,fMaxLat,fMinLon,fMaxLon,fMinDepth,fMaxDepth,(fYr1+fYr2)/2,fYr2);
            mCat=[mCatA;mCatB];
        end
        mCat(:,1)=mCat(randperm(size(mCat,1))',1);
        [Y,Idx]=sort(mCat(:,3),1);
        mCat=mCat(Idx,:);
        mCat1=[fix(mCat(:,3)) mCat(:,4) mCat(:,5) mCat(:,8) mCat(:,9) rand(size(mCat,1),1)*60 mCat(:,2) mCat(:,1) mCat(:,7) mCat(:,6)];
        %  [N,Mmax,catalog,IDAll,HistoryAll] = ETESProject2(cat1,RateGrid2,0.095,1.34,0.008,Mmin,MminR,maxm,DMax,sYr1,sYr2,6.5,FaultParam)
        [N,Mmax,catalog,IDAll,HistoryAll] = ETESProject3(mCat1,RateGrid2,CX,P,A,Mmin,MminR,maxm,DMax,sYr1,sYr2,magb,FaultParam);

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
