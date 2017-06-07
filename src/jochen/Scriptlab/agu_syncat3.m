% Matlab-Script: agu_syncat3.m
%
% Produce synthetic catalog with different alterations at specific regions
% Use actual catalog in ZMAP (syncat_NCSN_b1_Mc1_realloc.mat)
mCat = a;

% Produce second time period
mCat1 = mCat;
mCat2 = mCat;
mCat2(:,3) = mCat2(:,3)+(max(mCat(:,3))-min(mCat(:,3)));

% Manipulations on second time period catalog
% Shifts
mPos = [-122.5 40];
fSpaceDeg = 0.5;
mPos = repmat(mPos,length(mCat2(:,1)), 1);
mDist = abs(distance(mCat2(:,1), mCat2(:,2), mPos(:,1), mPos(:,2)));
vSel = (mDist <= fSpaceDeg) ;
mCat2(vSel,6) = mCat2(vSel,6)+0.3;
mCatShift = mCat2(vSel,:);

fSpaceDeg2 = 1.5;
vSel = (mDist > fSpaceDeg & mDist <= fSpaceDeg2);
mCat2(vSel,6) = mCat2(vSel,6)+0.2;
mCatShift = [mCatShift; mCat2(vSel,:)];

% Rate
mPos = [-118 36];
fSpaceDeg = 0.5;
mPos = repmat(mPos,length(mCat2(:,1)), 1);
mDist = abs(distance(mCat2(:,1), mCat2(:,2), mPos(:,1), mPos(:,2)));
vSel = (mDist <= fSpaceDeg) ;
mCat2 = [mCat2; mCat2(vSel,:); mCat2(vSel,:)];
mCatRate = mCat2(vSel,:);

fSpaceDeg2 = 1;
vSel = (mDist > fSpaceDeg & mDist <= fSpaceDeg2);
mCat2(vSel,6) = mCat2(vSel,6);
mCat2 = [mCat2; mCat2(vSel,:)];
mCatRate = [mCatRate; mCat2(vSel,:)];


% Stretch 1.2 and Rate 2
% mPos = [-125 34]
% fSpaceDeg = 1;
% mPos = repmat(mPos,length(mCat2(:,1)), 1);
% mDist = abs(distance(mCat2(:,1), mCat2(:,2), mPos(:,1), mPos(:,2)));
% vSel = (mDist <= fSpaceDeg) ;
% mCat2(vSel,6) = 1.2.*mCat2(vSel,6);
% mCat2 = [mCat2; mCat2(vSel,:); mCat2(vSel,:)];
% mCatStretchRate = mCat2(vSel,:);

%vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) >= 34.8);
% mCat2(vSel,6) = 1.2.*mCat2(vSel,6);
% %
% % Rate
% vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) < 34.8 & mCat2(:,2) >= 34.6);
% mCat2 = [mCat2; mCat2(vSel,:)];
% %
% % Shift and Stretch
% vSel = (mCat2(:,1) <= -116.2 & mCat2(:,2) < 34.6 & mCat2(:,2) >= 34.4);
% mCat2(vSel,6) = 1.2.*mCat2(vSel,6)+0.2;
% %
% % Shift and Rate
% vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) < 34.6 & mCat2(:,2) >= 34.4);
% mCat2(vSel,6) = mCat2(vSel,6)+0.2;
% mCat2 = [mCat2; mCat2(vSel,:)];
% %
% % Stretch and Rate
% vSel = (mCat2(:,1) <= -116.2 & mCat2(:,2) < 34.4);
% mCat2(vSel,6) = 1.2.*mCat2(vSel,6);
% mCat2 = [mCat2; mCat2(vSel,:)];
%
% % Shift, Stretch, Rate
% vSel = (mCat2(:,1) > -116.2 & mCat2(:,2) < 34.4);
% mCat2(vSel,6) = 1.2.*mCat2(vSel,6)+0.2;
% mCat2 = [mCat2; mCat2(vSel,:)];
%
% Catalog
mSynCat = [mCat1; mCat2];
