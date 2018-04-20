function active_cluster = markclus(clus, active_cluster, slider_obj, text_obj)
    % markclus  -
    % active_cluster = markclus(clus, active_cluster, slider_obj, text_obj)
    % uses slider_obj.Value to determine next cluster
    % active_cluster is the previous cluster
    % returns new cluster, based on slider position, and changes the text to match.
    %
    % sets newt2 to the current cluster!
    % 
    % see also getclu
    
    report_this_filefun();
    ZG=ZmapGlobal.Data;
    %
    
    if isempty(active_cluster)
        active_cluster = 1;
    end
    
    shadow=findobj('Tag','clus_shadow'); % used to make data stand out more
    
    j = findobj('tag',num2str(active_cluster));
    try
        set(j, 'MarkerSize', 6, 'LineWidth', 1.0);
    catch ME
        error_handler(ME, @do_nothing);
    end
    
    val = round(get(slider_obj,'Value'));
    %val = floor(val*max(clus))+1;
    %val = max(val, max(clus));
    j = findobj('tag',num2str(val));
    assert(~isempty(j),'cluster # %d isn''t on plot',val);
    
    str = sprintf('Cluster# %d\n  (%d evts)',val, numel(j.XData));
    set(text_obj,'string',str);
    
    set(j,'MarkerSize',20,'Linewidth',4);
    
    set(shadow,'XData',j.XData,'YData',j.YData,...
        'Marker',j.Marker,'MarkerSize',j.MarkerSize+5,...
        'Linewidth',j.LineWidth+2);
    uistack(shadow,'top');
    uistack(j,'top');
    
    ZG.newt2 = ZG.original.subset(clus==val);
    ZG.newt2.Name=[ZG.newt2.Name ':clust #',num2str(val)];
    
    nu = (1:ZG.newt2.Count) ;
    nu = nu';
    if length(nu) > 2
        set(findobj('Tag','tiplo2'),'Xdata',ZG.newt2.Date,'Ydata',nu);
    end
    
    active_cluster = val;
end
