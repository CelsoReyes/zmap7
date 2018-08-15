function [spatial_km, temporal] = calc_windows(mags, dcwMethod)
    % Calculate window lengths in space and time for the windowing declustering technique
    % function [spatial_km, temporal] = calc_windows(mags, dcwMethod);
    %
    %
    % Incoming variables:
    % mags : magnitude
    % dcwMethod    : decluster window calculation method  (see DeclusterWindowingMethods)
    %
    % Outgoing variables:
    % spatial_km : Window length in space [km]
    % temporal  : Window duration in time % was [dec. years], now duration
    %
    % J. Woessner, woessner@seismo.ifg.ethz.ch
    % updated: 22.07.02
    %
    % see also DeclusterWindowingMethods
    
    mags=mags(:);
    spatial_km = nan(size(mags));
    temporal = nan(size(mags));
    
    switch dcwMethod
        case DeclusterWindowingMethods.GardinerKnopoff1974
            
            spatial_km = 10.^(0.1238*mags+0.983);
            
            idxT = mags < 6.5;
            temporal(idxT) = 10.^(0.5409*mags(idxT)-0.547);   % mags < 6.5
            temporal(~idxT) = 10.^(0.032*mags(~idxT)+2.7389); % mags >= 6.5
            
            temporal = days(temporal);
            
        case DeclusterWindowingMethods.GruenthalPersCom
            
            spatial_km = exp(1.77+sqrt(0.037+1.02*mags));
            
            idxT = mags < 6.5;
            temporal(idxT) = abs((exp(-3.95+sqrt(0.62+17.32*mags(idxT)))));
            temporal(~idxT) = (10.^(2.8+0.024*mags(~idxT)));
            
            temporal = days(temporal);
            
        case DeclusterWindowingMethods.Urhammer1986
            
            spatial_km = exp(-1.024+0.804*mags);
            temporal = days(exp(-2.87+1.235*mags));
            
            %% the following are not used
            %{
        case DeclusterWindowingMethods.Gruenthal1985
            
            spatial_km = 10.^(0.1060*mags+1.0982);
            temporal = days(10.^(0.5055*mags-0.1329));
            
        case DeclusteringWindowingMethods.ModifiedYoungs1987Max
            spatial_km(mags <= 2.43) = 20;
            
            idxS = mags > 2.43 & mags <=5.86;
            spatial_km(idxS) = 10.^(0.1159*mags(idxS)+1.0197);
            
            idxS = mags > 5.86;
            spatial_km(idxS) = 10.^(0.5281*mags(idxS)-1.3937);
            
            idxT = mags <= 3.89;
            temporal(idxT) = 30;
            
            temporal(~idxT)  = 10.^(0.4916*mags(~idxT)-0.4317);
            temporal = days(temporal);
            
        case DeclusteringWindowingMethods.ModifiedYoungs1987Min
            idxS = mags <= 4.41;
            spatial_km(idxS) = 10;
            
            idxS = mags > 4.41 & mags <= 4.98;
            spatial_km(idxS) = 10.^(0.5281*mags(idxS)-1.329);
            
            idxS = mags > 4.98 & mags <= 6.42;
                spatial_km(idxS) = 10.^(0.3313*mags(idxS)-0.349);
            
            idxS = mags >6.42;
                spatial_km(idxS) = 10.^(0.1154*mags(idxS)+1.0371);
            
            
            idxT = mags <= 5;
            temporal(idxT) = 15;
            temporal(~idxT) = 10.^(1.0526*mags-4.5610);
            temporal = days(temporal);
            %}
            
        otherwise
            disp('Choose a valid method number');
    end
end
