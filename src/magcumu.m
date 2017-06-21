%   This subroutine selects earthquakes in a magnitude, time
%   and depth range for plotting cumulative curves
%   Operates on the last subset of the catalogue (newcat).
%   Changes newt2
%
%minma2 =  input('Please input Minimum Magnitude (inclusive):')
%maxma2 =  input('Please input Maximum Magnitude:')
%minde =  input('Please input minimum depth (inclusive):')
%maxde =  input('Please input Maximum depth:')

report_this_filefun(mfilename('fullpath'));

% make selection from  catalogue newcat
% newt2 is changed

newt2 = newcat;

l = newt2.Magnitude >= minma2 & newt2.Magnitude <= maxma2 & ...
    newt2.Date >= mint & newt2.Date <= maxt;
newt2 = newt2(l,:);

l = newt2.Depth >= minde & newt2.Depth <= maxde ;
newt2 = newt2(l,:);

%l = newt2.Date >= minti & newt2.Date <= maxti ;
%newt2 = newt2(l,:);

stri = ['# ' stri1 '#  ' num2str(minma2) ' <= M <= ' num2str(maxma2) ...
    '#  ' num2str(minde) ' <= h(km) < ' num2str(maxde) ];

t0b = min(newt2.Date);
timeplot



