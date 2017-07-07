function [result]=sv_timeperdiff(mCatalog, fTimePeriod)
% function [result]=sv_timeperdiff(mCatalog, fTimePeriod)
% --------------------------------------------------------------------------------------
% Function to calculate absolute difference of number of events between
% two time periods of an earthquake catalog
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 08.07.02
%
% Incoming variables:
% mCatalog           : current earthquake catalog
% params.fTimePeriod : Time period in days
%
% Outgoing variable:
% result.dNdiffsumVal      : total difference of number of events in the two time periods
% result.dNdiffsumYearVal  : total difference of number of events in the two time periods normalized to a year
% result.dNdiffsumMonthVal : total difference of number of events in the two time periods normalized to a month
% result.dNdiff            : Difference of seismicity in 0.1 magnitude bins

% Init variable
result=[];

% Create the catalogs for two time periods
fStartTime = min(mCatalog(:,3));
fEndTime = max(mCatalog(:,3);

[result.mFirstCatalog, result.mSecondCatalog, result.fFirstPeriodExact, result.fSecondPeriodExact, result.fFirstPeriod,...
        result.fSecondPeriod] = ex_SplitCatalog(mCatalog, fSplitTime, 0, 100, 0, 100);

[dEv_val dMags dEv_valsum dEv_valsum_rev,  dMags_rev] =fcumulsum(result.mFirstCatalog);
[dEv_val2 dMags2 dEv_valsum2 dEv_valsum_rev2,  dMags_rev2] =fcumulsum(result.mSecondCatalog);


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
