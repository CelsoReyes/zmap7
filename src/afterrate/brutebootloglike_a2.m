function [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, time_asf, bootloops,fT1, nMod)
    % function [mMedModF, mStdL, loopout] = brutebootloglike_a2(time_as, bootloops,fT1, nMod);
    % -------------------------------------------------------------------------------
    % Bootstrap analysis of Omori parameters calculated by bruteforce.m
    % (p1,p2,c1,c2,k1,k2)-pair is mean of the bootstrap values by determining the mean cumulative number modeled a end of the learning period
    % Standard deviations are calculated as the 2nd moment, not to rely fully on normal distributions
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
    % last update: 05.08.03

    time_as = sort(time_as);
    %bootloops = 50; % number of bootstrap samples
    n = length(time_as);
    loopout = [];
    % Initialize random seed
    rng('shuffle');
    %hWaitbar1 = waitbar(0,'Bootstrapping...');
    %set(hWaitbar1,'Numbertitle','off','Name','Bootstap Omori parameters')
    for j = 1:bootloops
        clear newtas
        randnr = ceil(rand(n,1)*n);
        i = (1:n)';
        newtas(i,:) = time_as(randnr(i),:); % bootstrap sample
        newtas = sort(newtas);
        [pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL] = bruteforceloglike_a2(newtas, fT1, nMod); % bruteforce.m is called
        loopout = [loopout; pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL];
        %    waitbar(j/bootloops)
    end
    %close(hWaitbar1)

    % New version: Choose mean (p,c,k)-variables by modelling the cumulative number at end of
    % the learning period

    % 2nd moment i.e. Standard deviations
    [pstd1] = calc_StdDev(loopout(:,1));
    [pstd2] = calc_StdDev(loopout(:,2));
    [cstd1] = calc_StdDev(loopout(:,3));
    [cstd2] = calc_StdDev(loopout(:,4));
    [kstd1] = calc_StdDev(loopout(:,5));
    [kstd2] = calc_StdDev(loopout(:,6));

    % Uncertainties of fit
    mStdL = [pstd1 pstd2 cstd1 cstd2 kstd1 kstd2];

    % Compute best fitting pair of variates
    loopout = [loopout , loopout(:,1)*0];
    for j = 1:length(loopout(:,1))

        cumnr = (1:length(time_asf))';
        cumnr_model = [];
        pval1 = loopout(j,1);
        pval2 = loopout(j,2);
        cval1 = loopout(j,3);
        cval2 = loopout(j,4);
        kval1 = loopout(j,5);
        kval2 = loopout(j,6);
        if nMod == 1
            for i=1:length(time_asf)
                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                else
                    cm = kval1*log(time_asf(i)/cval1+1);
                end
                cumnr_model = [cumnr_model; cm];
            end % END of FOR on length(time_asf)
            loopout(j,9) = max(cumnr_model);
        else
            for i=1:length(time_asf)
                if time_asf(i) <= fT1
                    if pval1 ~= 1
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1));
                    else
                        cm = kval1*log(time_asf(i)/cval1+1);
                    end
                    cumnr_model = [cumnr_model; cm];
                else
                    if (pval1 ~= 1 & pval2 ~= 1)
                        cm = kval1/(pval1-1)*(cval1^(1-pval1)-(time_asf(i)+cval1)^(1-pval1))+ kval2/(pval2-1)*(cval2^(1-pval2)-(time_asf(i)-fT1+cval2)^(1-pval2));
                    else
                        cm = kval1*log(time_asf(i)/cval1+1) + kval2*log((time_asf(i)-fT1)/cval2+1);
                    end
                    cumnr_model = [cumnr_model; cm];
                end %END of IF on fT1
            end % End of FOR length(time_asf)
            loopout(j,9) = max(cumnr_model);
        end % End of if on nMod
    end

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

