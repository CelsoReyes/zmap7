function [Mcomp] = mcwithtime(eqcatalogue,tas,time)
    % function [Mcomp] = mcwithtime(eqcatalogue,tas,time);
    % --------------------------------------------
    % Determines magnitude of completeness of aftershocks
    % which occurred up to time
    %
    % Input parameters:
    %   eqcatalogue earthquake catalog (ZMAP format)
    %   tas         aftershock delay times (days)
    %   time        threshold time (days)
    %
    % Output parameters:
    %   Mcomp       Magnitude of completeness
    %
    % Samuel Neukomm
    % June 25, 2002

    l = tas <= time;
    mccat = eqcatalogue(l,:);
    Mcomp = NaN;

    try
        [Mcomp] = calc_Mc(mccat,2);
    end

    if isnan(Mcomp)
        Mcomp = 3; %???, calc_Mc fails mostly for high completeness, for the data sets used ~ 3
    end

