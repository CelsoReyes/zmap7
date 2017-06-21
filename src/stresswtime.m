% Script: stresswtime.m
% Calculates stress tensor inversion using the approach by Michael (1987)
report_this_filefun(mfilename('fullpath'));

mResStress = [];
def = {'50','10'};
sPrompt = {'Number of events in window','Step size'};
sdlgTitle = 'Window specifications'
answer = inputdlg(sPrompt,sdlgTitle,1,def);
l = answer{1};
ni = str2double(l);
nStep = str2double(answer{2});

% Path
sPath = pwd;
% Path to stress tensor inversion program
hodis = fullfile(hodi, 'external');
% Select  fault plane solution
tmpi = [newt2(:,10:12) ];

cd(hodis);

think

for i = 1:nStep:newt2.Count-ni
    % Check for data in catalog
    nCnt = i+ni;
    if nCnt < newt2.Count-1
        tmpi = [newt2(i:i+ni,10:12)];
        fMeanTime = mean(newt2(i:i+ni,3));
    else
        tmpi = [newt2(i:end,10:12)];
        fMeanTime = mean(newt2(i:end,3));
    end
    % Create data file for inversion
    fid = fopen('data2','w');
    str = ['Inversion data'];str = str';
    fprintf(fid,'%s  \n',str');
    fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');
    fclose(fid);

    % slick calculates the best solution for the stress tensor according to
    % Michael(1987): creates data2.oput
    %unix([hodi fs 'external/slick data2 ']);
    if strcmp(cputype,'GLNX86') == 1
        unix(['"' hodi fs 'external/slick_linux" data2 ']);
    elseif strcmp(cputype,'MAC') == 1
        unix(['"' hodi fs 'external/slick_macppc" data2 ']);
    elseif strcmp(cputype,'MACI') == 1
        unix(['"' hodi fs 'external/slick_maci" data2 ']);
    elseif strcmp(cputype,'MACI64') == 1
        unix(['"' hodi fs 'external/slick_maci" data2 ']);
    else
        dos(['"' hodi fs 'external\slick.exe" data2 ']);
    end
    % Get data from data2.oput
    sFilename = ['data2.oput'];
    [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename);

    % Remove eventually existing output
    delete data2.slboot
    % Calculate the stress tensor
    %unix([hodi fs 'external/slfast data2 ']);
    if strcmp(cputype,'GLNX86') == 1
        unix(['"' hodi fs 'external/slfast_linux" data2 ']);
    elseif strcmp(cputype,'MAC') == 1
        unix(['"' hodi fs 'external/slfast_macpcc" data2 ']);
    elseif strcmp(cputype,'MACI') == 1
        unix(['"' hodi fs 'external/slfast_maci" data2 ']);
    elseif strcmp(cputype,'MACI64') == 1
        unix(['"' hodi fs 'external/slfast_maci" data2 ']);
    else
        dos(['"' hodi fs 'external\slfast.exe" data2 ']);
    end

    load data2.slboot
    d0 = data2;
    disp([' Time step :' num2str(fMeanTime)]);

    mResStress = [mResStress ; fMeanTime d0(2,2:7) d0(1,1) fBeta fStdBeta fTauFit];

end

% Back to original directory
cd(sPath);

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('stress-value with time',1);
newdepWindowFlag=~existFlag;
bdep= figNumber;

% Set up the window

% if newdepWindowFlag
%     bdep = figure_w_normalized_uicontrolunits( ...
%         'Name','stress-value with time',...
%         'NumberTitle','off', ...
%         'MenuBar','none', ...
%         'NextPlot','replace', ...
%         'backingstore','on',...
%         'Visible','on');
%
%     matdraw
% end
%
% hold on
% % figure_w_normalized_uicontrolunits(bdep)
% hold on
% delete(gca)
% delete(gca)
% axis off
%
% % Convert the stress axis angles to values between 0-180
% l = mResStress(:,2)<0;
% mResStress(l,2) = mResStress(l,2)+180;
% l = mResStress(:,4)<0;
% mResStress(l,4) = mResStress(l,4)+180;
% l = mResStress(:,6)<0;
% mResStress(l,6) = mResStress(l,6)+180;

% % Plotting the time series
% rect = [0.15 0.70 0.7 0.25];
% axes('position',rect)
% % Plot Azimuth of principle stress axis
% pl1 = plot(mResStress(:,1),mResStress(:,2),'o');
% set(pl1,'LineWidth',1.,'MarkerSize',4,...
%    'MarkerFaceColor','w','MarkerEdgeColor','k')
% hold on
% pl2 = plot(mResStress(:,1),mResStress(:,4),'rs');
% set(pl2,'LineWidth',1.,'MarkerSize',4,...
%    'MarkerFaceColor','w','MarkerEdgeColor','r')
% pl3 = plot(mResStress(:,1),mResStress(:,6),'g^');
% set(pl3,'LineWidth',1.,'MarkerSize',4,...
%    'MarkerFaceColor','w','MarkerEdgeColor','b')
% set(gca,'Xlim',[floor(min(newt2.Date)) max(newt2.Date)],'XTicklabel',[]);
% set(gca,'Ylim',[0 180]);
% set(gca,'box','on',...
%     'SortMethod','childorder','TickDir','out','FontWeight',...
%     'bold','FontSize',fontsz.m,'Linewidth',1.2)
% legend([pl1,pl2,pl3],'S1','S2','S3')
% ylabel('Azimuth ')
%
%
% % 2nd axis  Plot plunge of principle stress axis
% rect = [0.15 0.4 0.7 0.25];
% axes('position',rect)
% pl1 = plot(mResStress(:,1),mResStress(:,3),'o');
% set(pl1,'LineWidth',1.,'MarkerSize',4,...
%     'MarkerFaceColor','w','MarkerEdgeColor','k')
% hold on
% pl2 = plot(mResStress(:,1),mResStress(:,5),'rs');
% set(pl2,'LineWidth',1.,'MarkerSize',4,...
%     'MarkerFaceColor','w','MarkerEdgeColor','r')
% pl3 = plot(mResStress(:,1),mResStress(:,7),'g^');
% set(pl3,'LineWidth',1.,'MarkerSize',4,...
%     'MarkerFaceColor','w','MarkerEdgeColor','b')
% set(gca,'Xlim',[floor(min(newt2.Date)) max(newt2.Date)],'XTicklabel',[]);
% set(gca,'Ylim',[0 90]);
% set(gca,'box','on',...
%     'SortMethod','childorder','TickDir','out','FontWeight',...
%     'bold','FontSize',fontsz.m,'Linewidth',1.2)
% ylabel(' Plunge ')
%
%
% % 3rd axis: Plot phi - relative magnitude measure
% rect = [0.15 0.10 0.7 0.25];
% axes('position',rect)
% plot(mResStress(:,1),mResStress(:,8),'k')
% hold on
% pl3 =plot(mResStress(:,1),mResStress(:,8),'^k');
% set(pl3,'LineWidth',1.,'MarkerSize',6,...
%     'MarkerFaceColor','w','MarkerEdgeColor','k')
% set(gca,'Xlim',[floor(min(newt2.Date)) max(newt2.Date) ]);
% set(gca,'box','on',...
%     'SortMethod','childorder','TickDir','out','FontWeight',...
%     'bold','FontSize',fontsz.m,'Linewidth',1.2)
% xlabel('Time [dec. year]')
% ylabel('\phi')

% Plot time series of Variance
figure
hPlerr = plot(mResStress(:,1),mResStress(:,8),'^');
set(hPlerr,'LineWidth',1.5,'Linestyle','-','MarkerSize',6,'Color',[0 0 0])
set(gca,'box','on','SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.5)
xlabel('Time [dec. year]');
ylabel('Variance')


% Plot time series of Beta
figure
%hPlerr = errorbar(mResStress(:,1),mResStress(:,9),mResStress(:,10));
hPlerr = plot(mResStress(:,1),mResStress(:,9),'d');
set(hPlerr,'LineWidth',1.5,'Linestyle','--','MarkerSize',6,'Color',[0 0 0])
set(gca,'box','on','SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.5)
xlabel('Time [dec. year]');
ylabel('\beta [deg]')
fBetamean = nanmean(mResStress(:,9))
fBetastd = nanmean(mResStress(:,10))

% % Plot time series of S1 direction
% figure
% hPlS1 = plot(mResStress(:,1),mResStress(:,2));
% set(hPlS1,'LineWidth',1.5,'Linestyle','-','MarkerSize',6,'Color',[0 0 0])
% set(gca,'box','on','SortMethod','childorder','TickDir','out','FontWeight',...
%     'bold','FontSize',fontsz.m,'Linewidth',1.5)
% xlabel('Time [dec. year]');
% ylabel('S1 trend [deg]')
% fS1mean = nanmean(mResStress(:,2))
% fS1std = calc_StdDev(mResStress(:,2))
%
