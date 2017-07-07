report_this_filefun(mfilename('fullpath'));

sl0 = sl*0;
sl1 = sl*0;

for ni=50:50:300
    for lta_winy = 0.5:0.5:4

        lta_win = round(100/tdiff * lta_winy);
        lta_out = 100 - lta_win;

        tiz = 100-lta_win;

        lta_winy
        ni
        zvg = squeeze(zv4(:,:,:,1));

        for j = 1:length(gz)
            zv3 = zv4(:,:,j,:);
            zv3 = squeeze(zv3);
            [l, l2] = find(isnan(zv3(:,:,1)) == 0);


            for i = 1:length(l)
                s0 = squeeze(zv3(l(i),l2(i),1:ni));
                cumu = histogram(a(s0,3),(t0b:(teb-t0b)/99:teb));
                s1 = cumu(tiz:tiz+lta_win);
                s2 = cumu; s2(tiz:tiz+lta_win) = [];
                var1= cov(s1);
                var2= cov(s2);
                me1= mean(s1);
                me2= mean(s2);
                zvg(l(i),l2(i),j) = -(me1 - me2)/(sqrt(var1/(length(s1))+var2/length(s2)));
            end % for i
        end % for j
        S0 = sl1;
        for z0 = 0:5:25
            Z3 = Z2*0+z0;
            S0 = interp3(X,Y,Z,zvg,Y2,X2,Z3);
            S0 = max(S0,sl1);
        end
        sl = S0;


        as = zeros(1,300);

        for i = 1:300
            s0 = ceil(rand(ni,1)*(length(a)-1));
            tizr = ceil(  rand(1,1)*(100 -lta_win));
            cumu = histogram(a(s0,3),(t0b:(teb-t0b)/99:teb));
            s1 = cumu(tizr:tizr+lta_win);
            s2 = cumu; s2(tizr:tizr+lta_win) = [];
            var1= cov(s1);
            var2= cov(s2);
            me1= mean(s1);
            me2= mean(s2);
            as(i) = (me1 - me2)/(sqrt(var1/(length(s1))+var2/length(s2)));
        end % for i

        mu = mean(as); varz = std(as);

        zvals = sl;
        l = isnan(zvals) == 0;
        zvals(l)  = log10(1- normcdf(zvals(l),mu,varz));

        sl0 =  min(sl0,zvals);


    end % for lta
end % for ni




