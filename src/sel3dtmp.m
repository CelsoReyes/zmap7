

questdlg('Please selelct a polygon on the cross-section', ...
    '3D grid selection', ...
    'OK','Cancel');

figure_w_normalized_uicontrolunits(xsec_fig)

x = [];
y = [];
hold on
but=1;
while but==1 | but == 112
    [xi,yi,but] = ginput(1);
    mark1 =    plot(xi,yi,'ob','era','back'); % doesn't matter what erase mode is
    % used so long as its not NORMAL
    set(mark1,'MarkerSize',8,'LineWidth',1.0)
    n = n + 1;
    % mark2 =     text(xi,yi,[' ' int2str(n)],'era','normal');
    % set(mark2,'FontSize',15,'FontWeight','bold')

    x = [x; xi];
    y = [y; yi];

end  % while but
welcome('Message',' Thank you .... ')

x = [x ; x(1)];
y = [y ; y(1)];     %  closes polygon

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

m = length(x)-1;      %  number of coordinates of polygon
l = 1:length(XI);
l = (l*0)';
ll = l;               %  Algorithm to select points inside a closed
%  polygon based on Analytic Geometry    R.Z. 4/94
for i = 1:m;

    l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
        (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
        ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
        (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);

    if i ~= 1
        ll(l) = 1 - ll(l);
    else
        ll = l;
    end;         % if i

end;         %
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
