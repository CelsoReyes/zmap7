% Scipt: view_fast.m
[mCat1 mCat2 fPer1e fPer2e fPer1,  fPer2] = ex_SplitCatalog(a, 1983.33, 1, 1, 1, 1);
[mLMagsig mHMagsig fLZmax fLZmean fLZmin fHZmax fHZmean,  fHZmin] = plot_Magsig(mCat1, mCat2 , fPer1, fPer2, 0.1);
