
% messtext=...
%  ['To select a polygon for a grid.       '
%   'Please use the LEFT mouse button of   '
%   'or the cursor to the select the poly- '
%   'gon. Use the RIGTH mouse button for   '
%   'the final point.                      '
%   'Mac Users: Use the keyboard "p" more  '
%   'point to select, "l" last point.      '
%   '                                      '];
% welcome('Select Polygon for a grid',messtext);
%
% figure_w_normalized_uicontrolunits(map);
% x = [];
% y = [];
% hold on
% but=1;
% while but==1 | but == 112
%     [xi,yi,but] = ginput(1);
% mark1 =    plot(xi,yi,'+k','erase','back'); % doesn't matter what erase mode is
%                                          % used so long as its not NORMAL
% set(mark1,'MarkerSize',6,'LineWidth',1.0)
%    n = n + 1;
% % mark2 =     text(xi,yi,[' ' int2str(n)],'era','normal');
% % set(mark2,'FontSize',15,'FontWeight','bold')
%
%    x = [x; xi];
%    y = [y; yi];
%
% end
% welcome('Message',' Thank you .... ')
%
% x = [x ; x(1)];
% y = [y ; y(1)];     %  closes polygon
% figure_w_normalized_uicontrolunits(map)
%
% plos2 = plot(x,y,'b-');        % plot outline
% sum3 = 0.;
% pause(0.3)

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

% plot the grid points
figure_w_normalized_uicontrolunits(map)
pl = plot(newgri(:,1),newgri(:,2),'+k','era','normal');
set(pl,'MarkerSize',8,'LineWidth',1)
drawnow
