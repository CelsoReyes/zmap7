function plot_svmodel(fdM, fdS, fRf, mCat1, mCat2)
% function plot_svmodel(fdM, fdS, fRf, mCat1, mCat2);
% ---------------------------------------------------
% Function to plot cumulative and non-cumulative FMDs and show fit using
% manipulations on mCat1.
%
% Incoming variables
% fdM    : Magnitude shift
% fdS    : Magnitude stretch
% fRf    : Rate factor
% mCat1  : EQ catalog period 1 -> subject to modification
% mCat2  : EQ catalog period 2
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 30.10.02

% Plt bounds
fMinMag = min([min(mCat1(:,6)) min(mCat2(:,6))]);
fMaxMag = max([max(mCat1(:,6)) max(mCat2(:,6))]);
fPeriod1 = (max(mCat1(:,3))-min(mCat1(:,3)));
fPeriod2 = (max(mCat2(:,3))-min(mCat2(:,3)));

% Model catalog
mCatMod = mCat1;

% Check input variables
bdM = (~isnan(fdM) & ~isempty(fdM) & fdM ~= 0);
bdS = (~isnan(fdS) & ~isempty(fdS) & fdS ~= 0);
bRf = (~isnan(fRf) & ~isempty(fRf) & fRf ~= 0);

% Shift and stretch
if (bdM & bdS)
    mCatMod(:,6) = fdS.*mCatMod(:,6)+fdM;
elseif bdM
    mCatMod(:,6) = mCatMod(:,6)+fdM;
elseif bdS
    mCatMod(:,6) = fdS.*mCatMod(:,6);
else
    mCatMod(:,6) =mCatMod(:,6);
end

% Determine cumulative and non-cumulative sums
[mEv_val mMags mEv_valsum mEv_valsum_rev,  mMags_rev] = calc_cumulsum(mCat1);
[mEv_val2 mMags2 mEv_valsum2 mEv_valsum_rev2,  mMags_rev2] = calc_cumulsum(mCat2);
[mEv_valMod mMagMod mEv_valsumMod mEv_valsum_revMod,  mMags_revMod] = calc_cumulsum(mCatMod);

% Apply rate factor
if bRf
   mEv_valMod = mEv_valMod.*fRf;
   mEv_valsumMod = mEv_valsumMod.*fRf;
   mEv_valsum_revMod = mEv_valsum_revMod.*fRf;
end

% Time normalization
mEv_val2 = mEv_val2./fPeriod2;
mEv_valsum2 = mEv_valsum2./fPeriod2;
mEv_valsum_rev2 = mEv_valsum_rev2./fPeriod2;
mEv_val = mEv_val./fPeriod1;
mEv_valsum = mEv_valsum./fPeriod1;
mEv_valsum_rev = mEv_valsum_rev./fPeriod1;
mEv_valMod = mEv_valMod./fPeriod1;
mEv_valsumMod = mEv_valsumMod./fPeriod1;
mEv_valsum_revMod = mEv_valsum_revMod./fPeriod1;

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
axs3=findobj('tag','ax_cumFMD1');
axes(axs3(1));
plot(mMags,mEv_val,'-o',mMags2,mEv_val2,'-*');
hold on;
plot(mMagMod, mEv_valMod,'r-^');
ylabel('Non-cumulative sum ');
hold off;
set(gca,'Xlim',[floor(fMinMag) ceil(fMaxMag)]);
legend('Period 1', 'Period 2','Model');
% subplot(3,1,2);
% set(gca,'tag','ax_cumFMD2','Nextplot','replace','box','on','Yscale','log');
% axs4=findobj('tag','ax_cumFMD2');
% axes(axs4(1));
% semilogy(mMags,mEv_valsum,'-o','Color',[0 0 1]);
% hold on;
% semilogy(mMags2,mEv_valsum2,'-*','Color',[0 0.5 0]);
% semilogy(mMagMod, mEv_valsumMod, '-^','Color',[1 0 0]);
% ylabel('Cumulative sum');
% hold off;
% fMaxEv = max([max(mEv_valsumMod) max(mEv_valsum2) max(mEv_valsum)]);
% set(gca,'Xlim',[floor(fMinMag) ceil(fMaxMag)],'Ylim', [0 ceil(fMaxEv)]);
subplot(2,1,2);
set(gca,'tag','ax_cumFMD3','Nextplot','replace','box','on','Yscale','log');
axs5=findobj('tag','ax_cumFMD3');
axes(axs5(1));
semilogy(mMags_rev,mEv_valsum_rev,'-o','Color',[0 0 1])
hold on;
semilogy(mMags_rev2,mEv_valsum_rev2,'-*','Color',[0 0.5 0])
semilogy(mMags_revMod, mEv_valsum_revMod, '-^','Color',[1 0 0]);
ylabel('Cumulative sum');
xlabel('Magnitude')
hold off;
set(gca,'Xlim',[floor(fMinMag) ceil(fMaxMag)],'Ylim', [0 ceil(fMaxEv)]);
