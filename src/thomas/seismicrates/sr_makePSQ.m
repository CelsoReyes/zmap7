function [mCat]=sr_makePSQ(mCat,fTw,T,fPSQ,nPSQType,mPSQ)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function removes events and creates a quiescence according to the
% chosen input variables. The lat/lon position of the quiescence is
% determined randomly.
%
%
% van Stiphout Thomas ; vanstiphout@sed.ethz.ch
% Created: 14.08.2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('zmap/src/thomas/seismicrates/sr_makePSQ.m')

if nPSQType==1
    fLonPSQ=mPSQ(1);
    fLatPSQ=mPSQ(2);
    nN=mPSQ(3);
if isempty(fLonPSQ)  ||  isempty(fLatPSQ)
    % get arbitrary position for quiescence
    fLon0=randn(1,1)*(max(mCat(:,1))-min(mCat(:,1)))+min(mCat(:,1));
    fLat0=randn(1,1)*(max(mCat(:,2))-min(mCat(:,2)))+min(mCat(:,2));
else
    fLon0=fLonPSQ;
    fLat0=fLatPSQ;
end
% get N nearest events for certain grid point
[caNodeIndices, vResolution_] = ex_CreateIndexCatalog(mCat, [fLon0 fLat0], 1, 0, nN, 99, 0.1, 0.1);
% transform cell array to matrix
vSel=cell2mat(caNodeIndices);
elseif nPSQType==2
   [vSel,bnd]=inpoly(mCat(:,1:2),mPSQ);
   vSel=find(vSel==1);
end
% control plots
% figure;plot(mCat(:,1),mCat(:,2),'.k');
% set(gca,'NextPlot','add');plot(mCat(vSel,1),mCat(vSel,2),'dr');


% select from N events the one in the quiescence time period
vSel3=find((mCat(vSel,3)>T-fTw) & (mCat(vSel,3)<T));
% create help matrix for events in quite period
vSel4=zeros(size(vSel3,1),1);
% determine number of events to remove
fRemove=fPSQ;
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
