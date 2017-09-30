function [fL] = bruteloglike_pck2(vValues,tas,fT1)
    % bruteloglike_pck2 calculates the log likelihood function of an Omori law including one secondary aftershock at time fT1. 
    % 
    %[fL] = bruteloglike_pck2(vValues,time_as, fT1)
    % Function to calculate the log likelihood function of an Omori law including one
    % secondary aftershock at time fT1. Assume p and c constant for the entire sequence,
    % but different k's before and after fT1
    %
    % Incoming variables:
    % vValues : Starting values for p,c,k1,k2
    % time_as : Vector of aftershock times from mainshock time
    % fT1     : time after mainshock of the large aftershock
    %
    % Outgoing:
    % fL  : Log likelihood function value
    %
    % J. Woessner
    % updated: 05.08.03

    p = vValues(1);
    c = vValues(2);
    k1 = vValues(3);
    k2 = vValues(4);

    % Calculate different time lengths
    vSel = (tas > fT1);

    % Select the two time periods
    vTperiod1 = tas(~vSel,:);
    vTperiod2 = tas(vSel,:);

    % Setting start end end time
    fTstart = min(tas);
    fTend = max(tas);

    %% Calculate the likelihood function for the mainshock sequence up to the large aftershock time ft1
    if p ~= 1
        fAcp = ((fT1+c).^(1-p)-(fTstart+c).^(1-p))./(1-p);
        %cumnr_model = k/(p-1)*(c^(1-p)-(c+time_as(i)).^(1-p)); % integrated form of MOL
    else
        fAcp = log(fT1+c)-log(fTstart+c);
        %cumnr_model = k*log(time_as(i)/c+1); % integrated form of MOL
    end
    % rms = (sum((i-cumnr_model).^2)/length(i))^0.5; % RMS between observed data and MOL
    % Log likelihood first period
    nEvents = length(vTperiod1);
    fL_per1 = nEvents*log(k1)-p*sum(log(vTperiod1+c))-k1*fAcp;


    %% Calculate the likelihood function for the sequence after the large aftershock time fT1
    % Some shortcuts
    % fT2 = min(vTperiod2); % Staring time of events after large aftershock
    fTerm1 = sum(log(k1*(vTperiod2+c).^(-p)+k2*(vTperiod2-fT1+c).^(-p)));
    fpsup = 1-p;
    if p~=1
        fTerm2a = k1/fpsup*((fTend+c).^fpsup-(fT1+c).^fpsup);
        fTerm2b = k2/fpsup*((fTend-fT1+c).^fpsup-c.^fpsup);
        fTerm2 = fTerm2a + fTerm2b;
    else
        fTerm2 = k1*(log(fTend+c)-log(fT1+c))+k2*(log(fTend-fT1+c)-log(c));
    end
    % Log likelihood second period
    fL_per2 = fTerm1-fTerm2;

    % Add upp likelihoods
    fL = -(fL_per1+fL_per2);


