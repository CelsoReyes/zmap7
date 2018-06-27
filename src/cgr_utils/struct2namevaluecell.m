function c = struct2namevaluecell(s)
    % STRUCT2NAMEVALUECELL converts a struct into a cell of name-value pairs.eg. {name1, value1, name2, value2,...}
    % ex.
    %   origcell = {'name','fred','age',23}
    %   s = struct(origcell{:});
    %   c = struct2namevaluecell(s)
    %    % so that...
    %   isequal(origcell, c);   % TRUE
    %

    fn = fieldnames(s)';
    ns = numel(s);
    c = cell(numel(s), numel(fn)*2);
    c(:,1:2:end)=repmat(fn,ns,1);
    for r = 1:ns
        for f = 1:numel(fn)
        c(r,f*2) = {s(r).(fn{f})};
        end
    end
end
    