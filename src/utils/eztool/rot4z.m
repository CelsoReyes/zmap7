function r=rot4z(theta,xscale,yscale,zscale)
    % r = rot4z(theta)
    %
    % rotz produces a 4x4 rotation matrix representing
    % a rotation by theta radians about the z axis.
    %
    %	Argument definitions:
    %
    %	theta = rotation angle in radians
    if nargin == 1
        c = cos(theta);
        s = sin(theta);
        r = [c -s  0 0;
            s  c  0 0;
            0  0  1 0;
            0  0  0 1];
    else
        c = cos(theta);
        s = sin(theta);
        r = [c -s  0 xscale;
            s  c  0 yscale;
            0  0  1 zscale;
            0 0 0  1];
    end
