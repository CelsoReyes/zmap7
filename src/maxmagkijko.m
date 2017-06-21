
report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As');

s = [a.Magnitude ];
le = a.Count;

fid = fopen([newpath newmatfile],'w') ;
fprintf(fid,'%5.0f %2.0f %2.0f\n',[floor(a(1,3)) a(1,4) a(1,5)]);
fprintf(fid,'%5.0f %2.0f %2.0f\n',[floor(a(le,3)) a(le,4) a(le,5)]);
fprintf(fid,'%4.1f \n',2.0);
fprintf(fid,'%4.1f \n',0.3);
fprintf(fid,'%4.1f\n',s');

fclose(fid);
clear s
cd kijko
!hn

return

%historic part

str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As');

s = [a.Date.Year a.Date.Month a.Date.Day a.Magnitude ];
le = a.Count;

fid = fopen([newpath newmatfile],'w') ;
fprintf(fid,'%5.0f %2.0f %2.0f\n',[floor(a(1,3))-1 a(1,4) a(1,5)]);
fprintf(fid,'%5.0f %2.0f %2.0f\n',[floor(a(le,3))+1 a(le,4) a(le,5)]);
fprintf(fid,'%5.2f \n',0.50);
fprintf(fid,'%5.0f %2.0f %2.0f %5.1f\n',s');

fclose(fid);



