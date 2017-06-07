report_this_filefun(mfilename('fullpath'));

tr = [];
[newmatfile, newpath] = uiputfile([hodi  ], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs


s = [a(:,1)  ; a(:,2) ; a(:,3) ; a(:,4) ; a(:,5) ; a(:,6) ; a(:,7)  ];
fid = fopen([newpath newmatfile],'w') ;;
fprintf(fid,'%6.2f  %6.2f %6.2f %6.2f  %6.2f %6.2f %6.2f\n',s);
fclose(fid)
return
