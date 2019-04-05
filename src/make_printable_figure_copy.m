function make_printable_figure_copy(fig_to_copy)
    % copy a figure, making backgroudnds white and removing undisplayed tabs
    %
    
    % copy the figure to start with...
    fig = copy(fig_to_copy);
    fig.Color = 'w';
    
    
    % get rid of unnecesary tabs
    tg = findobj(fig,'Type','uitabgroup');
    nTrys = 0;
    
    % loop is repeated because of nesting issues
    while(~isempty(tg))
        tabs = findobj(fig,'Type','uitab');
        delete(tabs(~ismember(tabs,[tg.SelectedTab])));
        tabs = tabs(isvalid(tabs));
        
        for idx = 1:numel(tabs)
            t = tabs(idx);
            p = t.Parent; % tab group
            if ~isempty(findobj(p.Children, 'Type', 'uitabgroup'))
                continue % do not delete any tab groups that have nested tab groups
            end
            f(idx) = uipanel(p.Parent, 'Title', t.Title, 'Units', p.Units,...
                'Position', p.Position, 'BackgroundColor', 'w');
            copyobj(t.Children, f(idx));
            delete(p);
        end
        tg = findobj(fig, 'Type', 'uitabgroup');
        for g = numel(tg):-1:1
            if isempty(tg(g).SelectedTab)
                delete(tg(g));
                tg(g)=[];
            end
        end
        nTrys = nTrys + 1;
        if nTrys > 5
            error('probably got into some sort of recursion loop');
        end
    end
    
    set(findobj(fig, 'Tag', 'zmap_watermark'), 'BackgroundColor', 'w');
    delete(findobj(fig, 'Type', 'uicontextmenu'));
    delete(findobj(fig, 'Type', 'uimenu'));
    
    myAxes = findobj(fig,'Type','axes');
    for j = 1:numel(myAxes)
        ma = myAxes(j);
        mypanel = ancestor(ma,'uipanel');
        if isempty(ma.Title.String)
            if ~isempty(mypanel)
                ma.Title.String = mypanel.Title;
            end
        end
        mypanel.Title = '';
        mypanel.BorderType = 'none';
    end
    
    orient(fig, 'landscape')
    set(fig,'Tag',['printable', get(fig,'Tag')]);
    
end
