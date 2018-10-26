function clear_empty_legend_entries(parent)
    % remove any entries from legends where string is empty
    % CLEAR_EMPTY_LEGEND_ENTRIES(parent)
    
    ax=findall(parent,'Type','axes','-not','Legend',[]);
    for i=1:numel(ax)
        h=findobj(ax(i).Children,'flat','Visible','on','-not','DisplayName','');
        ll=legend(ax(i),h);
        ll.Interpreter='none';
    end
end