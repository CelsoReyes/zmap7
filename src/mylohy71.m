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
a = []; b = [];
n2 = 0;

% open the file and read 100 lines at a time
[file1,path1] = uigetfile([ '*.sum'],' Earthquake Datafile');
fid = fopen([path1 file1],'r') ;;

while  ferror(fid) == ''
    %                                              lon    Xm p&s   dis rms   ler   ier  md    ser    herver
    % variabl #   1  2  3  4  5  6  7     8  9      10 11 12 13     14 15     16     17 18     19     20 21
    % position    2  4  6 7    8 10  11  15 16  17 21 24 25  29 34 36 39 42  45  49 54 58 63  67 69 72  76 80  84 88
    l =fscanf(fid,'%2d%2d%2d%*1c%2d%2d%*1c%5d%2d%*1c%4d%3d%*1c%4d%5d%2d%3d%*3c%3d%4d%*5c%4d%*5c%4d%2d%*3c%4d%*4c',[21 100]) ;
    l =fscanf(fid,'%2d%2d%2d%*1c%2d%2d%*1c%2d%*1c%2d',[7 100]) ;


    n2 = n2 +  length(l(1,:));

    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ;...
        l(1,:);l(2,:);l(3,:);l(12,:)/10;l(11,:)/100;l(4,:);...
        l(5,:);l(13,:); l(14,:);l(15,:);l(16,:);l(17,:);l(18,:);l(19,:); l(20,:);l(21,:)];
    % 1   2    3  4  5  6   7  8   9   10      11  12    13    14   15    16     17  18
    % lat long yr mo da mag dep hr min P p&s   dis rms   ler   ier  md    ser    her ver
    b = b';
    a = [a ; b(:,:)];
    disp([ num2str(n2,10) ' earthquakes scanned, ' num2str(length(a)) ' EQ found'])
    %  if max(b(:,3)) >  tmax ; break; end
end
ferror(fid)
fclose(fid);

dep1 = 0.3*(max(a.Depth)-min(a.Depth))+min(a.Depth);
dep2 = 0.6*(max(a.Depth)-min(a.Depth))+min(a.Depth);
dep3 = max(a.Depth);

stri1 = [file1];
tim1 = minti;
tim2 = maxti;
minma2 = minma;
maxma2 = maxma;
minde = min(a.Depth);
maxde = max(a.Depth);
rad = 50.;
ic = 0;
ya0 = 0.;
xa0 = 0.;
iwl3 = 1.;
step = 3;
t1p(1) = 80.;
t2p(1) = 85.;
t3p(1) = 90.;
t4p(1) = 93.;
tresh = 10;

% save the catalog
save newcat.mat a

