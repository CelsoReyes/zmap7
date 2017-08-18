% Script: plot_circ__FMD
% Selects earthquakes in the radius ra around a grid node and calculate magnitude shift
%
% Jochen Woessner
% last update: 22.01.04

report_this_filefun(mfilename('fullpath'));
ZG=ZmapGlobal.Data;
try
    delete(plos1)
catch
    disp(' ');
end

axes(h1)
%zoom off

titStr ='Selecting EQ in Circles                         ';
messtext= ...
    ['                                                '
    '  Please use the LEFT mouse button              '
    ' to select the center point.                    '
    ' The "ni" events nearest to this point          '
    ' will be selected and displayed in the map.     '];

zmap_message_center.set_message(titStr,messtext);

% Input center of circle with mouse
%
[xa0,ya0]  = ginput(1);

stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
stri = stri1;
pause(0.1)

%  Calculate distance for each earthquake from center point
% Select data in radius ra
[mask, furthest_event_km] = eventsInRadius(ZG.a, ya0, xa0, ra);
ZG.newt2 = ZG.a.subset(mask);

messtext = ['Number of selected events: ' num2str(ZG.newt2.Count)  ];
disp(messtext)
zmap_message_center.set_message('Message',messtext)


% Sort the catalog
ZG.newt2.sort('Date');
R2 = ra;

% Plot selected earthquakes
hold on;

plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','normal');

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
pl = plot(xa0+sin(x)*R2/(cosd(ya0)*111), ya0+cos(x)*R2/(cosd(ya0)*111),'k','era','normal')

% Compute magshift
% Select data from 2 time periods
vSelT = ZG.newt2.Date < fSplitTime;
mCat1 = ZG.newt2(vSelT,:);
mCat2 = ZG.newt2(~vSelT,:);

fPeriod1 = max(mCat1(:,3))-min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3))-min(mCat2(:,3));

% Plot the FMDs
% Create the frequency magnitude distribution vector
[vFMD1, vNonCFMD1] = calc_FMD(mCat1);
[vFMD2, vNonCFMD2] = calc_FMD(mCat2);
figure
subplot(1,2,1)
hPlot1 = semilogy(vNonCFMD1(1,:), vNonCFMD1(2,:)./fPeriod1,'Marker','o','Color',[0 0 0]);
hold on;
hPlot2 = semilogy(vNonCFMD2(1,:), vNonCFMD2(2,:)./fPeriod2,'Marker','^','Color',[0.5 0.5 0.5]);
hLeg = legend([hPlot1 hPlot2],'Period 1','Period 2')

subplot(1,2,2)
hPlot1 = semilogy(vFMD1(1,:), vFMD1(2,:)./fPeriod1,'Marker','o','Color',[0 0 0]);
hold on;
hPlot2 = semilogy(vFMD2(1,:), vFMD2(2,:)./fPeriod2,'Marker','^','Color',[0.5 0.5 0.5]);
hLeg = legend([hPlot1 hPlot2],'Period 1','Period 2')

%[fMshift, fProbability, fAICc, mProblikelihood, bH] = calc_loglikelihood_dM2(mCat1, mCat2)

%set(gcf,'Pointer','arrow')
%
newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2

% Call program "timeplot to plot cumulative number
clear l s is
timeplot(ZG.newt2)
