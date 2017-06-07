%function plot_timeslice(a,RCREL,dx,dy,t,rctslice)
%
% Plot time slices off the results from calc_rcgrid.m
prompt  = {'Enter time step:'};
title   = 'Time slice plot input';
lines= 1;
def     = {'1'};
answer  = inputdlg(prompt,title,lines,def);
t = str2double(answer{1});

% get longitude / latitude
lon = newt2(:,1); lat = newt2(:,2);
% define grid
xmax = round(10*max(lon))/10+dx;
xmin = round(10*min(lon))/10-dx;
ymax = round(10*max(lat))/10+dy;
ymin = round(10*min(lat))/10-dy;


xx = xmin-dx/2:dx:xmax-dx/2;
yy = ymax+dy/2:-dy:ymin+dy/2; yy = yy';
%
% figure_w_normalized_uicontrolunits(rctfig)
% gcf=findobj('tag','rtslice')
% set(gcf,'Name','Rate change time slice')
% set(gca,'tag','axrctfig');

% axs=findobj('tag','axrctfig');
% axes(axs(1));
% opts = uimenu('Label','ZTools');
% uimenu(opts,'Label','Plot time slice', 'Callback','plot_timeslice')% % cc = colormap;
figure
colormap('jet')
cc = colormap;
for i = 25:40
    cc(i,:) = [1 1 1];
end
colormap(cc)
hold on;

pcolor(xx,yy,RCREL(:,:,t))
shading flat
axis equal
caxis([-4 4])
colorbar
hold off;
xlabel('Longitude')
ylabel('Latitude')
