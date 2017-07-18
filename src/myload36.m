% This script file load a data set using fscanf
% The default reads Northern California Hypoellipse Format
%

report_this_filefun(mfilename('fullpath'));
disp('Please make sure the has 36 characters for each line')
disp('and all blanks have been substituted by zeros')

% Lets make sure the file is closed...
safe_fclose(fid);
% reset paramteres
replaceMainCatalog([]); b = []; n = 0;

if inda == 1
    % initial selection option
    tmin   = 10.0001;
    tmax   = 98.000;
    lonmin = -180.0;
    lonmax =  180.0;
    latmin =  -90.00;
    latmax =  90.0 ;
    Mmin   = -4.0;
    Mmax   = 10.;
    mindep = -10;
    maxdep = 700;

    % call the pre-selection window
    call = 'myload36';
    presel
    return
end

% open the file and read 10000 lines at a time
[file1,path1] = uigetfile([ '*.dat'],' Earthquake Datafile');
if length(file1) >1
    fid = fopen([path1 file1],'r') ;;
else
    disp('Data import canceled'); return
end

while  ferror(fid) == ''
    n = n+1;
    % vari name   yr mo da hr mi se lat   la  lon    lo de ma1
    % variabl #   1  2  3  4  5  6  7      8  9      10 11 12
    % position    2  4  6  8  10 14 16 17  21 24 25  29 34 36
    l = fscanf(fid,'%2d%2d%2d%2d%2d%4d%2d%*1c%4d%3d%*1c%4d%5f%2d',...
        [12 10000]) ;
    %if ferror(fid) ~= '' ; break; end

    b = [ -l(9,:)-l(10,:)/6000 ; l(7,:)+l(8,:)/6000 ; l(1,:);l(2,:);l(3,:);
        l(12,:)/10;l(11,:)/100;l(4,:);l(5,:)];
    b = b';
    l =  b.Magnitude >= Mmin & b(:,1) >= lonmin & b(:,1) <= lonmax & ...
        b(:,2) >= latmin & b(:,2) <= latmax & b.Date <= tmax  & ...
        b.Date >= tmin  ;
    a = [a ; b(l,:)];

    disp([ num2str(n*10000) ' earthquakes scanned, ' num2str(ZG.a.Count) ' EQ found'])
    if max(b.Date) >  tmax ; break; end

end
ferror(fid)
fclose(fid);

% Convert the third column into time in decimals
if length(a(1,:))== 7
    ZG.a.Date = decyear(a(:,3:5));
elseif length(a(1,:))>=9       %if catalog includes hr and minutes
    ZG.a.Date = decyear(a(:,[3:5 8 9]));
end

% save the data
[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Save Earthquake Datafile');
sapa2 = ['save ' path1 file1 ' a'];
if length(file1) > 1; eval(sapa2);end

dep1 = 0.3*(max(ZG.a.Depth)-min(ZG.a.Depth))+min(ZG.a.Depth);
dep2 = 0.6*(max(ZG.a.Depth)-min(ZG.a.Depth))+min(ZG.a.Depth);
dep3 = max(ZG.a.Depth);

stri1 = [file1];
minma2 = minma;
maxma2 = maxma;
minde = min(ZG.a.Depth);
maxde = max(ZG.a.Depth);
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

% call the map window
update(mainmap())

