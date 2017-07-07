report_this_filefun(mfilename('fullpath'));

s = [a(:,3:5) a(:,8:9) a.Magnitude a.Depth l(l2)  ];
s = s';


fid = fopen(['tmp.dat' ],'w')
fprintf(fid,'%2.0f%2.0f%2.0f%2.0f%2.0f      %3.1f     %6.2f     %6.2f\n',s)
fclose(fid)

