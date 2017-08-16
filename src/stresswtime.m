function stresswtime()
% Script: stresswtime.m
% Calculates stress tensor inversion using the approach by Michael (1987)
ZG=ZmapGlobal.Data;
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
hodis = fullfile(ZG.hodi, 'external');
fs=filesep;
% Select  fault plane solution
tmpi = [ZG.newt2(:,10:12) ];

cd(hodis);

think

for i = 1:nStep:ZG.newt2.Count-ni
    % Check for data in catalog
    nCnt = i+ni;
    if nCnt < ZG.newt2.Count-1
        tmpi = [ZG.newt2(i:i+ni,10:12)];
        fMeanTime = mean(ZG.newt2(i:i+ni,3));
    else
        tmpi = [ZG.newt2(i:end,10:12)];
        fMeanTime = mean(ZG.newt2(i:end,3));
    end
    % Create data file for inversion
    fid = fopen('data2','w');
    str = ['Inversion data'];str = str';
    fprintf(fid,'%s  \n',str');
    fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');
    fclose(fid);

    % slick calculates the best solution for the stress tensor according to
    % Michael(1987): creates data2.oput
    switch(computer)
        case 'GLNX86'
            unix(['"' ZG.hodi fs 'external/slick_linux" data2 ']);
        case 'MAC'
            unix(['"' ZG.hodi fs 'external/slick_macppc" data2 ']);
        case 'MACI'
            unix(['"' ZG.hodi fs 'external/slick_maci" data2 ']);
        case 'MACI64'
            unix(['"' ZG.hodi fs 'external/slick_maci" data2 ']);
        otherwise
            dos(['"' ZG.hodi fs 'external\slick.exe" data2 ']);
    end
    % Get data from data2.oput
    sFilename = ['data2.oput'];
    [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename);

    % Remove eventually existing output
    delete data2.slboot
    % Calculate the stress tensor
    %unix([hodi fs 'external/slfast data2 ']);
    switch(computer)
        case 'GLNX86'
            unix(['"' ZG.hodi fs 'external/slfast_linux" data2 ']);
        case 'MAC'
            unix(['"' ZG.hodi fs 'external/slfast_macpcc" data2 ']);
        case 'MACI'
            unix(['"' ZG.hodi fs 'external/slfast_maci" data2 ']);
        case 'MACI64'
            unix(['"' ZG.hodi fs 'external/slfast_maci" data2 ']);
        otherwise
            dos(['"' ZG.hodi fs 'external\slfast.exe" data2 ']);
    end

    load data2.slboot
    d0 = data2;
    disp([' Time step :' num2str(fMeanTime)]);

    mResStress = [mResStress ; fMeanTime d0(2,2:7) d0(1,1) fBeta fStdBeta fTauFit];

end

% Back to original directory
cd(sPath);

% Find out if figure already exists
%
figNumber=findobj('Type','Figure','-and','Name','stress-value with time');

bdep= figNumber;

% Set up the window

% Plot time series of Variance
figure
hPlerr = plot(mResStress(:,1),mResStress(:,8),'^');
set(hPlerr,'LineWidth',1.5,'Linestyle','-','MarkerSize',6,'Color',[0 0 0])
set(gca,'box','on','SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.5)
xlabel('Time [dec. year]');
ylabel('Variance')


% Plot time series of Beta
figure
%hPlerr = errorbar(mResStress(:,1),mResStress(:,9),mResStress(:,10));
hPlerr = plot(mResStress(:,1),mResStress(:,9),'d');
set(hPlerr,'LineWidth',1.5,'Linestyle','--','MarkerSize',6,'Color',[0 0 0])
set(gca,'box','on','SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.5)
xlabel('Time [dec. year]');
ylabel('\beta [deg]')
fBetamean = nanmean(mResStress(:,9))
fBetastd = nanmean(mResStress(:,10))
end
