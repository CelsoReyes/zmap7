function clustNum0 = getclu(gecl, clustNum0)
    % get the selected cluster
    % TOFIX this program spits out several variables including new, clustNum0
    
    global cluslength % [IN]
    global equi %[IN]
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    
    switch  gecl
        
        case 'mouse'
            disp('Click with the left mouse button #next to the equivalent event #of the cluster you want to examine');
            
            clmap = findobj(0,'Name','Cluster Map');
            if ~isempty(clmap);figure(clmap);end

            [x,y]=ginput(1);
            
            l=sqrt(((equi(:,1)-x)*cosd(y)*111).^2 + ((equi(:,2)-y)*111).^2) ;
            [~,sort_idx] = sort(l);            % sort by distance
            % new = equi(is(1),:);  % seems to not be used anywhere
            
            disp(['selected: Cluster # ' num2str(sort_idx(1)) ]);
            
            if isempty(clustNum0)
                clustNum0 = 1;
            end
            set(findobj('tag',num2str(clustNum0)),'MarkerSize',6,'Linewidth',1.0);
            
            val = sort_idx(1);
            
            set(findobj('tag',num2str(val)),'MarkerSize',22,'Linewidth',4);
            
            
        case 'large'
            val = find(cluslength == max(cluslength));
    end
    
    ZG.newt2 = ZG.original.subset(clus == val);
    
    if ~exist('tiplo', 'var')
        timeplot(ZG.newt2);
    end
    nu = (1:ZG.newt2.Count) ;
    nu = nu';
    set(tiplo2,'Xdata',ZG.newt2.Date,'Ydata',nu);
    figure(cum);
    
    
    clustNum0 = val;
end
