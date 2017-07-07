% script redraw2;
%

report_this_filefun(mfilename('fullpath'));

iwl = round(iwl3*365/par1);

if (iwl<min_freq)
    iwl=min_freq;
end
if (iwl>max_freq)
    iwl=max_freq;
end
delete(k)
pause(0.1)
set(freq_field,'String',num2str(iwl3));
set(freq_slider,'Value',iwl3);
calclta
drawnow;

