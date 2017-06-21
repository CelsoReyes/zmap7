function [su] = sumval(newt2,Tw)

    report_this_filefun(mfilename('fullpath'));

    dt = 0.2;su = []; maxmag = max(newt2.Magnitude);
    for t1 = min(newt2.Date): dt: max(newt2.Date)-2*Tw
        t2 = t1+Tw; t3 = t2;  t4 = t2+Tw;
        l = newt2.Date > t1 & newt2.Date <= t2 ;
        [bval,xt2] = hist(newt2(l,6),(0:0.1:maxmag));

        l = newt2.Date > t3 & newt2.Date <= t4 ;
        [bval2,xt2] = hist(newt2(l,6),(0:0.1:maxmag));
        anz = (sum(bval)+sum(bval2))/2;
        su = [su  ; t2 sum(bval2-bval)/anz];
    end   % for t1


    figure_w_normalized_uicontrolunits('Position',[100 100 700 200])

    p2 = plot(su(:,1),su(:,2),'r','LineWidth',1)
    hold on
    fillbar(su(:,1),su(:,2),'b')
    grid
