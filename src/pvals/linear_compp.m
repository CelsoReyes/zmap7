%%
% omorip.m calculates the p value for an entire sequence -- not on a grid
% one of the following methods can be used:
% basic_omori.m constant Mc cut
% monte_omoris.m variable Mc cut
% monte_omoris2.m variable Mc cut filling in of missing events to an Mc datum
%%

global no1 bo1 inb1 inb2

forem = 2.0;
compflag = 'on';

tmp_newt2 = newt2;

%%
% call linearb_omori for fixed mc calculation
%%
linearb_omori;
fa = x(1);
fb=x(2);
fc=x(3);
fp=x(4);

ll = tmp_newt2.Date >= fore_start & tmp_newt2.Date <= fore_end;
fore_cat = newt2(ll,:);

llb = fore_cat(:,6) >= forem;
fore_catf = fore_cat(llb,:);

dt = .1
calc_mag = [];
calc_cummag = [];
calctime = (calc_ed-calc_sd)/365.0;
foretime = (fore_ed-fore_sd)/365.0;

mag_events = [];
ct=1;
for m = forem-.1:0.1:7
    tct = 1;
    for t = fore_sd:dt:fore_ed
        mag_events(tct,ct) = 10^(x(1)+x(2)*(maepi(1,6)-m))*(t+x(3)).^(-x(4))*dt;
        tct = tct + 1;
    end
    ct = ct + 1;
end
sum_mag = sum(mag_events,1)';
diff_magb = -diff(sum_mag,1);
%diff_mag = [nan;diff_mag];
[obs_magb,basic_magbin] = histc(fore_catf(:,6),forem:0.1:7);
basicpdf = poisspdf(obs_magb,diff_magb);

%%
% linearv_omori for variable mc calculation
%%
linearv_omori;
va= x(1);
vb=x(2);
vc=x(3);
vp = x(4);
calc_mag = [];
calc_cummag = [];

mag_events = [];
dt = .1;
ct = 1;
for m = forem-.1:0.1:7
    tct = 1;
    for t=fore_sd:dt:fore_ed
        mag_events(tct,ct) = 10^(x(1)+x(2)*(maepi(1,6)-m))*(t+x(3)).^(-x(4))*dt;
        tct = tct + 1;
    end
    ct=ct+1;
end

sum_mag = sum(mag_events,1)';
diff_mags = -diff(sum_mag,1);
%diff_mag = [nan;diff_mag];
[obs_mags,smoo_magbin] = histc(fore_catf(:,6),forem:0.1:7);
smoopdf = poisspdf(obs_mags,diff_mags);

%%
% fixed b forecast
%%

lf = fore_cat(:,6) > magco_fixed;
af = log10(length(fore_cat(lf,1))) + 0.85*magco_fixed;

tr2 = [];

%%
% teb = end of newt2 cat time
% t0b = mainshock time
% pt = length of prediction in years
% tdpre = length of cst before prediction time
%%

for m = forem-.1:0.1:7
    N2 = 10^(af-0.85*m)/calctime*foretime;   % this is with a fixed b =
    tr2 = [tr2 ; N2  m];
end

diff_fixb = -diff(tr2(:,1),1);
fixbpdf = poisspdf(obs_mags,diff_fixb);


%%
% call infilling
%%

% monte_omoris2;
% fia=x(1);
% fib=x(2);
% fic=x(3);
% fip=x(4);
%
%
% mag_events = [];
% dt = .1;
% ct = 1;
% for m = rmean_mc-0.1:0.1:7
%     tct = 1;
%     for t=fore_sd:dt:fore_ed
%         mag_events(tct,ct) = 10^(x(1)+x(2)*(maepi(1,6)-m))*(t+x(3)).^(-x(4));
%         tct = tct + 1;
%     end
%     ct=ct+1;
% end
%
% sum_mag = sum(mag_events,1)';
% diff_mag = -diff(sum_mag,1);
% %diff_mag = [nan;diff_mag];
% [obs_mag,fill_magbin] = hist(fore_cat(:,6),rmean_mc-0.05:0.1:7);
% fillpdf = poisspdf(obs_mag',diff_mag);

lpbasic = log(basicpdf);
l = isinf(lpbasic);
lpbasic(l) = 0.00;

lpsmoo = log(smoopdf);
l = isinf(lpsmoo);
lpsmoo(l) = 0.00;

lpfixb = log(fixbpdf);
l = isinf(lpfixb);
lpfixb(l) = 0.00;

% lpfill = log(fillpdf);
% l = isinf(lpfill);
% lpfill(l) = 0;

figure
%pl1 = plot(basic_magbin',cumsum((lpbasic)),'b');
pl1 = plot(forem:.1:7,cumsum(lpbasic),'b');
set(pl1,'LineWidth',2.0);
hold on
%pl2 = plot(smoo_magbin',cumsum(lpsmoo),'k');
pl2 = plot(forem:.1:7,cumsum(lpsmoo),'k');
set(pl2,'LineWidth',2.0);

pl4 = plot(forem:.1:7.0,cumsum(lpfixb),'m');
set(pl4,'LineWidth',2.0);

% pl3 = plot(fill_magbin',cumsum(lpfill),'y');
% set(pl3,'LineWidth',2.0);

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
xlabel('Magnitude')
ylabel('Ln(P)')
%legend([pl1,pl2,pl3],'Fixed Mc Prediction','Variable Mc Prediction','Filled Mc Prediction',3);
legend([pl1,pl2,pl4],'Fixed Mc Forecast','Variable Mc Forecast','Fixed b Forecast','location', 'SouthWest');


str2 = ['Log Likelihood sum: Fixed Mc: ' num2str(sum(lpbasic)) ];
str3 = ['Log Likelihood sum: Variable Mc: ' num2str(sum(lpsmoo))  ];
%str4 = ['Log Likelihood sum: Filled to datum Mc: ' num2str(sum(lpfill))  ];
str4b = ['Log Likelihood sum: Fixed b: ' num2str(sum(lpfixb)) ];

str5 = ['Fixed Mc: A,b,c,p = ' num2str(fa,'%5.2f'),', ', num2str(fb,'%5.2f'),', ', num2str(fc,'%5.2f'),', ', num2str(fp,'%5.2f')];
str6 = ['Variable Mc: A,b,c,p = ' num2str(va,'%5.2f'),', ', num2str(vb,'%5.2f'),', ', num2str(vc,'%5.2f'),', ', num2str(vp,'%5.2f')];
%str7 = ['Filled Mc: A,b,c,p = ' num2str(fia,'%5.2f'),', ', num2str(fib,'%5.2f'),', ', num2str(fic,'%5.2f'),', ', num2str(fip,'%5.2f')];
str8 = ['Fixed b: a,b = ' num2str(af,'%5.2f'),', .85' ];


axes('pos',[0 0 1 0.5 ])
axis off
text(0.45,0.85,str2)
text(0.45,0.8,str3)
text(0.45,0.75,str4b)
axes('pos',[.5 .7 .4 .2])
axis off
text(0,.90,str5)
text(0, .750, str6)
text(0,.60, str8)
compflag = 'of';
