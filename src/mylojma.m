% This script file load a data set using fscanf
% The default reads Northern California Hypoellipse Format
%

report_this_filefun(mfilename('fullpath'));
disp('Plase make sure that  all blanks have been substituted by zeros')

% Lets make sure the file is closed...
safe_fclose(fid);

% reset paramteres
a = []; b = []; n = 0;

if inda == 1
    % initial selection option
    tmin   = 0.0001;
    tmax   = 2005.000;
    lonmin = -180.0;
    lonmax =  180.0;
    latmin =  -90.00;
    latmax =  90.0 ;
    Mmin   = -4.0;
    Mmax   = 10.;
    mindep = -10;
    maxdep = 700;

    % call the pre-selection window
    call = 'mylojma'; % this callback is needed so presel know where to return to
    presel
    return
end

% open the file and read 10000 lines at a time
[file1,path1] = uigetfile([ '*'],' Earthquake Datafile - JMA Format');
if length(file1) >1
    fid = fopen([path1 file1],'r') ;;
else
    disp('Data import canceled'); return
end

while  ferror(fid) == ''
    n = n+1;
    % vari name   yr mo da hr mi se lat   la  lon    lo de ma1     ma he   hz
    % variabl #   1  2  3  4  5  6  7      8  9      10 11 12      13 14   15
    % position    2  4  6  8  10 14 16 17  21 24 25  29 34 36 67   69 84   88
    l = fscanf(fid,'%*1c%4d%2d%2d%2d%2d%4d%4d%3d%4d%4d%4d%4d%4d%5d%3d%2d%*1c%2d%*2c%1d%1d%*36c',...
        [19 1000000]) ;
    %if ferror(fid) ~= '' ; break; end

    b = [l(11,:)+l(12,:)/6000 ; l(8,:)+l(9,:)/6000 ; l(1,:) ; l(2,:);l(3,:);
        l(16,:)/10;l(14,:)/100;l(4,:);l(5,:) ; l(17,:) ];
    b = b';
    l =  b(:,6) >= Mmin & b(:,1) >= lonmin & b(:,1) <= lonmax & ...
        b(:,2) >= latmin & b(:,2) <= latmax & b(:,3) <= tmax  & ...
        b(:,3) >= tmin  ;
    a = [a ; b(l,:)];

    disp([ num2str(n*100) ' earthquakes scanned, ' num2str(length(a)) ' EQ found'])
    if max(b(:,3)) >  tmax ; break; end
    %ferror(fid)

end
ferror(fid)
fclose(fid);

% Convert the third column into time in decimals
if length(a(1,:))== 7
    a.Date = decyear(a(:,3:5));
elseif length(a(1,:))>=9       %if catalog includes hr and minutes
    a.Date = decyear(a(:,[3:5 8 9]));
end

% save the data
[file1,path1] = uiputfile(fullfile(hodi, 'eq_data', '*.mat'), 'Save Earthquake Datafile');
sapa2 = ['save ' path1 file1 ' a'];
if length(file1) > 1; eval(sapa2);end

minmag = max(a.Magnitude) -0.2;
dep1 = 0.3*max(a.Depth);
dep2 = 0.6*max(a.Depth);
dep3 = max(a.Depth);
minti = min(a.Date);
maxti  = max(a.Date);
minma = min(a.Magnitude);
maxma = max(a.Magnitude);
mindep = min(a.Depth);
maxdep = max(a.Depth);


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

% call the map window
mainmap_overview()

