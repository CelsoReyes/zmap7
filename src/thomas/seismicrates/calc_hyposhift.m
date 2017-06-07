function [mCatNew, mHyposhift] =calc_hyposhift(mCat,mDelta,nDim)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example:  [mCatNew, mHyposhift]=calc_hyposhift(mCatalog,mDelta,logical(1))
% Input paramter:
% mCat    Earthquake catalog in zmap format
% mDelta Error bounds given provided by network ( [dLon, dLat, dDepth] )
% nDim  0 : error bounds in lon / lat, 1: errorbounds in [km]
%
% Output parameter
% mCatNew Shifted hypocenter
% mHyposhift   Values by which hypocenters were shifted
%
% Author
% van Stiphout, Thomas
% vanstiphout@sed.ethz.ch
% Created
% 09 Aug 2007
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% global bDebug;
% if bDebug
% report_this_filefun(mfilename('fullpath'));
% end

% bring error into degree format
nDim=logical(nDim);
if nDim
    mDelta(:,1)=km2deg(mDelta(:,1)).*cos(deg2rad(mCat(:,2)));
    mDelta(:,2)=km2deg(mDelta(:,2));
end

% reset random number generator
rand('state',sum(100*clock));
% create randomly uniform distributed errors within given errorbounds
% mHyposhift=(randn(size(mCat,1),3).*2-1).*mDelta;
% create hypocenters with normal distributed error
% for i=1:size(mDelta,1)
%     mHyposhift(i,:)= [normrnd(0,mDelta(i,1)) normrnd(0,mDelta(i,2))  normrnd(0,mDelta(i,3))];
% end

mHyposhift=normrnd(0,mDelta);

% add error to the catalog hypocenters
mCatNew=mCat;
mCatNew(:,1)=mCatNew(:,1)+mHyposhift(:,1);
mCatNew(:,2)=mCatNew(:,2)+mHyposhift(:,2);
mCatNew(:,7)=mCatNew(:,7)+mHyposhift(:,3);
