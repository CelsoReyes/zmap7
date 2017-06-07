function [mCat]=sr_makeSRC(mCat,fTw,T,fR,nPSQType,mPSQ)
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
% nPSQType  PSQ in (1) nearest events, (2) polygon, (3) fixed radius
% mPSQ      Properties of PSQ lon, lat, volume
%
% Output Variables
% mCat      Catalog with PSQ%
%
% van Stiphout Thomas ; vanstiphout@sed.ethz.ch
% Created: 14.08.2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('zmap/src/thomas/seismicrates/sr_makeSRC.m')

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
%     % get N nearest events for certain grid point
%     [caNodeIndices, vResolution_] = ex_CreateIndexCatalog(mCat, [fLon0 fLat0], 1, 0, nN, 99, 0.1, 0.1);
%     % transform cell array to matrix
%     vSel=cell2mat(caNodeIndices);
params2=get_parameterSRC;
    % get events within certain radius of a grid point
    [caNodeIndices, vResolution] = ex_CreateIndexCatalog(mCat, [fLon0 fLat0], 1, 1, ...
        params2.fResolution, params2.fRadius, 0.1, 0.1);
    % transform cell array to matrix
    caNodeIndices_=cell2mat(caNodeIndices);
    vSel=caNodeIndices_;
    % transform cell array to matrix
    vResolution_=cell2mat(vResolution);

elseif nPSQType==2
    [vSel,bnd]=inpoly(mCat(:,1:2),mPSQ);
    vSel=find(vSel==1);

end
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
