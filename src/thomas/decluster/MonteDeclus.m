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
    %                     6: Gardner and Knopoff (From Annemarie's codes)
    %                     7: Uhrhammer (From Annemarie's codes)
    %                     8: Utsu (From Annemarie's codes)
    
    % Output parameters:
    %   declusCat     Declustered Catalog (events that occur in every
    %                 declustered catalog
    %   mNumDeclus    Logical matrix that contains result of all declustered
    %                 catalogs with ones for mainshocks, zeros for aftershocks
    %
    %
    %
    % Example:
    % [declusCat,params.mNumDeclus] = MonteDeclus(mCatalog_,nSimul_, DeclusterTypes.Reasenberg);
    %
    % Th. van Stiphout; vanstiphout@sed.ethz.ch
    % updated: 14.08.2006
    %
    % See DeclusterTypes
    
    % set variables
    fFactor_=0.9;
    
    switch nMode_
        case DeclusterTypes.Reasenberg
            disp('Monte Carlo Simulation for Reasenberg-declustering parameters');
            [declusCat,mNumDeclus] = MonteReasenberg(nSimul_, mCatalog_, mReasenParam_); % NOTE: parameters are reversed. (?)
            
        case DeclusterTypes.Gardner_Knoppoff
            
            disp('Monte Carlo Simulation for Gardner&Knopoff-declustering parameters');
            [declusCat,mNumDeclus] = MonteGK(mCatalog_,nSimul_);
            
        case DeclusterTypes.Stochastic
            msg.dbdisp('Monte Carlo Simulation for Stochastic-declustering parameters : Not available');
            beep
            
        case DeclusterTypes.Reasenberg_cluster200x
            disp('Monte Carlo Simulation for Reasenberg-declustering parameters (fortran Cluster200x)');
            [declusCat,mNumDeclus] = MonteCluster2000(nSimul_, mCatalog_, mReasenParam_);
            
        case DeclusterTypes.Marsan
            clear mNumDeclus;
            disp('Monter Carlo Simulation for Model-independent stochastic declustering / misd');
            [declusCat,mNumDeclus] = MonteMarsan(nSimul_, mCatalog_); % NOTE: parameters are reversed. (?)
            % create catalog with events that are mainshocks for 90%
            % probability
        case {DeclusterTypes.Gardner_Knopoff_clusterGK, DeclusterTypes.Uhrhammer, DeclusterTypes.Utsu}
            fprintf('Monter Carlo Simulation for %s time-space-declustering', char(nMode_));
            [declusCat,mNumDeclus] = MonteAnnemarie(nMode_, mCatalog_, nSimul_);
    end
    
    if nSimul_ > 1 || nMode_ == DeclusterTypes.Reasenberg  % is this exception some sort of error?
        % create catalog with events that are mainshocks for 90% probability
        clear declusCat
        declusCat = mCatalog_((sum(mNumDeclus') > nSimul_*fFactor_)',:);
        mNumDeclus(:,nSimul_)=(sum(mNumDeclus') > nSimul_*fFactor_)';
    end
                
end
