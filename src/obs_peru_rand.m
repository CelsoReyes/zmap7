report_this_filefun(mfilename('fullpath'));

b = a;


ve = [];dx = 0.25; dy = 0.25
x0 = -82;
x1 = -70;
y0 = -18;
y1 = -3;
z =0;


for x = x0:dx:x1;
    for y = y0:dy:y1
        ve =    [ ve ; x y ];
    end
end


ld = length(b(:,1));
le = length(ve);
Y0 = zeros(le,1);
randn('state',sum(100*clock));
rand('state',sum(100*clock));

mapga0 = [];

for k = 1:100
    b2 = b;
    b2(:,6)= b2(:,6) + randn(ld,1)/2;
    b2(:,1)= b2(:,1) + randn(ld,1)/3;
    b2(:,2)= b2(:,2) + randn(ld,1)/3;

    k


    % dy = y + ( 1.45 - 0.1*m);

    for i = 1:length(b)
        if b(i,7) > 40;
            z = 1;
        else
            z = 0;
        end

        di2 = deg2km((distance(ve(:,2),ve(:,1),repmat(b2(i,2),le,1),repmat(b2(i,1),le,1))));
        Z = repmat(b(i,7),le,1);
        l = di2 < 30;
        di2(l) = 30;
        R = di2;

        r = sqrt(R.^2 + Z.^2);
        M = b2(i,6);
        h = b2(i,7);

        y = 0.2418 + 1.414*M -2.552*log(R+ 1.7818 * exp(0.554*M)) - 0.00607*h + 0.3846*z ;

        Y = exp(y);

        %Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) ;
        %Y = 10.^Y;

        c = [Y , Y0];
        mapga = max(c');
        Y0 = mapga';
    end
    if k == 1
        mapga0 = mapga;
    else

        mapga0 = mapga0 + mapga;
    end


end

mapga2 = mapga0'/k;

l1 = length(x0:dx:x1);
l2 = length(y0:dy:y1);

re = reshape(mapga2,l2,l1);
rey = reshape(ve(:,2),l2,l1);
rex = reshape(ve(:,1),l2,l1);

Z = re; X = rex; Y = rey;

figure
pcolor(rex,rey,re);
shading interp
colorbar
overlay




