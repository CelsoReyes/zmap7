report_this_filefun(mfilename('fullpath'));

questdlg('Please click in the map and drag a rectangle around the area to be included in the gridding', ...
    '3D grid selection', ...
    'OK','Cancel');
figure_w_normalized_uicontrolunits(map);

k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');	% button down detected
finalRect = rbbox; 			% return Figure units
point2 = get(gca,'CurrentPoint');	% button up detected
point1 = point1(1,1:2); 		% extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2); 		% calculate locations
offset = abs(point1-point2); 		% and dimensions

x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold on
axis manual
plot(x,y) % redraw in dataspace units

welcome('Message',' Thank you .... ')

%create a rectangular grid
xvect=[min(x):dx:max(x)];
yvect=[min(y):dy:max(y)];
zvect=[min(a(:,7)):dz:max(a(:,7))];
gx = xvect;
gy= yvect;
gz= zvect;
tmpgri=zeros((length(xvect)*length(yvect)),2);
n=0;
for i=1:length(xvect)
    for j=1:length(yvect)
        n=n+1;
        tmpgri(n,:)=[xvect(i) yvect(j)];
    end
end
%extract all gridpoints in chosen polygon
XI=tmpgri(:,1);
YI=tmpgri(:,2);

    ll = polygon_filter(x,y, XI, YI, 'inside');
%grid points in polygon
newgri=tmpgri(ll,:);

% plot the grid points
figure_w_normalized_uicontrolunits(map)
pl = plot(newgri(:,1),newgri(:,2),'+k','era','normal');
set(pl,'MarkerSize',8,'LineWidth',1)
drawnow
