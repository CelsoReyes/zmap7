function tf = ischarlike(v)
    % returns true if argument is either a char array or a string scalar
    tf = ischar(v) || (isstring(v) && isscalar(v));