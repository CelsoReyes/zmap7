%% Skritp to test Mc determination
%
mCatalog = newt2;

plot_McCdf2(mCatalog, 0.1);
pause

[vProbMin, vMcBest, mMag_bstsamp, fStd_Mc, fConfLow, fConfUp] = calc_BstMc(newt2,0.1);

figure_w_normalized_uicontrolunits(10)
histogram(vMcBest)
