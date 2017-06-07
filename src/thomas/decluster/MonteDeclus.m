function [declusCat, mNumDeclus] = MonteDeclus(mCatalog_,nSimul_,nMode_,mReasenParam_)
% function MonteDeclus(mCatalog_,nSimul_,nMode_)
% -------------------------------------------------------------------------
% Starts monte carlo simulation on input parameters of different types of
% declustering algorithms
%
% Input parameters:
%   mCatalog_     Earthquake catalog to be declustered
%   nSimul_       Number of Monte Carlo runs
%   nMode_        Type of declustering
%                     1: Reasenberg declustering (Matlab-Code)
%                     2: Gardner & Knoppoff  (zmap)
%                     3: Stochastic Declustering
%                     4: Reasenberg Declustering (cluster200x)
%                     5: Marsan (Model-independent stochastic declustering (misd)
%                     6: Gardner and Knopoff (clusterGK.m)
%                     7: Uhrhammer (clusterU.m)
%                     8: Utsu (clusterUtsu.m)

%  nSynCat_      Creating Synthetic Catalogs?
%                     0: no synthetic catalog
%                     1: synthetic catalog only background rate
%                     2: synthetic catalog with ETAS
% Output parameters:
%   declusCat     Declustered Catalog (events that occur in every
%                 declustered catalog
%   mNumDeclus    Logical matrix that contains result of all declustered
%                 catalogs with ones for mainshocks, zeros for aftershocks
%
%
%
% Example:
% [declusCat,params.mNumDeclus] = MonteDeclus(mCatalog_,nSimul_,1);
%
% Th. van Stiphout; vanstiphout@sed.ethz.ch
% last update: 14.08.2006

% set variables
fFactor_=0.9;

switch nMode_
    case 1
        disp('Monte Carlo Simulation for Reasenberg-declustering parameters (Matlab)');
%         sprintf('No. of Simulations : %d',nSimul_)
        tic
        [declusCat,mNumDeclus] = MonteReasenberg(nSimul_,mCatalog_,mReasenParam_);
        toc
        % create catalog with events that are mainshocks for 90%
        % probability
        clear declusCat;
        declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
        mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
    case 2
%         if (nSynCat_==0)
         disp('Monte Carlo Simulation for Gardner&Knopoff-declustering parameters');
%         sprintf('No. of Simulations : %d',nSimul_)
        [declusCat,mNumDeclus] = MonteGK(mCatalog_,nSimul_);

        if nSimul_  > 1
            % create catalog with events that are mainshocks for 90%
            % probability
            clear declusCat;
            declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
            mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
        end
%         else
%             mSimulNo=[];
%             for i=1:nSimul_
%             [mCatalog_, vMain] = calc_SynCat(12000,2.5,2.5,8,100,'January 1,1980','December 31,1990',6.5,nSynCat_);
% %             tmp(1:size(mCatalog_,1),1)=i;
% %             mSimulNo=[mSimulNo; tmp];clear tmp
%             [declusCat{i},mNumDeclus{i}] = MonteGK(mCatalog_,1);
% %             mTmp=[cell2mat(declusCat') cell2mat(params.mNumDeclus')];
% %             [tmp, Xi]=sort(mTmp(:,3));
% %             declusCat=mTmp(Xi,:);
%
%
% %             size([declusCat1 mNumDeclus])
%             sString=sprintf('%d. catalog simulated and declustering',i);disp(sString);
%             end
%             declusCat=cell2mat(declusCat');
%             mNumDeclus=cell2mat(mNumDeclus');
%             mSimulNo=reshape(mSimulNo,size(mSimulNo,1)*size(mSimulNo,2),1);
%             [tmp, Xi] =sort(declusCat(:,3));clear tmp;
%             declusCat=declusCat(Xi,:);
%             mNumDeclus=mNumDeclus(Xi,:);
%             mSimulNo=mSimulNo(Xi,:);
%             for i=1:nSimul_
%                 vSimulNo(:,i)=(mSimulNo==i);
%             end

%             mNumDeclus=vSimulNo;
%         end
    case 3
        disp('Monte Carlo Simulation for Stochastic-declustering parameters');
%         disp('not available at the moment')
%         disp('test',nSimul_)
%         [declusCat,params.mNumDeclus] = MonteEtasDeclus(nSimul_,mCatalog_);
%         % create catalog with events that are mainshocks for 90%
%         % probability
%         clear declusCat;
%         declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
%         mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
    case 4
        clear declus mNumDeclus;
        disp('Monte Carlo Simulation for Reasenberg-declustering parameters (fortran Cluster200x)');
%         sprintf('No. of Simulations : %d',nSimul_)
        tic
        [declusCat,mNumDeclus] = MonteCluster2000(nSimul_,mCatalog_,mReasenParam_);
        toc
        % create catalog with events that are mainshocks for 90%
        % probability
        if nSimul_ > 1
            clear declusCat;
            declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
            mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
        end
    case 5
        clear declus mNumDeclus;
        disp('Model-independent stochastic declustering / misd');
        sprintf('No. of Simulations : %d',nSimul_)
        tic
        [declusCat,mNumDeclus] = MonteMarsan(nSimul_,mCatalog_);
        toc
        % create catalog with events that are mainshocks for 90%
        % probability
        if nSimul_ > 1
            clear declusCat;
            declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
            mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
        end
    case 6
%         if (nSynCat_==0)
         disp('Gardner&Knopoff time-space-declustering');
%         sprintf('No. of Simulations : %d',nSimul_)
        [declusCat,mNumDeclus] = MonteGK2(mCatalog_,nSimul_);

        if nSimul_  > 1
            % create catalog with events that are mainshocks for 90%
            % probability
            clear declusCat;
            declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
            mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
        end
    case 7
%         if (nSynCat_==0)
         disp('Uhrhammer time-space-declustering');
%         sprintf('No. of Simulations : %d',nSimul_)
        [declusCat,mNumDeclus] = MonteUhr(mCatalog_,nSimul_);

        if nSimul_  > 1
            % create catalog with events that are mainshocks for 90%
            % probability
            clear declusCat;
            declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
            mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
        end
    case 8
%         if (nSynCat_==0)
         disp('Utsu time-space-declustering');
%         sprintf('No. of Simulations : %d',nSimul_)
        [declusCat,mNumDeclus] = MonteUtsu(mCatalog_,nSimul_);

        if nSimul_  > 1
            % create catalog with events that are mainshocks for 90%
            % probability
            clear declusCat;
            declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
            mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
        end
end
