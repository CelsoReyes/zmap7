function [rms] = bruteloop(vValues,time_as)
    % this is the function used in bruteforce.m

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

