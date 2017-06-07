function [fStdDev] = calc_StdDev(vDistribution)
% function [fStdDev] = calc_StdDev(vDistribution)
% -----------------------------------------------
% Computes the standard deviation of a non-parameterized distribution
%
% Input parameters:
%   vDistribution   Vector containing the distribution
%
% Output parameters:
%   fStdDev         Standard deviation of the given distribution
%
% Copyright (C) 2003-2006 by Danijel Schorlemmer
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

global bDebug
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Get number of elements of distribution
nNumElements = length(vDistribution);

% Compute standard deviation as the second moment of the given distribution
vDist = vDistribution.^2 .* (1/nNumElements);
fStdDev = sqrt(nansum(vDist)-(nanmean(vDistribution))^2);

% Check result for imaginary part
% Explanation: For a large vector vDistribution with all the same numbers
% the argument of the sqrt-coomand may be not zero although it should.
% Thus the sqrt outputs a complex number, although it should be zero!
% This is fixed now by the following if command.
if (~isreal(fStdDev) & ~isnan(fStdDev))
    fStdDev = 0;
end
