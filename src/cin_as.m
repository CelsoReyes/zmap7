% This script file calculates  a z value at each grid point
% using the as function. The z-map is plotted ready for getframe

% set up matrices
%

report_this_filefun(mfilename('fullpath'));

var1 = zeros(1,ncu);
var2 = zeros(1,ncu);
as = zeros(1,ncu);

%calculate as
%
mean1 = mean(cumuall(1:it,:));
mean2 = mean(cumuall(it:len,:));

for i = 1:ncu
    var1(i) = cov(cumuall(1:it,i));
end     % for i

for i = 1:ncu
    var2(i) = cov(cumuall(it:len,i));
end     % for i

as = (mean1 - mean2)./(sqrt(var1/it+var2/(len-it)));
re3 = reshape(as,length(gy),length(gx));



%Plot the z-map
%
% define size of the plot etc.
%
figure_w_normalized_uicontrolunits(tmp)

clf reset
rect = [0.10 0.30 0.55 0.50 ];
rect1 = rect;


% plot image
%
orient landscape
axes('position',rect)
pco1 = pcolor(gx,gy,re3);
shading interp
caxis([minc maxc]);
colormap(jet)
hold on

% plot overlay
%
overlay

tx2 = text(0.07,0.85 ,['AS(t); ti=' num2str(it*par1/365+t0b)  ] ,...
    'Units','Norm','FontSize',ZmapGlobal.Data.fontsz.l,'Color','k','FontWeight','bold');

has = gca;


