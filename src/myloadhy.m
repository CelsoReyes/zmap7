% This file load eq catalogs in hypoellipes format. Since the formated reading
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
tmin = 60.0001;
tmax = 97.00900;
lonmin = -180.0;
lonmax =  180.0;
latmin = -90.0;
latmax = 90.0 ;
Mmin = 3.1
deperr = 1000.5;

a = []; b = [];
n2 = 0;

% open the file and read 2000 lines at a time
[file1,path1] = uigetfile([ '*.mat'],' Earthquake Datafile');
fid = fopen([path1 file1],'r') ;;

while  ferror(fid) == ''
    l =fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d%*31c%2d%*15c%4d',[14 2000]) ;
    n2 = n2 +  length(l(1,:));

    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ;...
        l(1,:);l(2,:);l(3,:);l(13,:)/10;l(11,:)/100;l(4,:);...
        l(5,:); l(14,:)/100;l(12,:)/10];
    b = b';
    l =  b(:,6) >= Mmin & b(:,1) >= lonmin & b(:,1) <= lonmax & ...
        b(:,2) >= latmin & b(:,2) <= latmax & b(:,3) <= tmax  & ...
        b(:,3) >= tmin & b(:,10) <= deperr;
    a = [a ; b(l,:)];
    disp([ num2str(n2) ' earthquakes scanned, ' num2str(length(a)) ' EQ found'])
    if max(b(:,3)) >  tmax ; break; end
end
ferror(fid)
fclose(fid);

dep1 = 0.3*(max(a(:,7))-min(a(:,7)))+min(a(:,7));
dep2 = 0.6*(max(a(:,7))-min(a(:,7)))+min(a(:,7));
dep3 = max(a(:,7));

stri1 = [file1];
tim1 = minti;
tim2 = maxti;
minma2 = minma;
maxma2 = maxma;
minde = min(a(:,7));
maxde = max(a(:,7));
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

