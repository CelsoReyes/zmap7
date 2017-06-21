%function  bdiff(newcat)
%  This routine etsimates the b-value of a curve automatically
%  The b-valkue curve is differenciated and the point
%  of maximum curvature marked. The b-value will be calculated
%  using this point and the point half way toward the high
%  magnitude end of the b-value curve.
%
%  Stefan Wiemer 1/95
%
think
%zmap_message_center.set_info('  ','Calculating b-value...')
global cluscat mess bfig backcat fontsz
global ttcat les n
report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('b-value curve',1);
if existFlag
    figure_w_normalized_uicontrolunits(bfig);
    clf ;
    %set(bfig,'visible','off')
else
    bfig=figure_w_normalized_uicontrolunits(...                  %build figure for plot
        'Units','normalized','NumberTitle','off',...
        'Name','b-value curve',...
        'MenuBar','none',...
        'visible','off',...
        'pos',[ 0.300  0.7 0.5 0.5]);

end
uicontrol('Style','Pushbutton',...
    'Callback','myprint',...
    'Units','normalized',...
    'String','Print','Position',[0.02 .73 .08 .05]);

uicontrol('Style','Pushbutton',...
    'Callback','close;zmap_message_center.set_info('' '','' '');done',...
    'Units','normalized',...
    'String','Close','Position',[0.02 .93 .08 .05]);
uicontrol('Style','Pushbutton',...
    'Callback','clinfo(8)',...
    'Units','normalized',...
    'String','Info','Position',[0.02 .83 .08 .05]);

newcat = c;
maxmag = max(newcat.Magnitude);
mima = min(newcat.Magnitude);
if mima > 0 ; mima = 0 ; end

% number of mag units
nmagu = (maxmag*1)+1;

bval = zeros(1,nmagu);
bvalsum = zeros(1,nmagu);
bvalsum3 = zeros(1,nmagu);

[bval,xt2] = hist(newcat.Magnitude,(mima:1:maxmag));
bvalsum = cumsum(bval);                        % N for M <=
bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
xt3 = (maxmag:-1:mima);


backg_be = log10(bvalsum);
backg_ab = log10(bvalsum3);
orient tall
rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
axes('position',rect);

semilogy(xt3,bvalsum3,'-.m')
hold on
semilogy(xt3,bvalsum3,'om')
difb = [0 diff(bvalsum3) ];
semilogy(xt3,difb,'xg')
semilogy(xt3,difb,'g')
grid

% Marks the point of maximum curvature
%
i = find(difb == max(difb));
i = max(i);
te = semilogy(xt3(i),difb(i),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)
te = semilogy(xt3(i),bvalsum3(i),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)

% Estimate the b-value
%
i2 = round(i/3);
te = semilogy(xt3(i2),difb(i2),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)
te = semilogy(xt3(i2),bvalsum3(i2),'xk');
set(te,'LineWidth',2,'MarkerSize',ms10)

xlabel('Magnitude','FontWeight','bold','FontSize',fontsz.m)
ylabel('Cumulative Number','FontWeight','bold','FontSize',fontsz.m)
set(gca,'Color',[1 1 0.6])
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')


M1b = [];
M1b = [xt3(i) bvalsum3(i)];
tt3=num2str(fix(100*M1b(1))/100);
text( M1b(1),M1b(2),['|: M1=',tt3] )

M2b = [];
M2b =  [xt3(i2) bvalsum3(i2)];
tt4=num2str(fix(100*M2b(1))/100);
text( M2b(1),M2b(2),['|: M2=',tt4] )

ll = xt3 >= M1b(1) & xt3 <= M2b(1);
x = xt3(ll);


me = log10(bval(1*M1b(1)+2)) - log10(bval(1*M2b(1)));
me= me/( M2b(1)-0.2- M1b(1));
%mer = 1.96*me/(sqrt(length(newcat(l,6))));

pause(0.1)

y = backg_ab(ll);
[p,s] = polyfit(x,y,1);                   % fit a line to background
f = polyval(p,x);
f = 10.^f;
hold on
ttm= semilogy(x,f,'b');                         % plot linear fit to backg
set(ttm,'LineWidth',2)
r = corrcoef(x,y);
r = r(1,2);
std_backg = std(y - polyval(p,x));      % standard deviation of fit

p=-p(1,1);
p=fix(100*p)/100;
std_backg=fix(100*std_backg)/100;
tt2=num2str(std_backg);
tt1=num2str(p);


rect=[0 0 1 1];
h2=axes('position',rect);
set(h2,'visible','off');

txt1=text(.16, .18,['B-Value(L2): ',tt1,'  B(eff): ',num2str(me), '  B(mean2)= ']);
set(txt1,'FontWeight','bold','FontSize',fontsz.m)
txt1=text(.16, .1,['Standard Deviation: ',tt2]);
set(txt1,'FontWeight','bold','FontSize',fontsz.m)
set(gcf,'visible','on');
zmap_message_center.set_info('  ','Done')
done


