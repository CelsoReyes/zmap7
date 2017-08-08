%In order to analyse the parameters in the "Modified Omori Law" for aftershock sequences, especially the p-value, please take into account the following:

%1. The routines are available from the "Cumulative Number" window
%   or from "Seismicity Map Window" - for mapping of parameters.
%   Thus, the file timeplot.m and
%   update(mainmap()).m have options to call the relevant routines. Besides,
%   the cross-sectional mapping is available from "Cross-section Window".
%2. Before starting analysing the data, please execute the following
%   command in "Matlab Command Window": set(0, 'recursionlimit', 510).
%   It can be any other
%   number greater or equal than 502 instead of 510. The reason for this
%   command is that the routine for determining the parameters in the
%   Omori formula, ploop_c_and_p_calcs.m, works by recursion and the default of
%   Matlab has a maximum of 500 recursive calls.
%3. The file opened for analysis should contain the mainshock. Please
%   be sure to open the "Cumulative Number Window" at least ones before
%   starting any analysis.
%   This is because the mainshock information is contained in the matrix
%   "ZG.maepi", which is not defined until you open the "Cumulative Number
%   Window". After this,
%   please eliminate the mainshock, by filtering the catalog in magnitude.
%4. There are several files which permit the analysis of the parameters in
%   Omori formula. You can modify them on your convenience:
%   - src/declus/pvalcat.m - starts computation of p, c and k and their
%     standard deviations for the catalog displayed in the "Cumulative
%     Number Window".
%     You can choose the threshold magnitude, the starting time (in days)
%     after the mainshock and if the value of c is fixed or not. If you
%     want a fix c, you can
%     choose its value.
%   - src/declus/pvalcat2.m - determines p, c and K for different
%     magnitude thresholds and different starting times and presents them
%     as a map. You have to choose
%     the minimum and maximum threshold magnitude, the minimum and maximum
%     starting time and a step for each of them.
%   - src/bpvalgrid.m - computes the spatial (map) distribution of p, b
%     and Mc values for an aftershock sequence. Interactively you can choose
%     several parameters.
%     You can save your grid of values and use it at a later time.
%   - src/view_bpva.m - plots map of b, p, Mc values, computed before with
%     bpvalgrid.m.
%   - src/pcrossnew - compute the spatial (cross-section) distribution of p,
%     b and Mc values. Interactively you can choose several parameters.
%   - src/view_bpvs.m - plots map of b, p, Mc values, computed before with
%     pcrossnew.m.
%   - src/declus/mypval2m.m - interface between the programmes pvalcat.m,
%     pvalcat2.m or bpvalgrid.m on one hand and ploop_c_and_p_calcs.m
%     other hand.
%   - src/declus/ploop2.m - this is the routine which computes the p,c and
%     K values in the "Modified Omori Law".
%   - src/declus/ploop3.m - the same as above, but c is fixed (0 or any
%     other value can be chosen). However, if c = 0, ts should not be 0,
%     because when the time
%     approaches 0 the frequency tends to infinity. Please check the routine
%     mypval2m.m to verify ts, the minimum time in the aftershock sequence.
%   - src/adju2.m - filters the results displayed on the map (for spatial
%     variation of parameters) in function of different parameters, including
%     the standard error
%     in p. It is called from src/view_bpva.m.
%   - src/timabs.m - computes the number of minutes from a reference date.
%   - src/afthlp - opens this file (afthelp.m).
%   - afthelp.m - file with explanations regarding the analysis of aftershock
%     sequences (this file).
%5.  Please read the comments in the above mentioned files for further instructions.

% Bogdan Enescu, 5/2001.


%   References:

%  Ogata Y., Estimation of the parameters in the Modified Omori Formula for aftershock sequencies by the maximum likelihood procedure, J. Phys. Earth, 31, 115-
%            -124, 1983.
%  Wiemer, S. and Katsumata, K., Spatial variability of seismicity parameters in aftershock zones, J. Geophys. Res., 104, B6, 13135-13151, 1999.
%  Utsu, T, Ogata, Y., and Matsu'ura, R.S., The centenary of the Omori Formula for a Decay Law of Aftershock Activity., J. Phys. Earth, 43, 1-33, 1995.
%  Reasenberg, P.A., Lucile M. Jones, Earthquake hazard after a mainshock in California, Science, 243, 1173-1176, 1989.
%  Reasenberg, P.A., Lucile M. Jones, California Aftershock Hazard Forecasts, Science, 247, 345-346, 1990.
%  Reasenberg, P.A., Lucile M. Jones, Earthquake Aftershocks: Update, Science, 265, 1251-1252, 1994.
%  Ogata, Y., Seismicity analysis through point-process modelling: a review, Pure Appl. Geophys., 155, 471-507, 1999.
