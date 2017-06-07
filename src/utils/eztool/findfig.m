function handle = findfig(figname)
    % function handle = findfig(FIGNAME)
    % Returns the handle of the foremost figure
    % with name FIGNAME, or 0 if not found
    %
    % Keith Rogers 9/26/94

    allfigs = get(groot,'children');
    handle = 0;
    for thisfig = (allfigs')
        if strcmp(get(thisfig,'name'),figname)
            handle = thisfig;
            break
        end
    end
