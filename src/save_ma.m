report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] =  uiputfile([hodi], 'Save MagSig As'); %Syntax change Matlab Version 7, no window positioning on macs

if exist('masi_syn') > 0
    s = [ (minmag2:0.1:maxmag)  ;  masi ; masi2   ];
    fid = fopen([newpath newmatfile],'w')
    fprintf(fid,'%6.2f %6.2f  %6.2f\n',s)
    fclose(fid)
else
    minmag2 = mmin; maxmag = mmax;
    s = [ (minmag2:0.1:maxmag)  ;  masi ; masi2   ];
    fid = fopen([newpath newmatfile],'w')
    fprintf(fid,'%6.2f %6.2f  %6.2f\n',s)
    [newmatfile, newpath] =  uiputfile([hodi], 'Save SynSig As');
    s = [ (minmag2:0.1:maxmag)  ;  masi_syn ; masi_syn2   ];
    fid = fopen([newpath newmatfile],'w')
    fprintf(fid,'%6.2f %6.2f  %6.2f\n',s)
    fclose(fid)
end             % if length

