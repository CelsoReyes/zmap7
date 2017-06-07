% this script plots the z-values from a timecut of the map
% Stefan Wiemer  11/94

%Find out of figure already exists
%
report_this_filefun(mfilename('fullpath'));

% This is the info window text
%
ttlStr='The Histogram Window                                ';
hlpStr1= ...
    ['                                                '
    ' This window displays all z-values displayed in '
    ' the z-value map, therefore all the z-values at '
    ' this specific cut in time for the applied      '
    'stastitical function.                           ']

think
watchon
[existFlag,figNumber]=figure_exists('Histogram',1);
newhistWindowFlag=~existFlag;
%
% Set up the Cumulative Number window

if newhistWindowFlag
    hi= figure_w_normalized_uicontrolunits( ...
        'Name','Histogram',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'Visible','off', ...
        'Position',[ 200 100 winx-200 winy-200]);


end % if fig exist

figure_w_normalized_uicontrolunits(hi);
clf
uicontrol('Units','normal',...
    'Position',[.0  .75 .12 .09],'String','Close ',...
     'Callback','close(hi)')

uicontrol('Units','normal',...
    'Position',[.0  .90 .12 .09],'String','Print ',...
     'Callback','myprint')

set(gca,'visible','off','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')

uicontrol('Units','normal',...
    'Position',[.0 .60 .12 .09],'String','Info ',...
     'Callback','zmaphelp(ttlStr,hlpStr1)')

matdraw
orient tall
rect = [0.25,  0.18, 0.60, 0.70];
axes('position',rect)
hold on
[m,n] = size(re3);
reall = reshape(re3,1,m*n);
l = isnan(reall);
reall(l) = [];
[n,x] =hist(reall,30);
bar(x,n,'k');
grid
xlabel('z-value','FontWeight','bold','FontSize',fontsz.m) %what is lab1, at the moment just print 'z-value'
ylabel('Number ','FontWeight','bold','FontSize',fontsz.m)

%title2([name ' (' in '); ' num2str(t0b) ' to ' num2str(teb) ' - cut at ' num2str(it)],'FontSize',fontsz.s,...
%'Color','r','FontWeight','normal')



set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on')
set(hi,'Visible','on');
figure_w_normalized_uicontrolunits(hi);
%watchoff(zmap);
watchoff;done

