% Matlab-Script: seisshift.m
% Script to evaluate increase and decrease of seismicity
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 04.09.02

% Track changes:
% 04.09.02 : Changed fcumulsum to calc_cumulsum

report_this_filefun(mfilename('fullpath'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END Header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Load data file %%%%%%%%
%%  Data is stored in catalog matrix a in the ZMAP form
%%% lon lat year month day mag depth hour min
mCatalog = ga; % Catalog initialazation
fSplitTime = mean(mCatalog(:,3));
fLastDate = max(mCatalog(:,3));
fFirstDate = min(mCatalog(:,3));

% [mCatalog1, mCatalog2, fPeriodExact1, fPeriodExact2, fPeriod, fPeriod2] = ...
%     ex_SplitCatalog(mCatalog, fSplitTime, 0, 0, 0, 0);
[mCatalog1, mCatalog2, fPeriodExact1, fPeriodExact2, fPeriod, fPeriod2] = ...
     ex_SplitCatalog(ga, 1984.7, 1, 1, 1,1);
maxmag = max(mCatalog1(:,6))
maxmag2 = max(mCatalog2(:,6))


[ev_val mags ev_valsum ev_valsum_rev,  mags_rev] =calc_cumulsum(mCatalog1);
[ev_val2 mags2 ev_valsum2 ev_valsum_rev2,  mags_rev2] =calc_cumulsum(mCatalog2);

% Figures
if exist('h_mag_fig','var') & ishandle(h_mag_fig)
    set(0,'Currentfigure',h_mag_fig);
    disp('Figure exists');
else
    h_mag_fig=figure_w_normalized_uicontrolunits('tag','ev_hist','Name','Magnitude histogram','Units','normalized','Nextplot','add',...
        'Numbertitle','off');
    h_mag_axs=axes('tag','ax_ev_hist','Nextplot','add','box','on');
end

xmag=max([maxmag maxmag2]); % Define length of x-axis

% Figure: Magnitude historgrams

subplot(2,1,1);
set(gca,'tag','ax_ev_hist1','Nextplot','replace','box','on');
axs1=findobj('tag','ax_ev_hist1');
axes(axs1(1));
histogram(mCatalog1(:,6),mags)
axis([0 xmag 0 max(ev_val)]);
ylabel('Events');
subplot(2,1,2);
set(gca,'tag','ax_ev_hist2','Nextplot','replace','box','on');
axs2=findobj('tag','ax_ev_hist2');
axes(axs2(1));
histogram(mCatalog2(:,6),mags2);
fig_hd1 = findobj(gca,'Type','patch');
set(fig_hd1,'FaceColor',[0 0.5 0])
axis([0 xmag 0 max(ev_val2)]);
ylabel('Events');
xlabel('Magnitude')



if exist('cum_mag_fig','var') &  ishandle(cum_mag_fig)
   set(0,'Currentfigure',cum_mag_fig);
   disp('Figure exists');
else
    cum_mag_fig=figure_w_normalized_uicontrolunits('tag','cumFMD','Name','Cumulative FMD','Units','normalized','Nextplot','add','Numbertitle','off');
    cum_mag_axs=axes('tag','ax_cumFMD','Nextplot','add','box','on');
end
% Figure: Bar and cumulative sums

subplot(2,1,1);
set(gca,'tag','ax_cumFMD1','Nextplot','replace','box','on');
axs3=findobj('tag','ax_cumFMD1')
axes(axs3(1));
plot(mags,ev_val,'-o',mags2,ev_val2,'-*')
ylabel('Non-cumulative number of events ');
subplot(2,1,2);
set(gca,'tag','ax_cumFMD2','Nextplot','replace','box','on','Yscale','log');
axs4=findobj('tag','ax_cumFMD2')
axes(axs4(1));
semilogy(mags,ev_valsum,'-o','Color',[0 0 1])
hold on;
semilogy(mags_rev,ev_valsum_rev,'-o','Color',[0 0 1])
semilogy(mags2,ev_valsum2,'-*','Color',[0 0.5 0])
semilogy(mags_rev2,ev_valsum_rev2,'-*','Color',[0 0.5 0])
ylabel('Cumulative sum');
xlabel('Magnitude')
hold off;

%% Difference illustrations
[params] = calc_totdiff(mCatalog, fSplitTime);

params.dNdiffsum
params.dNdiffsumYearVal
params.dNdiffsumMonthVal

if exist('hDiff_fig','var') &  ishandle(hDiff_fig)
   set(0,'Currentfigure',hDiff_fig);
   disp('Figure exists');
else
    hDiff_fig=figure_w_normalized_uicontrolunits('tag','hDiff','Name','Normalized differences','Units','normalized','Nextplot','add','Numbertitle','off');
    hDiff_axs=axes('tag','ax_hDiff','Nextplot','add','box','on');
end

subplot(3,1,1);
set(gca,'tag','ax_hDiff1','Nextplot','replace','box','on');
axs5=findobj('tag','ax_hDiff1')
axes(axs5(1));
bar(params.dMags,params.dNdiff);
ylabel('Seismicity difference');

subplot(3,1,2);
set(gca,'tag','ax_hDiff2','Nextplot','replace','box','on');
axs6=findobj('tag','ax_hDiff2')
axes(axs6(1));
bar(params.dMags,params.dNdiffYear)
ylabel(' Normalized per year');

subplot(3,1,3);
set(gca,'tag','ax_hDiff3','Nextplot','replace','box','on');
axs7=findobj('tag','ax_hDiff3')
axes(axs7(1));
bar(params.dMags,params.dNdiffMonth)
ylabel(' Normalized per month');
