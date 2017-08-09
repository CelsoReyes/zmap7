% Matlab script to write output from genas to a file.
% writes two files: one for results for magnitudes and below
% another for magnitudes and above.
%

report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(mess)
clf ;
set(mess,'Name','Messages');
set(gca,'visible','off');
set(mess,'pos',[ 0.02  0.9 0.3 0.2])
format short

[tbin,zmag,zval] = find(ZABO);           % deal with sparse matrix results
xtz = t0b + (tbin*days(ZG.bin_days));
zmag = minmg+(zmag-1)*magstep;
[~,l] = sort(xtz);                     % sort in time
xtz = xtz(l);
zmag = zmag(l);
zval = zval(l);
tbin = tbin(l);
Z = [tbin'; xtz'; zmag'; zval'];

[newmatfile, newpath] = uiputfile(hodi  , 'Above -Save As'); %Syntax change Matlab Version 7, no window positioning on macs
fid = fopen(fullfile(newpath,newmatfile),'w');
fprintf(fid,'%3.0f %4.2f  %3.2f+  %6.4f\n',Z);

[tbin,zmag,zval] = find(ZBEL);
xtz = t0b + (tbin*days(ZG.bin_days));
zmag = minmg+(zmag-1)*magstep;
[xx,l] = sort(xtz);                     % sort in time
xtz = xtz(l);
zmag = zmag(l);
zval = zval(l);
tbin = tbin(l);
Z = [tbin'; xtz'; zmag'; zval'];

[newmatfile, newpath] = uiputfile(hodi, 'Below -Save As'); %Syntax change Matlab Version 7, no window positioning on macs
fid = fopen(fullfile(newpath,newmatfile),'w');
fprintf(fid,'%3.0f %4.2f  %3.2f-  %6.4f\n',Z);

disp('Output was saved in files \newline \newlinebelow.out and above.out,\newline \newlinePlease rename them if desired. ');

pause(5.0);
zmap_message_center();


