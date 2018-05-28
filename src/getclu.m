function selected_cluster_num = getclu(gecl, clus, slider_obj, text_obj)
    % get the selected cluster
    % selected_cluster_num = getclu(gecl, clus, slider_obj, text_obj)
    %
    % see also markclus
    
    global cluslength % [IN]
    global equi %[IN] reference events in cluster
    report_this_filefun();
    ZG=ZmapGlobal.Data;
    
    prev_cluster_num = round(slider_obj.Value);
    switch  gecl
        
        case 'mouse'
            disp('Click with the left mouse button #next to the equivalent event #of the cluster you want to examine');
            
            clmap = findobj('Name','Cluster Map');
            if ~isempty(clmap);figure(clmap);end
            
            [x,y]=ginput(1);
            
            l=sqrt(((equi.Longitude-x)*cosd(y)*111).^2 + ((equi.Latitude-y)*111).^2) ;
            [~,sort_idx] = sort(l);            % sort by distance
            % new = equi(is(1),:);  % seems to not be used anywhere
            
            selected_cluster_num = sort_idx(1);
            
            disp(['selected: Cluster # ' num2str(selected_cluster_num) ]);
            
            slider_obj.Value=selected_cluster_num;
            %set(findobj('tag',num2str(prev_cluster_num)),'MarkerSize',6,'Linewidth',1.0);
            %set(findobj('tag',num2str(selected_cluster_num)),'MarkerSize',22,'Linewidth',4);
            
            
        case 'large'
            selected_cluster_num = find(cluslength == max(cluslength));
    end
    
    assert( markclus(clus,prev_cluster_num,slider_obj, text_obj) == selected_cluster_num,...
        'expected cluster %d, got %d', selected_cluster_num,...
        markclus(clus,prev_cluster_num,slider_obj, text_obj))
    
    ZG.newt2 = ZG.original.subset(clus==selected_cluster_num);
    ZG.newt2.Name=sprintf('%s : cluster %d',ZG.newt2.Name, selected_cluster_num);
    
    if ~exist('tiplo', 'var')
        CumTimePlot(ZG.newt2);
    end
    nu = (1:ZG.newt2.Count) ;
    nu = nu';
    set(findobj('Tag','tiplo2'),'Xdata',ZG.newt2.Date,'Ydata',nu);
    figure(findobj('Type','Figure','-and','Tag','cum'));
    % prev_cluster_num = selected_cluster_num;
end

