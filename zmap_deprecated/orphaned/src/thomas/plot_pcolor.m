function plot_pcolor(vResults,j)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% example: plot_pcolor(vResults,85)
%
%  vResults : result matrix
%  i : position in result matrix
%  j : no of simulation to plot
%
%
figure;
set(gca,'LineWidth',2);
set(gca,'FontSize',14);
set(get(gca,'XLabel'),'FontSize',16);
set(get(gca,'YLabel'),'FontSize',16);

string=sprintf('load mCatBkgr%03.0f.mat',j);eval(string);
mBkgr=mCatalog;
string=sprintf('load vMain%03.0f.mat',j);eval(string);
vMain=logical(vMain);
string=sprintf('load mCatETAS%03.0f.mat',j);eval(string);
mETAS=mCatalog;
string=sprintf('load vDeclus%03.0f.mat',j);eval(string);
vDeclus=logical(vDeclus);

vTmp = ones(length(vResults(1).vX) * length(vResults(1).vY), 1) * nan;

for i=1:3
vTmp(vResults(i).vUsedNodes) = vResults(i).mValueGrid(:,j);
mPlotValues = reshape(vTmp, length(vResults(i).vY), length(vResults(i).vX));

mX=repmat(vResults(i).vX,length(vResults(i).vY),1);
mY=repmat(vResults(i).vY',1,length(vResults(i).vX));
% plot pcolor
subplot(3,1,i);
pcolor(mX,mY,mPlotValues);
shading interp;
xlabel('Lon');ylabel('Lat');

set(gca,'CLim',[-4 4]);
if i==3
    colorbar('location','southoutside')
end

switch i
    case 1
        hold on;plot(mETAS(vMain,1),mETAS(vMain,2),'k.');
    case 2
        hold on;plot(mETAS(vDeclus,1),mETAS(vDeclus,2),'k.');
    case 3
        hold on;plot(mETAS(vDeclus,1),mETAS(vDeclus,2),'k.');
        hold on;plot(mETAS(~vDeclus,1),mETAS(~vDeclus,2),'rx');
end
end





