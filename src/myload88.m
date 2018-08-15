function myload88(da,inda) 
    % This script file load a data set using fscanf
    % The default reads Northern California Hypoellipse Format
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    disp('Please make sure the has 88 characters for each line')
    disp('and all blanks have been substituted by zeros')
    
    % Lets make sure the file is closed...
    safe_fclose(fid);
    
    % reset paramteres
    replaceMainCatalog([]); b = []; n = 0;
    
    if inda == 1
        % initial selection option
        tmin   = 10.0001;
        tmax   = 98.000;
        lonmin = -180.0;
        lonmax =  180.0;
        latmin =  -90.00;
        latmax =  90.0 ;
        Mmin   = -4.0;
        Mmax   = 10.;
        mindep = -10;
        maxdep = 700;
        
        % call the pre-selection window
        presel(@myload88);
        return
    end
    
    % open the file and read 10000 lines at a time
    [file1,path1] = uigetfile([ '*.dat'],' Earthquake Datafile');
    if length(file1) >1
        fid = fopen([path1 file1],'r') ;
    else
        disp('Data import canceled'); return
    end
    
    while  ferror(fid) == ''
        n = n+1;
        % vari name   yr mo da hr mi se lat   la  lon    lo de ma1     ma he   hz
        % variabl #   1  2  3  4  5  6  7      8  9      10 11 12      13 14   15
        % position    2  4  6  8  10 14 16 17  21 24 25  29 34 36 67   69 84   88
        l = fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d%*31c%2d%*15c%4d',...
            [14 10000]) ;
        %if ferror(fid) ~= '' ; break; end
        
        b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ; l(1,:);l(2,:);l(3,:);
            l(13,:)/10;l(11,:)/100;l(4,:);l(5,:); l(14,:)/100;l(12,:)/10];
        b = b';
        l =  b.Magnitude >= Mmin & b(:,1) >= lonmin & b(:,1) <= lonmax & ...
            b(:,2) >= latmin & b(:,2) <= latmax & b.Date <= tmax  & ...
            b.Date >= tmin  ;
        a = [a ; b(l,:)];
        
        disp([ num2str(n*10000) ' earthquakes scanned, ' num2str(ZG.primeCatalog.Count) ' EQ found'])
        if max(b.Date) >  tmax ; break; end
        
    end
    ferror(fid)
    fclose(fid);
    
    % Convert the third column into time in decimals
    if length(a(1,:))== 7
        ZG.primeCatalog.Date = decyear(a(:,3:5));
    elseif length(a(1,:))>=9       %if catalog includes hr and minutes
        ZG.primeCatalog.Date = decyear(a(:,[3:5 8 9]));
    end
    
    
    dep1 = 0.3*(max(ZG.primeCatalog.Depth)-min(ZG.primeCatalog.Depth))+min(ZG.primeCatalog.Depth);
    dep2 = 0.6*(max(ZG.primeCatalog.Depth)-min(ZG.primeCatalog.Depth))+min(ZG.primeCatalog.Depth);
    dep3 = max(ZG.primeCatalog.Depth);
    
    stri1 = [file1];
    tim1 = minti;
    tim2 = maxti;
    minma2 = minma;
    maxma2 = maxma;
    minde = min(ZG.primeCatalog.Depth);
    maxde = max(ZG.primeCatalog.Depth);
    rad = 50.;
    ic = 0;
    ya0 = 0.;
    xa0 = 0.;
    ZG.compare_window_dur_v3 = years(1);
    step = 3;
    t1p(1) = 80.;
    t2p(1) = 85.;
    t3p(1) = 90.;
    t4p(1) = 93.;
    ZG.tresh_km = 10;
    
    % save the data
    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Save Earthquake Datafile');
    sapa2 = ['save ' path1 file1 ' a'];
    if length(file1) > 1; eval(sapa2);end
    
    % call the map window
    zmap_update_displays();
end
