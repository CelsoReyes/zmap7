report_this_filefun(mfilename('fullpath'));

str = [];
[newmatfile, newpath] =  uiputfile([hodi], 'Save Backb-val mags and below'); %Syntax change Matlab Version 7, no window positioning on macs

s = [xt2  ;  backg_be  ];
fid = fopen([newpath newmatfile],'w')
fprintf(fid,'%6.2f %6.2f\n',s)

[newmatfile, newpath] =  uiputfile([hodi], 'Save Backb-val mags and above'); %Syntax change Matlab Version 7, no window positioning on macs

s = [xt3  ;  backg_ab  ];
fid = fopen([newpath newmatfile],'w')
fprintf(fid,'%6.2f %6.2f\n',s)

[newmatfile, newpath] =  uiputfile([hodi], 'Save Foreb-val mags and below'); %Syntax change Matlab Version 7, no window positioning on macs

s = [xt2  ;  foreg_be  ];
fid = fopen([newpath newmatfile],'w')
fprintf(fid,'%6.2f %6.2f\n',s)

[newmatfile, newpath] =  uiputfile([hodi], 'Save Foreb-val mags and above'); %Syntax change Matlab Version 7, no window positioning on macs


s = [xt3  ;  foreg_ab  ];
fid = fopen([newpath newmatfile],'w')
fprintf(fid,'%6.2f %6.2f\n',s)

[newmatfile, newpath] =  uiputfile([hodi], 'Save Newb-val mags and below'); %Syntax change Matlab Version 7, no window positioning on macs


s = [xt2  ;  backg_beN  ];
fid = fopen([newpath newmatfile],'w')
fprintf(fid,'%6.2f %6.2f\n',s)

[newmatfile, newpath] =  uiputfile([hodi], 'Save Newb-val mags and above'); %Syntax change Matlab Version 7, no window positioning on macs


s = [xt3  ;  backg_abN  ];
fid = fopen([newpath newmatfile],'w')
fprintf(fid,'%6.2f %6.2f\n',s)

