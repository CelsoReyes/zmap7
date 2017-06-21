function [mean_m1, b1, sig1, av2] =  bmemag(b)
    % function calculates the mean magnitute, the b value based
    % on the mean and the standart deviation
    % Stefan Wiemer 03/95

    %report_this_filefun(mfilename('fullpath'));

    newcat = b;
    maxmag = max(newcat.Magnitude);
    mima = min(newcat.Magnitude);
    if mima > 0
        mima = 0 ;
    end


    % calculate the mean magnitude, b(mean) and std
    %
    n = newcat.Count;
    mean_m1 = mean(newcat.Magnitude);
    b1 = (1/(mean_m1-min(newcat.Magnitude-0.05)))*log10(exp(1));
    sig1 = (sum((newcat.Magnitude-mean_m1).^2))/(n*(n-1));
    sig1 = sqrt(sig1);
    sig1 = 2.30*sig1*b1^2;            % standard deviation
    %disp ([' b-value segment 1 = ' num2str(b1) ]);
    %disp ([' standard dev b_val_1 = ' num2str(sig1) ]);
    av2 = log10(newcat.Count) + b1*min(newcat.Magnitude);

