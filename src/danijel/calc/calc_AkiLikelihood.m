function [fLogLikelihood] = calc_AkiLikelihood(mCatalog, fBValue, fBinning)
% function [fLogLikelihood] = calc_AkiLikelihood(mCatalog, fBValue, fBinning)
% ---------------------------------------------------------------------------
% Calculates the likelihood of a b-value fit
%
% Input parameters:
%   mCatalog        Earthquake catalog
%   fBValue         b-value
%   fBinning        Binning of the earthquake magnitudes (default 0.1)
%
% Output parameters:
%   fLogLikelihood  Log-likelihood
%
%@ARTICLE{Aki1965,
%  author =       "K. Aki",
%  title =        "Maximum likelihood estimate of $b$ in the formula
%                  $\log N = a-bM$ and its confidence limits",
%  journal =      "Bull. Earthquake Re. Inst., Tokyo Univ.",
%  year =         "1965",
%  volume =       "43",
%  pages =        "237-239",
%}
%
% Copyright (C) by Danijel Schorlemmer
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

if ~exist('fBinning', 'var')
  fBinning = 0.1
end

fBPrime = fBValue/(log10(exp(1)));
fMinMag = min(mCatalog(:,6))-(fBinning/2);

fL = ones(length(mCatalog(:,1)),1)*nan;

fL = log(fBPrime) - (fBPrime * (mCatalog(:,6) - fMinMag));
fLogLikelihood = sum(fL);
