% Load the alarm data set
%
report_this_filefun(mfilename('fullpath'));

cupa = cd;

try
    delete(pd)
catch ME
    error_handler(ME, ' ');
end

[file1,path1] = uigetfile(['*.mat'],'Alarm Data File?');

if length(path1) > 1
    load([path1 file1])
    plotala
else
    return
end
