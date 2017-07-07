

x = [-117.6 -115.6 -115.6 -117.6 -117.6]
y = [35.5 35.5 33.5 33.5 35.5]

%create a rectangular grid
xvect=[min(x):dx:max(x)];
yvect=[min(y):dy:max(y)];
gx = xvect;
gy= yvect;
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
