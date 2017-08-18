function [mNewCatalog] = bc_SelectMechanism(mCatalog, nType, fAngle, nRake1, nRake2)
% function [mNewCatalog] = bc_SelectMechanism(mCatalog, nType, fAngle, nRake1, nRake2)
% ------------------------------------------------------------------------------------
% Selects a subset of earthquakes of a given mechanism
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   nType           Type of mechanism
%                   1: Strike-slip
%                   2: Thrust
%                   3: Normal
%   fAngle          Range of angles to be included in a given mechanism
%   nRake1          Column of rake of nodal plane 1 (default = 12)
%   nRake2          Column of rake of nodal plane 2 (default = none)
%
% Output parameters:
%   mNewCatalog     Catalog containing the subset of the given mechanism
%
% Danijel Schorlemmer
% April 2, 2004

% Set column for rake 1
if ~exist('nRake1', 'var')
  nRake1 = 12;
end

% If column of rake 2 is given select events based on both rakes
if exist('nRake2', 'var') && ~isempty(nRake2)
  [vSel1] = CreateSelectionVector(mCatalog, nType, fAngle, nRake1);
  [vSel2] = CreateSelectionVector(mCatalog, nType, fAngle, nRake2);
  vSel = vSel1 & vSel2;
else
  [vSel] = CreateSelectionVector(mCatalog, nType, fAngle, nRake1);
end

mNewCatalog = mCatalog.subset(vSel);

% --- Helper function ---
% Select earthquakes based on rake of one given column

function [vSel] = CreateSelectionVector(mCatalog, nType, fAngle, nColumn)

if nType == 1 % Strike-slip
  vSel = ((mCatalog(:,nColumn) >= -fAngle) & (mCatalog(:,nColumn) <= fAngle)) | ...
    (mCatalog(:,nColumn) <= (-180 + fAngle)) | (mCatalog(:,nColumn) >= (180 - fAngle));
elseif nType == 2 % Thrust
  vRakes = mCatalog(:,nColumn) - 90;
  vCorrection = (vRakes < -180) .* 360;
  vRakes = vRakes + vCorrection;
  vSel = abs(vRakes) <= fAngle;
else % Normal
  vRakes = mCatalog(:,nColumn) + 90;
  vCorrection = (vRakes > 180) .* -360;
  vRakes = vRakes + vCorrection;
  vSel = abs(vRakes) <= fAngle;
end
