function [fMc] = calc_McMag(vMagnitudes, nMethod)
% function [fMc] = calc_McMag(mCatalog, nMethod)
% -------------------------------------------
% Calculates the magnitude of completeness of the given catalog
%
% Input parameters:
%   mCatalog    Earthquake catalog for determing the magnitude of completeness
%   nMethod     Method to determine the magnitude of completeness
%               1: Maximum curvature
%               2: Fixed Mc = minimum magnitude (Mmin)
%               3: Mc90 (90% probability)
%               4: Mc95 (95% probability)
%               5: Best combination (Mc95 - Mc90 - maximum curvature)
%
% Output parameters:
%   fMc         Magnitude of completeness
%
% Danijel Schorlemmer
% April 12, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

if nMethod == 1
  % Maximum curvature
  fMc = calc_McMaxCurvatureMag(vMagnitudes);
elseif nMethod == 2
  % Fixed Mc (Mc = Mmin)
  fMc = min(vMagnitudes);
elseif nMethod == 3
  % Automatic Mc90
  [fDummy, fDummy, fMc] = calc_McBestMag(vMagnitudes);
elseif nMethod == 4
  % Automatic Mc95
  [fDummy, fMc, fDummy] = calc_McBestMag(vMagnitudes);
else % nMethod == 5
  % Best combination (Mc95 - Mc90 - maximum curvature)
  [fMc, Mc95, Mc90] = calc_McBestMag(vMagnitudes);
  if isnan(Mc95) == 0
    fMc = Mc95;
  elseif isnan(Mc90) == 0
    fMc = Mc90;
  else
    fMc = calc_McMaxCurvatureMag(vMagnitudes);
  end
end

