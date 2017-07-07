report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs


s = [a(:,10) a(:,11) a(:,12) a(:,13) a(:,14) ];
fid = fopen([newpath newmatfile],'w') ;
fprintf(fid,'%7.3f  %7.3f %7.2f %7.3f  %3.0f\n',s');
fclose(fid);
clear s
return
