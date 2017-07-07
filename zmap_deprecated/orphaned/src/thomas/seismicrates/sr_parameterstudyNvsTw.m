function sr_parameterstudyNvsTw


disp('~/zmap/src/thomas/seismicrates/sr_parameterstudyNvsTw.m')

% reset random number generator
rand('state',sum(100*clock));
% set default sample size


fYrs=[10]';
fYr1=1980;
fYr2=1980+fYrs;


% create range for N
vN=[25 50 100 150 200]';
% vN=[50 75 100]';

% create range for Tw
vTw=[0.1:0.1:0.9]'.*fYrs;

% fix Tbin by 1/100 of whole period
nTbin1=1/100;
% round time bins
vTbin=ceil((fYr2-fYr1)*nTbin1*365)';

% set default catalog size
nCatSize=5000;

% prepare input parameter matrix  [ vN   vTw   vTbin ]
mVar(:,1)=repmat(vN,size(vTw,1)*size(vTbin,1),1);
mVar(:,2)=reshape(repmat(vTw',size(vN,1)*size(vTbin,1),1),...
    size(vTw,1)*size(vN,1)*size(vTbin,1),1);
mVar(:,3)=repmat(reshape(repmat(vTbin',size(vN,1),1),...
    size(vTbin,1)*size(vN,1),1),size(vTw,1),1);

mCat20=[];mCat00=[];

% bRchange=logical(0)
% rate change?
fRate2=100  ; %  percent of original rate
% nInit=logical(1);
for iCat=1:500
    iCat
    for j=1:size(mVar)
        while isempty(mCat20) | isempty(mCat00)
            vRand=rand(mVar(j,1),1);

            if (fRate2~=100)
                % Fraction of period with 100% rate and fRchange % rate
                fRYr1=1-mVar(j,2)/(fYr2-fYr1);
                fRYr2=mVar(j,2)/(fYr2-fYr1);
                vRand=rand(mVar(j,1),1);
                fRYr1+(fRYr2*fRate2/100);
                vRand1=vRand*(fRYr1+(fRYr2*fRate2/100));
                vSel=(vRand1>fRYr1);
                vRand=vRand1;
                vRand(vSel)=(vRand1(vSel)-fRYr1)*100/fRate2+fRYr1;
                clear vRand1
            else
                vRand=rand(mVar(j,1),1);
            end

            mCat00=vRand*(fYr2-fYr1)+fYr1;
            mCat=rand(nCatSize,1)*(fYr2-fYr1)+fYr1;
            mCat20=mCat00(mCat00>(fYr2-mVar(j,2)));
            if isempty(mCat20) disp('looooop'); end
        end
%         [mLTA(j,iCat), mLTAprob(j,iCat)] =calc_zlta(mCat,mCat00,mCat20,fYr1, fYr2,mVar(j,2),mVar(j,3),mVar(j,1));
%         [mBeta(j,iCat), mBetaprob(j,iCat)] =calc_beta(mCat,mCat00,mCat20,fYr1, fYr2,mVar(j,2),mVar(j,3),mVar(j,1));
        [mResult_(iCat,1,j), mResult_(iCat,2,j)] =calc_zlta(mCat,mCat00,mCat20,fYr1, fYr2,mVar(j,2),mVar(j,3),mVar(j,1));
        [mResult_(iCat,3,j), mResult_(iCat,4,j)] =calc_beta(mCat,mCat00,mCat20,fYr1, fYr2,mVar(j,2),mVar(j,3),mVar(j,1));
        mCat20=[];
        clear mCat00 mCat;
    end
end
%         disp(n);
%     subplot(2,2,1)
%     hold on;plot(1./nTbin1,mLTA);
%     subplot(2,2,2)
%     hold on;plot(1./nTbin1,mLTAprob);
%     subplot(2,2,3)
%     hold on;plot(1./nTbin1,mBeta);
%     subplot(2,2,4)
%     hold on;plot(1./nTbin1,mBetaprob);


% for i=1:size(mLTA,1)
%     mLTA1(:,i)=reshape(mLTA(i,:,:),size(mLTA,2)*size(mLTA,3),1);
%     mLTAprob1(:,i)=reshape(mLTAprob(i,:,:),size(mLTAprob,2)*size(mLTAprob,3),1);
%     mBeta1(:,i)=reshape(mBeta(i,:,:),size(mBeta,2)*size(mBeta,3),1);
%     mBetaprob1(:,i)=reshape(mBetaprob(i,:,:),size(mBetaprob,2)*size(mBetaprob,3),1);
% end

params.mResult_=mResult_;
params.mVar=mVar;
params.vN=vN;
params.vTw=vTw;
params.vTbin=vTbin;

sPrint=sprintf('save NvsTw-Sim%04.0f-R%03.0f.mat params -mat',iCat, fRate2);
eval(sPrint);
disp(sPrint);
% figure;
% subplot(2,1,1)
% errorbar(1./nTbin1,mean(mLTA1),std(mLTA1),'b--x','LineWidth',3);
% hold on;
% errorbar(1./nTbin1,mean(mBeta1),std(mBeta1),'r:o','LineWidth',2);
% xlabel('Bin Size [1/X]');
% ylabel('Z and \beta [ ]');
% legend('z','\beta');
% subplot(2,1,2);
% errorbar(1./nTbin1,mean(mLTAprob1),std(mLTAprob1),'b--x','LineWidth',3);
% YLim([0,1]);
% hold on;
% errorbar(1./nTbin1,mean(mBetaprob1),std(mBetaprob1),'r:o','LineWidth',2);
% xlabel('Bin Size [1/X]');
% ylabel('Probability of Z and \beta [ ]');
% legend('p(z)','p(\beta)');
%

