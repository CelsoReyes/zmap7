%  M file that starts a Mosaic Browser displaying
%  the HTML version of the ZMAP Users Guide
%
%  Stefan Wiemer   6/96

%    !netscape /Seis/A/stefan/zmapwww/title.htm  &

report_this_filefun(mfilename('fullpath'));
disp('Attempting to open browser - please be patient...');
disp('If the browser does not open, please open the browser first and try again, or open the file ./zmapwww/title.hmt manually');
do = [ 'web ' hodi '/zmapwww/title.htm ;' ];
err=['errordlg('' Error while opening, please open the browser first and try again or open the file ./zmapwww/title.hmt manually'');'];
eval(do,err)

