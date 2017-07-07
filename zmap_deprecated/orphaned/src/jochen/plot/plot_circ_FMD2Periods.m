% Script: plot_circ_FMD2Periods
% Selects earthquakes in the radius ra around a grid node and calculate magnitude shift
%
% Jochen Woessner
% last update: 22.01.04

report_this_filefun(mfilename('fullpath'));
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
%  and sort by distance l
% Calculate distance from center point and sort with distance
sFigName = get(gcf,'Name')
% if sFigName == 'RC-Cross-section'
%     % Cross section
%     newt2 = newa;
%     l = sqrt(((xsecx' - xa0)).^2 + (((xsecy+ya0))).^2) ;
% else % Map view
    newt2 = a;
    l = sqrt(((newt2.Longitude-xa0)*cos(pi/180*ya0)*111).^2 + ((newt2.Latitude-ya0)*111).^2) ;
% end
[s,is] = sort(l);
newt2 = newt2(is(:,1),:) ;

l =  sort(l);

% Select data in radius ra
l3 = l <= ra;
newt2 = newt2(l3,:);

% Select radius in time
% newt3=newt2;
% vSel = (newt2.Date <= maepi(:,3)+time/365);
% newt2 = newt2(vSel,:);
%R2 = l(ni);
messtext = ['Number of selected events: ' num2str(length(newt2))  ];
disp(messtext)
zmap_message_center.set_message('Message',messtext)


% Sort the catalog
[st,ist] = sort(newt2);
newt2 = newt2(ist(:,3),:);
R2 = ra;

% Plot selected earthquakes
hold on;

plos1 = plot(newt2.Longitude,newt2.Latitude,'xk','EraseMode','normal');

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
pl = plot(xa0+sin(x)*R2/(cos(pi/180*ya0)*111), ya0+cos(x)*R2/(cos(pi/180*ya0)*111),'k','era','normal')

% Compute magshift
% Select data from 2 time periods
vSelT = newt2.Date < fSplitTime;
mCat1 = newt2(vSelT,:);
mCat2 = newt2(~vSelT,:);

fPeriod1 = max(mCat1(:,3))-min(mCat1(:,3));
fPeriod2 = max(mCat2(:,3))-min(mCat2(:,3));

% Plot the FMDs
% Create the frequency magnitude distribution vector
[vFMD1, vNonCFMD1] = calc_FMD(mCat1);
[vFMD2, vNonCFMD2] = calc_FMD(mCat2);
figure
subplot(1,2,1)
hPlot1 = plot(vNonCFMD1(1,:), vNonCFMD1(2,:)./fPeriod1,'Marker','o','Color',[0 0 0],'MarkerFaceColor',[0.4 0.4 0.4]);
hold on;
hPlot2 = plot(vNonCFMD2(1,:), vNonCFMD2(2,:)./fPeriod2,'Marker','^','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.7 0.7 0.7]);
set(hPlot1,'Linewidth',2)
set(hPlot2,'Linewidth',2)
hLeg = legend([hPlot1 hPlot2],'Period 1','Period 2')
set(gca,'Linewidth',1.5,'Fontweight','bold','FontSize',12)
set(hLeg,'Linewidth',1.5,'Fontweight','bold','FontSize',12)
xlabel('Magnitude','Fontweight','bold','FontSize',12)
ylabel('Rate of events / year','Fontweight','bold','FontSize',12)

subplot(1,2,2)
hPlot1 = semilogy(vFMD1(1,:), vFMD1(2,:)./fPeriod1,'Marker','o','Color',[0 0 0],'MarkerFaceColor',[0.4 0.4 0.4]);
hold on;
hPlot2 = semilogy(vFMD2(1,:), vFMD2(2,:)./fPeriod2,'Marker','^','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.7 0.7 0.7]);
hLeg = legend([hPlot1 hPlot2],'Period 1','Period 2')
ylim([1 ceil(max(vFMD2(2,:)./fPeriod2))]);
set(hPlot1,'Linewidth',2)
set(hPlot2,'Linewidth',2)
set(gca,'Linewidth',1.5,'Fontweight','bold','FontSize',12)
set(hLeg,'Linewidth',1.5,'Fontweight','bold','FontSize',12)
xlabel('Magnitude','Fontweight','bold','FontSize',12)
ylabel('Cum. rate of events  / year','Fontweight','bold','FontSize',12)
%[fMshift, fProbability, fAICc, mProblikelihood, bH] = calc_loglikelihood_dM2(mCat1, mCat2)


newcat = newt2;                   % resets newcat and newt2

% Call program "timeplot to plot cumulative number
clear l s is
timeplot
