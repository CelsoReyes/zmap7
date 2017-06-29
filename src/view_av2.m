% subroutine to plotinga-value and others
% run by calc_across
% This subroutine is based on view_bv2.m and
% was created by
% Thomas van Stiphout 3/04


% define size of the plot etc.
%
if isempty(name) >  0
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
co = 'k';

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('a-value cross-section',1);
newbmapcWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newbmapcWindowFlag
    bmapc = figure_w_normalized_uicontrolunits( ...
        'Name','a-value cross-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    % make menu bar
    matdraw
    lab1 = 'a-value';

    add_symbol_menu('eqc_plot');


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_av2')
    uimenu(options,'Label','Select EQ in Circle (const N)',...
         'Callback',' h1 = gca;ho = ''noho'';ic = 1;cicros;')
    uimenu(options,'Label','Select EQ in Circle (const R)',...
         'Callback',' h1 = gca;ho = ''noho'';ic = 2;cicros;')
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'Callback','h1 = gca;ho = ''hold'';cicros;')
    uimenu(options,'Label','Select Eqs in Polygon - new',...
         'Callback','ho = ''noho'';polyb;');
    uimenu(options,'Label','Select Eqs in Polygon - hold',...
         'Callback','ho = ''hold'';polyb;');

    % Menu 'Maps'
    op1 = uimenu('Label',' Maps ');
    % A-Value map calculated by the MaxLikelihoodA...
    uimenu(op1,'Label','a-value map ',...
         'Callback','lab1 =''a-value''; re3 = aValueMap; view_av2')
    % B-Value map (fixed b-value by input from calc_avalgrid.m
    uimenu(op1,'Label','b-value map ',...
         'Callback','lab1=''b-value''; re3 = bValueMap; view_av2')
    % Magnitude of completeness calculated by MaxCurvature
    uimenu(op1,'Label','Magnitude of completness map ',...
         'Callback','lab1 = ''Mcomp''; re3 = MaxCMap; view_av2')
    % Resolution estimation by mapping the needed radius to cover ni
    % earthquakes
    uimenu(op1,'Label','Resolution map',...
         'Callback','lab1=''Radius in [km]'';re3 = reso; view_av2')
    % Earthquake density map
    uimenu(op1,'Label','Earthquake density map',...
         'Callback','lab1=''log(EQ per km^2)'';re3 = log10(ni./(reso.^2*pi)); view_av2')
    % Mu-value of the normal CDF
    uimenu(op1,'Label','Mu-value of the normal CDF',...
         'Callback','lab1=''Mu-Value'';re3 = MuMap; view_av2')
    %  Sigma-value of the normal CDF
    uimenu(op1,'Label','Sigma-value of the normal CDF',...
         'Callback','lab1=''Sigma-Value'';re3 = SigmaMap; view_av2')



    op2e = uimenu('Label',' Display ');
    uimenu(op2e,'Label','Fix color (z) scale', 'Callback','fixax2 ')
    uimenu(op2e,'Label','Show Grid ',...
         'Callback','hold on;plot(newgri(:,1),newgri(:,2),''+k'')')
    uimenu(op2e,'Label','Show Circles ', 'Callback','plotci3')
    uimenu(op2e,'Label','Colormap InvertGray',...
         'Callback','g=gray; g = g(64:-1:1,:);colormap(g);brighten(.4)')
    uimenu(op2e,'Label','Colormap Invertjet',...
         'Callback','g=jet; g = g(64:-1:1,:);colormap(g)')
    uimenu(op2e,'Label','shading flat',...
         'Callback','axes(hzma); shading flat;sha=''fl'';')
    uimenu(op2e,'Label','shading interpolated',...
         'Callback','axes(hzma); shading interp;sha=''in'';')
    uimenu(op2e,'Label','Brigten +0.4',...
         'Callback','axes(hzma); brighten(0.4)')
    uimenu(op2e,'Label','Brigten -0.4',...
         'Callback','axes(hzma); brighten(-0.4)')
    uimenu(op2e,'Label','Redraw Overlay',...
         'Callback','hold on;overlay_')

    colormap(jet)
    bOverlayTransparentStdDev = 0;
end   % This is the end of the figure setup

% Now lets plot the color-map of the z-value
%
figure_w_normalized_uicontrolunits(bmapc)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

rect = [0.15,  0.10, 0.8, 0.75];
rect1 = rect;

% set values greater tresh = nan
%
re4 = re3;
l = r > tresh;
re4(l) = zeros(1,length(find(l)))*nan;

%l = re4 > min(bvgr(:,1)) &  re4 < max(bvgr(:,1)) ;
%l = re4 > mean(bvgr(:,1))-2*std(bvgr(:,1)) &  re4 <  mean(bvgr(:,1))+2*std(bvgr(:,1));
%re4(l) = zeros(1,length(find(l)))*nan;
%re4(l) = zeros(1,length(find(l)))+ mean(bvgr(:,1));

% plot image
%
orient portrait
%set(gcf,'PaperPosition', [2. 1 7.0 5.0])

axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image

if bOverlayTransparentStdDev
    mTransparentStdDev = mAverageStdDev;
    vSelection = mAverageStdDev <= 0.05;
    mTransparentStdDev(vSelection) = 1;
    vSelection = (mAverageStdDev > 0.05) & (mAverageStdDev <= 0.1);
    mTransparentStdDev(vSelection) = 0.75;
    vSelection = (mAverageStdDev > 0.1) & (mAverageStdDev <= 0.15);
    mTransparentStdDev(vSelection) = 0.5;
    vSelection = (mAverageStdDev > 0.15) & (mAverageStdDev <= 0.2);
    mTransparentStdDev(vSelection) = 0.25;
    vSelection = mAverageStdDev > 0.2;
    mTransparentStdDev(vSelection) = 0;
    set(pco1, 'FaceALpha', 'flat', 'AlphaData', mTransparentStdDev, 'AlphaDataMapping', 'none');
end
bOverlayTransparentStdDev = 0;

hold on
if sha == 'fl'
    shading flat
else
    shading interp
end

if term == 1
    colormap(gray)
else
    % h = hsv(64);
    %h = h(57:-1:1,:);
    %colormap(jet)
end

% make the scaling for the recurrence time map reasonable
if lab1(1) =='T'
    fre = 0;
    l = isnan(re3);
    re = re3;
    re(l) = [];
    caxis([min(re) 5*min(re)]);
end
if fre == 1
    caxis([fix1 fix2])
end

title2([name ';  '   num2str(t0b,4) ' to ' num2str(teb,4) ],'FontSize',fontsz.m,...
    'Color','w','FontWeight','bold')

xlabel('Distance [km]','FontWeight','normal','FontSize',fontsz.s)
ylabel('Depth [km]','FontWeight','normal','FontSize',fontsz.s)

% plot overlay
%
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
set(ploeqc,'Tag','eqc_plot','MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)

try

    if exist('vox', 'var')
        plovo = plot(vox,voy,'^r');
        set(plovo,'MarkerSize',8,'LineWidth',1,'Markerfacecolor','w','Markeredgecolor','r')
        axis([ min(gx) max(gx) min(gy) max([ 1 max(gy)]) ])

    end

    if exist('maix', 'var')
        pl = plot(maix,maiy,'*k');
        set(pl,'MarkerSize',12,'LineWidth',2)
    end

    if exist('maex', 'var')
        pl = plot(maex,-maey,'hm');
        set(pl,'LineWidth',1.,'MarkerSize',12,...
            'MarkerFaceColor','w','MarkerEdgeColor','k')

    end

    if exist('wellx', 'var')
        hold on
        plwe = plot(wellx,-welly,'w')
        set(plwe,'LineWidth',2);
    end

catch
end

h1 = gca;
hzma = gca;

% Create a colorbar
%

h5 = colorbar('horz');
apo = get(h1,'pos');
set(h5,'Pos',[0.35 0.07 0.4 0.02],...
    'FontWeight','normal','FontSize',fontsz.s,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Position',[ 0.2 0.07 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',fontsz.s,....
    'FontWeight','normal',...
    'String',lab1);


% Make the figure visible
%
axes(h1)
set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
    'Box','on','TickDir','out','Ticklength',[0.02 0.02])
%whitebg(gcf,[0 0 0])
set(gcf,'Color',[ 1 1 1 ])
figure_w_normalized_uicontrolunits(bmapc);
watchoff(bmapc)
done
