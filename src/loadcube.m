report_this_filefun(mfilename('fullpath'));

cupa = cd;


[file1,path1] = uigetfile(['*.mat'],'Cube Data File');

if length(path1) > 1
    think
    load([path1 file1])
    abo2 = abo;
    plotala()
else
    return
end
