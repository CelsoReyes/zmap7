%
% Calculates the average over the ten iterations for each number of events
% and for each volume.
%
for kd =1:8

    avrfr8(1:20, kd) = sum(fdnumfr10(:,:, kd),2)/10;
    avrpkfrrg = sum(fdnpkfrrg,2)/25;
end

kd1 = 1:8;
for kd = 1:8

    Havr = figure_w_normalized_uicontrolunits('numbertitle', 'off', 'name', 'Average D-value for 25 iterations versus # of events');
    plot(avrpkfrrg,'kx');
    axis([0 44 1.5 3.5]);
    set(gca, 'Xtick', [1:4:41],'Xticklabel', [50:200:2050],  'Fontweight', 'bold');
    title('D-value versus Number of Events Simulated in a Real Geometry');
    xlabel('Number of Events');
    ylabel('D-value');
    %figure_w_normalized_uicontrolunits(100);
    %plot(avr25);
end


colinav = jet(64);
Hf=figure_w_normalized_uicontrolunits('Numbertitle', 'off','Name','Average of the Iterations');

for kd =1:8

    Ac = round((kd*64)/8);
    %Hfig3 = figure_w_normalized_uicontrolunits(300+kd);
    %figure_w_normalized_uicontrolunits(Hfig3);
    plot(avrfr8(:,kd),'Marker', 'o','linestyle', '-', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);
    %plot(avr8,'ko');
    %axis([0 46 2.5 3.5]);
    hold on;
    %plot(avrfr10(:,kd),'Marker', 'x','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);

end

cb=colorbar('horiz');
set(cb, 'pos', [0.3 0.05 0.4 0.04], 'XTickLabel', col, 'fontsize', 9, 'title', 'D-value');


%
% The mean over the 10/25 iterations and then over the 8 volumes.
%
avr18 = sum(avr10,2)/8;
avrfr18 = sum(avrfr10,2)/8;

figure_w_normalized_uicontrolunits('Numbertitle', 'off','Name','Mean value of the average over the volumes');
%plot(avr18 ,'ko');
axis([0 46 2.5 3.5]);
hold on;
plot(avrfr18, 'rx');
%
% Calculates the variance of the points for each number-of-events and for
% each volume. The mean value is set to the 1000 number-of-events average.
%
%
avrpk2040 = avrpkfrrg(20:40,1);
mean = sum(avrpk2040)/21;

for kd = 1:8
    %mean = avrfr10(20,kd);
    for k7 = 1:20
        for k8 = 1:10
            %varfr1(k7,k8,kd) = (fdnumfr10(k7,k8,kd)-mean)^2;
            varpkfrrg1 = (fdnpkfrrg-mean).^2;
        end
    end
end

for kd = 1:8
    %varfr(1:20,kd) = sum(varfr1(:,:,kd), 2)*1/10;
    varpkfrrg = sum(varpkfrrg1, 2)*1/25
end



figure_w_normalized_uicontrolunits('Numbertitle', 'off','Name','Variance of the Iterations 1');

for kd =1:8

    Ac = round((kd*64)/8);
    %plot(var(1:20,kd),'Marker', 'o','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);
    semilogy(varfrrg, 'ko');
    axis([0 46 0 1.2]);
    hold on;
    plot(varfrrg(1:20,kd),'Marker', 'x','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);
    plot(varpkfrrg, 'kx');
end

figure_w_normalized_uicontrolunits('Numbertitle', 'off','Name','Variance of the Iterations 2');

for kd =1:8

    Ac = round((kd*64)/8);
    plot(var(8:20,kd),'Marker', 'o','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);
    axis([0 13 0 0.025]);
    hold on;
    plot(varfr(8:20,kd),'Marker', 'x','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);

end




% La mean of the variances.

mvar = sum(var,2)/8;
mvarfr = sum(varfr,2)/8;

figure_w_normalized_uicontrolunits('Numbertitle', 'off','Name','Mean value of the variances between the volumes');
plot(mvar,'ko');
axis([0 21 0 0.7]);
hold on;
plot(mvarfr, 'rx');
%
% Calculation of the standard deviation.
%
stdev25 = var25.^(1/2);
stdevpkfrrg = varpkfrrg.^(1/2);

figure_w_normalized_uicontrolunits('Numbertitle', 'off','Name','Standard Deviation of the Iterations 1');

for kd = 1:8

    Ac = round((kd*64)/8);
    %plot(stdev(1:20,kd),'Marker', 'o','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);
    plot(stdev25, 'ko');
    axis([0 46 0 0.4]);
    hold on;
    plot(stdevpkfrrg(1:20,kd),'Marker', 'x','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);

end


for kd =1:8

    figure_w_normalized_uicontrolunits(600+kd);%,'Name','Standard Deviation of the Iterations 2');
    Ac = round((kd*64)/8);
    plot(stdev(1:20,kd),'Marker', 'o','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);
    axis([0 21 0 1]);
    hold on;
    plot(stdevfr(1:20,kd),'Marker', 'x','linestyle', 'none', 'color', [colinav(Ac,1) colinav(Ac,2) colinav(Ac,3)]);

end


Hstdev = figure_w_normalized_uicontrolunits('numbertitle', 'off', 'name', 'D-value versus Number of Events');
plot(stdevpkfrrg,'kx');
axis([0 42 0 0.4]);
set(gca, 'Xtick', [1:4:41],'Xticklabel', [50:200:2050],  'Fontweight', 'bold');
title('Standard Deviation of the D-value versus Number of Events Simulated in a Real Geometry');
xlabel('Number of Events');
ylabel('D-value');

% The mean of the standard deviations.

mstdev = sum(stdev,2)/8;
mstdevfr = sum(stdevfr,2)/8;

figure_w_normalized_uicontrolunits('Numbertitle', 'off','Name','Mean value of the standard deviations between the volumes');
plot(mstdev,'ko');
axis([0 21 0 1]);
hold on;
plot(mstdevfr, 'rx');
