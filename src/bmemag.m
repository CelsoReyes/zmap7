function [bval, bval_std, av2] =  bmemag(catalog)
    % bmemag calculates the b value based on the mean and the standard deviation
    % Stefan Wiemer 03/95
    
    % calculate the mean and std for catalog magnitudes
    %
    
    nEvents = catalog.Count;
    meanmag = mean(catalog.Magnitude);
    
    bval = (1/(meanmag - min(catalog.Magnitude-0.05)))*log10(exp(1));
    bval_std = (sum((catalog.Magnitude-meanmag).^2)) / (nEvents*(nEvents-1));
    bval_std = sqrt(bval_std);
    bval_std = 2.30*bval_std*bval^2;            % standard deviation
    
    %disp ([' b-value segment 1 = ' num2str(b1) ]);
    %disp ([' standard dev b_val_1 = ' num2str(sig1) ]);
    av2 = log10(nEvents) + bval*min(catalog.Magnitude);
    
end
