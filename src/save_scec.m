%Saving data into ASPAR type 5 format

report_this_filefun(mfilename('fullpath'));


str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs

s = [floor(a(:,3))  a(:,4)  a(:,5)  a(:,8)  a(:,9) a(:,8)*0  a(:,6)  a(:,6)*0 a(:,2)  a(:,1) a(:,7) a(:,9)*0  ];
fid = fopen([newpath newmatfile],'w') ;
fprintf(fid,'%4.0f%2.0f%2.0f%2.0f%2.0f%2.0f%3.1f%2.0f%7.3f%8.3f%5.1f%1.0f\n',s');
fclose(fid);
clear s
return
