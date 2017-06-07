report_this_filefun(mfilename('fullpath'));

l = isnan(ret);
re = ret;
re(l) = [];
min(re)
