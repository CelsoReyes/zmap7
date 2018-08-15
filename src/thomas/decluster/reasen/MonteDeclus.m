function [declusCat, mNumDeclus] = MonteDeclus(mCatalog_,nSimul_,nMode_,nSynCat_)
    % Starts monte carlo simulation on input parameters of different types of declustering algorithms
    %
    %  MonteDeclus(mCatalog_,nSimul_,nMode_)
    % -------------------------------------------------------------------------
    % 
    %
    % Input parameters:
    %   mCatalog_     Earthquake catalog to be declustered
    %   nSimul_       Number of Monte Carlo runs
    %   nMode_        Type of declustering
    %                     1: Reasenberg declustering (Matlab-Code)
    %                     2: Gardner & Knoppoff
    %                     3: Stochastic Declustering
    %                     4: Reasenberg Declustering (cluster200x)
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
    % updated: 14.08.2006
    
    % set variables
    fFactor_=0.9;
    
    switch nMode_
        case 1
            disp('Monte Carlo Simulation for Reasenberg-declustering parameters');
            sprintf('No. of Simulations : %d',nSimul_)
            tic
            [declusCat,mNumDeclus] = MonteReasenberg(nSimul_,mCatalog_);
            toc
            % create catalog with events that are mainshocks for 90% probability
            clear declusCat;
            declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
            mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
        case 2
            disp('Monte Carlo Simulation for Gardner&Knopoff-declustering parameters');
            [declusCat,mNumDeclus] = MonteGK(mCatalog_,nSimul_);
            
            if nSimul_  > 1
                % create catalog with events that are mainshocks for 90%
                % probability
                clear declusCat;
                declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
                mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
            end
        case 3
            disp('Monte Carlo Simulation for Stochastic-declustering parameters');
            % Not available
        case 4
            clear mNumDeclus;
            disp('Monte Carlo Simulation for Reasenberg-declustering parameters (fortran Cluster200x)');
            sprintf('No. of Simulations : %d',nSimul_)
            tic
            [declusCat,mNumDeclus] = MonteCluster2000(nSimul_,mCatalog_);
            toc
            % create catalog with events that are mainshocks for 90%
            % probability
            if nSimul_ > 1
                clear declusCat;
                declusCat=mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
                mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
            end
    end
end
