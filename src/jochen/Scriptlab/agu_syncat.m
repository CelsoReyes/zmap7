% Matlab-Script: agu_syncat.m
%
% Produce synthetic catalog with different alterations at specific regions
% Use actual catalog in ZMAP (syncat_10000_b1_Mc1.mat)
mCat = a;

% Produce second time period
mCat1 = mCat;
mCat2 = mCat;
mCat2(:,3) = mCat2(:,3)+6;

% Manipulations on second time period catalog
% Shift
vSel = (mCat2(:,1) <= -116.2 & mCat2(:,2) >= 34.8);
mCat2(vSel,6) = mCat2(vSel,6)+0.2;

% Stretch
vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) >= 34.8);
mCat2(vSel,6) = 1.2.*mCat2(vSel,6);
%
% Rate
vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) < 34.8 & mCat2(:,2) >= 34.6);
mCat2 = [mCat2; mCat2(vSel,:)];
%
% Shift and Stretch
vSel = (mCat2(:,1) <= -116.2 & mCat2(:,2) < 34.6 & mCat2(:,2) >= 34.4);
mCat2(vSel,6) = 1.2.*mCat2(vSel,6)+0.2;
%
% Shift and Rate
vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) < 34.6 & mCat2(:,2) >= 34.4);
mCat2(vSel,6) = mCat2(vSel,6)+0.2;
mCat2 = [mCat2; mCat2(vSel,:)];
%
% Stretch and Rate
vSel = (mCat2(:,1) <= -116.2 & mCat2(:,2) < 34.4);
mCat2(vSel,6) = 1.2.*mCat2(vSel,6);
mCat2 = [mCat2; mCat2(vSel,:)];

% Shift, Stretch, Rate
vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) < 34.4);
mCat2(vSel,6) = 1.2.*mCat2(vSel,6)+0.2;
mCat2 = [mCat2; mCat2(vSel,:)];
%
% Catalog
mSynCat = [mCat1; mCat2];
