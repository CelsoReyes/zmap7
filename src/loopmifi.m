%  domisfit
% This file calculates the misfit for each EQ to a given
% stress tensor orientation. The actual calculation is done
% using a call to a fortran program.
%
% Stefan Wiemer 07/95

global mi mif1 mif2 term  hndl3 a newcat2 fontsz mi2
global tmp cumu2
report_this_filefun(mfilename('fullpath'));
think
az0 = [];

tmp = a(:,10:14);
save /home/stefan/ZMAP/tmpin.dat tmp -ascii
infi = '/home/stefan/ZMAP/tmpin.dat';
outfi = '/home/stefan/ZMAP/tmpout.dat';

for az= 35:2:55
    disp(az)
    fid = fopen('/home/stefan/ZMAP/inmifi.dat','w');

    fprintf(fid,'%s\n',infi);
    fprintf(fid,'%s\n',outfi);
    fprintf(fid,'%2.0f\n',sig);
    fprintf(fid,'%6.2f\n',plu);
    fprintf(fid,'%6.2f\n',az);
    fprintf(fid,'%6.2f\n',phi);
    fprintf(fid,'%3.2f\n',R);
    fprintf(fid,'%6.2f\n',length(a(:,6)));

    fclose(fid);
    comm = ['!/bin/rm ' outfi];
    eval(comm)

    comm = '!/home/lu/stress/bin/fmsietab_matlab < /home/stefan/ZMAP/inmifi.dat ';
    eval(comm)

    load /home/stefan/ZMAP/tmpout.dat
    mi = tmpout;
    az0 = [az0 ; az mean(mi(:,2))];
end

return
%{
    Nothing after this is calculated because of the return above, so I'm commenting it out -CGR

me1=zeros(length(newgri(:,1)),1);
va1=zeros(length(newgri(:,1)),1);
mic = mi(inde,:);

for i= 1:length(me1)   %all eqs which are in spacewindow in east-west direction
   x = newgri(i,1);y = newgri(i,2);

  l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
  [s,is] = sort(l);
  b = newcat(is(:,1),:) ;       % re-orders matrix to agree row-wise
  mi2 = mic(is(:,1),2);    % take first ni points
  mi2 = mi2(1:ni);
  me1(i) = mean(mi2);
  va1(i) = std(mi2);
  do = ['me' num2str(az) '=me1;'];
eval(do);
end
end   % for az
m = [me0 me10 me20 me30 me40 me50 me60 me70 me80 me90 me100 me110 me120 me130 me140 me150 me160 me170 me180 me190 me200 me210 me220 me230 me240 me250 me260 me270 me280 me290 me300 me310 me320 me330 me340 me350];


for j = 1:length(m(:,1))
 i  = find( m(j,:)  == min(m(j,:)));
 me1(j) = i*10;
end

me1 = min(m') ;

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
        'Position',[ 600 400 500 650]);
% make menu bar
matdraw


hold on
end

[existFlag,mifmap]=figure_exists('Misfit-Map 2',1);
figure_w_normalized_uicontrolunits(mifmap)

delete(gca);delete(gca); delete(gca);delete(gca);
delete(gca);delete(gca); delete(gca);delete(gca);

set(gca,'visible','off','FontSize',fontsz.m,'FontWeight','bold',...
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

rect = [0.25,  0.60, 0.7, 0.35];
axes('position',rect)
hold on
pco1 = pcolor(xvect,yvect,normlap2);
shading flat
colormap(jet)
%axis([ s2 s1 s4 s3])
axis([ min(gx) max(gx) min(gy) max(gy)])
axis image

hold on
colorbar
if exist('maex') > 0
 hold on
 pl = plot(maex,-maey,'xw');
 set(pl,'MarkerSize',10,'LineWidth',2)
end

%overlay
title('Mean of the Misfit','FontWeight','bold','FontSize',fontsz.m)
xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.m)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.m)

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

rect = [0.25,  0.10, 0.7, 0.35];
axes('position',rect)
hold on
pco1 = pcolor(xvect,yvect,normlap3);
axis([ min(gx) max(gx) min(gy) max(gy)])
axis image

if exist('maex') > 0
 hold on
 pl = plot(maex,-maey,'xw');
 set(pl,'MarkerSize',10,'LineWidth',2)
end


hold on
shading flat
colormap(jet)
hold on
colorbar
title(' Variance of the Misfit','FontWeight','bold','FontSize',fontsz.m)
xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.m)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.m)

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

end
%}
