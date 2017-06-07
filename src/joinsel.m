% This script file loads input files defined in vector 'n'  and
% selects some eartquakes based on various criteria
% (e.g. latidude, longitude, magnitude, depth error)

% The selected EQ are stored in matrix 'a'.
%
%  Stefan Wiemer, June 1994

report_this_filefun(mfilename('fullpath'));

clear
a = []
n = [ 'calsplitaa'
    'calsplitab'
    'calsplitac'
    'calsplitad'
    'calsplitae'
    'calsplitaf'
    'calsplitag'
    'calsplitah'
    'calsplitai'
    'calsplitaj'
    'calsplitak'
    'calsplital'
    'calsplitam'
    'calsplitan'
    'calsplitao'
    'calsplitap'
    'calsplitaq'
    'calsplitar'
    ]

for i = 1:length(n)

    lofi = ['load ' n(i,1:10) ]
    eval(lofi)
    comm = [' s = ' n(i,1:10) ';']
    eval(comm)
    a2 = [ -s(:,1) s(:,2) s(:,3) s(:,4) s(:,5) s(:,6) s(:,7)/100 s(:,8)/100];
    l = a2(:,8) < 2.0 & a2(:,1) < -121.2 & a2(:,1) > -122.4 & a2(:,2) > 36.65  & a2(:,2) < 37.8;
    a2 = a2(l,:);

    a = [a ; a2];
    size(a)
    comm = [' clear a2 s ' n(i,1:10)]
    eval(comm)
end

a2 = a;
load /FM1/ramon/matlab/zmapv1.1/eq_data/landers_cata.mat
a = a2;
clear a2;
save /FM1/ramon/matlab/zmapv1.1/eq_data/centcal_cata.mat

