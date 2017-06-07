function r=rot4y(theta)
    % r = rot4y(theta)
    %
    % roty produces a 4x4 rotation matrix representing
    % a rotation by theta radians about the y axis.
    %
    %	Argument definitions:
    %
    %	theta = rotation angle in radians
    c = cos(theta);
    s = sin(theta);
    r = [c  0  s 0;
        0  1  0 0;
        -s  0  c 0;
        0  0  0 1];
