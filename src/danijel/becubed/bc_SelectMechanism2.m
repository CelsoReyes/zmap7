function [mNewCatalog] = bc_SelectMechanism(mCatalog, nType, fAngle)
% function [mNewCatalog] = bc_SelectMechanism(mCatalog, nType, fAngle)
% --------------------------------------------------------------------
% Selects a subset of earthquakes of a given mechanism
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   nType           Type of mechanism
%                   1: Strike-slip
%                   2: Thrust
%                   3: Normal
%   fAngle          Range of angles to be included in a given mechanism
%
% Output parameters:
%   mNewCatalog     Catalog containing the subset of the given mechanism
%
% Danijel Schorlemmer
% April 20, 2002

% Nodal plane 1
if nType == 1 % Strike-slip
  vSel1 = ((mCatalog(:,12) >= -fAngle) & (mCatalog(:,12) <= fAngle)) | (mCatalog(:,12) <= (-180 + fAngle)) | (mCatalog(:,12) >= (180 - fAngle));
elseif nType == 2 % Thrust
  vSel1 = (mCatalog(:,12) >= (90 - fAngle)) & (mCatalog(:,12) <= (90 + fAngle));
else % Normal
  vSel1 = (mCatalog(:,12) >= (-90 - fAngle)) & (mCatalog(:,12) <= (-90 + fAngle));
end
% Nodal plane 2
if nType == 1 % Strike-slip
  vSel2 = ((mCatalog(:,12) >= -fAngle) & (mCatalog(:,12) <= fAngle)) | (mCatalog(:,12) <= (-180 + fAngle)) | (mCatalog(:,12) >= (180 - fAngle));
elseif nType == 2 % Thrust
  vSel2 = (mCatalog(:,12) >= (90 - fAngle)) & (mCatalog(:,12) <= (90 + fAngle));
else % Normal
  vSel2 = (mCatalog(:,12) >= (-90 - fAngle)) & (mCatalog(:,12) <= (-90 + fAngle));
end
% Select only earthquakes with both rakes in the given range
vSel = vSel1 & vSel2;
mNewCatalog = mCatalog(vSel,:);
