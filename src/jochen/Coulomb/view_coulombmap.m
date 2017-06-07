% Script: view_coulomb.m
% Display Coulomb stress change map together with seismicity
% Allow to analyze seismicity rate changes using the Ztools
%
% J. Woessner, jochen.woessner@sed.ethz.ch, 05.07.2004

report_this_filefun(mfilename('fullpath'));

% Default value for map view
bMap =1;

% Load CFS file
[sFilename, sPathname] = uigetfile('*.mat', 'Pick CFS change MAT-file');
sHelp = [sPathname sFilename];
sFile = [sFilename(1:length(sFilename)-4)];
load(sHelp)
rCfs = eval(sFile);

% Load rate change file
[sFilename1, sPathname1] = uigetfile('*.mat', 'Pick Rate Change MAT-file');
sHelp1 = [sPathname1 sFilename1];
sFile1 = [sFilename1(1:length(sFilename1)-4)];
load(sHelp1)


% Set up the Seismicity Map window Enviroment
% Find out of figure already exists
[existFlag,figNumber]=figure_exists('Coulomb-map',1);
newcfsmapWindowFlag=~existFlag;

if newcfsmapWindowFlag
    oldfig_button = 0;
end

if oldfig_button == 0
    cfsmap = figure_w_normalized_uicontrolunits( ...
        'Name','Coulomb-map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','add', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    % make menu bar
    matdraw

    % Display
    add_symbol_menu('eq_plot');

    % Menu: Ztools
    op1 = uimenu('Label','Ztools');
    uimenu(op1,'Label','Rate change, p-,c-,k-value map in aftershock sequence (MLE) ',...
        'Callback','sel= ''in'';,rcvalgrid_a2');
    uimenu(op1,'Label','Load existing  Rate change, p-,c-,k-value map (MLE)',...
        'Callback','sel= ''lo'';rcvalgrid_a2');

    % Menu: ZAnalyze
    op2 = uimenu('Label',' ZAnalyze ');
    uimenu(op2,'Label','Refresh ', 'Callback','view_coulombmap')
    uimenu(op2,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ho=''noho'';plot_circbootfit_a2;watchoff(cfsmap)')
    uimenu(op2,'Label','Select EQ with const. number',...
         'Callback','h1 = gca;ho2=''hold'';ho = ''hold'';plot_constnrbootfit_a2;watchoff(cfsmap)')

    % Set default colormap
    colormap(jet)
end  % This is the end of the figure setup.

% Load the data from the Coulomb data file
% Define colormap
% mColormap = gui_Colormap_Rastafari(256);
colormap(jet);

% Get the gridding
vY = linspace(rCfs.fMinLat,rCfs.fMaxLat,rCfs.nNy);
vY = fliplr(vY);
vX = linspace(rCfs.fMinLon,rCfs.fMaxLon,rCfs.nNx);

% Plot Coulomb stress map with seismicity
figure_w_normalized_uicontrolunits(cfsmap)
% Fix color scale for imagesc
vClims = [-2 2];
hCoulomb = imagesc(vX,vY,rCfs.mCfs,vClims);
shading interp;
set(gca,'Ydir','normal');
% Colorbar
hColor = colorbar;
chl = get(hColor,'Ylabel');
set(chl,'String','\Delta CFS [bar]','FontS',10,'Rot',270);

% Labeling
ylabel('Latitude [deg]');
xlabel('Longitude [deg]');

% Add rate change map
hold on;
normlap2=ones(length(ll),1)*nan;
% Relative rate change
normlap2(ll)= mRcGrid(:,15);
mRelchange = reshape(normlap2,length(yvect),length(xvect));
hRate = pcolor(xvect,yvect,mRelchange)
set(hRate, 'AlphaData', 0.6, 'AlphaDataMapping', 'none');
shading(gca,'flat')
% Plot seismicity
ploeq=plot(a(:,1),a(:,2),'Markersize',3,'Marker','o','Linestyle','none','Color',[0 0 0],'Tag','eq_plot');
hold off;
