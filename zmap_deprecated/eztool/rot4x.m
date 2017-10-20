function r=rot4x(theta)
    % r = rot4x(theta)
    %
    % rotx produces a 4x4 rotation matrix representing
    % a rotation by theta radians about the x axis.
    %
    %	Argument definitions:
    %
    %	theta = rotation angle in radians
    c = cos(theta);
    s = sin(theta);
    r = [1  0  0 0;
        0  c -s 0;
        0  s  c 0;
        0  0  0 1];
