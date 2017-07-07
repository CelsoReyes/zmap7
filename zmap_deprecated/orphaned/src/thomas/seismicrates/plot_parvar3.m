
mResult=params.mResult2;
mean_=repmat(squeeze(mean(mResult(:,1,:),3)),1,size(mResult,3));
val_=squeeze(mResult(:,1,:));
mNormval=val_-mean_;
vNormval=reshape(mNormval,size(mNormval,1)*size(mNormval,2),1);
std(vNormval)
figure;cdfplot(vNormval);
