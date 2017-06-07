report_this_filefun(mfilename('fullpath'));

le = length(newt2(:,1));
buda = [(1:le)' newt2(:,3) newt2(:,4) newt2(:,5) newt2(:,6) newt2(:,7)];
save Idata.m buda -ascii

