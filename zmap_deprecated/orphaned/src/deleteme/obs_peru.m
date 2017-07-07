report_this_filefun(mfilename('fullpath'));

b = a;


ve = [];dx = 0.2; dy = 0.2
x0 = -82;
x1 = -68;
y0 = -18;
y1 = -3;
z = 0;


for x = x0:dx:x1;
    for y = y0:dy:y1
        ve =    [ ve ; x y ];
    end
end



le = length(ve);
Y0 = zeros(le,1);


for i = 1:length(b)
    di2 = deg2km((distance(ve(:,2),ve(:,1),repmat(b(i,2),le,1),repmat(b(i,1),le,1))));
    Z = repmat(b(i,7),le,1);
    l = di2 < 50;
    di2(l) = 50;
    R = di2;

    r = sqrt(R.^2 + Z.^2);
    M = b(i,6);
    h = b(i,7);

    y = 0.2418 + 1.414*M -2.552*log(R+ 1.7818 * exp(0.554*M)) - 0.00607*h + 0.3846*z;
    Y = exp(y);

    %Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) ;
    %Y = 10.^Y;

    c = [Y , Y0];
    mapga = max(c');
    Y0 = mapga';
end

mapga = mapga';



l1 = length(x0:dx:x1);
l2 = length(y0:dy:y1);


re = reshape(mapga,l2,l1);
rey = reshape(ve(:,2),l2,l1);
rex = reshape(ve(:,1),l2,l1);

figure
pcolor(rex,rey,re);
shading interp
colorbar
overlay




