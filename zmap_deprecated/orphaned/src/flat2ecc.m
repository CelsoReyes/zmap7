function eccent = flat2ecc(parm)

    %FLAT2ECC  Computes the eccentricity of an ellipse given a flattening
    %
    %  e = FLAT2ECC(mat) computes the eccentricity of an ellipse (or
    %  ellipsoid of revolution) given the flattening.  If the
    %  input is a column vector, then each input is assumed to be a
    %  flattening.  If the input has two columns, then the second
    %  column is assumed to be the flattening.  If the input is a
    %  n x m matrix, where m ~= 2, then each element is assumed to be a
    %  flattening and the corresponding eccentricity is calculated.
    %
    %  See also:  ECC2FLAT, N2ECC, AXES2ECC

    %  Copyright (c) 1996-98 by Systems Planning and Analysis, Inc. and The MathWorks, Inc.
    %  Written by:  E. Byrns, E. Brown
    %   $Revision: 1399 $    $Date: 2006-08-11 11:19:27 +0200 (Fr, 11 Aug 2006) $

    %report_this_filefun(mfilename('fullpath'));

    if nargin == 0
        error('Incorrect number of arguments')
    end

    %  Dimension tests

    if min(size(parm)) == 1 && ndims(parm) <= 2

        col = min(size(parm,2), 2);   % Select first or second column
        flat = parm(:,col);           % First col if single vector input
        % Second col if two column inputs (eg. geoid vecs)
    else
        flat = parm;        %  General matrix input
    end

    %  Ensure real inputs

    if ~isreal(flat)
        warning('Imaginary parts of complex argument ignored')
        flat = real(flat);
    end

    %  Compute the eccentricity

    eccent = sqrt(2*flat - flat.^2);


