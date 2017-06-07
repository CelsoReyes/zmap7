report_this_filefun(mfilename('fullpath'));

s = [a(:,3:5) a(:,8:9)  ];
s = s';


fid = fopen(['tmp.dat' ],'w')
fprintf(fid,'%2.0f%2.0f%2.0f%2.0f%2.0f\n',s)
fclose(fid)

