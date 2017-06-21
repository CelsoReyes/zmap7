

questdlg('Please selelct a polygon on the cross-section', ...
    '3D grid selection', ...
    'OK','Cancel');

figure_w_normalized_uicontrolunits(xsec_fig)

ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);
zmap_message_center.set_info('Message',' Thank you .... ')

plos2 = plot(x,y,'b-','era','xor');        % plot outline
sum3 = 0.;
pause(0.3)

%create a rectangular grid
xvect=[min(x):dx:max(x)];
zvect=[min(y):dy:max(y)];
yvect=[z2:dz:z1];
gx = xvect;
gy= yvect;
gz= zvect;
tmpgri=zeros((length(xvect)*length(zvect)),2);
tmpgri2=zeros((length(xvect)*length(zvect)),2);

n=0;
for i=1:length(xvect)
    for j=1:length(zvect)
        n=n+1;
        tmpgri(n,:)=[xvect(i) zvect(j)];
        tmpgri2(n,:) = [i j ];
    end
end

%extract all gridpoints in chosen polygon
XI=tmpgri(:,1);
YI=tmpgri(:,2);

    ll = polygon_filter(x,y, XI, YI, 'inside');
%grid points in polygon
newgri=tmpgri(ll,:);

n2 = repmat(tmpgri,length(yvect),1);
k = repmat(yvect,length(tmpgri),1);
k = reshape(k,length(k)*length(yvect),1);
k2 = repmat(ll,length(yvect),1);
t3 = [n2 k k2];

n3 = repmat(tmpgri2,length(yvect),1);
k = repmat((1:1:length(yvect)),length(tmpgri),1);
k = reshape(k,length(k)*length(yvect),1);
t4 = [t3 n3 k];

l = t4(:,4) == 1;
t5 = t4(l,:);


% plot the grid points
figure_w_normalized_uicontrolunits(xsec_fig)
pl = plot(newgri(:,1),newgri(:,2),'+k','era','normal');
set(pl,'MarkerSize',8,'LineWidth',1)
drawnow
