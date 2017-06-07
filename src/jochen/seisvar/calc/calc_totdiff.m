function [result]=sv_totdiff(mCatalog, fSplitTime)
% function [result]=calc_totdiff(mCatalog, fSplitTime)
% --------------------------------------------------------------------------------------
% Function to calculate absolute difference of number of events between
% to time periods of an earthquake catalog normalized to a year.
%
% Incoming variables:
% mCatalog         : current earthquake catalog
% fSplitTime: Splitting time
%
% Outgoing variable:
% result.dNdiffsumVal      : total difference of number of events in the two time periods
% result.dNdiffsumYearVal  : total difference of number of events in the two time periods normalized to a year
% result.dNdiffsumMonthVal : total difference of number of events in the two time periods normalized to a month
% result.dNdiff            : Difference of seismicity in 0.1 magnitude bins
% result.dNdiffYear        : Difference of seismicity in 0.1 magnitude bins normalized to year
% result.dNdiffMonth       : Difference of seismicity in 0.1 magnitude bins normalized to month (30.5 d)
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 27.06.02

% Check the binning !!!!

% Track changes:
% 04.09.02: Changed fcumulsum to calc_cumulsum
% Init variable
result=[];

% Create the catalogs for the two time peiods
[result.mFirstCatalog, result.mSecondCatalog, result.fFirstPeriodExact, result.fSecondPeriodExact, result.fFirstPeriod,...
        result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, 1, 0.1, 1, 0.1);

[dEv_val dMags dEv_valsum dEv_valsum_rev,  dMags_rev] = calc_cumulsum(result.mFirstCatalog);
[dEv_val2 dMags2 dEv_valsum2 dEv_valsum_rev2,  dMags_rev2] = calc_cumulsum(result.mSecondCatalog);


result.dNdiff = dEv_val2-dEv_val;
result.dNdiffYear=result.dNdiff/365;
result.dNdiffMonth = result.dNdiffYear/12;

result.dNdiffsum = cumsum(result.dNdiff');
result.dNdiffsumVal = result.dNdiffsum(length(result.dNdiffsum));
result.dNdiffsumYearVal = result.dNdiffsumVal/365;
result.dNdiffsumMonthVal = result.dNdiffsumYearVal/12;

result.dMags = dMags;
result.dMags = dMags2;
return
