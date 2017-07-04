%
% This code calculates the fractal dimension for time windows of "nev" events
% that are shifted by "inc" and plots the fractal dimension as a function of
% time. It also plots the D-value as a function of the b-value.
% Called from timeplot.m.
%
%
disp('fractal/codes/fdtime.m');
%
%
%
fdtim2 = [];
fdtim3 = [];
bv2 = [];
bv3 = [];

Ho_Wb = waitbar(0,'Calculating the fractal dimension D with time');
Hf_Cfig = gcf;
Hf_child = get(groot,'children');
set(Hf_child,'pointer','watch','papertype','A4');

m = 0;

for l = 1:inc:size(newt2,1)-nev

    E = newt2(l:(l + nev),:);

    dtokm = [1];
    pdc3nofig;
    fdallfig;

    fdtim3 = [fdtim3 ; coef(1,1) newt2(l,3) ; coef(1,1) newt2(l+nev-1,3) ; inf inf];
    fdtim2 = [fdtim2 ; coef(1,1) newt2(l+nev,3) deltar];

    [bv magco stan ] =  bvalca2(newt2(l:l+nev,:));
    bv3 = [bv3 ; bv newt2(l,3) ; bv newt2(l+nev-1,3) ; inf inf];
    bv2 = [bv2 ; bv newt2(l+nev,3) stan];

    waitbar(1/((size(newt2,1)-nev)/inc)*m, Ho_Wb);
    m = m + 1;

end %for loop

close(Ho_Wb);
Hf_child = get(groot,'children');
set(Hf_child,'pointer','arrow');



Hdwt = figure_w_normalized_uicontrolunits('Numbertitle', 'off', 'Name', 'D with Time', 'position', [50 100 500 500]);
rect = [0.15 0.60 0.7 0.25];
axes('position',rect);
errorbar(fdtim2(:,2),fdtim2(:,1),fdtim2(:,3),'k-');
hold on;
fdt = plot(fdtim3(:,2),fdtim3(:,1), 'k');
set(fdt,'LineWidth',1.0);
set(gca,'Ylim',[1 3],'Xlim',[t0b teb]);
grid;
set(gca,'Color',color_bg)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',10,'Linewidth',1.2)
xlabel('Time in years', 'fontsize',10);
ylabel('D-value', 'fontsize',10);
str1 = ['Temporal Variation of the D-value. Window: ' sprintf('%.0f',nev) '; Increment: ' sprintf('%.0f',inc)];
title(str1, 'fontsize',12);

hold on;
rect = [0.15 0.17 0.7 0.25];
axes('position',rect)
errorbar(bv2(:,2),bv2(:,1),bv2(:,3),'k');
hold on;
pl = plot(bv3(:,2),bv3(:,1),'k-');
set(pl,'LineWidth',1.0)

grid
set(gca,'Color',color_bg)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
ylabel('b-value', 'fontsize', 10);
xlabel('Time in years', 'fontsize', 10);
title('Temporal Variation of the b-value','fontsize',12);
set(gca,'Xlim',[t0b teb], 'Ylim',[0.5 1.5]);

clear l m nev inc;
%
%
% Construction of button "D versus b"
%
axes('pos',[0 0 1 1]); axis off; hold on;
uicontrol('Units','normal','Position',[.01 .93 .15 .06],...
    'String','D versus b', 'Callback','Dvbtim');

%
% Creates the figure with all of the correlation integral curves calculated.
%
figure_w_normalized_uicontrolunits(HCIfig);
cb = colorbar('horiz');
set(cb, 'position', [0.32 0.08 0.4 0.03], 'XTickLabel', col);
axes('pos',[0 0 1 1]); axis off; hold on;
te= text('string','D-value','pos',[0.49,0.02], 'fontsize',12);
set(gcf, 'visible','on');
