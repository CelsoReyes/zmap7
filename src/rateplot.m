report_this_filefun(mfilename('fullpath'));


% make a rate per year plot:
ed = (floor(min(newt2(:,3))):1:ceil(max(newt2(:,3))));


[ny,hy ] = hist(newt2(:,3),ed-0.5);

figure
bar(hy,ny)

