report_this_filefun(mfilename('fullpath'));

dy = 0.15;
tmin1 = 0.05;
newt0 = newt2;
tpre = 365;
dt = 1;

save_aspar2;
do = [ ' ! '  hodi '/aspar/myaspar' ];
eval(do)


try
    load aspar3.out
catch ME
    error_handler(ME,@do_nothing);
end
re = aspar3;

% std of p etc form pauls code.
pvar0 = 0.04, bvar0 = 0.029; avar0 = 0.337, cvar0 = 0.002;
bv = re(2,3);
p =  re(1,3);
c =  re(4,3);
A =  re(3,3);
bv0 = re(2,1);
p0 =  re(1,1);
c0 =  re(4,1);
A0 =  re(3,1);
tpre2 = 100

la = 0;
m0 = maepi(1,6);

m = min(newt2.Magnitude);
dt = 1;

t0 = ( max(newt2.Date) - mati)*365;
pla = 0;plae = 0;

P2 = [];
mp = 6;

for tpre = 0.1:tpre2
    pla = 0; plae = 0;
    for t = t0:dt:t0+tpre
        pla = pla + (10^(A + bv*(7.4-mp)) * (t + c)^(-p))  *dt;
        plae = plae + (10^(A-avar0 + bv+bvar0*(7.3-mp)) * (t + c+cvar0)^(-p+pvar0))  *dt;

    end
    P = 1 - exp(-pla);
    Pe = 1-exp(-plae);
    P2 = [P2 ; P tpre Pe];

end

P0 = [];

for tpre = 0.1:tpre2
    pla = 0;
    for t = t0:dt:t0+tpre
        pla = pla + (10^(A0 + bv0*(7.4-mp)) * (t + c0)^(-p0))  *dt;
    end
    P  =  1 - exp(-pla);
    P0 = [P0 ; P tpre ];
end

figure
axes('position',[0.1 0.25 0.35 0.6])
hold on; box on
plot(P2(:,2),P2(:,1));
hold on
%plot(P2(:,2),P2(:,3),'k');

hold  on
plot(P0(:,2),P0(:,1),'r-.');
set(gca,'TickDir','out','fontweight','bold')

legend('Bayes Estimate','Generic Model', 'Location', 'SouthEast');
xlabel('Time after Mainshock')
ylabel('Probability')
te = text(0.1,0.9,'Mag. 6','units','normalized','fontweight','bold')


P2 = [];
mp = 7;

for tpre = 0.1:tpre2
    pla = 0;
    for t = t0:dt:t0+tpre
        pla = pla + (10^(A + bv*(7.3-mp)) * (t + c)^(-p))  *dt;
    end
    P = 1 - exp(-pla);
    P2 = [P2 ; P tpre ];

end

P0 = [];

for tpre = 0.1:tpre2
    pla = 0;
    for t = t0:dt:t0+tpre
        pla = pla + (10^(A0 + bv0*(7.3-mp)) * (t + c0)^(-p0))  *dt;
    end
    P  =  1 - exp(-pla);
    P0 = [P0 ; P tpre ];
end

axes('position',[0.55 0.25 0.35 0.6])
hold on; box on
plot(P2(:,2),P2(:,1));
hold  on
plot(P0(:,2),P0(:,1),'r-.');
set(gca,'TickDir','out','fontweight','bold')

legend('Bayes Estimate','Generic Model', 'Location', 'SouthEast');
xlabel('Time after Mainshock')
te = text(0.1,0.9,'Mag. 7','units','normalized','fontweight','bold');












