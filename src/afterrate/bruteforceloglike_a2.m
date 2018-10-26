function [pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL] = bruteforceloglike_a2(tas, fT1, nMod)
    % bruteforceloglike_a2 Calculates by a constrained grid search the parameters of the modified Omori formula
    % using the log likelihood function by Ogata (1983) and calculates the best model by the
    % corrected AIC (Burnham & Anderson(2002)
    %
    % [pv1, pv2, cv1, cv2, kv1, kv2, fAIC, fL] = bruteforceloglike_a2(tas, fT1, nMod);
    % --------------------------------------------
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
    % updated: 20.04.04

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

    switch nMod
        case OmoriModel.pck
            % Modified Omori law
            % 3 free parameters: p, c , k
            fPar = 3;
            vStartValues = [1.1 0.5 50];
            [vValues, fL] = fmincon(@bruteloglike, vStartValues, [], [], [], [],...
                [fPmin fCmin fKmin1 ], [fPmax fCmax fKmax1 ], [], options, tas);
            
            pv1 = vValues(1);
            pv2 = vValues(1);
            cv1 = vValues(2);
            cv2 = vValues(2);
            kv1 = vValues(3);
            kv2 = vValues(3);
        case OmoriModel.pckk
            % 4 free parameters: p, c , k1, k2
            fPar = 4;
            vStartValues = [1.1 0.5 50 50];
            [vValues, fL] = fmincon(@bruteloglike_pck2, vStartValues, [], [], [], [],...
                [fPmin fCmin fKmin1 fKmin2], [fPmax fCmax fKmax1 fKmax2], [], options, tas, fT1);
            
            pv1 = vValues(1);
            pv2 = vValues(1);
            cv1 = vValues(2);
            cv2 = vValues(2);
            kv1 = vValues(3);
            kv2 = vValues(4);
            
        case OmoriModel.ppckk
            % 5 free parameters: p1,p2,c,k1,k2
            fPar = 5;
            vStartValues = [1.1 1.1 0.5 0.5 50 50];
            [vValues, fL] = fmincon(@bruteloglike_p2ck2, vStartValues, [], [], [], [],...
                [fPmin fPmin fCmin fCmin fKmin1 fKmin2], [fPmax fPmax fCmax fCmax fKmax1 fKmax2], [], options, tas, fT1);
            
            pv1 = vValues(1);
            pv2 = vValues(2);
            cv1 = vValues(3);
            cv2 = vValues(3);
            kv1 = vValues(5);
            kv2 = vValues(6);
        case OmoriModel.ppcckk
            % 6 free parameters: p1,p2,c1, c2,k1,k2
            fPar =6;
            vStartValues = [1.1 1.1 0.5 0.5 50 50];
            [vValues, fL] = fmincon(@bruteloglike_p2c2k2, vStartValues, [], [], [], [],...
                [fPmin fPmin fCmin fCmin fKmin1 fKmin2], [fPmax fPmax fCmax fCmax fKmax1 fKmax2], [], options, tas, fT1);
            
            pv1 = vValues(1);
            pv2 = vValues(2);
            cv1 = vValues(3);
            cv2 = vValues(4);
            kv1 = vValues(5);
            kv2 = vValues(6);
    end
    % corrected Akaike Information Criterion
    [fk,~]=size(tas);
    fAIC = -2*(-fL)+2*fPar+2*fPar*(fPar+1)/(fk-fPar-1);


end

function [fL] = bruteloglike_pck2(vValues,tas,fT1)
    % bruteloglike_pck2 calculates the log likelihood function of an Omori law including one secondary aftershock at time fT1. 
    % 
    % [fL] = bruteloglike_pck2(vValues,time_as, fT1)
    %
    % Calculate the log likelihood function of an Omori law including one
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
end

function [fL] = bruteloglike_p2ck2(vValues,tas,fT1)
    % bruteloglike_p2ck2 calculates the log likelihood function of an Omori law including one secondary aftershock at time fT1. c constant , p and k different before and after fT1
    %
    % [fL] = bruteloglike_p2ck2(vValues,time_as, fT1);
    % --------------------------------------------------
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
end

function [fL] = bruteloglike_p2c2k2(vValues,tas,fT1)
    % bruteloglike_p2c2k2 calculates the log likelihood function of an Omori law including one secondary aftershock at time fT1. p, c and k different before and after fT1
    %
    % [fL] = bruteloglike_p2c2k2(vValues,time_as, fT1);
    % --------------------------------------------------
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

    p1 = vValues(1);
    p2 = vValues(2);
    c1 = vValues(3);
    c2 = vValues(4);
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
end




