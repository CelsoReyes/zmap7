function [mask] = polygon_filter(x, y, XI, YI, in_or_out)
    % POLYGON_FILTER used Analytic Geometry to select points inside or outside polygon
    %
    % [mask] = POLYGON_FILTER(x, y, XI, YI, in_or_out)
    % 
    % input params:
    %    x, y : polygon vertices, with x(1)==x(end) and y(1)==y(end)
    %           x & y must be vectors of same size, and include
    %           more than 3 points (len(polyX) > 3)
    %
    %    XI, YI : x and y values for points to be tested
    %
    %    in_or_out : either 'inside' or 'outside'
    %               'inside' : returns a mask that is true for points inside polygon
    %               'outside': returns mask that is true for points outside polygon
    %
    %               default is 'inside'
    %
    %    I don't know about edge cases.
    %
    % see also inpolygon, inpoly
    
    
    assert(length(XI) == length(YI), 'test-points should have equal numbers of x and y' );
    assert(length(x) == length(y), 'number of polygon x should equal polygon y');
    assert(numel(x) > 3,'not enough points to be a polygon');
    
    m = length(x)-1;      %  number of coordinates of polygon
    l = zeros(size(XI));
    l2 = l;            %  Algorithm to select points inside a closed
    %  polygon based on Analytic Geometry    R.Z. 4/94
    for i = 1:m
        
        l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
            (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
            ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
            (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);
        
        if i ~= 1
            l2(l) = 1 - l2(l);
        else
            l2 = l;
        end         % if i
        
    end 
    
    if ~exist('in_or_out','var')
        in_or_out = 'inside';
    end
    
    switch(in_or_out)
        case 'inside'
            mask = l2;
        case 'outside'
            mask = ~l2;
        otherwise
            error('unrecognized in_or_out option. either ''inside'' or ''outside''');
    end
end
