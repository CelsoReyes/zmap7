function [fL] = bruterms_p2c2k2(vValues,tas,fT1)
    % [fL] = bruterms_p2c2k2(vValues,time_as, fT1);
    % --------------------------------------------------
    %
    % Incoming variables:
    % vValues : Starting values for p,c,k1,k2
    % time_as : Vector of aftershock times from mainshock time
    % fT1     : time after mainshock of the large aftershock

    p1 = vValues(1);
    p2 = vValues(2);
    c1 = vValues(3);
    c2 = vValues(4);
    k1 = vValues(5);
    k2 = vValues(6);

    % Select time periods
    vSel = tas > fT1;
    vTper1 = tas(~vSel,:);
    vTper2 = tas(vSel,:);

    % Calculate length
    i = (1:1:length(tas))';
    i1 = (1:1:length(vTper1));
    i2 = (1:1:length(vTper2));


    % Setting start end end time
    fTstart = min(tas);
    fTend = max(tas);

    % First time period
    if p1 ~= 1
        cm1 = k1/(p1-1)*(c1.^(1-p1)-(vTper1(i1)+c1).^(1-p1));
    else
        cm1 = k1*log(vTper1(i1)/c1+1);
    end

    % Second time period
    if (p1 ~= 1 & p2 ~= 1)
        cm2 = k1/(p1-1)*(c1.^(1-p1)-(vTper2(i2)+c1).^(1-p1))+ k2/(p2-1)*(c2.^(1-p2)-(vTper2(i2)-fT1+c2).^(1-p2));
    else
        cm2 = k1*log(vTper2(i2)/c1+1) + k2*log((vTper2(i2)-fT1)/c2+1);
    end

    cumnr_model = [cm1;cm2];

    fL = (sum((i-cumnr_model).^2)/length(i))^0.5; % RMS between observed data and MOL
