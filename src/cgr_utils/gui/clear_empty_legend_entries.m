function clear_empty_legend_entries(parent)
    % remove any entries from legends where string is empty
    % CLEAR_EMPTY_LEGEND_ENTRIES(parent)
    
    if nargin==0
        l=findall(0,'Type','legend');
    else
        l=findobj(parent,'Type','legend');
    end
    for n=1:numel(l)
        l(n).String(cellfun(@isempty,l(n).String))=[];
    end
end