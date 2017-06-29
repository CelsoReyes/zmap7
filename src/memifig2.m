report_this_filefun(mfilename('fullpath'));


%input window
%
%default parameters

%make a color map
% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Misfit-Map 2',1);
newlapWindowFlag=~existFlag;
% Set up the Seismicity Map window Enviroment
%
if newlapWindowFlag
    mifmap = figure_w_normalized_uicontrolunits( ...
        'Name','Misfit-Map 2',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ 600 400 500 350]);
    % make menu bar
    matdraw
    

    hold on
end

[existFlag,mifmap]=figure_exists('Misfit-Map 2',1);
figure_w_normalized_uicontrolunits(mifmap)

delete(gca);delete(gca); delete(gca);delete(gca);
delete(gca);delete(gca); delete(gca);delete(gca);

set(gca,'visible','off','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

%minimum and maximum of normlap2 for automatic scaling
maxc = max(normlap2);
minc = min(normlap2);

%construct a matrix for the color plot
normlap1=ones(length(tmpgri(:,1)),1);
normlap2=ones(length(tmpgri(:,1)),1)*nan;
normlap3=ones(length(tmpgri(:,1)),1)*nan;
normlap1(ll)=me1;
normlap2(ll)=normlap1(ll);
normlap1(ll)=va1;
normlap3(ll)=normlap1(ll);

normlap2=reshape(normlap2,length(yvect),length(xvect));
normlap3=reshape(normlap3,length(yvect),length(xvect));

%plot color image
orient tall
gx = xvect; gy = yvect;

hold on
pco1 = pcolor(xvect,yvect,normlap2);
shading interp
j = jet(10); j = j(10:-1:1,:);
colormap(j)
%brighten(0.8)
%caxis([4.  10])
%axis([ s2 s1 s4 s3])
axis([ min(gx) max(gx) min(gy) max(gy)])
axis image

hold on
h5 = colorbar('vert');
set(h5,'Pos',[0.82 0.46 0.02 0.20],...
    'FontSize',12)



if exist('maex', 'var')
    hold on
    pl = plot(maex,-maey,'*k');
    set(pl,'MarkerSize',6,'LineWidth',2)
end

overlay
title(['Mean of the Misfit (' num2str(sig) '/' num2str(az)  '/' num2str(plu) '/' num2str(phi) '/' num2str(R) ')'] ,'FontWeight','bold','FontSize',fontsz.s)
xlabel('Longitude in [deg]','FontWeight','bold','FontSize',fontsz.s)
ylabel('latitude in [deg]','FontWeight','bold','FontSize',fontsz.s)

set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')


