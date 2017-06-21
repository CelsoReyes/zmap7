% this script produces aftershock catalogues containing relative seismic
% quiescences around a specified point in a specified time interval
%
% Samuel Neukomm
% last update: 27.02.04

[filename,pathname] = uigetfile('*.mat','Load earthquake sequence');
do = ['load ' pathname filename]; eval(do)

[m_main, main] = max(a.Magnitude);
if size(a,2) == 9
    date_matlab = datenum(a.Date.Year,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,zeros(length(a),1));
else
    date_matlab = datenum(a.Date.Year,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,a(:,10));
end
date_main = date_matlab(main);
t_aftershock = date_matlab-date_main;

% input dialog strings
xmin = round(10*min(a.Longitude))/10; xmax = round(10*max(a.Longitude))/10;
ymin = round(10*min(a.Latitude))/10; ymax = round(10*max(a.Latitude))/10;
zmin = round(10*min(a.Depth))/10; zmax = round(10*max(a.Depth))/10;
xstring = ['x = (Longitude: ' num2str(xmin) ' - ' num2str(xmax) ' deg)'];
ystring = ['y = (Latitude: ' num2str(ymin) ' - ' num2str(ymax) ' deg)'];
zstring = ['z = (Depth: ' num2str(zmin) ' - ' num2str(zmax) ' km)'];
rstring = ['r = (Radius: ' num2str(0.05) ' - ' num2str(min([xmax-xmin;ymax-ymin])/2) ' deg)'];

% get parameters
prompt = {xstring,ystring,zstring,rstring,'start time = [days]','end time = [days]','decrease rate = [%]'};
def = {num2str(round(10*a(main,1))/10),num2str(round(10*a(main,2))/10),num2str(round(10*a(main,7))/10),'0.1','0',num2str(floor(max(t_aftershock))),'50'};
answ = inputdlg(prompt,'get central point / radius / time interval / decrease rate',1,def);
x = str2double(answ{1});
y = str2double(answ{2});
z = str2double(answ{3});
r = str2double(answ{4});
tstart = str2double(answ{5});
tend = str2double(answ{6});
percent = str2double(answ{7});

% get quakes inside/outside chosen area
l = ((a.Longitude-x).^2+(a.Latitude-y).^2+(km2deg(a.Depth-z)).^2).^0.5 < r;
outside = a(l==0,:);
tas_outside = t_aftershock(l==0);
inside = a.subset(l);
t_aftershock = t_aftershock(l);

% cut 'inside'
l = t_aftershock > tstart & t_aftershock < tend;
inside_indt = inside(l,:);
tas_inside_indt = t_aftershock(l);
inside_outdt = inside(l==0,:);
tas_inside_outdt = t_aftershock(l==0);
n = sum(l);
isitluck = randperm(n);
newinside_indt = []; tas_newinside_indt = [];
for i = 1:round(n*(1-percent/100))
    newinside_indt(i,:) = inside_indt(isitluck(i),:);
    tas_newinside_indt(i,:) = tas_inside_indt(isitluck(i),:);
end
cutout = n-round(n*(1-percent/100));

% compile, sort and save new catalogue
tas = [tas_outside; tas_inside_outdt; tas_newinside_indt];
a = [outside; inside_outdt; newinside_indt];

[tas, pos] = sort(tas);
a = a.subset(pos);

[filename, pathname] = uiputfile('*.mat', 'Save new catalogue as');
try
    save(fullfile(pathname, filename),'a','x','y','z','r','tstart','tend','percent','cutout');
catch
    disp('failed to display'); %complain
end
