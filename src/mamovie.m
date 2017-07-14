report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(cube)

hm = gcf;
m = moviein(19,hm);

i = 0;

for j=-180:10:0
    i=i+1;
    view([ j 16+i*2])
    m(:,i) = getframe(hm);
end
m(:,i+1) = getframe(hm);
m(:,i+2) = getframe(hm);

figure_w_normalized_uicontrolunits(gcf)
clf
axis off
fs2 = get(gcf,'pos');
set(gca,'pos',[0 0 fs2(3) fs2(4)]);
set(gca,'visible','on')

movie(m,3,12)

mamo = uicontrol('Units','normal',...
    'Position',[.02 .01 .15 .08],'String','Play ',...
     'Callback','movie(m,3,12)');

uicontrol('Units','normal',...
    'Position',[.20 .01 .15 .10],'String','Back ',...
     'Callback','close(cube);close(vie);;plotala');

uicontrol('Units','normal',...
    'Position',[.0 .93 .10 .06],'String','Print ',...
     'Callback','myprint')


uicontrol('Units','normal',...
    'Position',[.2 .93 .10 .06],'String','Close ',...
     'Callback','close(cube); close(vie);clear m;zmap_message_center();')

uicontrol('Units','normal',...
    'Position',[.4 .93 .10 .06],'String','Info ',...
     'Callback','zmaphelp(ttlStr,hlpStr1)')


