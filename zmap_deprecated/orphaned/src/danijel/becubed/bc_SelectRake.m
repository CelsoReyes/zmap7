function [mNewCatalog] = bc_SelectRake(mCatalog, fRake, fAngle, nRake1, nRake2)
% function [mNewCatalog] = bc_SelectRake(mCatalog, fRake, fAngle, nRake1, nRake2)
% ------------------------------------------------------------------------------------
% Selects a subset of earthquakes of a given rake
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   fRake           Rake
%   fAngle          Range of angles to be included for a given rake
%   nRake1          Column of rake of nodal plane 1 (default = 12)
%   nRake2          Column of rake of nodal plane 2 (default = none)
%
% Output parameters:
%   mNewCatalog     Catalog containing the subset of the given mechanism
%
% Copyright (C) 2004 by Danijel Schorlemmer
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the
% Free Software Foundation, Inc.,
% 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

% Set column for rake 1
if ~exist('nRake1', 'var')
  nRake1 = 12;
end

% If column of rake 2 is given select events based on both rakes
if exist('nRake2', 'var') & ~isempty(nRake2)
  [vSel1] = CreateSelectionVector(mCatalog, fRake, fAngle, nRake1);
  [vSel2] = CreateSelectionVector(mCatalog, fRake, fAngle, nRake2);
  vSel = vSel1 & vSel2;
else
  [vSel] = CreateSelectionVector(mCatalog, fRake, fAngle, nRake1);
end

mNewCatalog = mCatalog(vSel,:);

% --- Helper function ---
% Select earthquakes based on rake of one given column

function [vSel] = CreateSelectionVector(mCatalog, fRake, fAngle, nColumn)

fMinRake = fRake - fAngle;
fMaxRake = fRake + fAngle;
vSel = (mCatalog(:,nColumn) > fMinRake) & (mCatalog(:,nColumn) < fMaxRake);

% Change of sign in rake at +/-180: Extend range
if fMinRake < -180
  fDelta = -180 - fMinRake;
  vSelAdd = mCatalog(:,nColumn) >= (180 - fDelta);
  vSel = vSel | vSelAdd;
end
if fMaxRake > 180
  fDelta = fMaxRake - 180;
  vSelAdd = mCatalog(:,nColumn) <= (-180 + fDelta);
  vSel = vSel | vSelAdd;
end


