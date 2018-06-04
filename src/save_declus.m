function cluster_length = save_declus(catalog) 
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    global cluslength %[OUT]
    %FIXME: this is torn to shreds by the updated catalog format
    report_this_filefun();
    storedcat=a;
    hodis = fullfile(hodi, 'external');
    cd(hodis);
    
    str = [];
    
    s = [  ZG.primeCatalog.Date.Year  ZG.primeCatalog.Date.Month  ZG.primeCatalog.Date.Day ZG.primeCatalog.Date.Hour ZG.primeCatalog.Date.Minute ZG.primeCatalog.Magnitude   ZG.primeCatalog.Latitude  ZG.primeCatalog.Longitude  ZG.primeCatalog.Depth   ];
    fid = fopen(['data'],'w') ;
    fprintf(fid,'%4.0f%2.0f%2.0f%2.0f%2.0f  %3.1fmb%7.3f%8.3f%5.1fA\n',s');
    fclose(fid);
    clear s
    
    s = [taumin*60*24 taumax*60*24 P xk xmeff rfact err derr ];
    fid = fopen(['para.dat'],'w') ;
    fprintf(fid,'%5.0f  %5.0f  %5.3f  %5.3f  %5.3f  %5.3f  %5.3f  %5.3f\n',s');
    fclose(fid);
    clear s
    
    % This executes the clus.exe FORTRAN code
    unix(['.' filesep 'myclus ']);
    
    %open datafile
    fid = 'outf.clu';
    
    try
        format = ['%12c %3f %f %f %f %d'];
        [dat,mag,lat,lon,dep,clu] = ...
            textread(fid,format,'whitespace',' \b\r\t\n mb A ');
    catch ME
        l=ME.message;
        l1 = strfind(l,',');
        anz = str2double(l(53:l1-1));
        [dat,mag,lat,lon,dep,clu] = ...
            textread(fid,format,anz-1,'whitespace',' \b\r\t\n mb A ');
        disp(['Error in Line ' num2str(anz) ' read only lines  1 - ' num2str(anz-1) ]);
        
    end
    
    
    %transform data to ZMAP format
    watchon;
    disp('Reloading data ...')
    
    yr = str2double(dat(:,1:4));
    mo=  str2double(dat(:,5:6));
    da=  str2double(dat(:,7:8));
    hr=  str2double(dat(:,9:10));
    mi=  str2double(dat(:,11:12));
    
    replaceMainCatalog([lon lat ZG.primeCatalog.Date mo da mag storedcat.Depth hr mi clu]);
    
    cluslength=[];
    n=0;
    k1=max(clu);
    for j=1:k1                         %for all clusters
        cluslength(j)=length(find(clu==j));  %length of each clusters
    end
    
    tmp=find(cluslength);      %numbers of clusters that are not empty
    
    %cluslength,bg,mbg only for events which are not zero
    cluslength=cluslength(tmp);
    
    clustnumbers=(1:length(tmp));    %stores numbers of clusters
    l = a(:,10) > 0;
    clus = ZG.primeCatalog.subset(l);
    ZG.primeCatalog(l,:) = [];
    
    % plot the results
    zmap_update_displays();
    set(gca,'NextPlot','add')
    plot(clus(:,1),clus(:,2),'m+');
    
    st1 = [' The declustering found ' num2str(max(clu)) ' clusters of earthquakes, a total of '...
        ' ' num2str(length(clus(:,1))) ' events (out of ' num2str(storedcat.Count) '). '...
        ' The map window now display the declustered catalog containing ' num2str(ZG.primeCatalog.Count) ' events . The individual clusters are displayed as magenta o in the map. ' ];
    
    msgbox(st1,'Declustering Information')
    watchoff;
end
