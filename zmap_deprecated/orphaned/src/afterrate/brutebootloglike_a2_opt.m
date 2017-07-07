function [loopout] = brutebootloglike_a2_opt(time_as, time_asf, bootloops,fT1)
    % function [loopout] = brutebootloglike_a2_opt(time_as, bootloops,fT1);
    % -------------------------------------------------------------------------------
    % Bootstrap analysis of Omori parameters
    %
    % Input parameters:
    %   time_as     Delay times [days] of learning period
    %   time_asf    Delay times [days] until end of forecast period
    %   bootloops   Number of bootstraps
    %   fT1         Time of biggest aftershock in learning period
    %
    % Model to fit data, three models including a secondary aftershock sequence.
    % Different models have varying amount of free parameters
    % 1: modified Omori law (MOL): 3 free parameters: p1=p2,c1=c2,k1=k2
    % 2: MOL with one secondary aftershock sequence: 4 free parameters: p1=p2,c1=c2,k1~=k2
    % 3: MOL with one secondary aftershock sequence: 5 free parameters: p1~=p2,c1=c2,k1~=k2
    % 4: MOL with one secondary aftershock sequence: 6 free parameters: p1~=p2,c1~=c2,k1~=k2
    %
    % Output parameters:
    %  loopout     contains all results
    %
    % Jochen Woessner / Samuel Neukomm
    % last update: 22.03.04

    time_as = sort(time_as);
    n = length(time_as);
    loopout = [];
    nCnt = 0; % counts failed bootstrap samples

    for j = 1:bootloops
        clear newtas
        randnr = ceil(rand(n,1)*n);
        i = (1:n)';
        newtas(i,:) = time_as(randnr(i),:); % bootstrap sample
        newtas = sort(newtas);

        % Calculate fits of different models
        mRes = [];
        % Modified Omori law (pck)
        nMod = 1; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (pckk)
        nMod = 2; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (ppckk)
        nMod = 3; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];
        % MOL with secondary aftershock (ppcckk)
        nMod = 4; [pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL] = bruteforceloglike_a2(newtas,fT1,nMod);
        mRes = [mRes; nMod, pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL];

        % Select best fitting model by AIC
        vSel = (mRes(:,8)==min(mRes(:,8)));
        mRes = mRes(vSel,:);
        if length(mRes(:,1)) > 1
            vSel = (mRes(:,1)==min(mRes(:,1)));
            mRes = mRes(vSel,:);
        end
        % Model to use for bootstrapping as of lowest AIC to observed data
        nMod = mRes(1,1);
        pval1= mRes(1,2); pval2= mRes(1,3);
        cval1= mRes(1,4); cval2= mRes(1,5);
        kval1= mRes(1,6); kval2= mRes(1,7);

        % Calculate goodness of fit with KS-Test and RMS
        [H,P,KSSTAT,fRMS] = calc_llkstest_a2(newtas,fT1,pval1, pval2, cval1, cval2, kval1, kval2, nMod);
        if H==1
            nCnt = nCnt + 1;
            if nCnt/bootloops >= 0.5
                mMeanModF = NaN; loopout = NaN;
                return
            end
        else
            if nMod == 1
                if pval1 ~= 1
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_asf)+cval1)^(1-pval1));
                    cl = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_as)+cval1)^(1-pval1));
                else
                    cm = kval1*log(max(time_asf)/cval1+1);
                    cl = kval1*log(max(time_as)/cval1+1);
                end
            else
                if (pval1 ~= 1 & pval2 ~= 1)
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_asf)+cval1)^(1-pval1)) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_asf)-fT1+cval2)^(1-pval2));
                    cl = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_as)+cval1)^(1-pval1)) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_as)-fT1+cval2)^(1-pval2));
                elseif (pval1 ~= 1  &&  pval2 == 1)
                    cm = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_asf)+cval1)^(1-pval1)) + kval2*log((max(time_asf)-fT1)/cval2+1);
                    cl = kval1/(pval1-1)*(cval1^(1-pval1)-(max(time_as)+cval1)^(1-pval1)) + kval2*log((max(time_as)-fT1)/cval2+1);
                elseif (pval1 == 1  &&  pval2 ~= 1)
                    cm = kval1*log(max(time_asf)/cval1+1) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_asf)-fT1+cval2)^(1-pval2));
                    cl = kval1*log(max(time_as)/cval1+1) + kval2/(pval2-1)*(cval2^(1-pval2)-(max(time_as)-fT1+cval2)^(1-pval2));
                else
                    cm = kval1*log(max(time_asf)/cval1+1) + kval2*log((max(time_asf)-fT1)/cval2+1);
                    cl = kval1*log(max(time_as)/cval1+1) + kval2*log((max(time_as)-fT1)/cval2+1);
                end
            end % End of if on nMod
            loopout = [loopout; pval1, pval2, cval1, cval2, kval1, kval2, fAIC, fL, cm, cl, nMod];
        end % End of KS-Test
    end
