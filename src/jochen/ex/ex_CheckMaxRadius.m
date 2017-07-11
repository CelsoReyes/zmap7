function [mMaxRadCatalog] = ex_CheckMaxRadius(mCatalog, mPolygon, nNode, caNodeIndices, fMaxRadius, nNumberEvents, bMap)
% function [mMaxRadCatalog] = ex_CheckMaxRadius(mCatalog, mPolygon, nNode, caNodeIndices, fMaxRadius, nNumberEvents, bMap);
% --------------------------------------------------------------------------------------------------------------------
% Function to check an earthquake catalog for one grid node on a given number and a maximum radius.
% Returns an earthquake catalog with a constant number of events if the events of the catalog at the grid node is equal or larger
% than nNumberEvents. If the number of events is smaller, an empty matrix is returned.
%
% Input parameters:
%  mCatalog       : Earthquake catalog of Node_
%  mPolygon       : Polygon (defined by ex_selectgrid)
%  nNode          : Node number
%  caNodeIndices  : Node indices
%  fMaxRadius     : maximum radius for nNumberEvents [km]
%  nNumberEvents  : Number of earthquakes (constant number)
%  bMap           : Map view (deg) or cross-section (km)
%
% Output parameters:
% mMaxRadCatalog  : Earthquake catalog for one node with constant number of events
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% last update: 11.06.03

global bDebug;
if bDebug
    report_this_filefun(mfilename('fullpath'));
end

mNodeCatalog_ = mCatalog;

% Check for size
if (length(mNodeCatalog_(:,1)) >= nNumberEvents)
    % If cross-section calculate the length along cross-section
    if ~bMap
        [nRow_, nColumn_] = size(mNodeCatalog_);
        vXSecX_ = mNodeCatalog_(:,nColumn_);  % length along x-section
        vXSecY_ = (-1) * mNodeCatalog_(:,7);  % depth of hypocenters
    end
    % Get the grid node coordinates
    fX_ = mPolygon(nNode, 1);
    fY_ = mPolygon(nNode, 2);

    % Calculate distance from center point
    if bMap % Map view
        vDistances_ = sqrt(((mNodeCatalog_(:,1)-fX_)*cosd(fY_)*111).^2 + ((mNodeCatalog_(:,2)-fY_)*111).^2);
    else  % Cross-section
        vDistances_ = sqrt(((vXSecX_ - fX_)).^2 + ((vXSecY_ - fY_)).^2);
    end

    % Select those in between the maximum radius
    vSel = (vDistances_ <= fMaxRadius);
    vCheckDist = vDistances_(vSel, :);
    mMaxRadCatalog = mNodeCatalog_(vSel, :);

    % Check size
    if length(mMaxRadCatalog(:,1)) == nNumberEvents
        mMaxRadCatalog = mMaxRadCatalog;
    elseif (length(mMaxRadCatalog(:,1)) > nNumberEvents)
        mMaxRadCatalog = mMaxRadCatalog(1:nNumberEvents,:);
    else
        mMaxRadCatalog = [];
    end % END of if length(mMaxRadCatalog(:,1))
else
    mMaxRadCatalog = [];
end % END on if on length(mNodeCatalog_(:,1)
