function clustNum0 = markclus(clus, clustNum0, sl, te)
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    %
    
    if isempty(clustNum0)
        clustNum0 = 1;
    end
    j = findobj('tag',num2str(clustNum0));
    
    try
        set(j, 'MarkerSize', 6, 'LineWidth', 1.0);
    catch ME
        error_handler(ME, @do_nothing);
    end
    
    val = get(sl,'value');
    val = floor(val*max(clus))+1;
    val = max(val, max(clus));
    
    str = ['Cluster # ',num2str(val) ];
    set(te,'string',str);
    
    j = findobj('tag',num2str(val));
    set(j,'MarkerSize',22,'Linewidth',4);
    
    ZG.newt2 = ZG.original.subset(clus == val);
    
    nu = (1:ZG.newt2.Count) ;
    nu = nu';
    if length(nu) > 2
        set(findobj(0,'Tag','tiplo2'),'Xdata',ZG.newt2.Date,'Ydata',nu);
        %figure(cum);
    end
    
    clustNum0 = val;
end
