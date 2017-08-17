function d = degrees(r)
    % d = degrees(r)
    % TODO rename or remove, this should be rad2deg. this probably already exists
    report_this_filefun(mfilename('fullpath'));
    
    %
    % degrees converts radians to degrees
    %
    % Argument definitions:
    %
    % r = a number in radians
    d = 180*r/pi;
end