function [fBValue, fStdDev, fMc, fAValue, nNumberQuakes] = calc_BandMc(mCatalog, nMinimumNumber, nCalculateMC, fBinning, bConstrainMc, fMcMin, fMcMax, fMcAdd)
% function [fBValue, fStdDev, fMc, fAValue, nNumberQuakes] = calc_BandMc(mCatalog, nMinimumNumber, nCalculateMC, fBinning, bConstrainMc, fMcMin, fMcMax, fMcAdd)
% --------------------------------------------------------------------------------------------------------------------------------------------------------------
% Calculation of the b-values, its standard deviation and the magnitudes of completeness
%   of a given catalog
%
% Input parameters:
%   mCatalog            Earthquake catalog
%   nMinimumNumber      Minimum number of earthquakes in the catalog for calculating the output values
%   nCalculateMC        Method to determine the magnitude of completeness (see also: help calc_Mc)
%   fBinning            Magnitude binning of the catalog (default 0.1)
%   bConstrainMc        Constrain Mc to [fMcMin, fMcMax] if set to 1 (default 0)
%   fMcMin              see bConstrainMc
%   fMcMax              see bConstrainMc
%   fMcAdd              Value to be added to Mc after potential constraining and prior to
%                       b-value computation for conservative computations
%
% Output parameters:
%   fBValue             b-value of the catalog with respect to magnitude of completeness
%   fStdDev             Standard deviation of the b-value (Shi & Bolt)
%   fMc                 Magnitude of completeness (Mc)
%   fAValue            a-value of the catalog
%   nNumberQuakes       Number of quakes used to compute the b-value (M > Mc)
%
% Copyright (C) 2003 by Danijel Schorlemmer
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

report_this_filefun();

% Magnitude binning
if ~exist('fBinning', 'var')
  fBinning = 0.1;
end

% Constrain magnitude of completeness
if ~exist('bConstrainMc', 'var')
  bConstrainMc = 0;
end
if ~exist('fMcMin', 'var')
  fMcMin = 0;
end
if ~exist('fMcMax', 'var')
  fMcMax = 1;
end

% Conservative adding of a constant
if ~exist('fMcAdd', 'var')
  fMcAdd = 0;
end

% Init output variables
fBValue = nan;
fStdDev = nan;
fMc = nan;
fAValue = nan;

try
  % Determine magnitude of completeness
  fMc = calc_Mc(mCatalog, nCalculateMC, fBinning);
  % Constrain magnitude of completeness
  if bConstrainMc
    if fMc < fMcMin
      fMc = fMcMin;
    elseif fMc > fMcMax
      fMc = fMcMax;
    end
  end
  % Conservative Mc
  fMc = fMc + fMcAdd;
  % Calculate the b-value of the learning period
  vSel_ = mCatalog.Magnitude >= fMc;
  mCatalog = mCatalog.subset(vSel_);
  nNumberQuakes = mCatalog.Count;
  if nNumberQuakes >= nMinimumNumber
    [fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog, fBinning);
  end
  if isempty(fMc)
    fMc = nan;
  end
catch
end
