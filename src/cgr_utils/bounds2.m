function min_max = bounds2(someVector)
    % bounds2 is get min and max limits of vector.
    % like bounds, but returns a nx2 instead of two nx1 vectors.
    % min_max = bounds2([1 2 3 -1]); % returns [-1 3];
    %
    % see also bounds
    [min_max(1), min_max(2)] = bounds(someVector);
end