function out = logical2onoff(val)
    % logical2onoff returns 'on' if true, 'off' if false
    if val
        out = 'on';
    else
        out = 'off';
    end
end