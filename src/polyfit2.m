function [p,S] = polyfit(x,y,n)
    %POLYFIT Polynomial curve fitting.
    %	POLYFIT(x,y,n) finds the coefficients of a polynomial p(x) of
    %	degree n that fits the data, p(x(i)) ~= y(i), in a least-squares sense.
    %
    %	[p,S] = POLYFIT(x,y,n) returns the polynomial coefficients p and a
    %	matrix S for use with POLYVAL to produce error estimates on predictions.
    %	If the errors in the data, y, are independent normal with constant
    %	variance, POLYVAL will produce error bounds which contain at least 50%
    %	of the predictions.
    %
    %	See also POLY, POLYVAL, ROOTS.
    
    %	J.N. Little 4-21-85, 8-23-86; CBM, 12-27-91 BAJ, 5-7-93.
    %	Copyright (c) 1984-94 by The MathWorks, Inc.
    
    % The regression problem is formulated in matrix format as:
    %
    %    y = V*p    or
    %
    %          3  2
    %    y = [x  x  x  1] [p3
    %                      p2
    %                      p1
    %                      p0]
    %
    % where the vector p contains the coefficients to be found.  For a
    % 7th order polynomial, matrix V would be:
    %
    % V = [x.^7 x.^6 x.^5 x.^4 x.^3 x.^2 x ones(size(x))];
    
    %TODO understand why this exists -CR
    
    report_this_filefun(mfilename('fullpath'));
    
    if any(size(x) ~= size(y))
        error('X and Y vectors must be the same size.')
    end
    
    x = x(:);
    y = y(:);
    
    % Construct Vandermonde matrix.
    V(:,n+1) = ones(length(x),1);
    for j = n:-1:1
        V(:,j) = x.*V(:,j+1);
    end
    
    % Solve least squares problem.
    [Q,R] = eval('qr(V,0)','qr(V)');
    
    % The current PC version does not have the two-argument form of qr
    [rows, cols] = size(R);
    if rows ~= cols
        R
        cols
        R = R(1:cols,:);
        Q = Q(:,1:cols);
    end
    
    p = R\(Q'*y);    % Same as p = V\y;
    r = y - V*p;
    p = p';          % Polynomial coefficients are row vectors by convention.
    
    % S is a structure containing three elements: the Cholesky factor of the
    % Vandermonde matrix, the degrees of freedom and the norm of the residuals.
    
    df = length(y) - (n+1);
    S = [R; [df zeros(1,n)]; [norm(r) zeros(1,n)]];
    
