% save a current map and its coordinates

[XX,YY] = meshgrid(gx,gy);
[mm, nn] = size(re3);

dats = [  reshape(XX,mm*nn,1) reshape(YY,mm*nn,1) reshape(re3,mm*nn,1) ];

[filename, pathname] = uiputfile( ...
    {'*.dat'}, ...
    'Save as');

fid = fopen([pathname filename],'w') ;;
fprintf(fid,'%9.4f  %9.4f %12.5f \n',dats');
fclose(fid);


