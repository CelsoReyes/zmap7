%%
% calculates the loglikelihood scores for random simulations
%%

global no1 bo1 inb1 inb2


compflag = 'on';
tmp_newt2 = newt2;


%%
% get the name of the p value grid file and load it
%%

prompt = {'Enter the name of the random simulation file',...
    'Enter the name of the real data file (p value estimation)',...
    'Enter the forecast start time (days from mainshock)',...
    'Enter the forecast end time (days from mainshock)'...
    'Enter the number of random simulations'};
title = 'Filename Input';
lines = 1;
def = {'','','10','15','100'};
answer = inputdlg(prompt,title,lines,def);
rand_in = answer{1,1};
real_in = answer{2,1};
fore_sday = str2double(answer{3,1});
fore_eday = str2double(answer{4,1});
numrand = str2double(answer{5,1});

real_in = 'test.mat';
load(real_in);

%%
% get a b c p and k from input file (in that order) for spatially varying models
%%
tvg(:,1) = bpvg(:,16);
tvg(:,2) = bpvg(:,18);
tvg(:,3) = bpvg(:,14);
tvg(:,4) = bpvg(:,11);
tvg(:,5) = bpvg(:,3);
tvg(:,6) = bpvg(:,4);

rand_in = '100rand.mat';
load(rand_in)
nodes = tmpgri;

%bpvg = rpvg;

%if(bpvg(1,15) == 1)
%         % this grid was not calculated with constant area so stop.
%         disp('%%%%ERROR%%%% This input grid was NOT calculated with constant radius please use one that is.')
%         return
%end

%%
% cut cat to only forecast time period
%%
fore_start = maepi(:,3) + fore_sday/365;
fore_end = maepi(:,3) + fore_eday/365;
ll = tmp_newt2.Date >= fore_start & tmp_newt2.Date <= fore_end;
fore_cat = tmp_newt2(ll,:);

dt = .1
calc_mag = [];
calc_cummag = [];

%%
% call distofault to get the distance from each grid node to the estimated fault
% gx and gy come from the input file
%%

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

%totd = sum(1./(fdkm.^2));
totd = sum(fdkm.^2);
da = -1.67-log(totd);
dssa = ssa/totd;
numevents = length(fore_cat);
for i = 1:length(fdkm)
    id(i) = totd/(fdkm(i)^2);
end
sid =  sum(id);
sler = id/sid;
%%
% gevents is the number of events scaled with distance from fault
% this is not actually observed but is only the number of total
% obs events distributed over the entire grid with number of events
% taper as 1/r^2
%
% a is scaled by subtracting the log of the ratio of number of
% events at the node to the entire number of events from the
% overall a value.
%%
gevents = sler*numevents;
for i = 1:length(gevents)
    tapera(i) = -1.67-log(numevents/gevents(i));
    sstapera(i) = ssa-log(numevents/gevents(i));
end


%plot_tapera(tapera,s1x,s1y,s2x,s2y,tmpgri,xvect,yvect)
magco_fixed = 1.0
lvary_a = [];
lvary_ab = [];
lgca = [];

%%
% calculate the overall b-value
%%
[magml bo1 stanml,  avml] =  bmemag(newt2);

%%
% loop over all grid nodes and calculate various forecasts
%%

allcount = 0;
itotal = length(bpvg);
wait = waitbar(0,'Thinking...');
[lgl dum,  dum] = size(bpvg);
for gloop = 1:itotal
    allcount=allcount+1;

    %%
    %     Calculate the forecast for varying a & b and varying a w/constant b
    %
    %  select the events within the radius used for the parameter calc. (rd) from
    %  the forecast time period, to compare the calculated number of events with
    %%
    xg = bpvg(gloop,3);
    yg = bpvg(gloop,4);
    l = sqrt(((fore_cat(:,1)-xg)*cos(pi/180*yg)*111).^2 + ((fore_cat(:,2)-yg)*111).^2) ;
    [s,is] = sort(l);
    fore_cat = fore_cat(is(:,1),:) ;       % re-orders matrix to agree row-wise

    %%
    % get fore events  w/in the original radius
    %%
    l3 = l <= bpvg(1,5);
    obs_events = fore_cat(l3,:);      % obs_events is the events at the node w/in the radius of the original


    for rand_loop = 1:numrand+1
        if rand_loop == 1  % only calculate these the first time thru -- not for each rand loop


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
            % calculate the PDF and the log likelihood score for the ss model -- a tapered away from fault
            %%
            sum_mag = sum(mag_events_ss,1)';
            diff_mag = -diff(sum_mag,1);
            ss_pdf = poisspdf(obs_mag',diff_mag);

            lss(:,gloop) = log(ss_pdf);
            l = isinf(lss(:,gloop));
            lss(l,gloop) = -350;


            %%
            % get a b c p and k from input file (in that order) for spaitally varying models
            %%
            x(1) = tvg(gloop,1);
            x(2) = tvg(gloop,2);
            x(3) = tvg(gloop,3);
            x(4) = tvg(gloop,4);

        else %% if rand_loop ~= 1
            x(1) = rpvg(gloop, 1, rand_loop-1);
            x(2) = rpvg(gloop, 2, rand_loop-1);
            x(4) = rpvg(gloop, 3, rand_loop-1);
            x(3) = rpvg(gloop, 4, rand_loop-1);
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
        % calculate the PDF and the log likelihood score for Generic model -- a tapered away from fault
        %%
        sum_mag = sum(mag_events_gca,1)';
        diff_mag = -diff(sum_mag,1);
        [obs_mag,gca_magbin] = hist(obs_events(:,6),magco_fixed-0.05:0.1:7);
        gca_pdf = poisspdf(obs_mag',diff_mag);

        lgca(:,gloop) = log(gca_pdf);
        l = isinf(lgca(:,gloop));
        lgca(l,gloop) = -350;

        %%
        % calculate the forecast for each magnitude bin for varying a and constant b
        % bo1 is the constant b value calculated above using max likelihood
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

        lvary_ab(:,gloop,rand_loop) = log(vary_abpdf);
        l = isinf(lvary_ab(:,gloop,rand_loop));
        lvary_ab(l,gloop,rand_loop) = -350;


        %%
        % calculate the PDF and the log likelihood score for varying a & constant b
        %%
        sum_mag = sum(mag_events_a,1)';
        diff_mag = -diff(sum_mag,1);
        [obs_mag,vary_amagbin] = hist(obs_events(:,6),magco_fixed-0.05:0.1:7);
        vary_apdf = poisspdf(obs_mag',diff_mag);

        lvary_a(:,gloop,rand_loop) = log(vary_apdf);
        l = isinf(lvary_a(:,gloop,rand_loop));
        lvary_a(l,gloop,rand_loop) = -350;



        waitbar(allcount/itotal);
    end
end

close(wait);

slvary_ab=[];
slvary_a=[];
gdiffab=[];
gdiffa=[];

%%
% sum the scores
%%
slgca = sum(lgca(:,gloop),2);
slss = sum(lss(:,gloop),2);
[dum numm,  dum] = size(lvary_ab);
for rloop2 = 1:numrand+1
    %%
    % sum the scores at each node
    %%
    slgca(rloop2,1:numm) = sum(lgca(:,:,rloop2),1);
    slvary_ab(rloop2,1:numm) = sum(lvary_ab(:,:,rloop2),1);
    slvary_a(rloop2,1:numm) = sum(lvary_a(:,:,rloop2),1);
    if rloop2 >= 2
        gdiffab(rloop2,1:length(slvary_ab(1,:))) = slvary_ab(rloop2,:) - slgca.subset(rloop2);
        gdiffa(rloop2,1:length(slvary_a(1,:))) = slvary_a(rloop2,:) - slgca.subset(rloop2);
    end
end

meanab = mean(gdiffab,2);
meana = mean(gdiffa,2);

[xll, yll] =size(slvary_ab);
gcatot = sum(slgca);
sstot = sum(slss);
abtot = sum(slvary_ab(2:numrand+1,:));
atot = sum(slvary_a(2:numrand+1,:));

rdabtot = sum(slvary_ab(1,:));
rdatot = sum(slvary_a(1,:));

tdiff = gcatot - abtot;

compflag = 'of';
