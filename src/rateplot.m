report_this_filefun(mfilename('fullpath'));


% make a rate per year plot:
ed = (floor(min(newt2.Date)):1:ceil(max(newt2.Date)));


[ny,hy ] = hist(newt2.Date,ed-0.5);

figure
bar(hy,ny)

