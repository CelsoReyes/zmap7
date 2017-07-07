function [mCat]=sr_makeSRC4(mCat,fTw,T)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function removes events and creates a quiescence according to the
% chosen input variables. The lat/lon position of the quiescence is
% determined randomly.
%
% Input Variables
% mCat      Earthquake catalog in zmap-format
% fTw       Duration of PSQ
% T         Starting time of PSQ
% fR        Degree of rate change (0.75 = 75% reduction)
%
% Output Variables
% mCat      Catalog with PSQ%
%
% van Stiphout Thomas ; vanstiphout@sed.ethz.ch
% Created: 14.08.2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('zmap/src/thomas/seismicrates/sr_makeSRC4.m')

% rate decrease for grid node
fR=0.75;
fLonPSQ=-116.4;
fLatPSQ=34.3;
nN=300;
fLon0=fLonPSQ;
fLat0=fLatPSQ;

% get N nearest events for certain grid point
%     [caNodeIndices, vResolution_] = ex_CreateIndexCatalog(mCat, [fLon0 fLat0], 1, 0, nN, 99, 0.1, 0.1);
%     % transform cell array to matrix
%     vSel=cell2mat(caNodeIndices);

% get events within certain radius of a grid point
[caNodeIndices, vResolution] = ex_CreateIndexCatalog(mCat, [fLon0 fLat0], 1, 1, ...
    100, 10, 0.1, 0.1);
% transform cell array to matrix
caNodeIndices_=cell2mat(caNodeIndices);
vSel=caNodeIndices_;
% transform cell array to matrix
vResolution_=cell2mat(vResolution);

% control plots
% figure;plot(mCat(:,1),mCat(:,2),'.k');
% hold on;plot(mCat(vSel,1),mCat(vSel,2),'dr');


% select from N events the one in the quiescence time period
vSel3=find((mCat(vSel,3)>T-fTw) & (mCat(vSel,3)<T));
% create help matrix for events in quite period
vSel4=zeros(size(vSel3,1),1);
% determine number of events to remove
fRemove=fR;
% create vector with % events to be removed (=1)
vSel4(1:ceil(size(vSel4,1)*fRemove))=1;
vSel4=logical(vSel4(randperm(size(vSel4,1))));
% Select indices of the N events to be removed
% vSel5 are events to be removed (indices from N events)
vSel5=vSel3(vSel4,1);
% create position of events in mCatalog to be removed
vSelNaN=vSel(vSel5);
% tag events to be removed with NaN
mCat(vSelNaN,1)=NaN;
mCat=mCat(~isnan(mCat(:,1)),:);


%% calculate rate increase in box

fBvalue=1;
fInc=0.1;
fMinLat=33.6;
fMaxLat=33.75;
fMinLon=-116.75;
fMaxLon=-116.5;
mPoly=[fMaxLon fMinLat;fMaxLon fMaxLat;fMinLon fMaxLat;fMinLon fMinLat];
fMinTime=T-fTw;
fMaxTime=T;

[vSel,bnd]=inpoly(mCat(:,1:2),mPoly);
vSel=find(vSel==1);
nNSel=size(vSel,1);
mNewCat=nan(nNSel,size(mCat,2));

% Create magnitudes
[mNewCat] = syn_create_magnitudes(mNewCat, fBvalue, min(mCat(:,6)), fInc);
% Randomize
rng('shuffle');

fMaxDepth=max(mCat(:,7));
fMinDepth=min(mCat(:,7));
% Create location
mNewCat(:,1) = rand(nNSel, 1) * (fMaxLon-fMinLon) + fMinLon;
mNewCat(:,2) = rand(nNSel, 1) * (fMaxLat-fMinLat) + fMinLat;
mNewCat(:,7) = rand(nNSel, 1) * (fMaxDepth-fMinDepth) + fMinDepth;

% Randomize
rng('shuffle');

% Create focal times
mNewCat(:,3) = rand(nNSel, 1) * (fMaxTime-fMinTime) + fMinTime;
% vst: datevec does not transform mNewCat(:,3) properly. Replaced by
% decyear2mat.
mNewCat(:,3)=mNewCat(randperm(size(mNewCat,1)),3);
% [mNewCat(:,10) mNewCat(:,4) mNewCat(:,5) mNewCat(:,8) mNewCat(:,9)] = datevec(mNewCat(:,3));
[mNewCat(:,10) mNewCat(:,4) mNewCat(:,5) mNewCat(:,8) mNewCat(:,9) tmp] = decyear2mat(mNewCat(:,3));

% Remove column 10 (seconds)
% mNewCat = mNewCat(:,1:end);
mCat=[mCat; mNewCat];
[Xsort, Xi]=sort(mCat(:,3),1);
mCat=mCat(Xi,:);




