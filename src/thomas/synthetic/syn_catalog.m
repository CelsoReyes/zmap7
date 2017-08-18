function [mNewCatalog] = syn_catalog(nNumberEvents, fBValue, fMc, fInc, fMinLat, fMaxLat, fMinLon, fMaxLon, fMinDepth, fMaxDepth, fMinTime, fMaxTime,nSynMode,mCatalog)
% function [mNewCatalog] = syn_catalog(nNumberEvents, fBValue, fMc, fInc, fMinLat, fMaxLat,
%                                      fMinLon, fMaxLon, fMinDepth, fMaxDepth, fMinTime, fMaxTime)
% ------------------------------------------------------------------------------------------------
% Creates a synthetic catalog.
%
% Input parameters:
%   nNumberEvents     Number of events in the catalog
%   fBValue           b-value of the catalog
%   fMc               Magnitude of completeness of the catalog (= minimum magnitude)
%   fInc              Magnitude increment (usually 0.1)
%   fMinLat           Minimum latitude value of events in the catalog
%   fMaxLat           Maximun latitude value of events in the catalog
%   fMinLon           Minimum longitude value of events in the catalog
%   fMaxLon           Maximun longitude value of events in the catalog
%   fMinDepth         Minimum depth of events in the catalog (positive value)
%   fMaxDepth         Maximun depth of events in the catalog (positive value)
%   fMinTime          Minimum date/time of events in the catalog (decimal year: e.g. 1983.5)
%   fMaxTime          Maximun date/time of events in the catalog (decimal year: e.g. 1987.9)
% nSynMode          Type of synthetic catalog 0:homogeneous distr; 1:based
% on real catalog 2:hypocenter based on real catalog, magnitude and focal
% time is randomly computed
% mCatalog          declustered catalog needed only for nSynMode=1
%
% Output parameters:
%   mNewCatalog       Synthetic catalog
%
% Danijel Schorlemmer
% April 17, 2002
% Updates
% Mai  9, 2007  van Stiphout, Thomas     replaced datevec.m by decyear2mat.m


global bDebug
if bDebug
    report_this_filefun(mfilename('fullpath'));
end

% allocate matrix for synthetc catalog
mNewCatalog=nan(nNumberEvents,14);

% initial shift of hypocenter from reference event.
fHypoShift=5;
if nSynMode == 0
%     % Create empty catalog
%     mNewCatalog = nan(nNumberEvents, 10);

    % Create magnitudes
    [mNewCatalog] = syn_create_magnitudes(mNewCatalog, fBValue, fMc, fInc);

    % Randomize
    rng('shuffle');

    % Create location
    mNewCatalog(:,1) = rand(nNumberEvents, 1) * (fMaxLon-fMinLon) + fMinLon;
    mNewCatalog(:,2) = rand(nNumberEvents, 1) * (fMaxLat-fMinLat) + fMinLat;
    mNewCatalog(:,7) = rand(nNumberEvents, 1) * (fMaxDepth-fMinDepth) + fMinDepth;

    % Randomize
    rng('shuffle');

    % Create focal times
    mNewCatalog(:,3) = rand(nNumberEvents, 1) * (fMaxTime-fMinTime) + fMinTime;
    % vst: datevec does not transform mNewCatalog(:,3) properly. Replaced by
    % decyear2mat.
    mNewCatalog(:,3)=mNewCatalog(randperm(size(mNewCatalog,1)),3);
    % [mNewCatalog(:,10) mNewCatalog(:,4) mNewCatalog(:,5) mNewCatalog(:,8) mNewCatalog(:,9)] = datevec(mNewCatalog(:,3));
    [mNewCatalog(:,10) mNewCatalog(:,4) mNewCatalog(:,5) mNewCatalog(:,8) mNewCatalog(:,9) tmp] = decyear2mat(mNewCatalog(:,3));

    % Remove column 10 (seconds)
    mNewCatalog = mNewCatalog(:,1:end);

elseif nSynMode==1
    % take from real catalog hypocenters and magnitudes  ....
    for i=1:nNumberEvents
        mNewCatalog(i,:)=mCatalog(ceil(rand(1,1)*size(mCatalog,1)),1:end);
    end
    % create new  times
    % Randomize
    rng('shuffle');
    % Create focal times
    mNewCatalog(:,3) = rand(nNumberEvents, 1) * (fMaxTime-fMinTime) + fMinTime;
    % vst: datevec does not transform mNewCatalog(:,3) properly. Replaced by
    % decyear2mat.
    % [mNewCatalog(:,10) mNewCatalog(:,4) mNewCatalog(:,5) mNewCatalog(:,8) mNewCatalog(:,9)] = datevec(mNewCatalog(:,3));
    [mNewCatalog(:,10) mNewCatalog(:,4) mNewCatalog(:,5) mNewCatalog(:,8) mNewCatalog(:,9) tmp] = decyear2mat(mNewCatalog(:,3));
    mNewCatalog=mNewCatalog(:,1:10);
elseif nSynMode==2
    for i=1:nNumberEvents
        mNewCatalog(i,:)=mCatalog(ceil(rand(1,1)*size(mCatalog,1)),1:end);
    end
    % create new magnitudes
    mTmp=syn_create_magnitudes(mNewCatalog, fBValue, fMc, fInc);
    mNewCatalog(:,6)=mTmp(:,6);
    % create new  times
    % Randomize
    rng('shuffle');
    % Create focal times
    mNewCatalog(:,3) = rand(nNumberEvents, 1) * (fMaxTime-fMinTime) + fMinTime;
    % vst: datevec does not transform mNewCatalog(:,3) properly. Replaced by
    % decyear2mat.
    % [mNewCatalog(:,10) mNewCatalog(:,4) mNewCatalog(:,5) mNewCatalog(:,8) mNewCatalog(:,9)] = datevec(mNewCatalog(:,3));
    [mNewCatalog(:,10) mNewCatalog(:,4) mNewCatalog(:,5) mNewCatalog(:,8) mNewCatalog(:,9) tmp] = decyear2mat(mNewCatalog(:,3));
    % shift hypocenters
    vTmp=km2deg(rand(nNumberEvents,2).*fHypoShift-fHypoShift/2);
    mNewCatalog(:,1:2)=mNewCatalog(:,1:2)+vTmp;
end
