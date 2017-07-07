%Saving data into ASPAR type 5 format

report_this_filefun(mfilename('fullpath'));


str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs

s = [a.Date.Year  a.Date.Month  a.Date.Day  a.Date.Hour  a.Date.Minute a.Date.Hour*0  a.Magnitude  a.Magnitude*0 a.Latitude  a.Longitude a.Depth a.Date.Minute*0  ];
fid = fopen([newpath newmatfile],'w') ;
fprintf(fid,'%4.0f%2.0f%2.0f%2.0f%2.0f%2.0f%3.1f%2.0f%7.3f%8.3f%5.1f%1.0f\n',s');
fclose(fid);
clear s
return
