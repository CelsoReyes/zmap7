% This file load eq catalogs in hypoellipes format. Since the formated readin-
% is fast, this is the best way to load data for
% large catalogs.
% Earthquakes within a rectengular box (latmin latmax lonmin lonmax)
% a time window and a magnitude threshold can be selected.
% Note: lat/Lon are assumed to be in minutes in the original catalog
%
% last modified: March 96   stefan wiemer

report_this_filefun(mfilename('fullpath'));

%  close the file in case it is still open
safe_fclose(fid);


% selection criteria
tmin = 80.0001;
tmax = 97.00900;
lonmin = -122.0;
lonmax = -119.0;
latmin = 34.0;
latmax = 37.5 ;
Mmin = -1.0
deperr = 1000000.5;

a = []; b = [];
n2 = 0;

% open the file and read 2000 lines at a time
[file1,path1] = uigetfile([ '*.sum'],' Earthquake Datafile');
fid = fopen([path1 file1],'r') ;;

while  ferror(fid) == ''
    %  l =fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d%*31c%2d%*15c%4d',[14 20000]) ;
    % variabl #   1  2  3  4  5  6  7     8  9      10 11 12    13    14
    % position    2  4  6  8 10 14 16  17 21 24 25  29 34 36 45  49 54  58
    %  l =fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d%*9c%4d%*5c%4d',[14 2000]) ;
    %                                              lon    Xm p&s   dis rms   ler   ier  md    ser    herver
    % variabl #   1  2  3  4  5  6  7     8  9      10 11 12 13     14 15     16     17 18     19     20 21
    % position    2  4  6  8 10 14 16  17 21 24 25  29 34 36 39 42  45  49 54 58 63  67 69 72  76 80  84 88
    l =fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5d%2d%3d%*3c%3d%4d%*5c%4d%*5c%4d%2d%*3c%4d%*4c%4d%4d',[21 10000]) ;
    %l  = fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d%*31c%2d%*15c%4d',[14 10000]) ;

    n2 = n2 +  length(l(1,:));

    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ;...
        l(1,:);l(2,:);l(3,:);l(12,:)/10;l(11,:)/100;l(4,:);...
        l(5,:);l(13,:); l(14,:);l(15,:);l(16,:);l(17,:);l(18,:);l(19,:); l(20,:);l(21,:)];
    % 1   2    3  4  5  6   7  8   9   10      11  12    13    14   15    16     17  18
    % lat long yr mo da mag dep hr min P p&s   dis rms   ler   ier  md    ser    her ver
    b = b';
    l =  b(:,6) >= Mmin & b(:,1) >= lonmin & b(:,1) <= lonmax & ...
        b(:,2) >= latmin & b(:,2) <= latmax & b(:,3) <= tmax  & ...
        b(:,3) >= tmin & b(:,10) <= deperr;
    a = [a ; b(l,:)];
    disp([ num2str(n2,10) ' earthquakes scanned, ' num2str(length(a)) ' EQ found'])
    %  if max(b(:,3)) >  tmax ; break; end
end
ferror(fid)
fclose(fid);

% save the catalog
save newcat.mat a

