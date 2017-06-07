function [caNodeIndices] = ex_CreateIndexCatalogRectangle(mCatalog, mPolygon, bMap, fSizeRectHorizontal, fSizeRectDepth)
% function [caNodeIndices] = ex_CreateIndexCatalog(mCatalog, mPolygon, bMap, fSizeRectHorizontal, fSizeRectDepth)
% ---------------------------------------------------------------------------------------------------------------
% Creates a cell-array with subcatalogs for every grid node defined by mPolygon. These subcatalogs
%   contain only indices to the earthquake "rows" in mCatalog.
%
% Input parameters:
%   mCatalog              Earthquake catalog
%   mPolygon              Polygon (defined by ex_selectgrid)
%   bMap                  Calculate cell-array for a map (=1) or a cross-section (=0)
%   fSizeRectHorizontal   Size of rectangles in latitude/horizontal direction
%   fSizeRectDepth        Size of rectangles in longitude/depth direction
%
% Output parameters:
%   caNodeIndices         Cell-array with index-catalogs per grid node of mPolygon
%
% Danijel Schorlemmer
% June 17, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Create the catalogs for each node with pointers to the overall catalog
nNumberNodes_ = length(mPolygon(:,1));
caNodeIndices = cell(nNumberNodes_, 1);
% If cross-section calculate the length along cross-section
if ~bMap
  [nRow_, nColumn_] = size(mCatalog);
  vXSecX_ = mCatalog(:,nColumn_);  % length along x-section
  vXSecY_ = -mCatalog(:,7);         % depth of hypocenters
end
% Loop over all points of the polygon
for nNode_ = 1:nNumberNodes_
  % Get the grid node coordinates
  fX_ = mPolygon(nNode_, 1);
  fY_ = mPolygon(nNode_, 2);
  % Select all earthquakes within a rectangle (fSpacingHorizontal x fSpacingDepth)
  if bMap
    vSel_ = ((mCatalog(:,1) >= (fX_ - fSizeRectHorizontal/2)) & (mCatalog(:,1) < (fX_ + fSizeRectHorizontal/2)) & ...
    (mCatalog(:,2) >= (fY_ - fSizeRectDepth/2)) & (mCatalog(:,2) < (fY_ + fSizeRectDepth/2)));
  else
    vSel_ = ((vXSecX_ >= fX_ - fSizeRectHorizontal/2) & (vXSecX_ < (fX_ + fSizeRectHorizontal/2)) & ...
    (vXSecY_ >= fY_ - fSizeRectDepth/2) & (vXSecY_ < (fY_ + fSizeRectDepth/2)));
  end
  caNodeIndices{nNode_} = find(vSel_ == 1);
end % of for nNode_
