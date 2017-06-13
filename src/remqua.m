% This file seperates the catalog for different hour
% of the day;
% The original catalog is in the variable a;
% the two seperated ones are stored in variables
% day  and nig

report_this_filefun(mfilename('fullpath'));

% this line identifies all elemnets that fullfill
% the selection criteria (e.g Hr. bewteen 11 and 13)

l = newt2(:,8) >=11 & newt2(:,8) <=13;

% the day subcatalog contain all the elements
% for which the selection is true (that is  l = 1)

day = a(l,:);

% the nig catalog contain the ones for which it is not true

nig = a;
nig(l,:) = []; % thus we set the one were the condition is true to zero


% To  make the catalog the current one investigated,
% type

a = day;
% or a = nig;

% to plot these events in a map, refresh the map windo or type

mainmap_overview()  % which is just another *.m file in the src directory
