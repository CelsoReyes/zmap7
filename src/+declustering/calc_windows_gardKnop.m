function [fSpace, fTime] = calc_windows_gardKnop(fMagnitude, nMethod)
    % Calculate window lengths in space and time forthe windowing declustering technique
    %
    % [fSpace, fTime] = calc_windows_gardKnop(fMagnitude, nMethod);
    %
    % Calculate window lengths in space and time forthe windowing declustering technique
    %
    % Incoming variables:
    % fMagnitude : magnitude
    % nMethod    : Selection variable for window definition of specific authors
    %              1 = Gardener & Knopoff, 1974
    %              2 = Gruenthal pers. communication
    %              3 = Urhammer, 1986
    %
    % Outgoing variables:
    % fSpace : Window length in space [km]
    % fTime  : Window length in time [dec. years]
    %
    % J. Woessner, woessner@seismo.ifg.ethz.ch
    % last update: 22.07.02
    
    %%% Further possibilites, but not used %%%%%%%%%%%%%%%
    %              4 = Gruenthal, 1985 (from Figure)
    %              5 = Mod. Youngs, 1987, Maximum window
    %              6 = Mod. Youngs, 1987, Minimum window
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch nMethod
        case 1
            
            %The Gardner & Knopoff with table
            magtable=2.5 : 0.5 : 8;
            distTable=[19.5, 22.5, 26, 30, 35, 40, 47, 54, 61, 70, 81, 94];
            timedayTable=[6, 11.5, 22, 42, 83, 155, 290, 510, 790, 915, 960, 985];
            
            fTime=zeros(numel(fMagnitude),1);
            fSpace=zeros(numel(fMagnitude),1);
            
            %There would be "cleaner way to do this but this way it is vectorized
            %and supports vector inputs
            M25 = fMagnitude < magtable(1);
            M25_M3 = magtable(1) <= fMagnitude < magtable(2);
            M3_M35 = magtable(2) <= fMagnitude & fMagnitude < magtable(3);
            M35_M4 = magtable(3) <= fMagnitude & fMagnitude < magtable(4);
            M4_M45 = magtable(4) <= fMagnitude & fMagnitude < magtable(5);
            M45_M5 = magtable(5) <= fMagnitude & fMagnitude < magtable(6);
            M5_M55 = magtable(6) <= fMagnitude & fMagnitude < magtable(7);
            M55_M6 = magtable(7) <= fMagnitude & fMagnitude < magtable(8);
            M6_M65 = magtable(8) <= fMagnitude & fMagnitude < magtable(9);
            M65_M7 = magtable(9) <= fMagnitude & fMagnitude < magtable(10);
            M7_M75 = magtable(10) <= fMagnitude & fMagnitude < magtable(11);
            M75_M8 = magtable(11) <= fMagnitude & fMagnitude < magtable(12);
            M8 = magtable(12) <= fMagnitude;
            
            %now the time
            fTime(M25) = timedayTable(1)+(fMagnitude(M25)-magtable(1)) * (timedayTable(1)-timedayTable(2))/0.5;
            fTime(M25_M3) = timedayTable(1)+(fMagnitude(M25_M3)-magtable(1)) * (timedayTable(2)-timedayTable(1))/0.5;
            fTime(M3_M35) = timedayTable(2)+(fMagnitude(M3_M35)-magtable(2)) * (timedayTable(3)-timedayTable(2))/0.5;
            fTime(M35_M4) = timedayTable(3)+(fMagnitude(M35_M4)-magtable(3)) * (timedayTable(4)-timedayTable(3))/0.5;
            fTime(M4_M45) = timedayTable(4)+(fMagnitude(M4_M45)-magtable(4)) * (timedayTable(5)-timedayTable(4))/0.5;
            fTime(M45_M5) = timedayTable(5)+(fMagnitude(M45_M5)-magtable(5)) * (timedayTable(6)-timedayTable(5))/0.5;
            fTime(M5_M55) = timedayTable(6)+(fMagnitude(M5_M55)-magtable(6)) * (timedayTable(7)-timedayTable(6))/0.5;
            fTime(M55_M6) = timedayTable(7)+(fMagnitude(M55_M6)-magtable(7)) * (timedayTable(8)-timedayTable(7))/0.5;
            fTime(M6_M65) = timedayTable(8)+(fMagnitude(M6_M65)-magtable(8)) * (timedayTable(9)-timedayTable(8))/0.5;
            fTime(M65_M7) = timedayTable(9)+(fMagnitude(M65_M7)-magtable(9)) * (timedayTable(10)-timedayTable(9))/0.5;
            fTime(M7_M75) = timedayTable(10)+(fMagnitude(M7_M75)-magtable(10)) * (timedayTable(11)-timedayTable(10))/0.5;
            fTime(M75_M8) = timedayTable(11)+(fMagnitude(M75_M8)-magtable(11)) * (timedayTable(12)-timedayTable(11))/0.5;
            fTime(M8) = timedayTable(11)+(fMagnitude(M8)-magtable(11)) * (timedayTable(12)-timedayTable(11))/0.5;
            
            
            %same with the distance
            fSpace(M25) = distTable(1)+(fMagnitude(M25)-magtable(1)) * (distTable(1)-distTable(2))/0.5;
            fSpace(M25_M3) = distTable(1)+(fMagnitude(M25_M3)-magtable(1)) * (distTable(2)-distTable(1))/0.5;
            fSpace(M3_M35) = distTable(2)+(fMagnitude(M3_M35)-magtable(2)) * (distTable(3)-distTable(2))/0.5;
            fSpace(M35_M4) = distTable(3)+(fMagnitude(M35_M4)-magtable(3)) * (distTable(4)-distTable(3))/0.5;
            fSpace(M4_M45) = distTable(4)+(fMagnitude(M4_M45)-magtable(4)) * (distTable(5)-distTable(4))/0.5;
            fSpace(M45_M5) = distTable(5)+(fMagnitude(M45_M5)-magtable(5)) * (distTable(6)-distTable(5))/0.5;
            fSpace(M5_M55) = distTable(6)+(fMagnitude(M5_M55)-magtable(6)) * (distTable(7)-distTable(6))/0.5;
            fSpace(M55_M6) = distTable(7)+(fMagnitude(M55_M6)-magtable(7)) * (distTable(8)-distTable(7))/0.5;
            fSpace(M6_M65) = distTable(8)+(fMagnitude(M6_M65)-magtable(8)) * (distTable(9)-distTable(8))/0.5;
            fSpace(M65_M7) = distTable(9)+(fMagnitude(M65_M7)-magtable(9)) * (distTable(10)-distTable(9))/0.5;
            fSpace(M7_M75) = distTable(10)+(fMagnitude(M7_M75)-magtable(10)) * (distTable(11)-distTable(10))/0.5;
            fSpace(M75_M8) = distTable(11)+(fMagnitude(M75_M8)-magtable(11)) * (distTable(12)-distTable(11))/0.5;
            fSpace(M8) = distTable(11)+(fMagnitude(M8)-magtable(11)) * (distTable(12)-distTable(11))/0.5;
            
            fTime=fTime/365;
            
        case 2
            %disp('Using Gardner & Knopoff, 1974')
            fSpace = 10.^(0.1238*fMagnitude+0.983);
            if fMagnitude >= 6.5
                fTime = (10.^(0.032*fMagnitude+2.7389))/365;
            else
                fTime = (10.^(0.5409*fMagnitude-0.547))/365;
            end
            
        case 3
            %disp('Using Gruenthal, pers. communication')
            fSpace = exp(1.77+sqrt(0.037+1.02*fMagnitude));
            if fMagnitude < 6.5
                fTime = abs((exp(-3.95+sqrt(0.62+17.32*fMagnitude)))/365);
            else
                fTime = (10.^(2.8+0.024*fMagnitude))/365;
            end
            
        case 4
            %disp('Urhammer, 1976');
            fSpace = exp(-1.024+0.804*fMagnitude);
            fTime = (exp(-2.87+1.235*fMagnitude))/365;
            
        case 5
            disp('zonk')
            fSpace=5;
            fTime=1/365;
        otherwise
            disp('Choose a valid method number');
    end
end
