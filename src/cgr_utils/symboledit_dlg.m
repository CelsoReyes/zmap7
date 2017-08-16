function symboledit_dlg(ax,field)
    % symboledit_dlg choose line/scatterplot properties for specified axes
    %
    % symboledit_dlg(ax, field)
    %    AX is either the Tag name of an axes, or a handle to the axes
    %    FIELD is the property value to be chosen
    %
    % items that would not appear on the legend. If the DisplayName property is absent, then that
    % particular item will be ignored
    
    if ischar(ax)
        % ax was a Tag to an axis, but this requiers the handle
        ax = findobj( 'Tag', ax);
    end
    
    lines=findobj(ax,'Type','Line','-or','Type','Scatter');
    toshow=get(lines,'DisplayName');
    ignore = cellfun(@isempty,toshow);
    lines(ignore)=[]; % don't bother trying to change features that aren't supposed to show up
    
    for ii=numel(lines):-1:1
        if ~isprop(lines(ii),field)
            lines(ii)=[]; %not settable, so remove it
        end
    end
        
    options.Resize='on';
    toshow=get(lines,'DisplayName');
    symbs = get(lines,field);
    usenumbers = isnumeric(symbs{1});
    if usenumbers
        symbs = cellfun(@num2str,symbs,'UniformOutput',false);
    end
        
    % TODO (wishlist)  change font size for input dialog.  This is fixed by MATLAB unfortunately
    answer=inputdlg(strcat(field, ' for :',toshow),['Choose ' field], 1, symbs,options);
    if isempty(answer)
        return
    end
    if usenumbers
        answer = cellfun(@str2num,answer,'UniformOutput',false); %forces into cells
    end
    for ii=1:numel(lines)
        set(lines(ii),field,answer{ii});
    end
        
end