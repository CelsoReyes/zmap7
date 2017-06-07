report_this_filefun(mfilename('fullpath'));

[file1,path1] = uigetfile(['*.mat'],'Moviefile');


if length(path1) > 1
    load([path1 file1])
    showmovi
else
    welcome
end   % if exist

