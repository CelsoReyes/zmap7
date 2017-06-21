%%
%
% This version is the working version from Pasadena 12/00
% it uses a single Mc cut, not a time variable cut.
% this is the most basic version of the pval code
%
%
%
%%

global m0 m events t dt obs_events calc_events maxt pl1
global bvm cut_cat all_minx fval tstep_tmp disc_events
global ncst length_log vts calc_time synth_events
global calc_sd  calc_ed pre_events daymc pl2  binv cua
global magco_fixed comp_flag



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
mmc = [];

report_this_filefun(mfilename('fullpath'));
m0 = maepi(1,6);
dt = .1;
%%
% get GUI input for time interval for calculation
% and for prediction.
%%

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
% get catalog ffrom the plot cumulative number window
%%
tcut_cat = newt2;
hold_newt2 = newt2;
%%
% transform input days to decimal years
%%
calc_start = maepi(:,3) + calc_sd/365.0;
calc_end = maepi(:,3) + calc_ed/365.0;
fore_start = maepi(:,3) + fore_sd/365.0;
fore_end = maepi(:,3) + fore_ed/365.0;
endt = (calc_ed-calc_sd);




%%
% error check on GUI values
%%
maxt = (max(newt2.Date)-min(newt2.Date)+(0.05/365))*365;
if (calc_ed-calc_sd) > maxt
    disp('Less days in catalog that calculation period');
    return;
end



%%
% the following line is to take care of last eq's missed in
% bwith t calc
%%
m = min(newt2.Magnitude);



%%
% cut the events to the correct days
%
%%

ll = tcut_cat(:,3) <= calc_end;
cut_cat = tcut_cat(ll,:);
ll = cut_cat(:,3) < calc_start;
[pre_events,dump] = size(cut_cat(ll,3));
ll = cut_cat(:,3) > calc_start;
cut_cat=cut_cat(ll,:);

%%
% bvm from bwithtimc_nogui is used in the plot and c determination
% DO NOT USE THIS Mc
% calculate Mc in 100 event steps, returned in bvm
% same tool as for b with time
% defaults to best of 90 or 95% option
% ni is step size for Mc calc Set in bwithtimc_nogui too
%%
% use all events to compute mc
if exist('cutcat_flag') == 0
    keep_newt2 = newt2;
    newt2 = cut_cat;
    bwithtimc_nogui;
    newt2 = keep_newt2;
end




%%
% calculate b value for entire sequence and get stand dev
% and use for constraints in search
%%
tmp_newt2=newt2;
newt2=cut_cat;
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
% of the data.  Used only for plotting
%%
[xb,yb] = size(bvm);
numpoly = min(xb-1,10);
csday = cumsum(bvm(:,5));
[pcof] = polyfit(csday,bvm(:,4),numpoly);
smoo_mc = polyval(pcof,csday);
mmc(1:length(csday)) = magco;


figure
pbvm = plot(csday,bvm(:,4),'-mo');
hold on
psm = plot(csday,smoo_mc,'-b');
pmag = plot(csday,mmc,'k-');
xlabel('days')
ylabel('Mc')
legend([pbvm,psm,pmag],'Mc in 100 event steps','Smoothed Mc','Mc cut','location','northeast');


tlen = calc_ed;

%%
% get GUI input for fixed mc
%%

prompt   = {'The calculated Mc is as follows, this value may be adjusted.'};
title    = 'Fixed Magnitude of Completeness';
lines = 1;
def     = {num2str(magco)};
answer   = inputdlg(prompt,title,lines,def);
magco_fixed = str2double(answer{1,1});


%%
% cut the catalog at the given Mc
%%
ll = cut_cat(:,6) >= magco_fixed - .05;
cut_cat = cut_cat(ll,:);

disp(['Number of events used: ',num2str(length(cut_cat))]);


%%
% see if cmin should be increased based on fixed Mc cutting
%%
cmin = .05;

for cib = 1:length(bvm)
    if bvm(cib,4) <= magco_fixed
        cmin = (bvm(cib,2)-maepi(1,3))*365
        break
    end
    if cib == length(bvm)
        disp('%%%ERROR%%% -- no bins complete to the Mc cut!!');
        return
    end
end

%create initial obs_events
binv = maepi(:,3)+0.05/365:dt/365:maepi(:,3)+calc_ed/365;
[nn,pdfbin] = histc(cut_cat(:,3),binv);
obs_events = cumsum(nn(1:length(nn)));

tbin = (binv-maepi(1,3))*365;
smc = interp1(csday,smoo_mc,tbin,'linear',smoo_mc(1));

%if compflag == 'of'
%    figure
%    pl1 = plot(obs_events,'-rx');
%    hold on
%    pl2 = plot(obs_events+50,'b');
%    legend([pl1,pl2],'Observed','Calculated Events',2);
%    drawnow
%end

vlb = [-3.5 bv0 cmin -0.30];
vub = [-1.0 bv0 cmin 1.99];
minx = [-2.00 bv0 cmin 2.0];

lobs = [];
Ap = [];
Aparmas = [];
Ap2=[];
lamda= [];
nlAp2=[];
obs = diff(obs_events(1:length(binv)));
dll = obs > 0;
nobs = obs(dll);
lobs = log10(nobs);

Mm=maepi(:,6)-magco_fixed;
cfixed = cmin;

stbin = tbin(2:length(tbin));
stbin = stbin(dll);
ll = length(stbin);
Aparams = zeros(ll,2);
Aparams(1:ll,1) = 1;
Aparams(1:ll,2) = Mm;


for i = 1:length(stbin)-1
    nlAp2(i) = ((stbin(i+1)-stbin(i)));
end
nlAp2 = [nlAp2 nlAp2(length(nlAp2'))]';
Ap2 = log10(nlAp2);

Ap = -log10(stbin+cfixed)';
Aparams = cat(2,Aparams,Ap);
id= eye(3);
id(1,1) = 1/10000;
id(3,3) = 1/10000;
id(2,2) = 1/10;
apri = [-1.67/10000 bv0/10 1.08/10000]';

lamda = (lobs-Ap2);
lamda = [lamda;apri];
Aparams = [Aparams; id];

valinv = Aparams\(lamda)

%options = optimset('Display','iter','Diagnostics','on','HessUpdate','dfp',...
%   'TolX',.000002,'TolFun',.0000001,'DiffMinChange',1e-3,...
%   'DiffMaxChange',.01)
%[x,fval] = fmincon('norm(func_omoris(x))',minx,[],[],[],[],vlb,vub,[],options);
%fval = [];

%rjA = log(10x(1))-bv0*(maepi(1,6)-magco_fixed);
x=[];
x(1) = valinv(1);
x(2) = bv0;
x(3) = cfixed;
x(4) = valinv(3);

if compflag == 'of'

    %%
    % plot results
    %%
    figure
    p1 = plot(newt2.Date,1:newt2.Count,'.k','MarkerSize',3);
    hold on
    l = cut_cat(:,3) > maepi(1,3) + x(3)/365;
    p2 = plot(cut_cat(l,3),1:length(cut_cat(l,3)),'.y','MarkerSize',6);
    p3 = plot(binv,obs_events,'r-.');
    %p4 = plot(binv,cumsum(calc_events),'b');

    obs = max(obs_events);

    forecast_omoris;
    p5 = plot(fore_time,(cumsum(fore_events)+obs+pre_events),'ms','Markersize',4);

    di = (max(obs_events) - sum(calc_events))

    legend([p1,p2,p3,p5],'Original','Cut in M','Observed','Forecast','Location', 'NorthWest');

    axes('Position',[.7,.1,.2,.2],'Box','on')
    axis off
    text(.1,.6,['A = ',num2str(x(1))]);
    text(.1,.45,['b = ',num2str(x(2))]);
    text(.1,.3,['c = ',num2str(x(3))]);
    text(.1,.15,['p = ',num2str(x(4))]);
end

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

newt2 = hold_newt2;


