%%
% omorip.m calculates the p value for an entire sequence -- not on a grid
% one of the following methods can be used:
% basic_omori.m constant Mc cut
% monte_omoris.m variable Mc cut
% monte_omoris2.m variable Mc cut filling in of missing events to an Mc datum
%%

global no1 bo1 inb1 inb2


compflag = 'on';
tmp_newt2 = newt2;


%%
% get the name of the p value grid file and load it
%%

prompt = {'Enter the name of the variable p value grid file',...
    'Enter the forecast start time (days from mainshock)',...
    'Enter the forecast end time (days from mainshock)'};
title = 'Filename Input';
lines = 1;
def = {'','10','15'};
answer = inputdlg(prompt,title,lines,def);
file_in = answer{1,1};
fore_sday = str2double(answer{2,1});
fore_eday = str2double(answer{3,1});

file_in = 'lltest.mat'
load(file_in)
nodes = tmpgri;

if(bpvg(1,15) == 1)
    % this grid was not calculated with constant area so stop.
    disp('%%%%ERROR%%%% This input grid was NOT calculated with constant radius please use one that is.')
    return
end

%%
% cut cat to only forecast time period
%%
fore_start = maepi(:,3) + fore_sday/365;
fore_end = maepi(:,3) + fore_eday/365;
ll = tmp_newt2.Date >= fore_start & tmp_newt2.Date <= fore_end;
fore_cat = newt2(ll,:);

dt = .1
calc_mag = [];
calc_cummag = [];
%calctime = (calc_ed-calc_sd)/365.0;
%foretime = (fore_ed-fore_sd)/365.0;

%%
% call distofault to get the distance from each grid node to the estimated fault
% gx and gy come from the input file
%%

%[fdkm] = distofault(tmpgri);
faultdist

lt1 = fdkm < 1;
fdkm(lt1) = 1;


disp('values for sequence specific model');
pvalcat
ssa = rja;
ssb = rjb;
ssc = cv;
ssp = pv;

%%
% use the distance to taper the a value for the Generic calculation
% and the sequence specific calculation
%%

%totd = sum(1./(fdkm));
totd = sum(1./(fdkm.^2));
da = -1.67/totd;
dssa = ssa/totd;
for i = 1:length(nodes)
    tapera(i) = da*(1/fdkm(i).^2);
    sstapera(i) = dssa*(1/fdkm(i).^2);

    %    tapera(i) = da*(1/fdkm(i));
end

plot_tapera(tapera,s1x,s1y,s2x,s2y,tmpgri,xvect,yvect)
magco_fixed = 1.0
lvary_a = [];
lvary_ab = [];
lgca = [];

%%
% loop over all grid nodes and calculate various forecasts
%%

for gloop = 1:length(bpvg)

    %%
    %     Calculate the forecast for varying a & b and varying a w/constant b
    %
    %  select the events within the radius used for the parameter calc. (rd) from
    %  the forecast time period, to compare the calculated number of events with
    %%
    x = bpvg(gloop,3);
    y = bpvg(gloop,4);
    l = sqrt(((fore_cat(:,1)-x)*cos(pi/180*y)*111).^2 + ((fore_cat(:,2)-y)*111).^2) ;
    [s,is] = sort(l);
    fore_cat = fore_cat(is(:,1),:) ;       % re-orders matrix to agree row-wise

    if bpvg(gloop,15) == 0   % get points within the original radius.
        l3 = l <= bpvg(1,5);
        obs_events = fore_cat(l3,:);      % obs_events is the events at the node w/in the radius of the original
    else
        % this grid was not calculated with constant area so stop.
        disp('%%%%ERROR%%%% This input grid was NOT calculated with constant radius please use one that is.')
        return
    end

    %%
    % Calculate forecast for:
    % Generic CA model with a-values smoothed as 1/r^2 from fault and calculate the PDF
    %%

    num_nodes = length(nodes);
    gen_b = .91;
    gen_p =  1.08;
    gen_c = .05;

    mag_events = [];
    ct=1;
    for m = magco_fixed-0.1:0.1:7
        tct = 1;
        for t = fore_sday:dt:fore_eday
            mag_events_gca(tct,ct) = 10^(tapera(gloop)+gen_b*(maepi(1,6)-m))*(t+gen_c).^(-gen_p);
            tct = tct + 1;
        end
        ct = ct + 1;
    end

    %%
    % Calculate forecast for:
    % Sequence Specific model with a-values smoothed as 1/r^2 from fault and calculate the PDF
    %%


    mag_events = [];
    ct=1;
    for m = magco_fixed-0.1:0.1:7
        tct = 1;
        for t = fore_sday:dt:fore_eday
            mag_events_ss(tct,ct) = 10^(sstapera(gloop)+ssb*(maepi(1,6)-m))*(t+ssc).^(-ssp);
            tct = tct + 1;
        end
        ct = ct + 1;
    end

    %%
    % get a b c p and k from input file (in that order) for spaitally varying models
    %%
    x(1) = bpvg(gloop, 16);
    x(2) = bpvg(gloop, 18);
    x(3) = bpvg(gloop, 14);
    x(4) = bpvg(gloop, 11);
    x(5) = bpvg(gloop, 17);

    %%
    % calculate the forecast for each magnitude bin for varying a and constant b
    % bo1 is the constant b value calculated in bpvalgrid
    %%
    mag_events = [];
    ct=1;
    for m = magco_fixed-0.1:0.1:7
        tct = 1;
        for t = fore_sday:dt:fore_eday
            mag_events_ab(tct,ct) = 10^(x(1)+x(2)*(maepi(1,6)-m))*(t+x(3)).^(-x(4));
            mag_events_a(tct,ct) = 10^(x(1)+bo1*(maepi(1,6)-m))*(t+x(3)).^(-x(4));
            tct = tct + 1;
        end
        ct = ct + 1;
    end

    %%
    % calculate the PDF and the log likelihood score for varying a & b
    %%
    sum_mag = sum(mag_events_ab,1)';
    diff_mag = -diff(sum_mag,1);
    [obs_mag,magbin] = hist(obs_events(:,6),magco_fixed-0.05:0.1:7);
    vary_abpdf = poisspdf(obs_mag',diff_mag);

    lvary_ab(:,gloop) = log(vary_abpdf);
    l = isinf(lvary_ab(:,gloop));
    lvary_ab(l,gloop) = -350;

    %%
    % calculate the PDF and the log likelihood score for varying a & constant b
    %%
    sum_mag = sum(mag_events_a,1)';
    diff_mag = -diff(sum_mag,1);
    %[obs_mag,vary_amagbin] = hist(obs_events(:,6),magco_fixed-0.05:0.1:7);
    vary_apdf = poisspdf(obs_mag',diff_mag);

    lvary_a(:,gloop) = log(vary_apdf);
    l = isinf(lvary_a(:,gloop));
    lvary_a(l,gloop) = -350;

    %%
    % calculate the PDF and the log likelihood score for Generic model -- a tapered away from fault
    %%
    sum_mag = sum(mag_events_gca,1)';
    diff_mag = -diff(sum_mag,1);
    %[obs_mag,gca_magbin] = hist(obs_events(:,6),magco_fixed-0.05:0.1:7);
    gca_pdf = poisspdf(obs_mag',diff_mag);

    lgca(:,gloop) = log(gca_pdf);
    l = isinf(lgca(:,gloop));
    lgca(l,gloop) = -350;

    %%
    % calculate the PDF and the log likelihood score for Generic model -- a tapered away from fault
    %%
    sum_mag = sum(mag_events_ss,1)';
    diff_mag = -diff(sum_mag,1);
    ss_pdf = poisspdf(obs_mag',diff_mag);

    lss(:,gloop) = log(ss_pdf);
    l = isinf(lss(:,gloop));
    lss(l,gloop) = -350;
end
end

slvary_ab = sum(lvary_ab,2);
slvary_a = sum(lvary_a,2);
slgca = sum(lgca,2);
slss = sum(lss,2);


figure
pl1 = plot(magbin',cumsum((slgca)),'b');
set(pl1,'LineWidth',2.0);
hold on
pl2 = plot(magbin',cumsum(slvary_a),'k');
set(pl2,'LineWidth',2.0);

pl3 = plot(magbin',cumsum(slvary_ab),'y');
set(pl3,'LineWidth',2.0);

pl4 = plot(magbin',cumsum(slss),'g');
set(pl3,'LineWidth',2.0);

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
xlabel('Magnitude')
ylabel('Ln(P)')
legend([pl1,pl2,pl3 pl4],'Generic CA Forecast','Variable a Forecast','Variable a&b Forecast','Sequence Specific','location', 'SouthWest');


str2 = ['Log Likelihood sum: Generic CA: ' num2str(sum(slgca)) ];
str3 = ['Log Likelihood sum: Sequence Specific: ' num2str(sum(slss)) ];
str4 = ['Log Likelihood sum: Variable a: ' num2str(sum(slvary_a))  ];
str5 = ['Log Likelihood sum: Variable a&b: ' num2str(sum(slvary_ab))  ];

%str5 = ['Fixed Mc: A,b,c,p = ' num2str(fa,'%5.2f'),', ', num2str(fb,'%5.2f'),', ', num2str(fc,'%5.2f'),', ', num2str(fp,'%5.2f')];
%str6 = ['Variable Mc: A,b,c,p = ' num2str(va,'%5.2f'),', ', num2str(vb,'%5.2f'),', ', num2str(vc,'%5.2f'),', ', num2str(vp,'%5.2f')];
%str7 = ['Filled Mc: A,b,c,p = ' num2str(fia,'%5.2f'),', ', num2str(fib,'%5.2f'),', ', num2str(fic,'%5.2f'),', ', num2str(fip,'%5.2f')];

axes('pos',[0 0 1 0.5 ])
axis off
text(0.45,0.85,str2)
text(0.45,0.8,str3)
text(0.45,0.75,str4)
text(0.45,0.70,str5)
axes('pos',[.5 .7 .4 .2])
axis off
%text(0,.90,str5)
%text(0, .750, str6)
%text(0,.60, str7)
compflag = 'of';
