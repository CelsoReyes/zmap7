report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] =  uiputfile([hodi], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs


s = [xt ]

fid = fopen([newpath newmatfile],'w')
fprintf(fid,'%6.2f %6.2f  %6.2f\n',s)
fclose(fid)


