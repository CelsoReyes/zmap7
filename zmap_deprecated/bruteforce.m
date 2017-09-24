function [pv, cv, kv] = bruteforce(time_as)
    % bruteforce Calculates by a constrained grid search the parameters of the modified Omori formula
    %
    % [pv, cv, kv] = bruteforce(time_as);
    % --------------------------------------------
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

    [fValues, rms] = fmincon(@bruteloop, vStartValues, [], [], [], [],...
        [0.2 0.01 10], [2.7 1 5000], [], options, time_as);

    pv = fValues(1);
    cv = fValues(2);
    kv = fValues(3);

end

function [rms] = bruteloop(vValues,time_as)

    p = vValues(1);
    c = vValues(2);
    k = vValues(3);

    i = (1:10:length(time_as))';
    if p ~= 1
        cumnr_model = k/(p-1)*(c^(1-p)-(c+time_as(i)).^(1-p)); % integrated form of MOL
    else
        cumnr_model = k*log(time_as(i)/c+1); % integrated form of MOL
    end
    rms = (sum((i-cumnr_model).^2)/length(i))^0.5; % RMS between observed data and MOL

end
