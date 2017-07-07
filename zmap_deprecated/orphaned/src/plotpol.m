% plotpol load a series of polygons
% and plots them in the map window.

report_this_filefun(mfilename('fullpath'));

but = 'more';
while but == 'more';
    [file1,path1] = uigetfile([hodo '*.dat'],'Polygon Datafile');
    if length(path1) > 1
        think
        lofi = ['load ' path1 file1 ];
        eval(lofi)
        dopo = find(file1 == '.');
        lofi = ['poltmp = ' file1(1:dopo-1) ';' ];
        eval(lofi)
        figure_w_normalized_uicontrolunits(map)
        pl = plot(poltmp(:,1),poltmp(:,2),'k');
        set(pl,'LineWidth',2)
    else
        but = 'done';
        return
    end
end % while but
