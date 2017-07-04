% This is selgp3dB_x


figure;

plot(Da(:,1),-Da(:,7),'.k','MarkerSize',1);
xlabel('Distance in [km]')
ylabel('Depth in [km]')
axis image
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
    'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
    'Box','on')

ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);

zmap_message_center.set_info('Message',' Thank you .... ')

plos2 = plot(x,y,'b-','era','xor', 'Color', 'r');        % plot outline
sum3 = 0.;
pause(0.3)

%create a rectangular grid
xvect=[min(x):dx:max(x)];
yvect=[min(y):dy:max(y)];
zvect=[z2:dz:z1];

gx = xvect;gy = yvect;
tmpgri=zeros((length(xvect)*length(yvect)),2);
tmpgri2=zeros((length(xvect)*length(zvect)),2);

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

newgri=tmpgri(ll,:);

n2 = repmat(newgri,length(zvect),1);
k = repmat(zvect',length(newgri),1);
t3 = [n2(:,1)  k n2(:,2) ];

%n3 = repmat(tmpgri2,length(yvect),1);
%k = repmat((1:1:length(yvect)),length(tmpgri),1);
%k = reshape(k,length(k)*length(yvect),1);
%t4 = [t3 n3 k];

%l = t4(:,4) == 1;
%t5 = t4(l,:);



% Plot all grid points
plot(newgri(:,1),newgri(:,2),'+k','era','back')

figure
plot3(Da(:,1),Da(:,2),-Da(:,7),'.k','MarkerSize',1)
hold on
box on ; %axis image

plot3(t3(:,1),t3(:,2),t3(:,3),'+')


if length(xvect) < 2  ||  length(yvect) < 2
    errordlg('Selection too small! (not a matrix)');
    return
end

itotal = length(newgri(:,1));
if length(gx) < 4  ||  length(gy) < 4
    errordlg('Selection too small! ');
    return
end
