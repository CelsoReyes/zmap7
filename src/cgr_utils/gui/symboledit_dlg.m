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
        
    toshow=get(lines,'DisplayName');
    symbs = get(lines,field);
        
    zdlg = ZmapDialog([]);
    zdlg.AddBasicHeader(['Change ' field]);
    for n=1:numel(lines)
        zdlg.AddBasicEdit(['field' num2str(n)],toshow{n},symbs{n},'');
    end
    [answer,pressedOk]=zdlg.Create(['Change ' field]);
    if ~pressedOk
        return
    end
    
    if isempty(answer)
        return
    end
    
    for ii=1:numel(lines)
        myfield = ['field', num2str(ii)];
        set(lines(ii),field,answer.(myfield));
    end
        
end