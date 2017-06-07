function [fL] = bruterms_pck2(vValues,tas,fT1)
    % [fL] = bruterms_pck2(vValues,time_as, fT1);
    % --------------------------------------------------
    % Function to calculate the log likelihood function of an Omori law including one
    % secondary aftershock at time fT1. Assume p and c constant for the entire sequence,
    % but different k's before and after fT1
    %
    % Incoming variables:
    % vValues : Starting values for p,c,k1,k2
    % time_as : Vector of aftershock times from mainshock time
    % fT1     : time after mainshock of the large aftershock

    p = vValues(1);
    c = vValues(2);
    k1 = vValues(3);
    k2 = vValues(4);

    % Select time periods
    vSel = tas > fT1;
    vTper1 = tas(~vSel,:);
    vTper2 = tas(vSel,:);

    % Calculate length
    i = (1:1:length(tas))';
    i1 = (1:1:length(vTper1))';
    i2 = (1:1:length(vTper2))';
    % Setting start end end time
    fTstart = min(tas);
    fTend = max(tas);

    % First period
    if p ~= 1
        cm1 = k1/(p-1)*(c.^(1-p)-(vTper1(i1)+c).^(1-p));
    else
        cm1 = k1*log(vTper1(i1)/c+1);
    end

    % Second period
    if p ~= 1
        cm2 = k1/(p-1)*(c.^(1-p)-(vTper2(i2)+c).^(1-p))+ k2/(p-1)*(c.^(1-p)-(vTper2(i2)-fT1+c).^(1-p));
    else
        cm2 = k1*log(vTper2(i2)/c+1) + k2*log((vTper2(i2)-fT1)/c+1);
    end
    cumnr_model = [cm1; cm2];

    fL = (sum((i-cumnr_model).^2)/length(i))^0.5; % RMS between observed data and MOL
