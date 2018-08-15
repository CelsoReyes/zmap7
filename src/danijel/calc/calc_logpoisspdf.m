function [fResult] = calc_logpoisspdf(nX, fLambda)
    % Natural logarithm of the Poisson probability density function.
    %
    % [fResult] = calc_logpoisspdf(nX, fLambda)
    %
    %
    % Input parameters:
    %   nX          Parameter x (see help for 'poisspdf')
    %   fLambda     Parameter lambda (see help for 'poisspdf')
    %
    % Output parameters:
    %   fResult     Natural logarithm of the Poisson probability density
    %
    % Copyright (C) 2002-2006 by Danijel Schorlemmer
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
    
    % Create emtpy matrix for results
    fResult = zeros(size(nX));
    if isempty(fResult)
        return;
    end
    fResult(fLambda < 0) = NaN;
    
    % Select all computable elements
    vSel = (nX >= 0 & nX == round(nX) & fLambda >= 0);
    
    % Adding of realmin to 0 cases is to get the effect of 0^0 = 1.
    if (any(vSel))
        fResult(vSel) = -fLambda(vSel) + nX(vSel) .* log(fLambda(vSel) + realmin*(fLambda(vSel)==0)) ...
            - gammaln(nX(vSel) + 1);
    end
end
