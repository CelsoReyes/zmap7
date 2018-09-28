function tf=in_range_inclusive(value, R)
    % in_range_inclusive returns true where value in inverval [A B], where  R = [A B];
    % 
    % example:
    %  >> in_range_inclusive( 1:5 , [2 4])  % returns logical aray [0 1 1 1 0]
    %
    % see also in_range, in_range_exclusive
    
    if numel(R)==2
        tf = R(1) <= value & value <= R(2);
    else
        error('range should be a 1x2 vector of [minval maxval]');
    end
end