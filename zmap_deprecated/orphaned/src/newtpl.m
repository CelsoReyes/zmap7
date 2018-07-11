% This .m file "timeplot" plots the events select by "circle"
% or by other selection button as a cummultive number versus
% time plot in window 2.
% Time of events with a Magnitude greater than minmag will
% be shown on the curve.  Operates on newt2, resets  b  to newt2,
%     newcat is reset to:
%                       - "a" if either "Back" button or "Close" button is         %                          pressed.
%                       - newt2 if "Save as Newcat" button is pressed.
%Last modification 11/95

global tmvar                      %for P-Value
zmap_message_center.set_info(' ','Plotting cumulative number plot...');

if ~exist('xt','var')
xt=[]; % time series that will be used
end
if ~exist('as','var')
    as=[]; % z values, maybe? used by the save callback.
end

think
report_this_filefun(mfilename('fullpath'));

% This is the info window text
%
ttlStr='The Cumulative Number Window                  ';
hlpStr1= ...
    ['                                                     '
    ' This window displays the seismicity in the sel-     '
    ' ected area as a cumulative number plot.             '
    ' Options from the Tools menu:                        '
    ' Cuts in magnitude and  depth: Opens input para-     '
    '    meter window                                     '
    ' Decluster the catalog: Will ask for declustering    '
    '     input parameter and decluster the catalog.      '
    ' AS(t): Evaluates significance of seismicity rate    '
    '      changes using the AS(t) function. See the      '
    '      Users Guide for details                        '
    ' LTA(t), Rubberband: dito                            '
    ' Overlay another curve (hold): Allows you to plot    '
    '       one or several more curves in the same plot.  '
    '       select "Overlay..." and then selext a new     '
    '       subset of data in the map window              '
    ' Compare two rates: start a comparison and moddeling '
    '       of two seimicity rates based on the assumption'
    '       of a constant b-value. Will calculate         '
    '       Magnitude Signature. Will ask you for four    '
    '       times.                                        '
    '                                                     '];
hlpStr2= ...
    ['                                                      '
    ' b-value estimation:    just that                     '
    ' p-value plot: Lets you estimate the p-value of an    '
    ' aftershock sequence.                                 '
    ' Save cumulative number cure: Will save the curve in  '
    '        an ASCII file                                 '
    '                                                      '
    ' The "Keep as newcat" button in the lower right corner'
    ' will make the currently selected subset of eartquakes'
    ' in space, magnitude and depth the current one. This  '
    ' will also redraw the Map window!                     '
    '                                                      '
    ' The "Back" button will plot the original cumulative  '
    ' number curve without statistics again.               '
    '                                                      '];

global par1 pplot tmp1 tmp2 tmp3 tmp4 difp loopcheck Info_p
global cplot mess tiplo2 cum newt2 statime

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Cumulative Number',1);
newCumWindowFlag=~existFlag;
cum = figNumber;

% Set up the Cumulative Number window

if newCumWindowFlag
    cum = figure_w_normalized_uicontrolunits( ...
        'Name','Cumulative Number',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ 100 100 (ZmapGlobal.Data.map_len - [100 20]) ]);

    matdraw

    options = uimenu('Label','Tools ');

    uimenu(options,'Label','Cuts in time, magnitude and depth', 'Callback','inpu2')
    uimenu(options,'Label','Cut in Time (cursor) ', 'Callback','timesel(4);timeplot;');
    uimenu (options,'Label','Decluster the catalog', 'Callback','inpudenew;')
    iwl = ZG.compare_window_yrs*365/par1;
    uimenu(options,'Label','Overlay another curve (hold)', 'Callback','ho2=true; ')
    uimenu(options,'Label','Compare two rates (fit)', 'Callback','dispma2')
    uimenu(options,'Label','Compare two rates ( No fit)', 'Callback','dispma3')

    op4B = uimenu(options,'Label','Statistic');
    uimenu(op4B,'Label','AS(t)function',...
         'Callback','set(gcf,''Pointer'',''watch'');sta = ''ast'';newsta')
    uimenu(op4B,'Label','Rubberband function',...
         'Callback','set(gcf,''Pointer'',''watch'');sta = ''rub'';newsta')
    uimenu(op4B,'Label','LTA(t) function ',...
         'Callback','set(gcf,''Pointer'',''watch'');sta = ''lta'';newsta')
    op4 = uimenu(options,'Label','b-value estimation');
    uimenu(op4,'Label','automatic', 'Callback','bdiff(newt2)')
    uimenu(op4,'Label','manual', 'Callback','bfitnew(newt2)')
    uimenu(op4,'Label','b with depth', 'Callback','bwithde')
    uimenu(op4,'Label','b with time', 'Callback','bwithti')
    uimenu(op4,'label','b with magnitude', 'Callback','global bcat nh bmplot1 bmplot2 bmplot3 zoom1 zoom2 zoom3;bvalmag(newt2,1);');

    uimenu(options,'Label','get coordinates with Cursor', 'Callback','gi = ginput(1),plot(gi(1),gi(2),''+'');')
    uimenu(options,'Label','Cumlative Moment Release ', 'Callback','morel')
    uimenu(options,'Label','Time to failure  ', 'Callback','savebufe')
    uimenu(options,'Label','Invert for stress-tensor  ', 'Callback','doinvers')
    uimenu(options,'Label','Save cumulative number curve', 'Callback',{@calSave9, xt, cumu2});

    uimenu(options,'Label','Save cum #  and z value', 'Callback',{@calSave7, xt, cumu2, as});

    uicontrol('Units','normal',...
        'Position',[.0  .85 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1,hlpStr2)')

    uicontrol('Units','normal',...
        'Position',[.0  .75 .08 .06],'String','Close ',...
         'Callback','newcat=a;f1=gcf; f2=gpf; close(f1);if f1~=f2, figure_w_normalized_uicontrolunits(f2); end')

    uicontrol('Units','normal',...
        'Position',[.0  .93 .08 .06],'String','Print ',...
         'Callback','myprint')


    uicontrol('Units','normal','Position',[.9 .10 .1 .05],'String','Back', 'Callback','global newcat a newt2;newcat = newcat; newt2 = newcat; stri = ['' '']; stri1 = ['' '']; zmap_message_center.update_catalog();timeplot()')

    uicontrol('Units','normal','Position',[.65 .01 .3 .07],'String','Keep as newcat',...
        'Callback','global newcat a newt2; newcat = newt2;a=newt2;zmap_message_center.update_catalog();update(mainmap())')


end
%end;    if figure exist

if ho2
    cumu = 0:1:(tdiff*365/par1)+2;
    cumu2 = 0:1:(tdiff*365/par1)-1;
    cumu = cumu * 0;
    cumu2 = cumu2 * 0;
    n = newt2.Count;
    [cumu, xt] = hist(newt2.Date,(t0b:par1/365:teb));
    cumu2 = cumsum(cumu);


    hold on
    axes(ht)
    tiplo2 = plot(newt2.Date,(1:newt2.Count),'b');
    set(tiplo2,'LineWidth',2.5)

    ho2=false
    return
end

figure_w_normalized_uicontrolunits(cum)
delete(gca)
delete(gca)
reset(gca)
try
    delete(sicum);
catch ME
    error_handler(ME, @do_nothing);
end
cla
hold off
watchon;

set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

if isempty(newcat), newcat =a; end

% select big events ( > minmag)
%
l = newt2.Magnitude >= minmag;
big = newt2(l,:);
%big=[];
%calculate start -end time of overall catalog
%R
statime=[];
par2=par1;
t0b = min(newt2.Date);
n = newt2.Count;
teb = max(a.Date);
ttdif=(teb - t0b)*365;
if ttdif>10                 %select bin length respective to time in catalog
    %par1 = ceil(ttdif/300);
elseif ttdif<=10  &&  ttdif>1
    %par1 = 0.1;
elseif ttdif<=1
    %par1 = 0.01;
end


if par1>=1
    tdiff = round((teb - t0b)*365/par1);
    %tdiff = round(teb - t0b);
else
    tdiff = (teb-t0b)*365/par1;
end
% set arrays to zero
%
%if par1>=1
cumu = 0:1:(tdiff*365/par1)+2;
cumu2 = 0:1:(tdiff*365/par1)-1;
%else
%  cumu = 0:par1:tdiff+2*par1;
%  cumu2 =  0:par1:tdiff-1;
%end
% cumu = cumu * 0;
% cumu2 = cumu2 * 0;

%
% calculate cumulative number versus time and bin it
%
n = newt2.Count;
if par1 >=1
    [cumu, xt] = hist(newt2.Date,(t0b:par1/365:teb));
else
    [cumu, xt] = hist((newt2.Date-newt2(1,3)+par1/365)*365,(0:par1:(tdiff+2*par1)));
end
cumu2=cumsum(cumu);
% plot time series
%
%orient tall
set(gcf,'PaperPosition',[0.5 0.5 3.5 4.5])
rect = [0.25,  0.18, 0.60, 0.70];
axes('position',rect)
hold on
%tiplo = plot(xt,cumu2,'ob');
set(gca,'visible','off')
%tiplo2 = plot(xt,cumu2,'b');
%set(tiplo2,'LineWidth',2.5)
tiplo2 = plot(newt2.Date,(1:newt2.Count),'b');
set(tiplo2,'LineWidth',2.5)

% plot big events on curve
%
if par1>=1
    if ~isempty(big)
        if ceil(big(:,3) -t0b) > 0
            f = cumu2(ceil((big(:,3) -t0b)*365/par1));
            bigplo = plot(big(:,3),f,'xr');
            set(bigplo,'MarkerSize',10,'LineWidth',2.5)
            stri4 = [];
            [le1,le2] = size(big);
            for i = 1:le1;
                s = sprintf('  M=%3.1f',big(i,6));
                stri4 = [stri4 ; s];
            end   % for i

            te1 = text(big(:,3),f,stri4);
            set(te1,'FontWeight','bold','Color','m','FontSize',ZmapGlobal.Data.fontsz.s)
        end

        %option to plot the location of big events in the map
        %
        % figure_w_normalized_uicontrolunits(map)
        % plog = plot(big(:,1),big(:,2),'or','EraseMode','xor');
        %set(plog,'MarkerSize',ms10,'LineWidth',2.0)
        %figure_w_normalized_uicontrolunits(cum)

    end
end %if big

if exist('stri', 'var')
    v = axis;
    %if par1>=1
    % axis([ v(1) ceil(teb) v(3) v(4)+0.05*v(4)]);
    %end
    tea = text(v(1)+0.5,v(4)*0.9,stri) ;
    set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold')
else
    strib = [file1];
end %% if stri

strib = [name];

title2(strib,'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.l,...
    'Color','k')

grid
if par1>=1
    xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
else
    statime=newt2(1,3)-par1/365;
    xlabel(['Time in days relative to ',num2str(statime)],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
end
ylabel('Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ht = gca;
set(gca,'Color',color_bg);

%clear strib stri4 s l f bigplo plog tea v
% Make the figure visible
%
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')
figure_w_normalized_uicontrolunits(cum);

%sicum = signatur('ZMAP','',[0.65 0.98 .04]);
%set(sicum,'Color','b')
axes(ht);
set(cum,'Visible','on');
watchoff(cum)
watchoff(map)
zmap_message_center.clear_message();
%par1=par2;
done

