report_this_filefun(mfilename('fullpath'));

% compute the source zones for landers


cd /nfs/alaska/home2/stefan/ZMAP
%zmap   % initialize data
load /nfs/alaska/home2/stefan/ZMAP/eq_data2/swisshistoric.mat
minmag = 6;
par1 = 60;
mainmap_overview()
hold on
map0 = map;

ans_ = questdlg('  ',...
    'Which source zones should be used',...
    'Dieter','Kanton','New defined','No' );

switch ans_
    case 'Dieter'
        load /nfs/alaska/home2/stefan/srisk/swisszones.mat
        k = 16
        swisshaz
    case 'Kanton'
        makekantonmap
    case 'New defined'
        defzonesswiss
end
