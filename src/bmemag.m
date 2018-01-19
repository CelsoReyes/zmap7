function [bval, bval_std, av2] =  bmemag(magnitudes)
    % BMEMAG calculates the b value based on the mean and the standard deviation
    % [bval, bval_std, av2] =  BMEMAG(catalog) 
    % Stefan Wiemer 03/95
    
    % calculate the mean and std for magnitudes
    %
    
    nEvents = numel(magnitudes);
    meanmag = mean(magnitudes);
    
    bval = (1/(meanmag - min(magnitudes-0.05)))*log10(exp(1));
    if nargout<2
        return
    end
    bval_std = (sum((magnitudes-meanmag).^2)) / (nEvents*(nEvents-1));
    bval_std = sqrt(bval_std);
    bval_std = 2.30*bval_std*bval^2;            % standard deviation
    
    %disp ([' b-value segment 1 = ' num2str(b1) ]);
    %disp ([' standard dev b_val_1 = ' num2str(sig1) ]);
    av2 = log10(nEvents) + bval*min(magnitudes);
    
end
