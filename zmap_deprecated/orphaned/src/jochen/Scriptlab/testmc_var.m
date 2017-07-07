%% Skritp to test Mc determination
%
% Stretch
% %mFirstCatalog
% mSecondCatalog = mFirstCatalog;
% mSecondCatalog(:,6) = 1.2*mSecondCatalog(:,6);
% [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange2(mFirstCatalog, mSecondCatalog);
% [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM2(mFirstCatalog, mSecondCatalog);
% [fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch2(mFirstCatalog, mSecondCatalog);
% [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(mFirstCatalog, mSecondCatalog);
% [fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_llh_stretch_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans2(mFirstCatalog, mSecondCatalog);
% [fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_llh_dMdSrate(mFirstCatalog, mSecondCatalog);
% vBic1 = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
% pause
% Shift
mSecondCatalog = mFirstCatalog;
mSecondCatalog(:,6) = mSecondCatalog(:,6)+0.3;
[fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange2(mFirstCatalog, mSecondCatalog);
[fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM2(mFirstCatalog, mSecondCatalog);
[fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch2(mFirstCatalog, mSecondCatalog);
[fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(mFirstCatalog, mSecondCatalog);
[fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(mFirstCatalog, mSecondCatalog);
[fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_llh_stretch_rate2(mFirstCatalog, mSecondCatalog);
[fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans2(mFirstCatalog, mSecondCatalog);
[fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_llh_dMdSrate(mFirstCatalog, mSecondCatalog);
vBic2 = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]

% % Shift und Stretch
% mSecondCatalog = mFirstCatalog;
% mSecondCatalog(:,6) = 1.2*mSecondCatalog(:,6)+0.3;
% [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange2(mFirstCatalog, mSecondCatalog);
% [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM2(mFirstCatalog, mSecondCatalog);
% [fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch2(mFirstCatalog, mSecondCatalog);
% [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(mFirstCatalog, mSecondCatalog);
% [fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_llh_stretch_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans2(mFirstCatalog, mSecondCatalog);
% [fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_llh_dMdSrate(mFirstCatalog, mSecondCatalog);
% vBic3 = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
%
% % Shift and Rate
% mSecondCatalog = mFirstCatalog;
% mSecondCatalog(:,6) = mSecondCatalog(:,6)+0.3;
% mSecondCatalog = [mSecondCatalog; mSecondCatalog];
% [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange2(mFirstCatalog, mSecondCatalog);
% [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM2(mFirstCatalog, mSecondCatalog);
% [fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch2(mFirstCatalog, mSecondCatalog);
% [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(mFirstCatalog, mSecondCatalog);
% [fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_llh_stretch_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans2(mFirstCatalog, mSecondCatalog);
% [fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_llh_dMdSrate(mFirstCatalog, mSecondCatalog);
% vBic4 = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
%
% % Stretch and Rate
% mSecondCatalog = mFirstCatalog;
% mSecondCatalog(:,6) = 1.2*mSecondCatalog(:,6);
% mSecondCatalog = [mSecondCatalog; mSecondCatalog];
% [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange2(mFirstCatalog, mSecondCatalog);
% [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM2(mFirstCatalog, mSecondCatalog);
% [fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch2(mFirstCatalog, mSecondCatalog);
% [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(mFirstCatalog, mSecondCatalog);
% [fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_llh_stretch_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans2(mFirstCatalog, mSecondCatalog);
% [fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_llh_dMdSrate(mFirstCatalog, mSecondCatalog);
% vBic5 = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
%
% % All
% mSecondCatalog = mFirstCatalog;
% mSecondCatalog(:,6) = 1.2*mSecondCatalog(:,6)+0.3;
% mSecondCatalog = [mSecondCatalog; mSecondCatalog];
% [fProb_nochange, fBic_nochange] = calc_loglikelihood_nochange2(mFirstCatalog, mSecondCatalog);
% [fdM, fProb_dM, fBic_dM, mLikeli_dM] = calc_loglikelihood_dM2(mFirstCatalog, mSecondCatalog);
% [fS, fProb_stretch, fBic_stretch, mLikeli_dS] = calc_loglikelihood_stretch2(mFirstCatalog, mSecondCatalog);
% [fFac, fProb_Rate, fBic_Rate, mLikeli_Rate] = calc_loglikelihood_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_rate, fdM_Fac, fProb_dMrate, fBic_dMrate, mLikeli_dMrate] = calc_loglikelihood_dM_rate2(mFirstCatalog, mSecondCatalog);
% [fdS_rate, fdS_Fac, fProb_dSrate, fBic_dSrate mLikeli_dSrate] = calc_llh_stretch_rate2(mFirstCatalog, mSecondCatalog);
% [fdM_st, fStretch, fProb_Trans, fBic_Trans, mLikeli_Trans] = calc_loglikelihood_Trans2(mFirstCatalog, mSecondCatalog);
% [fdM_all, fdS_all, fFac_all, fProb_all, fBic_all, mLikeli_all] = calc_llh_dMdSrate(mFirstCatalog, mSecondCatalog);
% vBic6 = [fBic_nochange; fBic_dM; fBic_stretch; fBic_Rate; fBic_dMrate;  fBic_Trans; fBic_dSrate; fBic_all]
