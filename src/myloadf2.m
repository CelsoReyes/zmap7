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
tmin = 1960.0001;
tmax = 2005;
lonmin = -180.0;
lonmax =  180.0;
latmin = -90.0;
latmax = 90.0 ;
Mmin = 0.0
deperr = 1000.5;

a = []; b = [];
n2 = 0;

% open the file and read 2000 lines at a time
[file1,path1] = uigetfile([ '*.asc'],' Earthquake Datafile');
%fclose(fid);
fid = fopen([path1 file1],'r') ;;

while  ferror(fid) == ''
    % variabl #   1  2  3  4  5     6  7     8   9     10 11      12     13 14     15
    % position    2  4  6  8 10 11 17  20 21 26 30  31 36 43   81 84  85 87 91  93 97
    l =fscanf(fid,'%4d%2d%2d%*1c%2d%2d%*6c%3d%*1c%5d%4d%*1c%5d%7d%*38c%3d%*1c%2d%4d%*2c%3d',[14   2000]);

    n2 = n2 +  length(l(1,:));

    % make the catalog in the correct format
    % lon lat yr mo da mag dep hr min dip_direction dip rake misfit
    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ;...
        l(1,:);l(2,:);l(3,:);l(12,:)/10;l(11,:)/100;l(4,:);...
        l(5,:);l(13,:); l(14,:);l(15,:);l(16,:);l(17,:);l(18,:)];
    b = b';
    % l =  b(:,6) >= Mmin & b(:,1) >= lonmin & b(:,1) <= lonmax & ...
    % b(:,2) >= latmin & b(:,2) <= latmax & b(:,3) <= tmax  & ...
    % b(:,3) >= tmin & b(:,10) <= deperr;
    a = [a ; b];
    disp([ num2str(n2,10) ' earthquakes scanned, ' num2str(length(a)) ' EQ found'])
    %  if max(b(:,3)) >  tmax ; break; end
end
ferror(fid)
fclose(fid);

% save the catalog
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

save newcat.mat a

