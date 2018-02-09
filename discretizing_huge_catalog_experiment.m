% lump experiments in visualizing huge amounts of data at once by looking at the cumulative magnitude
% in each region
c=ZG.primeCatalog;%.subset(1:100);
ax=findobj('Tag','mainmap_ax');
ax=ax(1)

ax.Units='pixels';
xBins=ax.Position(3); xBins=50;
yBins=ax.Position(4); yBins=50;zBins=50;
xedges=linspace(ax.XLim(1),ax.XLim(2),xBins+1);
yedges=linspace(ax.YLim(1),ax.YLim(2),yBins+1);
zedges=linspace(ax.ZLim(1),ax.ZLim(2),zBins+1);
[~,~,moments]=calc_moment(c.Magnitude);
[myX]=discretize(c.Longitude,xedges);
[myY]=discretize(c.Latitude,yedges);
[myZ]=discretize(c.Depth,zedges);
pixelCumMoment=zeros(xBins, yBins);
pixel3CumMoment=zeros(xBins, yBins,zBins);
%%
for i=1:c.Count
    pixelCumMoment(myX(i),myY(i))=pixelCumMoment(myX(i),myY(i))+ moments(i);
    pixel3CumMoment(myX(i),myY(i),myZ(i))=pixel3CumMoment(myX(i),myY(i),myZ(i))+ moments(i);
end
[X,Y]=meshgrid(xedges(1:end-1),yedges(1:end-1));
f=figure(2);clf
ax2=subplot(2,1,1);
clear xyc;
xyc=[X(:) Y(:) pixelCumMoment(:)];
xyc(pixelCumMoment==0,:)=[];
%pixelCumMoment(pixelCumMoment==0)=nan;
%pcolor(ax2,X,Y,log10(pixelCumMoment)');
cc=log10(xyc(:,3));
sx=xyc(:,1); sy=xyc(:,2);
scatter(sx,sy,[],cc,'.');
xlabel('x')
ylabel('y')
%shading flat
%%
subplot(2,1,2);
[X,Y,Z]=meshgrid(xedges(1:end-1),yedges(1:end-1),zedges(1:end-1));
xyzc=[X(:),Y(:),Z(:),pixel3CumMoment(:)];
clear X Y Z pixel3CumMoment;
xyzc(xyzc(:,4)==0,:)=[];
scatter3(xyzc(:,1),xyzc(:,2),xyzc(:,3),[],log10(xyzc(:,4)),'.')
xlabel('x')
ylabel('y')
zlabel('z')
%scatter3(X(:),Y(:),Z(:),[],pixel3CumMoment(:));



