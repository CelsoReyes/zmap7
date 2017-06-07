report_this_filefun(mfilename('fullpath'));

cupa = cd;
try
    delete(pd);
catch ME
    error_handler(ME, @do_nothing);
end

[file1,path1] = uigetfile(['*.mat'],'Gridfile');

if length(path1) > 1
    think
    load([path1 file1])

    figure_w_normalized_uicontrolunits(map)
    d =  [min(gx) min(gy) ; min(gx) max(gy) ; max(gx) max(gy) ; max(gx) min(gy); min(gx) min(gy)];

    org2 = a;
    subcata;
    pl = plot(newgri(:,1),newgri(:,2),'+k','era','normal');
    set(pl,'MarkerSize',8,'LineWidth',1)

    %pd = plot(d(:,1),d(:,2),'r-','era','normal')
    zmapmenu
else
    return
end
