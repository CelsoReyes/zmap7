function sr_parameterstudy


disp('~/zmap/src/thomas/seismicrates/sr_parameterstudy.m')

% reset random number generator
rand('state',sum(100*clock));
% set default sample size
nN=[50];

% create random number generator

for iCat=1:200
    vRand=rand(nN(1),1);
    iCat
    % create different time intervals from 2 to 50 year
    vYY=[5:5:40]';
    for iYY=1:size(vYY,1)
        fYr1=1980;
        fYr2=1980+vYY(iYY);
        fTw=(fYr2-fYr1)/2;

        % create range of time bins
        %     nTbin1=[1/10000 1/2000 1/1000 1/500 1/100 1/50 1/25 1/10];
        %     nTbin1=1./([10 20 30 40 50 60 70 80 90 100 125 150 175 200 250 300 400 500 600 700 800 900 1000]);
        nTbin1=1./([20 40 50 75 100 125 150 175 200 300 400 500]);

        % round time bins
        nTbin=ceil((fYr2-fYr1)*nTbin1*365)';

        % set default catalog size
        nCatSize=1000;
        for j=1:size(nN)     % for each nN
            %             mCat00=rand(nN(j),1)*(fYr2-fYr1)+fYr1;

            mCat00=vRand*(fYr2-fYr1)+fYr1;
            mCat=rand(nCatSize,1)*(fYr2-fYr1)+fYr1;
            mCat20=mCat00(mCat00>(fYr2-fTw));
            for i=1:size(nTbin)
                [mLTA(i,iYY,iCat), mLTAprob(i,iYY,iCat)] =calc_zlta(mCat,mCat00,...
                    mCat20,fYr1, fYr2,fTw,nTbin(i),nN(1));
                [mBeta(i,iYY,iCat), mBetaprob(i,iYY,iCat)] =calc_beta(mCat,mCat00,...
                    mCat20,fYr1, fYr2,fTw,nTbin(i),nN(1));
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

    end
end

for i=1:size(mLTA,1)
    mLTA1(:,i)=reshape(mLTA(i,:,:),size(mLTA,2)*size(mLTA,3),1);
    mLTAprob1(:,i)=reshape(mLTAprob(i,:,:),size(mLTAprob,2)*size(mLTAprob,3),1);
    mBeta1(:,i)=reshape(mBeta(i,:,:),size(mBeta,2)*size(mBeta,3),1);
    mBetaprob1(:,i)=reshape(mBetaprob(i,:,:),size(mBetaprob,2)*size(mBetaprob,3),1);
end

save test.mat
figure;
subplot(2,1,1)
errorbar(1./nTbin1,mean(mLTA1),std(mLTA1),'b--x','LineWidth',3);
hold on;
errorbar(1./nTbin1,mean(mBeta1),std(mBeta1),'r:o','LineWidth',2);
xlabel('Bin Size [1/X]');
ylabel('Z and \beta [ ]');
legend('z','\beta');
subplot(2,1,2);
errorbar(1./nTbin1,mean(mLTAprob1),std(mLTAprob1),'b--x','LineWidth',3);
YLim([0,1]);
hold on;
errorbar(1./nTbin1,mean(mBetaprob1),std(mBetaprob1),'r:o','LineWidth',2);
xlabel('Bin Size [1/X]');
ylabel('Probability of Z and \beta [ ]');
legend('p(z)','p(\beta)');


sPrint=sprintf('print -dpng -r300 Tbin_N-%04.0f_Sim-%04.0f.png',nN,iCat);
eval(sPrint);
 disp(sPrint);
