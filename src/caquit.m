report_this_filefun(mfilename('fullpath'));

button_name =questdl2(['Do you really wnat to quit?  '],'Yes','No','Cancel');
if(strcmp(button_name,'No'))
    clear button_name
    return;
end
if(strcmp(button_name,'Yes'))
    quit;
end

