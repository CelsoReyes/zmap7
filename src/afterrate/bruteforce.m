function [pv, cv, kv] = bruteforce(time_as)
    % function [pv, cv, kv] = bruteforce(time_as);
    % --------------------------------------------
    % Calculates by a constrained grid search
    % the parameters of the modified Omori formula
    %
    % Input parameters:
    %   time_as     Delay time [days]
    %
    % Output parameters:
    %   pv          p value
    %   cv          c value
    %   kv          k value
    %
    % Samuel Neukomm
    % July 31, 2002

    options = optimset('Display','none','MaxFunEvals',400,'TolFun',1e-04,'MaxIter',500);
    vStartValues = [1.1 0.5 200];

    [fValues, rms] = fmincon('bruteloop', vStartValues, [], [], [], [],...
        [0.2 0.01 10], [2.7 1 5000], [], options, time_as);

    pv = fValues(1);
    cv = fValues(2);
    kv = fValues(3);
