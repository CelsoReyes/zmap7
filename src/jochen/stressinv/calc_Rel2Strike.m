function [vAngle] = calc_Rel2Strike(fStrike, vAngleNorth)
    % Calculate angle relative to strike of a fault for output of stress tensor inversion angles
    % that are relative to north
    % [vAngle] = calc_Rel2Strike(fStrike, vAngleNorth)
    %
    % Convention used in vAngleNorth: -179.99 - 179.99
    %
    % fStrike : Strike of fault 0 - 179.99
    % vAngleNorth : Vector of orientation relative to north -179.99 - 179.99
    %
    % 29.03.2004, J. Woessner
    
    vAngle = vAngleNorth;
    % Check for strike
    [vIndice0] = find(vAngleNorth == fStrike | vAngleNorth == fStrike-180);
    vAngle(vIndice0) = 0;
    
    % Strike >=90 and Strike < 180
    [vIndice1] = find(vAngleNorth < 0 & fStrike >= 90 & vAngleNorth <= fStrike-180);
    vAngle(vIndice1) = vAngleNorth(vIndice1)-(fStrike-180);
    
    [vIndice1b] = find(vAngleNorth <= 0 & fStrike >= 90 & vAngleNorth > fStrike-180);
    vAngle(vIndice1b) = vAngleNorth(vIndice1b)-(fStrike-180);
    
    [vIndice2] = find(vAngleNorth > 0  & fStrike >= 90 & vAngleNorth < fStrike);
    vAngle(vIndice2) = vAngleNorth(vIndice2)+abs((fStrike-180));
    
    [vIndice3] = find(vAngleNorth > 0  & fStrike >= 90 & vAngleNorth > fStrike);
    vAngle(vIndice3) = vAngleNorth(vIndice3)-fStrike;
    
    %  0 < Strike < 90
    [vIndice4] = find(vAngleNorth >= 0 & fStrike < 90 & vAngleNorth ~= fStrike);
    vAngle(vIndice4) = vAngleNorth(vIndice4)-fStrike;
    
    %  0 < Strike < 90
    [vIndice5] = find(vAngleNorth < 0 & fStrike < 90 & vAngleNorth > fStrike-180);
    vAngle(vIndice5) = vAngleNorth(vIndice5)-fStrike;
    
    %  0 < Strike < 90
    [vIndice6] = find(vAngleNorth < 0 & fStrike < 90 & vAngleNorth < fStrike-180);
    vAngle(vIndice6) = 180-abs(fStrike-180-vAngleNorth(vIndice6));
    
end