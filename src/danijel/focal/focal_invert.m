function [ax,ay,az] = focal_invert(ax,ay,az)
    % invert vector
    %
    %     usage:
    %     utility routine for internal use only
    %
    
    ax = -ax;
    ay = -ay;
    az = -az;
end