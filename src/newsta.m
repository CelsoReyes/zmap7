%  This is subroutine " displayas.m". A as(t) value is calculated for
%  a given cumulative number curve and displayed in the plot.
%  Operates on catalogue newcat

%
% start and end time
%
think
report_this_filefun(mfilename('fullpath'));
b = newcat;
%select big evenets
l = newt2.Magnitude > minmag;
big = newt2.subset(l);

def = {num2str(iwl2),num2str(par1)};

tit ='beta computation input parameters';
prompt={ 'Compare window length (years)',...
    'bin length (days)',...
    };
ni2 = inputdlg(prompt,tit,1,def);

l = ni2{1}; 
iwl2= str2double(l);
l = ni2{2}; 
par1= str2double(l);

% for hist, xt & 2nd parameter were centers.  for histcounts, it is edges.
[cumu, xt] = histcounts(newt2.Date,min(newt2.Date): par1 : max(newt2.Date));%(t0b:par1/365:teb));
xt = xt + (xt(2)-xt(1))/2; xt(end)=[]; % convert from edges to centers!
cumu2=cumsum(cumu);

%
%  iwl is the cutoff at the beginning and end of the analyses
%  to avoid spikes at the end
% iwl = 10;

%
% calculate mean and z value
%
ncu = length(xt);
as = zeros(1,ncu)*nan;

t0b = min(a.Date);
n = a.Count;
teb = max(a.Date);
tdiff = round(days(teb - t0b)/par1); % in days/par1

if sta == 'rub'
    iwl = floor(iwl2*365/par1);
    for i = iwl:1:tdiff-iwl
        mean1 = mean(cumu(1:i));
        mean2 = mean(cumu(i+1:i+iwl));
        var1 = cov(cumu(1:i));
        var2 = cov(cumu(i+1:i+iwl));
        as(i) = (mean1 - mean2)/(sqrt(var1/i+var2/iwl));
    end     % for i
end % if sta = rub

if sta == 'ast'
    iwl = iwl2*365/par1;
    for i = floor(iwl):floor(tdiff-iwl)
        mean1 = mean(cumu(1:i));
        mean2 = mean(cumu(i+1:ncu));
        var1 = cov(cumu(1:i));
        var2 = cov(cumu(i+1:ncu));
        as(i) = (mean1 - mean2)/(sqrt(var1/i+var2/(tdiff-i)));
    end     % for i
end % if sta == ast

if sta == 'lta'
    iwl = floor(iwl2*365/par1);
    %for i = 1:tdiff-iwl-1
    for i = 1:length(cumu)-iwl
        cu = [cumu(1:i-1) cumu(i+iwl+1:ncu)];
        mean1 = mean(cu);
        mean2 = mean(cumu(i:i+iwl));
        var1 = cov(cu);
        var2 = cov(cumu(i:i+iwl));
        as(i) = (mean1 - mean2)/(sqrt(var1/(ncu-iwl)+var2/iwl));
    end     % for i
end % if sta == lta

if sta == 'bet'

    Catalog=newcat;
    NumberBins = length(xt);
    BetaValues = zeros(1,NumberBins)*NaN;
    TimeBegin = min(Catalog.Date);
    NumberEQs = Catalog.Count;
    TimeEnd = max(Catalog.Date);

    iwl = floor(iwl2*365/par1);
    if (iwl2 >= TimeEnd-TimeBegin) | (iwl2 <= 0)
        errordlg('iwl is either too long or too short.');
        return;
    end

    for i = 1:length(cumu)-iwl
        EQIntervalReal=sum(cumu(i:i+(iwl-1)));
        NormalizedIntervalLength=iwl/NumberBins;
        STDTheor=sqrt(NormalizedIntervalLength*NumberEQs*(1-NormalizedIntervalLength));
        BetaValues(i) = (EQIntervalReal-(NumberEQs*NormalizedIntervalLength))/STDTheor;
    end     % for i=1:length(cumu)-iwl
    as = BetaValues;
end

%
%  Plot the as(t)
%
% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Cumulative Number Statistic',1);
newCumWindowFlag=~existFlag;

% Set up the Cumulative Number window


figure_w_normalized_uicontrolunits(cum)
delete(gca)
delete(gca)
tet1 = '';
try delete(sinewsta); catch ME; error_handler(ME, ' '); end
try delete(te2); catch ME; error_handler(ME, ' '); end
try delete(ax1); catch ME; error_handler(ME, ' '); end
%clf
hold on
set(gca,'visible','off','FontSize',fontsz.m,...
    'LineWidth',1.5,...
    'Box','on')

% orient tall
set(gcf,'PaperPosition',[2 1 5.5 7.5])
rect = [0.2,  0.15, 0.65, 0.75];
axes('position',rect)
[pyy,ax1,ax2] = plotyy(xt,cumu2,xt,as);

set(pyy(2),'YLim',[min(as)-2  max(as)+5],'XLim',[t0b teb],...
    'XTicklabel',[],'TickDir','out')
xl = get(pyy(2),'XLim');
set(pyy(1),'XLim',xl);

set(ax1,'LineWidth',2.0,'Color','b')
set(ax2,'LineWidth',1.0,'Color','r')
xlabel('Time in years ','FontWeight','normal','FontSize',fontsz.m)
ylabel('Cumulative Number ','FontWeight','normal','FontSize',fontsz.m)

if sta == 'ast'
    title(['AS(t) Function; wl = ' num2str(iwl2)],'FontWeight','bold',...
        'FontSize',fontsz.m,'Color','k');
end

if sta == 'rub'
    title(['Rubberband Function; wl = ' num2str(iwl2)],'FontWeight','bold',...
        'FontSize',fontsz.m,'Color','k');
end

if sta == 'lta'
    title(['LTA(t) Function; wl = ' num2str(iwl2)],'FontWeight','bold',...
        'FontSize',fontsz.m,'Color','k');

    probut =   uicontrol('Units','normal',...
        'Position',[.35 .0 .3 .05],'String','Translate into probabilities',...
         'Callback',' assignin(''base'', ''value2trans'', ''z''); translating;')

end

if sta == 'bet'

    title(['LTA(t) Function; \beta-values; wl = ' num2str(iwl2)],'FontWeight','bold',...
        'FontSize',fontsz.m,'Color','k');

    probut =  uicontrol('Units','normal',...
        'Position',[.35 .0 .3 .05],'String','Translate into probabilities',...
         'Callback',' assignin(''base'', ''value2trans'', ''beta''); translating;')

end


i = find(as == max(as));
if length(i) > 1 ; i = i(1) ;  end

tet1 =sprintf('Zmax: %3.1f at %s ',max(as),char(xt(i),'uuuu-MM-dd hh:mm:ss'));

vx = xlim;
vy = ylim;
%v = axis;
xlim([vx(1), dateshift(teb,'end','Year') ]);
ylim([vy(1),  vy(2)+0.05*vy(2)]);
te2 = text(vx(1)+0.5, vy(2)*0.9,tet1);
set(te2,'FontSize',fontsz.m,'Color','k','FontWeight','normal')

grid
set(gca,'Color',[cb1 cb2 cb3])

hold on;


% plot big events on curve
%
if ~isempty(big)
    %if ceil(big(:,3) -t0b) > 0
    %f = cumu2(ceil((big(:,3) -t0b)*365/par1));
    l = newt2.Magnitude > minmag;
    f = find( l  == 1);
    bigplo = plot(big.Date,f,'hm');
    set(bigplo,'LineWidth',1.0,'MarkerSize',10,...
        'MarkerFaceColor','y','MarkerEdgeColor','k')
    stri4 = [];
    for i = 1:big.Count
        s = sprintf('  M=%3.1f',big.Magnitude(i));
        stri4 = [stri4 ; s];
    end   % for i

    %te1 = text(big(:,3),f,stri4);
    %set(te1,'FontWeight','normal','Color','k','FontSize',8)
    %end

    %option to plot the location of big events in the map
    %
    % figure_w_normalized_uicontrolunits(map)
    % plog = plot(big(:,1),big(:,2),'or','EraseMode','xor');
    %set(plog,'MarkerSize',ms10,'LineWidth',2.0)
    %figure_w_normalized_uicontrolunits(cum)
end %if big



% repeat button

uicontrol('Units','normal',...
    'Position',[.25 .0 .08 .05],'String','New',...
     'Callback','newsta')

if exist('stri', 'var')
    vx=xlim;
    vy=ylim;
    %v = axis;

    tea = text(vx(1)+0.5,vy(2)*0.9,stri) ;
    set(tea,'FontSize',fontsz.m,'Color','k','FontWeight','normal')
else
    strib = [file1];
end %% if stri

strib = [name];

set(cum,'Visible','on');
figure_w_normalized_uicontrolunits(cum);
watchoff
watchoff(cum)
done

xl = get(pyy(2),'XLim');
set(pyy(1),'XLim',xl);
