report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs

s = [a(:,1)   a(:,2)  a(:,3)  a(:,4)  a(:,5)  a(:,6)  a(:,7) a(:,8) a(:,9) a(:,10) a(:,11) a(:,12) a(:,13) a(:,14)   ];
fid = fopen([newpath newmatfile],'w') ;
fprintf(fid,'%7.3f  %7.3f %6.2f %6.0f  %6.0f %6.1f %6.2f  %6.0f  %6.0f  %7.2f  %7.2f  %7.2f  %7.2f  %7.2f\n',s');
fclose(fid);
clear s
return
