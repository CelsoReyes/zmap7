% save a current map and its coordinates

[XX,YY] = meshgrid(gx,gy);
[nr, nc] = size(re3);

dats = [  reshape(XX,nr*nc,1) reshape(YY,nr*nc,1) reshape(re3,nr*nc,1) ];

[filename, pathname] = uiputfile( ...
    {'*.dat'}, ...
    'Save as');

fid = fopen([pathname filename],'w') ;
fprintf(fid,'%9.4f  %9.4f %12.5f \n',dats');
fclose(fid);


