function [fL] = bruteloglike(vValues,time_as)
    % bruteloglike calculates the log likelihood function for the modeled aftershock sequence and the maximum likelihood estimate for k, c and p
    %
    % [fL] = bruteloglike(vValues,time_as);
    % -------------------------------------------------------------
    % Reference: Ogata, Estimation of the parameters in the modified Omori formula
    % for aftershock sequences by  the maximum likelihood procedure, J. Phys. Earth, 1983
    % (Formula 6)
    %
    % J. Woessner
    % last update: 29.07.03

    p = vValues(1);
    c = vValues(2);
    k = vValues(3);

    % Setting start end end time
    fTstart = min(time_as);
    fTend = max(time_as);

    if p ~= 1
        fAcp = ((fTend+c).^(1-p)-(fTstart+c).^(1-p))./(1-p);
        %cumnr_model = k/(p-1)*(c^(1-p)-(c+time_as(i)).^(1-p)); % integrated form of MOL
    else
        fAcp = log(fTend+c)-log(fTstart+c);
        %cumnr_model = k*log(time_as(i)/c+1); % integrated form of MOL
    end
    % rms = (sum((i-cumnr_model).^2)/length(i))^0.5; % RMS between observed data and MOL
    % Log likelihood
    nNumEvents = length(time_as);
    fL = -(nNumEvents*log(k)-p*sum(log(time_as+c))-k*fAcp);

