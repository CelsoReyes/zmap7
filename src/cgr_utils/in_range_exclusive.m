function tf=in_range_exclusive(value, R)
    % in_range_exclusive returns true where value in interval (A B), where  R = [A B];
    %
    % example:
    %  >> in_range_exclusive( 1:5 , [2 4])  % returns logical aray [0 0 1 0 0]
    % 
    % see also in_range, in_range_inclusive
    if numel(R)==2
        tf = R(1) < value & value < R(2);
    else
        error('range should be a 1x2 vector of [minval maxval]');
    end
end