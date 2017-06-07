report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As');  %Syntax change in the Matlab Version 7, window positiobibg does not functioning on a mac

s = [a(:,1)   a(:,2)  floor(a(:,3))  a(:,4)  a(:,5)  a(:,6)  a(:,7) a(:,8) a(:,9)  ];
fid = fopen([newpath newmatfile],'w') ;;
fprintf(fid,'%8.3f   %7.3f %4.0f %6.0f  %6.0f %6.1f %6.2f  %6.0f  %6.0f\n',s');
fclose(fid);
clear s
return
