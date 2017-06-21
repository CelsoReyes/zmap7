%%
%
% This version is the working version from Pasadena 12/00
% it calculates a variable mc cut, but does no infilling of events to an Mc datum
% the version that attempts to implement the inflling is
% monte_omoris2.  and basic_omori does no variable mc cut
%
%%

global m0 m events t dt obs_events calc_events maxt pl1 csday
global bvm tcut_cat all_minx fval tstep_tmp disc_events smoo_mc
global ncst length_log vts calc_time synth_events bv0 smc
global calc_sd calc_ed pre_events daymc pl2 binv cua compflag



all_minx = [];
obs_events=[];
events = [];

synth_events = [];
cutobs_events = [];
nocutobs_events = [];
tstep_tmp = [];
vts = [];
daymc = [];
fval = [];
report_this_filefun(mfilename('fullpath'));
m0 = maepi(1,6);
dt = .1;
avpdf = [];
bvpdf = [];

%%
% get GUI input for time interval for calculation
% and for prediction.
%%

if compflag == 'of'

    prompt   = {'Enter A,b,c,p calculation start time(days):',...
        'Enter calculation end time:',...
        'Enter forecast start time(days):',...
        'Enter forecast end time:'};
    title    = 'Forecast based on A,b,c & p';
    lines = 1;
    def     = {'0','10','10','30'};
    answer   = inputdlg(prompt,title,lines,def);
    calc_sd = str2double(answer{1,1});
    calc_ed = str2double(answer{2,1});
    fore_sd = str2double(answer{3,1});
    fore_ed = str2double(answer{4,1});



    %%
    % transform input days to decimal years
    %%
    calc_start = maepi(:,3) + calc_sd/365.0;
    calc_end = maepi(:,3) + calc_ed/365.0;
    fore_start = maepi(:,3) + fore_sd/365.0;
    fore_end = maepi(:,3) + fore_ed/365.0;
    endt = (calc_ed-calc_sd);


    %%
    % Initial guess
    %%

    %%
    % error check on GUI values
    %%
    maxt = (max(newt2.Date)-min(newt2.Date)+(0.05/365))*365;
    if (calc_ed-calc_sd) > maxt
        disp('Less days in catalog than calculation period');
        return;
    end

end

%%
% cut the catalog to the correct calculation time
%
%%
tcut_cat = newt2;

ll = tcut_cat(:,3) <= calc_end;
tcut_cat = tcut_cat(ll,:);

post_events = length(tcut_cat);

ll = tcut_cat(:,3) >= calc_start;
tcut_cat = tcut_cat(ll,:);

pre_events = post_events - length(tcut_cat);

nocut_cat = tcut_cat;

%%
% calculate Mc in 100 event steps, returned in bvm
% same tool as for b with time
% defaults to best of 90 or 95% option
% ni is step size for Mc calc Set in bwithtimc_nogui too
%%
% use all events to compute mc
if exist('cutcat_flag') == 0
    keep_newt2 = newt2;
    newt2 = tcut_cat;
    bwithtimc_nogui;
    newt2 = keep_newt2;
end


%%
% the following line is to take care of last eq's missed in
% bwith t calc
%%
m = min(newt2.Magnitude);

%%
% calculate b value for entire sequence and get stand dev
% and use for constraints in search
%%
tmp_newt2=newt2;
newt2=tcut_cat;
bdiff_omori;
bmin = bvml-.01*stanml;
bmax = bvml+.01*stanml;
bv = bvml;
bv0 = bvml;
av0 = avml;
newt2=tmp_newt2;
disp(['Initial b value: ',num2str(bvml),'+/-',num2str(stanml)]);

%%
% calculate a 6th order poly fit to the mc
% and find the mean of that for the last third
% of the data.  Use this Mc as the threshold in which to create or remove events
%%
%tcut_cat = newt2;
[xb,yb] = size(bvm);
numpoly = min([abs(xb-1) 10]);
csday = cumsum(bvm(:,5));
[pcof] = polyfit(csday,bvm(:,4),numpoly);
smoo_mc = polyval(pcof,csday);

if numpoly < 10
    %    smoo_mc = interp(csday,bvm(:,4),csday+.01,'spline');

    smoo_mc(1) = bvm(1,4);
end


%%
% This bit calculates the mean mc for the last 1/3 of the data
%
% smc is smoothed Mc curve
% sbvm is the interpolated bvm Mc curve
%%
mc_start = length(smoo_mc)*2/3;
mean_mc = mean(smoo_mc(mc_start:length(smoo_mc)));
rmean_mc = (ceil(mean_mc*10.0))/10.0;

num_dt = (calc_ed-calc_sd)/.1;
%smc = interp1(0:(num_dt)/(length(smoo_mc)-1):num_dt,smoo_mc,1:num_dt);
smc = interp1(csday,smoo_mc,calc_sd+dt:dt:calc_ed,'spline',smoo_mc(1));
mc_cut = smc;
%sbvm = interp1(csday,bvm(:,4),calc_sd+dt:dt:calc_ed,'spline',bvm(1,4));
%mc_cut = sbvm;


%%
% below creates an Mc array with no smoothing
%%
multr = num_dt/length(bvm(:,4));
for rr = 1:num_dt
    rb(rr) = bvm(ceil(rr/multr),4);
end

%mc_cut = rb;

%%
% plot the Mc curves
%%
if compflag == 'of'
    figure
    axes
    pbvm = plot(csday,bvm(:,4),'-o');
    %pbvm = plot(calc_sd+dt:dt:calc_ed,sbvm,'-o');
    hold on
    %psm = plot(csday,smoo_mc,'-k');
    psm = plot(calc_sd+dt:dt:calc_ed,smc,'-k');
    xlabel('days')
    ylabel('Mc')
    legend([pbvm,psm],'Mc in 100 event steps','Smoothed Mc', 'location', 'NorthEast');
end

%%
% cut the data at the smoothed mc
%
%%
mst = maepi(:,3);
for imc = 0:num_dt-1
    llu = tcut_cat(:,3) >= mst+(imc*dt)/365 & tcut_cat(:,3) < mst +(imc*dt+dt)/365 &...
        tcut_cat(:,6) < mc_cut(imc+1);
    if max(llu) > 0
        tcut_cat(llu,:) = [];
        %             mc_cut(imc+1)
        %             sum(llu)
    end

    %ninout(imc+1) = length(tcut_cat(llu,:));
    %%
    % count the number of events in the bin
    %%o
    llo = tcut_cat(:,3) >= mst+(imc*dt)/365 & tcut_cat(:,3) < mst +(imc*dt+dt)/365 ;
    %tcut_cat(:,6) >= smc(imc+1);
    [ninbin(imc+1),dummy] = size(tcut_cat(llo,:));

end
disp(['Number of events used: ',num2str(length(tcut_cat))]);

if compflag == 'on'
    for mcst = 1:length(bvm(:,5))
        llo = tcut_cat(:,3) >= bvm(mcst,2) & tcut_cat(:,3) < bvm(mcst,3) ;
        tmp_newt2=newt2;
        newt2=tcut_cat(llo,:);

        bdiff_omori;
        bvpdf(mcst) = bvml;
        avpdf(mcst) = avml;
        newt2=tmp_newt2;
    end
end

%for imc = 1:length(bvm(:,1))
%   ll = tcut_cat(:,3) >= bvm(imc,2) &   tcut_cat(:,3) < bvm(imc,3) & tcut_cat(:,6) < smoo_mc(imc);
%   if max(ll) > 0
%      tcut_cat(ll,:) = [];
%  end
%end




mati = maepi(1,3);
tmin1 = 0.05;
tlen = calc_ed;

% Run Reasenberg for comparison
%calcp;

%create initial obs_events
binv = maepi(:,3)+0.05/365:dt/365:maepi(:,3)+calc_ed/365;
[nn,binn] = histc(tcut_cat(:,3),binv);
[nnn,binnn] = histc(nocut_cat(:,3),binv);
obs_events = cumsum(nn(1:length(nn)));



tbin = (binv-maepi(1,3))*365;

calc_events = [];
lobs = [];
Ap = [];
Aparmas = [];
Ap2=[];
lamda= [];
nlAp2=[];
valinv = [];
sAparams = [];
ce = [];

obs = diff(obs_events(1:length(binv)));
dll = obs > 0;
nobs = obs(dll);
lobs = log10(nobs);
stbin = tbin(2:length(tbin));
stbin = stbin(dll);
ll = length(stbin);
Aparams = zeros(ll,2);
sAparams(1:ll,1) = 1;

disp('Solving...');
for i = 1:length(stbin)-1
    nlAp2(i) = ((stbin(i+1)-stbin(i)));
    sAparams(i,2) = maepi(:,6) - mc_cut(i);
end
nlAp2 = [nlAp2 nlAp2(length(nlAp2'))]';
Ap2 = log10(nlAp2);
%%
% add on an extra 'Mc at the end
%%
sAparams(ll,2) = maepi(:,6) - mc_cut(ll);

ct = 1;
for cfixed = .01:.01:5.0
    Ap = -log10(stbin+cfixed)';
    Aparams = cat(2,sAparams,Ap);
    id= eye(3);
    id(1,1) = 1/10000;
    id(3,3) = 1/10000;
    id(2,2) = 1/10;
    apri = [-1.67/10000 bv0/10 1.08/10000]';

    slamda = (lobs-Ap2);
    lamda = [slamda;apri];

    Aparams = [Aparams; id];

    valinv(:,ct) = Aparams\(lamda);
    x = valinv(:,ct);

    for tc = 1:length(tbin)
        calc_events(tc) = 10^(x(1)+x(2)*(maepi(1,6)-mc_cut(tc)))*(tbin(tc)+cfixed).^(-x(3))*dt;
        %    calc_events(tc) = 10^(x(1)+x(2)*(maepi(1,6)-smc(tc)))*(tbin(tc)+cfixed).^(-x(3))*dt;
    end
    ce(ct) = norm(obs_events-cumsum(calc_events)');
    ct = ct + 1;
end
[minval,minind] = min(ce);

valmin = valinv(:,minind);
x(1) = valmin(1);
x(2) = valmin(2);
x(3) = .01*minind;
x(4) = valmin(3);
x

if compflag =='of'
    %%
    % plot results
    %%
    figure
    p1 = plot(newt2.Date,1:newt2.Count,'.k','MarkerSize',3);
    hold on
    l = tcut_cat(:,3) > maepi(1,3);
    p2 = plot(tcut_cat(l,3),1:length(tcut_cat(l,3)),'.y','MarkerSize',6);
    %p3 = plot(binv,obs_events,'r-.');
    p4 = plot(binv,cumsum(calc_events),'b');

    obs = max(obs_events);

    forecast_omoriab;
    p5 = plot(fore_time,(cumsum(fore_events)+obs+pre_events),'ms','Markersize',4);

    di = (max(obs_events) - sum(calc_events))

    legend([p1,p2,p4,p5],'Original - No cut','Cut in M','Calculated','Forecast','location','NorthWest');


    axes('Position',[.7,.1,.2,.2],'Box','on')
    axis off
    text(.1,.6,['A = ',num2str(x(1))]);
    text(.1,.45,['b = ',num2str(x(2))]);
    text(.1,.3,['c = ',num2str(x(3))]);
    text(.1,.15,['p = ',num2str(x(4))]);
    % compare the FMD
    %l = tcut_cat(:,3) > maepi(1,3)+fore_sd/365;
    %precat = tcut_cat(l,:);
    %bdiff(precat)
    %hold on
    %tmp = newt2;
    %newt2 = precat;
    %mcperc_ca3
    %axes(cua)
    %synthb_autp
    %plot(PM,10.^PN,'m','linewidth',2);
    %newt2 = tmp;
end

