% This script file load a data set using fscanf
% The default reads Northern California Hypoellipse Format
%

report_this_filefun(mfilename('fullpath'));

disp('Now loading data into matlab ')

% Lets make sure the file is closed...
safe_fclose(fid);

% reset paramteres
a = []; b = []; n = 0;

% initial selection option
tmin   = 95.0001;
tmax   = 96.50900;
lonmin = -180.2;
lonmax = -142.90;
latmin = 52.80;
latmax = 70.2 ;
Mmin   = -5.0;
deperr = 1000.5;

% open the file and read 10000 lines at a time
fid = fopen(['/home/stefan/pub/akdata3.sum'],'r') ;
%fid = fopen(['/Seis/A/stefan/tmp.asc'],'r') ;

while  ferror(fid) == ''
    n = n+1;
    % vari name   yr mo da hr mi se lat   la  lon    lo de m1 #s ga di rms
    % variabl #   1  2  3  4  5  6  7      8  9      10 11 12 13 14 15 16
    % position    2  4  6  8  10 14 16 17  21 24 25  29 34 36 39 42 45 49
    l = fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5d%2d%3d%3d%3d%4d', ...
        [16 10000]) ;
    %if ferror(fid) ~= '' ; break; end

    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ; l(1,:);l(2,:);l(3,:);
        l(12,:)/10;l(11,:)/100;l(4,:);l(5,:); l(13,:);l(16,:)];
    b = b';
    l =  b(:,6) >= Mmin & b(:,1) >= lonmin & b(:,1) <= lonmax & ...
        b(:,2) >= latmin & b(:,2) <= latmax & b(:,3) <= tmax  & ...
        b(:,3) >= tmin & b(:,10) <= deperr;
    a = [a ; b(l,:)];

    disp([ num2str(n*10000) ' earthquakes scanned, ' num2str(length(a)) ' EQ found'])
    if max(b(:,3)) >  tmax ; break; end

end
ferror(fid)
fclose(fid);

if length(a(1,:))== 7
    a(:,3) = decyear(a(:,3:5));
elseif length(a(1,:))>=9       %if catalog includes hr and minutes
    a(:,3) = decyear(a(:,[3:5 ]));
end

disp('Now plotting summary plot')
org2 = a;
avosumplot
