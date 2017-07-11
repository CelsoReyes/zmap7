%   This subroutine selects earthquakes in a magnitude, time
%   and depth range for plotting cumulative curves
%   Operates on the last subset of the catalogue (ZG.newcat).
%   Changes ZG.newt2
%
%minma2 =  input('Please input Minimum Magnitude (inclusive):')
%maxma2 =  input('Please input Maximum Magnitude:')
%minde =  input('Please input minimum depth (inclusive):')
%maxde =  input('Please input Maximum depth:')

report_this_filefun(mfilename('fullpath'));

% make selection from  catalogue ZG.newcat
% ZG.newt2 is changed

newt2 = ZG.newcat;

l = ZG.newt2.Magnitude >= minma2 & ZG.newt2.Magnitude <= maxma2 & ...
    ZG.newt2.Date >= mint & ZG.newt2.Date <= maxt;
newt2 = ZG.newt2(l,:);

l = ZG.newt2.Depth >= minde & ZG.newt2.Depth <= maxde ;
newt2 = ZG.newt2(l,:);

%l = ZG.newt2.Date >= minti & ZG.newt2.Date <= maxti ;
%ZG.newt2 = ZG.newt2(l,:);

stri = ['# ' stri1 '#  ' num2str(minma2) ' <= M <= ' num2str(maxma2) ...
    '#  ' num2str(minde) ' <= h(km) < ' num2str(maxde) ];

t0b = min(ZG.newt2.Date);
timeplot



