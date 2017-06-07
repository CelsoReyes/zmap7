function [fMc] = calc_Mc(mCatalog, nMethod, fBinning, fMcCorrection)
% function [fMc] = calc_Mc(mCatalog, nMethod, fBinning, fMcCorrection)
% --------------------------------------------------------------------
% Calculates the magnitude of completeness for a given catalog
%
% Input parameters:
%   mCatalog       Earthquake catalog for determing the magnitude of completeness
%   nMethod        Method to determine the magnitude of completeness
%                  1: Maximum curvature
%                  2: Fixed Mc = minimum magnitude (Mmin)
%                  3: Mc90 (90% probability)
%                  4: Mc95 (95% probability)
%                  5: Best combination (Mc95 - Mc90 - maximum curvature)
%                  6: Mc using EMR-method
%                  7: Mc due b using Shi & Bolt uncertainty
%                  8: Mc due b using bootstrap uncertainty
%                  9: Mc due b Cao-criterion
%   fBinning       Binning of catalog's magnitudes (default 0.1)
%   fMcCorrection  Correction term to be added to fMc (default 0)
%
% Output parameters:
%   fMc            Magnitude of completeness
%
% Special function
%   If called without any parameters, calc_Mc returns a string containing the names
%   of all available Mc-determination routines
%
% Copyright (C) 2004 by Danijel Schorlemmer, Jochen Woessner
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

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

if nargin == 0
  fMc = ['1: Maximum curvature|' ...
         '2: Fixed Mc = minimum magnitude (Mmin)|' ...
         '3: Mc90 (90% probability)|' ...
         '4: Mc95 (95% probability)|' ...
         '5: Best combination (Mc95 - Mc90 - maximum curvature)|' ...
         '6: EMR-method|' ...
         '7: Mc due b using Shi & Bolt uncertainty|' ...
         '8: Mc due b using bootstrap uncertainty|' ...
         '9: Mc due b Cao-criterion'];
  return;
end

% Magnitude binning
if ~exist('fBinning', 'var')
  fBinning = 0.1;
end

% Correction
if ~exist('fMcCorrection', 'var')
  fMcCorrection = 0;
end

% Init return variable
fMc = nan;

if nMethod == 1
    % Maximum curvature
    fMc = calc_McMaxCurvature(mCatalog);
elseif nMethod == 2
    % Fixed Mc (Mc = Mmin)
    fMc = min(mCatalog(:,6));
elseif nMethod == 3
    % Automatic Mc90
    [fDummy, fDummy, fMc] = calc_McBest(mCatalog, fBinning);
elseif nMethod == 4
    % Automatic Mc95
    [fDummy, fMc, fDummy] = calc_McBest(mCatalog, fBinning);
elseif nMethod == 5
    % Best combination (Mc95 - Mc90 - maximum curvature)
    [fMc, Mc95, Mc90] = calc_McBest(mCatalog, fBinning);
    if isnan(Mc95) == 0
        fMc = Mc95;
    elseif isnan(Mc90) == 0
        fMc = Mc90;
    else
        fMc = calc_McMaxCurvature(mCatalog);
    end
elseif nMethod == 6
    % EMR-method
    [fMc_EMR, fBvalue, fAvalue, fMu, fSigma] = calc_McEMR(mCatalog, fBinning);
    fMc = fMc_EMR;
elseif nMethod == 7
    % Mc due b using Shi & Bolt uncertainty
    [fMc_shi, fBvalue_shi, fBStd_shi, fAvalue_shi, mBave] = calc_Mcdueb(mCatalog);
    fMc = fMc_shi;
elseif nMethod == 8
    % Mc due b using bootstrap uncertainty
    nSample = 500;
    [fMc_bst, fBvalue_bst, fBStd_bst, fAvalue_bst, mBave] = calc_McduebBst(mCatalog, fBinning, 5, 50,nSample);
    fMc = fMc_bst;
else % nMethod == 9
    % Mc due b Cao-criterion
    [fMc_cao, fBvalue_cao, fBStd_cao, fAvalue_cao] = calc_McduebCao(mCatalog);
    fMc = fMc_cao;
end

% Check fMc
if isempty(fMc)
  fMc = nan;
end

% Apply correction
if ~isnan(fMc)
  fMc = fMc + fMcCorrection;
end
