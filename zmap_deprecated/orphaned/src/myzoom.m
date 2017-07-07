report_this_filefun(mfilename('fullpath'));

if get(gco,'tag') == 'of'
    set(gco,'BackgroundColor','r')
    set(gco,'String','Zoom ON')
    set(gco,'tag','on')

    zoom on
else
    set(gco,'BackgroundColor','w')
    set(gco,'String','Zoom OFF')
    set(gco,'tag','of')
    zoom off
end




