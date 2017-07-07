
% Plot time slices off the results from calc_rc.m
string = ['Enter time step: (1-' num2str(length(time)) ')'];
prompt = {string};
titel = 'Time slice plot';
lines = 1;
def = {'1'};
answer = inputdlg(prompt,titel,lines,def);
t = str2double(answer{1});

% get longitude / latitude
lon = a.Longitude; lat = a.Latitude;
% define grid
xmax = round(10*max(lon))/10+dx;
xmin = round(10*min(lon))/10-dx;
ymax = round(10*max(lat))/10+dy;
ymin = round(10*min(lat))/10-dy;


xx = xmin-dx/2:dx:xmax-dx/2;
yy = ymax+dy/2:-dy:ymin+dy/2; yy = yy';


figure
colormap('jet')
cc = colormap;
for i = 25:40
    cc(i,:) = [1 1 1];
end
cc = flipud(cc);
colormap(cc)
hold on;

pcolor(xx,yy,RCREL(:,:,t))
shading interp
axis equal
caxis([-4 4])
colorbar
xlabel('Longitude')
ylabel('Latitude')
str33 = ['Optimum parameters: learning period = ' num2str(time(t)) ' days'];
title(str33)

plot(lon,lat,'k.')
