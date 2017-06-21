report_this_filefun(mfilename('fullpath'));

le = newt2.Count;
buda = [(1:le)' newt2.Date newt2.Date.Month newt2.Date.Day newt2.Magnitude newt2.Depth];
save Idata.m buda -ascii

