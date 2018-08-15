function savemap() 
    % save a current map and its coordinates
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    [XX,YY] = meshgrid(gx,gy);
    [nr, nc] = size(valueMap);
    
    dats = [  reshape(XX,nr*nc,1) reshape(YY,nr*nc,1) reshape(valueMap,nr*nc,1) ];
    
    [filename, pathname] = uiputfile( ...
        {'*.dat'}, ...
        'Save as');
    
    fid = fopen([pathname filename],'w') ;
    fprintf(fid,'%9.4f  %9.4f %12.5f \n',dats');
    fclose(fid);
end
