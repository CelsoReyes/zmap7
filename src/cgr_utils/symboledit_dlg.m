function symboledit_dlg(ax,field)
    % choose properties for all lines & scatter plots for the current axis (that would be on legend)
    % if DisplayName is empty, then this will not edit it
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