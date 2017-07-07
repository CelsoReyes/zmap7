report_this_filefun(mfilename('fullpath'));

fid = fopen('longva.m');
a = fscanf(fid,'%g %g',[10 inf ]) ;
a = a';
fclose(fid)

