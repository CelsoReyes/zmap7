report_this_filefun(mfilename('fullpath'));
%

if ~exist('val0','var') ; val0 = 1; end
j = findobj('tag',num2str(val0));
try
    set(j, 'MarkerSize', 6, 'LineWidth', 1.0);
catch ME
    error_handler(ME, @do_nothing);
end

val = get(sl,'value');
val = floor(val*lec)+1;
if val > lec; val = lec; end

str = ['Cluster # ',num2str(val) ];
set(te,'string',str);

j = findobj('tag',num2str(val));
set(j,'MarkerSize',22,'Linewidth',4);

l = clus == val;
newt2 = original(l,:);

nu = (1:ZG.newt2.Count) ;nu = nu';
if length(nu) > 2
    set(tiplo2,'Xdata',ZG.newt2.Date,'Ydata',nu); figure_w_normalized_uicontrolunits(cum);
end


val0 = val;;

