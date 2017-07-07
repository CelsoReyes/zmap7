function [vDistances_] = ex_MapDist3D(mCatalog, mPolygon, vPolygon)
% function [caNodeIndices] = ex_CreateIndexCatalog(mCatalog, mPolygon, bMap, nGriddingMode,
%                                                  nNumberEvents, fRadius, fSizeRectHorizontal, fSizeRectDepth)
% -------------------------------------------------------------------------------------------------------------
% Creates a cell-array with subcatalogs for every grid node defined by mPolygon. These subcatalogs
%   contain only indices to the earthquake "rows" in mCatalog.
%
% Input parameters:
%   mCatalog              Earthquake catalog
%   mPolygon              Polygon (defined by ex_selectgrid)
%   vPolygonDepth         Polygon depth
%
% Output parameters:
%   caNodeIndices         Cell-array with index-catalogs per grid node of mPolygon
%
% Thomas van Stiphout
% July 28, 2008

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Create the catalogs for each node with pointers to the overall catalog
nNumberNodes_ = length(mPolygon(:,1));

% vResolution give the radius (for nGriddingMode = 0) and no. of events
% (for nGriddingMode = 1)
vResolution_(:,1)=ones(nNumberNodes_,1)*nan;

% Loop over all points of the polygon
for nNode_ = 1:nNumberNodes_
  % Get the grid node coordinates
  fX_ = mPolygon(nNode_, 1);
  fY_ = mPolygon(nNode_, 2);
  fZ_ = vPolygon(nNode_, 1);

  % Calculate distance from center point
  vDistances_ = sqrt(((mCatalog(:,1)-fX_)*cos(pi/180*fY_)*111).^2 + ((mCatalog(:,2)-fY_)*111).^2 + (mCatalog(:,7)-fZ_).^2);

  % Fixed radius
  % Use all events within fRadius
%       caNodeIndices{nNode_} = find(vDistances_ <= fRadius);
%       vResolution_(nNode_) = length(find(vDistances_ <= fRadius));
end; % of for nNode_
