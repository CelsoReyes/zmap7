report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As');  %Syntax change in the Matlab Version 7, window positiobibg does not functioning on a mac

s = [a.Longitude   a.Latitude  a.Date.Year  a.Date.Month  a.Date.Day  a.Magnitude  a.Depth a.Date.Hour a.Date.Minute  ];
fid = fopen([newpath newmatfile],'w') ;;
fprintf(fid,'%8.3f   %7.3f %4.0f %6.0f  %6.0f %6.1f %6.2f  %6.0f  %6.0f\n',s');
fclose(fid);
clear s
return
