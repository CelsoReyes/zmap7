%  This is subroutine betasta.m. An LTA value is calculated for
%  a given cumulative number curve and displayed in the plot.
%  Operates on catalogue newcat

% imported variables
%
% xt        beginning times of bins, calculated in \src\timeplot.m
% par1      binlength in days, default defined in \src\load_zmapfile.m
% iwl2      default set in \src\ini_zmap.m
% cumu      number of earthquakes in each bin, calculated in \src\timeplot.m
% cum       figure handle
% newcat

% local variables
%
% NumberBins            number of bins into which the catalog is divided
% BetaValues            to be calculated and displayed
% TimeBegin             time of first earthquake in catalog
% TimeEnd               time of last earthquake in catalog
% NumberEQs             number of earthquakes in the catalog
% Catalog               earthquake catalog used, imported newcat
% EQIntervalReal        number of earthquakes in interval of interest
% EQIntervalTheor       theoretical number of eq's in interval of interest under assumption "uniform seismicity"
% NormalizedIntervalLength  noramlized length of interval
% STDTheor              theoretical standard deviation of number of eq's in interval under assumption "uniform seismicity"

report_this_filefun(mfilename('fullpath'));

def = {num2str(iwl2),num2str(par1)};

tit ='beta computation input parameters';
prompt={ 'LTA window length (years)',...
    'bin length (days)',...
    };
ni2 = inputdlg(prompt,tit,1,def);

l = ni2{1}; iwl2= str2double(l);
l = ni2{2}; par1= str2double(l);

[cumu, xt] = hist(newt2.Date,(t0b:par1/365:teb));
cumu2=cumsum(cumu);

Catalog=newcat;
NumberBins = length(xt);
BetaValues = zeros(1,NumberBins)*NaN;
TimeBegin = Catalog(1,3);
NumberEQs = length(Catalog(:,1));
TimeEnd = max(Catalog(:,3));

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

%
% Plot the BetaValues
%
% Find out if figure already exists
%
[existFlag,figNumber]=figure_exists('Cumulative Number Statistic',1);
newCumWindowFlag=~existFlag;

% Set up the Cumulative Number window
figure_w_normalized_uicontrolunits(cum);
delete(gca);
tet1 = '';
try
    delete(sinewsta);
catch ME
    error_handler(ME,@do_nothing);
end
try
    delete(te2);
catch ME
    error_handler(ME,@do_nothing);
end
try
    delete(ax1);
catch ME
    error_handler(ME,@do_nothing);
end

hold on;
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,...
    'LineWidth',1.5,...
    'Box','on')

% orient tall
set(gcf,'PaperPosition',[2 1 5.5 7.5])
rect = [0.2,  0.15, 0.65, 0.75];
axes('position',rect)
[pyy,ax1,ax2] = plotyy(xt,cumu2,xt,BetaValues);

set(pyy(2),'YLim',[min(BetaValues)-4  max(BetaValues)+10],'XLim',[t0b teb],...
    'XTicklabel',[],'TickDir','out')
xl = get(pyy(2),'XLim');
set(pyy(1),'XLim',xl);

set(ax1,'LineWidth',2.0,'Color','b')
set(ax2,'LineWidth',0.5,'Color','r')
xlabel('Time in years ','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Cumulative Number ','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m)

title2(['LTA(t) Function; \beta-values; wl = ' num2str(iwl2)],'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');


i = find(BetaValues == min(BetaValues));
if length(i) > 1 ; i = i(1) ;  end

tet1 =sprintf('min. beta: %3.1f at %3.1f ',min(BetaValues),xt(i));

v = axis;
axis([ v(1) ceil(teb) v(3)  v(4)+0.05*v(4)]);
te2 = text(v(1)+0.5, v(4)*0.9,tet1);
set(te2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','normal')

grid
set(gca,'Color',color_bg)

hold on;

% plot big events on curve
%
l = Catalog(:,6) > minmag;
big = Catalog(l,:);
if ~isempty(big)
    ind = ceil((big(:,3) -t0b)*365/par1);
    if min(ind) == 0; l = find(ind == 0); ind(l) = ind(l) +1; end
    f = cumu2(ind);
    bigplo = plot(big(:,3),f,'xb');
    set(bigplo,'MarkerSize',10,'LineWidth',2.5)
    stri2 = [];
    [le1,le2] = size(big);
    for i = 1:le1
        s = sprintf('|  M=%3.1f',big(i,6));
        stri2 = [stri2 ; s];
    end   % for i
    te1 = text(big(:,3),f,stri2);
    set(te1,'FontWeight','normal','Color','m','FontSize',ZmapGlobal.Data.fontsz.m)

end %if big



% go button
uicontrol('Units','normal',...
    'Position',[.25 .0 .08 .05],'String','New',...
     'Callback','betasta')

uicontrol('Units','normal',...
    'Position',[.35 .0 .3 .05],'String','Translate into probabilities',...
     'Callback',' assignin(''base'', ''value2trans'', ''beta''); translating;')




if exist('stri', 'var')
    v = axis;
    tea = text(v(1)+0.5,v(4)*0.9,stri) ;
    set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','normal')
else
    strib = [file1];
end % if stri

strib = [name];

set(cum,'Visible','on');
figure_w_normalized_uicontrolunits(cum);
watchoff
watchoff(cum)
done

xl = get(pyy(2),'XLim');
set(pyy(1),'XLim',xl);
