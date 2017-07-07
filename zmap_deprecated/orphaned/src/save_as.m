report_this_filefun(mfilename('fullpath'));

tr = [];
[newmatfile, newpath] = uiputfile([hodi  ], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs


s = [a.Longitude  ; a.Latitude ; a.Date ; a.Date.Month ; a.Date.Day ; a.Magnitude ; a.Depth  ];
fid = fopen([newpath newmatfile],'w') ;;
fprintf(fid,'%6.2f  %6.2f %6.2f %6.2f  %6.2f %6.2f %6.2f\n',s);
fclose(fid)
return
