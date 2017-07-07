function [pv1, pv2, cv1, cv2, kv1, kv2] = bruteforcerms_a2(tas, fT1, nMod)
    % function [pv, cv, kv1, kv2] = bruteforcerms_a2(tas, fT1, sMod);
    % --------------------------------------------
    % Calculates by a constrained grid search
    % the parameters of the modified Omori formula
    % using RMS optimization
    %
    % Input parameters:
    %   tas     Delay time of entire sequence [days]
    %   fT1     Time of large aftershock after mainshock in days
    %
    % Output parameters:
    %   pv1          p value
    %   pv2          p value
    %   cv1          c value
    %   cv2          c value
    %   kv1         k1 value
    %   kv2         k2 value
    %
    % J. Woessner
    % last update: 31.07.03

    options = optimset('Display','none','MaxFunEvals',400,'TolFun',1e-04,'MaxIter',500);

    if nMod == 1

        vStartValues = [1.1 0.5 200 500];
        [vValues, fL] = fmincon('bruterms_pck2', vStartValues, [], [], [], [],...
            [0.2 0.01 10 10], [2.7 1 5000 3000], [], options, tas, fT1);

        pv1 = vValues(1);
        pv2 = vValues(1);
        cv1 = vValues(2);
        cv2 = vValues(2);
        kv1 = vValues(3);
        kv2 = vValues(4);

    else
        vStartValues = [1.1 1.1 0.5 0.5 200 200];
        [vValues, fL] = fmincon('bruterms_p2c2k2', vStartValues, [], [], [], [],...
            [0.2 0.2 0.01 0.01 50 10], [2.7 2.7 1 1 5000 4000], [], options, tas, fT1);

        pv1 = vValues(1);
        pv2 = vValues(2);
        cv1 = vValues(3);
        cv2 = vValues(4);
        kv1 = vValues(5);
        kv2 = vValues(6);
    end
    fL
