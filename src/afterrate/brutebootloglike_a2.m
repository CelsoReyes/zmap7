function [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1, nMod)
    % BRUTEBOOTLOGLIKE_A2 Bootstrap analysis of Omori parameters calculated by brute force
    % (p1,p2,c1,c2,k1,k2)-pair is mean of the bootstrap values by determining the mean cumulative 
    % number modeled a end of the learning period
    % Standard deviations are calculated as the 2nd moment, not to rely fully on normal distributions
    %
    % [mMedModF, mStdL, loopout] = BRUTEBOOTLOGLIKE_A2(time_as, time_asf, bootloops,fT1, nMod);
    % -------------------------------------------------------------------------------
    %
    % Input parameters:
    %   time_as     Delay times [days] of learning period
    %   time_asf    Delay times [days] until end of forecast period
    %   bootloops   Number of bootstraps
    %   fT1         Time of biggest aftershock in learning period
    %   nMod        Model to fit data, three models including a secondary aftershock sequence.
    %               Different models have varying amount of free parameters
    %               before (p1,c1,k1) and after (p2,c2,k2) the aftershock occurence
    %               1: modified Omori law (MOL): 3 free parameters
    %                  p1=p2,c1=c2,k1=k2
    %               2: MOL with one secondary aftershock sequence:4 free parameters
    %                  p1=p2,c1=c2,k1~=k2
    %               3: MOL with one secondary aftershock sequence:5 free parameters
    %                  p1~=p2,c1=c2,k1~=k2
    %               4: MOL with one secondary aftershock sequence:6 free parameters
    %                  p1~=p2,c1~=c2,k1~=k2
    %
    % Output parameters:
    %  mMedModF :  Result matrix including the values for the mean forecast at end of forecast period
    %  mStdL    :  Uncertainties of fit to the data in learning period
    %  loopout     contains all results
    %
    % Samuel Neukomm / S. Wiemer / J. Woessner
    % updated: 05.08.03

    time_as = sort(time_as);
    %bootloops = 50; % number of bootstrap samples
    n = length(time_as);
    loopout = nan(bootloops,9); % 8 from bruteforceloglike_a2, plus variate column.
    % Initialize random seed
    rng('shuffle');
    
    % i = (1:n)';
    for j = 1:bootloops
        newtas = sort(datasample(time_as, n, 'Replace',true)); 
        [pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL] = bruteforceloglike_a2(newtas, fT1, nMod);
        loopout(j,1:8) = [pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL];
    end

    % New version: Choose mean (p,c,k)-variables by modelling the cumulative number at end of
    % the learning period

    % 2nd moment i.e. Standard deviations
    [pstd1] = std(loopout(:,1),1,'omitnan');
    [pstd2] = std(loopout(:,2),1,'omitnan');
    [cstd1] = std(loopout(:,3),1,'omitnan');
    [cstd2] = std(loopout(:,4),1,'omitnan');
    [kstd1] = std(loopout(:,5),1,'omitnan');
    [kstd2] = std(loopout(:,6),1,'omitnan');

    % Uncertainties of fit
    mStdL = [pstd1 pstd2 cstd1 cstd2 kstd1 kstd2];

   
    %% Compute best fitting pair of variates
    % TODO (maybe) vectorize this
    n_time_asf = length(time_asf);
    
    
    
    pv1=loopout(:,1);
    pv2=loopout(:,2);
    cv1=loopout(:,3);
    cv2=loopout(:,4);
    kv1=loopout(:,5);
    kv2=loopout(:,6);
    
    cumnr_model = OmoriModel.doForecast(nMod,time_asf, pv1, cv1, kv1, fT1, kv2, pv2, cv2);
    loopout(:,9) = max(cumnr_model);
    
    %%
    [Y, in] = sort(loopout(:,9));
    loops = loopout(in,:);
    % % Median values: Old version
    % vMedian = abs(loops(:,9)-median(loops(:,9)));
    % nMedian = (find(vMedian == min(vMedian)));
    %
    % if length(nMedian(:,1)) > 1
    %     nMedian = nMedian(1,1);
    % end
    % pmedian1 = loops(nMedian,1);
    % pmedian2 = loops(nMedian,2);
    % cmedian1 = loops(nMedian,3);
    % cmedian2 = loops(nMedian,4);
    % kmedian1 = loops(nMedian,5);
    % kmedian2 = loops(nMedian,6);
    %
    % mMedModF = [pmedian1, pstd1, pmedian2, pstd2, cmedian1, cstd1, cmedian2, cstd2, kmedian1, kstd1, kmedian2, kstd2];

    % Mean values
    vMean = abs(loops(:,9)-mean(loops(:,9)));
    nMean = (find(vMean == min(vMean)));

    if length(nMean(:,1)) > 1
        nMean = nMean(1,1);
    end
    pMean1 = loops(nMean,1);
    pMean2 = loops(nMean,2);
    cMean1 = loops(nMean,3);
    cMean2 = loops(nMean,4);
    kMean1 = loops(nMean,5);
    kMean2 = loops(nMean,6);

    mMedModF = [pMean1, pstd1, pMean2, pstd2, cMean1, cstd1, cMean2, cstd2, kMean1, kstd1, kMean2, kstd2];

