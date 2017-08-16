function [pv, cv, kv] = bruteforceloglike(time_as)
    % function [pv, cv, kv] = bruteforceloglike(time_as);
    % --------------------------------------------
    % Calculates by a constrained grid search
    % the parameters of the modified Omori formula
    % using the log likelihood function by Ogata
    %
    % Input parameters:
    %   time_as     Delay time [days]
    %
    % Output parameters:
    %   pv          p value
    %   cv          c value
    %   kv          k value
    %
    % Samuel Neukomme
    % July 31, 2002

    options = optimset('Display','none','MaxFunEvals',400,'TolFun',1e-04,'MaxIter',500);
    vStartValues = [1.1 0.5 200];

    [vValues, fL] = fmincon('bruteloglike', vStartValues, [], [], [], [],...
        [0.2 0.01 10], [2.7 3 5000], [], options, time_as);

    pv = vValues(1);
    cv = vValues(2);
    kv = vValues(3);

