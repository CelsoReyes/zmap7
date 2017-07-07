% function circh(hpop)
% function to choose from two versions of routine Circle
%

report_this_filefun(mfilename('fullpath'));

val = get(hpop,'Value');
if val == 2
    set(gcf,'Pointer','watch') ; stri = ' ' ; stri1 = ' ' ;
    circle
elseif val == 3
    set(gcf,'Pointer','watch') ; stri = ' ' ; stri1 = ' ' ;
    incircle
end


