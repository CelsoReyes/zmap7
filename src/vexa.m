report_this_filefun(mfilename('fullpath'));

% set the vertical ex. of the x-section

def = {'1'};
ni2 = inputdlg('Vertical exageration factor?','Input',1,def);
l = ni2{:};
exf = str2double(l);

if exf*xpos(4) > 0.7
    exf = 0.7/xpos(4);
    set(gca,'pos',[xpos(1) xpos(2) xpos(3) xpos(4)*exf ]);
    helpdlg('set to maximal possible value','Value to big!');
end

set(gca,'pos',[0.15 0.13 xpos(3) xpos(4)*exf ]);


