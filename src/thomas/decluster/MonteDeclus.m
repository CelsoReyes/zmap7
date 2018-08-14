function [declusCat, mNumDeclus] = MonteDeclus(mCatalog_, nSimul_, nMode_, mReasenParam_)
    % Starts monte carlo simulation on input parameters of different types of declustering algorithms
    % MonteDeclus(mCatalog_, nSimul_, nMode_)
    % -------------------------------------------------------------------------
    %
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
        case DeclusterTypes.Reasenberg
            disp('Monte Carlo Simulation for Reasenberg-declustering parameters (Matlab)');
            [declusCat,mNumDeclus] = MonteReasenberg(nSimul_, mCatalog_, mReasenParam_); % NOTE: parameters are reversed. (?)
            
        case DeclusterTypes.Gardner_Knoppoff
            
            disp('Monte Carlo Simulation for Gardner&Knopoff-declustering parameters');
            [declusCat,mNumDeclus] = MonteGK(mCatalog_,nSimul_);
            
        case DeclusterTypes.Stochastic
            disp('Monte Carlo Simulation for Stochastic-declustering parameters');
            
        case DeclusterTypes.Reasenberg_cluster200x
            clear mNumDeclus;
            disp('Monte Carlo Simulation for Reasenberg-declustering parameters (fortran Cluster200x)');
            
            
            [declusCat,mNumDeclus] = MonteCluster2000(nSimul_, mCatalog_, mReasenParam_);
            
        case DeclusterTypes.Marsan
            clear mNumDeclus;
            disp('Model-independent stochastic declustering / misd');
            [declusCat,mNumDeclus] = MonteMarsan(nSimul_, mCatalog_); % NOTE: parameters are reversed. (?)
            % create catalog with events that are mainshocks for 90%
            % probability
        case DeclusterTypes.Gardner_Knopoff_clusterGK
            disp('Gardner&Knopoff time-space-declustering');
            [declusCat,mNumDeclus] = MonteGK2(mCatalog_, nSimul_);
            
        case DeclusterTypes.Uhrhammer
            disp('Uhrhammer time-space-declustering');
            [declusCat,mNumDeclus] = MonteUhr(mCatalog_, nSimul_);
            
        case DeclusterTypes.Utsu
            disp('Utsu time-space-declustering');
            [declusCat,mNumDeclus] = MonteUtsu(mCatalog_, nSimul_);
    end
    
    if nSimul_ > 1 || nMode_ == DeclusterTypes.Reasenberg  % is this exception some sort of error?
        % create catalog with events that are mainshocks for 90% probability
        clear declusCat
        declusCat = mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
        mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
    end
                
end
