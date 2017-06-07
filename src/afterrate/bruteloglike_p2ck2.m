function [fL] = bruteloglike_p2ck2(vValues,tas,fT1)
    % [fL] = bruteloglike_p2ck2(vValues,time_as, fT1);
    % --------------------------------------------------
    % Function to calculate the log likelihood function of an Omori law including one
    % secondary aftershock at time fT1. c constant , p and k different before and after fT1
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
    % last update: 05.08.03


    p1 = vValues(1);
    p2 = vValues(2);
    c1 = vValues(3); % c1 = c2
    c2 = vValues(3);
    k1 = vValues(5);
    k2 = vValues(6);

    % Calculate different time lengths
    vSel = (tas > fT1);
    % Select the two time periods
    vTperiod1 = tas(~vSel,:);
    vTperiod2 = tas(vSel,:);

    % Setting start end end time
    fTstart = min(tas);
    fTend = max(tas);

    %% Calculate the likelihood function for the mainshock sequence up to the large aftershock time ft1
    if p1 ~= 1
        fAcp = ((fT1+c1).^(1-p1)-(fTstart+c1).^(1-p1))./(1-p1);
    else
        fAcp = log(fT1+c1)-log(fTstart+c1);
    end
    % Log likelihood first period
    nEvents = length(vTperiod1);
    fL_per1 = nEvents*log(k1)-p1*sum(log(vTperiod1+c1))-k1*fAcp;


    %% Calculate the likelihood function for the sequence after the large aftershock time fT1
    % Some shortcuts
    fpsup1 = 1-p1;
    fpsup2 = 1-p2;

    fTerm1 = sum(log(k1*(vTperiod2+c1).^(-p1)+k2*(vTperiod2-fT1+c2).^(-p2)));

    if (p1~=1  &&  p2~=2)
        fTerm2a = k1/fpsup1*((fTend+c1).^fpsup1-(fT1+c1).^fpsup1);
        fTerm2b = k2/fpsup2*((fTend-fT1+c2).^fpsup2-c2.^fpsup2);
        fTerm2 = fTerm2a + fTerm2b;
    elseif (p1==1  &&  p2==1)
        fTerm2 = k1*(log(fTend+c1)-log(fT1+c1))+k2*(log(fTend-fT1+c2)-log(c2));
    elseif (p1~=1  &&  p2==1)
        fTerm2a = k1/fpsup1*((fTend+c1).^fpsup1-(fT1+c1).^fpsup1);
        fTerm2b = k2*(log(fTend-fT1+c2)-log(c2));
        fTerm2 = fTerm2a + fTerm2b;
    else % (p1==1 & p2~=1)
        fTerm2a = k1*(log(fTend+c1)-log(fT1+c1));
        fTerm2b = k2/fpsup2*((fTend-fT1+c2).^fpsup2-c2.^fpsup2);
        fTerm2 = fTerm2a + fTerm2b;
    end
    % Log likelihood second period
    fL_per2 = fTerm1-fTerm2;

    % Add upp likelihoods
    fL = -(fL_per1+fL_per2);

