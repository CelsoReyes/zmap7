function s = get_limited_categories(categorical_obj, lenlimit)
    % get_limited_categories gets the categories for a categorical, but designed for display
    % which means you limit the character length.  
    %
    % s = get_limited_categories(categorical_obj) will get a string contianning the first few and 
    % last few categories with ellipses in between.
    % default length is 80
    
    
    c = categories(categorical_obj);
    if nargin == 1
        lenlimit = 80;
    end
    
    s = strjoin(c,', ');
    if numel(s) > lenlimit
        commas = find(s==',');
        break1=max(commas(commas<25));
        break2=min(commas(commas>(length(s)-25)));
        s=[s(1:break1),'...',s(break2:end)];
    end
end