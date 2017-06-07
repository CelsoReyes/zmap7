%%
% forecast_omoris.m  creates a forecast of the number of
% events based on the out put from one of the omoris files
%
% av = minx(1) bv = minx(2) c = minx(3) p = minx(4)
%%

%global m0 m events dt obs_events newt2 maepi calc_events maxt pl1
%global  bvm cut_cat all_minx fval tstep_tmp disc_events
%global ncst calc_time length_log vts tstep_tmp synth_events

report_this_filefun(mfilename('fullpath'));

fore_events = [];
fore_time = [];

mcd = min(daymc);

t = fore_sd:dt:fore_ed;

%fore_events =   x(1) * (t+x(2)).^(-x(3));
fore_events = 10^(x(1)+x(2)*(maepi(1,6)-rmean_mc))*(t+x(3)).^(-x(4))*dt;
fore_time = maepi(1,3) + t/365;

