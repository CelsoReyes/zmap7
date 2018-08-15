function s = MenuSelectedField()
    % provide compatibility as Matlab changes from Callback to MenuSelectedFcn for menu items
    persistent ss
    if isempty(ss)
        if verLessThan('matlab','9.3')
            ss = 'Callback';
        else
            ss = 'MenuSelectedFcn';
        end
    end
    s=ss;
end