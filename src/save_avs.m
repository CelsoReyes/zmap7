report_this_filefun(mfilename('fullpath'));

str = [];
out = reshape(bv2,33759,1,1);
out = out*100;

[newmatfile, newpath] = uiputfile([ hodo '*.dat'], 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs

s = [33  ;33 ; 31  ;out(:,1)   ];
s = s'
fid = fopen([newpath newmatfile],'w') ;;
fwrite(fid,s,'integer*8');
fclose(fid);
clear s
return
