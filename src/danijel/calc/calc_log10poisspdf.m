function [fResult] = calc_log10poisspdf(nX, fLambda)
    % Logarithm (basis 10) of the Poisson probability density function.
    %
    % [fResult] = calc_log10poisspdf(nX, fLambda)
    %
    %
    % Input parameters:
    %   nX          Parameter x (see help for 'poisspdf')
    %   fLambda     Parameter lambda (see help for 'poisspdf')
    %
    % Output parameters:
    %   fResult     Logarithm to the basis of 10 of the Poisson probability density
    %
    % Danijel Schorlemmer
    % July 18, 2002
    
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
        fResult(vSel) = 1/log(10) * (-fLambda(vSel) + nX(vSel) .* log(fLambda(vSel) + realmin*(fLambda(vSel)==0)) ...
            - gammaln(nX(vSel) + 1));
        %fResult(vSel) = log10(poisspdf(nX(vSel),fLambda(vSel)));
    end
    
end