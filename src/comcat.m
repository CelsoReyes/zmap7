titStr ='Combining two catalogs                          ';

report_this_filefun(mfilename('fullpath'));

messtext= ...
    ['                                                '
    ' To combine two catakogs please input the       '
    ' second catalog filname. The data will be sorted'
    ' in time                                        '];

zmap_message_center.set_message(titStr,messtext);
figure_w_normalized_uicontrolunits(mess)

[file1,path1] = uigetfile([ '*.mat'],' Second Earthquake Datafile');
aa = a;

if length(path1) < 2
    zmap_message_center.clear_message();;done
    return
else
    lopa = [path1 file1];
    name = file1;
    messtext=...
        ['Thank you! Now loading data'
        'Hang on...                 '];
    zmap_message_center.set_message('  ',messtext)
end
try
    load(lopa)
catch ME
    error_handler(ME,'Error loading data! Are they in the right *.mat format?');
end

if max(a.Date) < 100;
    a.Date = a.Date+1900;
    errdisp = ...
        ['The catalog dates appear to be 2 digit.    '
        'Action taken: added 1900 for Y2K compliance'];
    zmap_message_center.set_message('Error!  Alert!',errdisp)
    warndlg(errdisp)

end


l1 = length(a(1,:));
l2 = length(aa(1,:));
l3 = min([l1 l2]);

try
    a = [a(:, 1:l3) ; aa(:, 1:l3)] ;
catch
    errordlg('Error combining data - same number of colums?');
    return
end

% Sort the catalog in time
[s,is] = sort(a.Date);
a = a(is(:,1),:) ;

mainmap_overview()
