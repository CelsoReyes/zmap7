function [pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL] = bruteforceloglike_a2(tas, fT1, nMod)
    % [pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL] = bruteforceloglike_a2(tas, fT1, nMod);
    % --------------------------------------------
    % Calculates by a constrained grid search the parameters of the modified Omori formula
    % using the log likelihood function by Ogata (1983) and calculates the best model by the
    % corrected AIC (Burnham & Anderson(2002)
    %
    % Input parameters:
    %   tas     Delay time of entire sequence [days]
    %   fT1     Time of large aftershock after mainshock in days
    %   nMod    Model number for choosing amount of free parameters
    %
    % Output parameters:
    %   pv1         p value before large aftershock
    %   pv2         p value after large aftershock
    %   cv1         c value before large aftershock
    %   cv2         c value after large aftershock
    %   kv1         k1 value before large aftershock
    %   kv2         k2 value after large aftershock
    %   fAIC        Akaike Information Criterion value
    %   fL          Maximum likelihood estunation
    %
    % J. Woessner / S. Neukomm
    % last update: 20.04.04

    options = optimset('Display','none','MaxFunEvals',400,'TolFun',1e-04,'MaxIter',500,'MaxSQPIter',500);

    % Starting values
    fPmin = 0.2;
    fPmax = 2.7;
    fCmin = 0.01;
    fCmax = 5;
    fKmin1 = 10;
    fKmax1 = 5000;
    fKmin2 = 10;
    fKmax2 = 4000;

    if nMod == 1
        % Modified Omori law
        % 3 free parameters: p, c , k
        fPar = 3;
        vStartValues = [1.1 0.5 50];
        [vValues, fL] = fmincon('bruteloglike', vStartValues, [], [], [], [],...
            [fPmin fCmin fKmin1 ], [fPmax fCmax fKmax1 ], [], options, tas);

        pv1 = vValues(1);
        pv2 = vValues(1);
        cv1 = vValues(2);
        cv2 = vValues(2);
        kv1 = vValues(3);
        kv2 = vValues(3);
    elseif nMod == 2
        % 4 free parameters: p, c , k1, k2
        fPar = 4;
        vStartValues = [1.1 0.5 50 50];
        [vValues, fL] = fmincon('bruteloglike_pck2', vStartValues, [], [], [], [],...
            [fPmin fCmin fKmin1 fKmin2], [fPmax fCmax fKmax1 fKmax2], [], options, tas, fT1);

        pv1 = vValues(1);
        pv2 = vValues(1);
        cv1 = vValues(2);
        cv2 = vValues(2);
        kv1 = vValues(3);
        kv2 = vValues(4);

    elseif nMod == 3
        % 5 free parameters: p1,p2,c,k1,k2
        fPar = 5;
        vStartValues = [1.1 1.1 0.5 0.5 50 50];
        [vValues, fL] = fmincon('bruteloglike_p2ck2', vStartValues, [], [], [], [],...
            [fPmin fPmin fCmin fCmin fKmin1 fKmin2], [fPmax fPmax fCmax fCmax fKmax1 fKmax2], [], options, tas, fT1);

        pv1 = vValues(1);
        pv2 = vValues(2);
        cv1 = vValues(3);
        cv2 = vValues(3);
        kv1 = vValues(5);
        kv2 = vValues(6);
    else
        % 6 free parameters: p1,p2,c1, c2,k1,k2
        fPar =6;
        vStartValues = [1.1 1.1 0.5 0.5 50 50];
        [vValues, fL] = fmincon('bruteloglike_p2c2k2', vStartValues, [], [], [], [],...
            [fPmin fPmin fCmin fCmin fKmin1 fKmin2], [fPmax fPmax fCmax fCmax fKmax1 fKmax2], [], options, tas, fT1);

        pv1 = vValues(1);
        pv2 = vValues(2);
        cv1 = vValues(3);
        cv2 = vValues(4);
        kv1 = vValues(5);
        kv2 = vValues(6);
    end
    % corrected Akaike Information Criterion
    [fk,nX]=size(tas);
    fAIC = -2*(-fL)+2*fPar+2*fPar*(fPar+1)/(fk-fPar-1);
