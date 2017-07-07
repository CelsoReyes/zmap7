% Rate
mPos = [-118 36];
fSpaceDeg = 1;
mPos = repmat(mPos,length(mSynCat(:,1)), 1);
mDist = abs(distance(mSynCat(:,1), mSynCat(:,2), mPos(:,1), mPos(:,2)));
vSel = (mDist <= fSpaceDeg) ;
mCatRate = mSynCat(vSel,:);
plot(mCatRate(:,1),mCatRate(:,2),'r*');

% Shifts
mPos = [-122.5 40];
mPos = repmat(mPos,length(mSynCat(:,1)), 1);
mDist = abs(distance(mSynCat(:,1), mSynCat(:,2), mPos(:,1), mPos(:,2)));
fSpaceDeg2 = 1;
vSel = (mDist <= fSpaceDeg2);
mCatShift =  mSynCat(vSel,:);
plot(mCatShift(:,1),mCatShift(:,2),'r*');
