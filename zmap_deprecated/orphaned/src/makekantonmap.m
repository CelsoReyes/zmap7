report_this_filefun(mfilename('fullpath'));

K = imread('/home2/stefan/kantone.jpg','jpg');

dx = (10.5-5.9)/627
x = 5.9:dx:5.9+dx*627;
length(x)




dy = (47.9 - 45.6)/924
y = 45.6:dy:45.6 + dy*924;
length(y)



figure
image(x,fliplr(y),K);
axis xy
map0 = map;

map = gcf;

k = 1;

defzonesswiss

