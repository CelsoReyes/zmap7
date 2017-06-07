% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactively.
% The aValue, Mc and a resolution estimation in each
% volume around a grid point, or defined by a radius
% (ra for Mc, ri for aValue) containing ni earthquakes
% will be calculated
%
%   This subroutine provides 4 methods for calculation:
% 1. calculatea-value for const b-value
% 2. calculatea-value by maxlikelihood (MaxLikelihoodA.m)
%    of b-value and Mc defined by MaxC
% 3. calculatea-value by maxlikelihood (MaxLikelihoodA.m)
%    of b-value and Mc defined by Mc(EMR)
% 4. calculatea-value within the radius ri and Mc within ra, where ra > ri
%
%   This subrouting is based on bcross.m
%       by Stefan Wiemer 1/95
%   and was modified
%       by Thomas van Stiphout 3/2004

report_this_filefun(mfilename('fullpath'));

global no1 bo1 inb1 inb2

% Do we have to create the dialogbox?
if sel == 'in'
    % Set the grid parameter
    % initial values
    %
    ra=10;
    ri=5;
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
    fFixbValue=0.9
    bv2 = NaN;
    Nmin = 50;
    stan2 = NaN;
    stan = NaN;
    prf = NaN;
    av = NaN;
    nRandomRuns = 1000;
    bGridEntireArea = 0;

    % Create the dialog box
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'units','points',...
        'Visible','on', ...
        'Position',[ wex+200 wey-200 550 300], ...
        'Color', [0.8 0.8 0.8]);
    axis off

    % Dropdown list
    labelList2=[' a(M=0) for fixed b | a(M=0) for Mc(MaxC) + M(corr) | a(M=0) for M(EMR) | a(M=0) by r1 & Mc by r2 '];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',[ 0.2 0.77  0.6  0.08],...
        'Units','normalized',...
        'String',labelList2,...
        'BackgroundColor','w',...
        'Callback','inb2 =get(hndl2,''Value''); ');

    % Set selection to 'Radius check'
    set(hndl2,'value',1);

    % Edit fields, radiobuttons, and checkbox
    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .60 .12 .06],...
        'Units','normalized','String',num2str(ni),...
        'FontSize',fontsz.m ,...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');

    freq_field0=uicontrol('Style','edit',...
        'Position',[.30 .50 .06 .06],...
        'Units','normalized','String',num2str(ra),...
        'FontSize',fontsz.m ,...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field1=uicontrol('Style','edit',...
        'Position',[.36 .50 .06 .06],...
        'Units','normalized','String',num2str(ri),...
        'FontSize',fontsz.m ,...
        'Callback','ri=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(ri)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .06 .06],...
        'Units','normalized','String',num2str(dx),...
        'FontSize',fontsz.m ,...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.36 .40 .06 .06],...
        'Units','normalized','String',num2str(dd),...
        'FontSize',fontsz.m ,...
        'Callback','dd=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dd));');

    tgl1 = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','radiobutton',...
        'string','Number of events:',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.02 .60 .28 .06], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    % Set to constant number of events
    set(tgl1,'value',1);

    tgl2 =  uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','radiobutton',...
        'string','Constant radius [km]:',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.52 .60 .40 .06], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');

    chkRandom = uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','checkbox',...
        'String', 'Additional random simulation',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.52 .40 .40 .06],...
        'Units','normalized');
    txtRandomRuns = uicontrol('Style','edit',...
        'Position',[.80 .30 .12 .06],...
        'Units','normalized','String',num2str(nRandomRuns),...
        'FontSize',fontsz.m ,...
        'Callback','nRandomRuns=str2double(get(txtRandomRuns,''String'')); set(txtRandomRuns,''String'',num2str(nRandomRuns));');

    freq_field4 =  uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .06],...
        'Units','normalized','String',num2str(Nmin),...
        'FontSize',fontsz.m ,...
        'Callback','Nmin=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(Nmin));');

    freq_field5 =  uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .06],...
        'Units','normalized','String',num2str(fFixbValue),...
        'FontSize',fontsz.m ,...
        'Callback','fFixbValue=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(fFixbValue)));');

    chkGridEntireArea = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','checkbox',...
        'string','Create grid over entire area',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.52 .50 .40 .06], 'Units','normalized', 'Value', 0);

    % Buttons
    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized', 'Position', [.80 .05 .15 .10], ...
        'Callback', 'close;done', 'String', 'Cancel');

    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized', 'Position', [.60 .05 .15 .10], ...
        'Callback', 'inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');bRandom = get(chkRandom, ''Value''); bGridEntireArea = get(chkGridEntireArea, ''Value'');close,sel =''ca'', calc_across',...
        'String', 'OK');

    % Labels
    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [0.2 1 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
        'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Please select a Mc estimation option');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [0.3 0.75 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
        'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Grid parameters');

    text('Color',[0 0 0], 'EraseMode','normal', 'Units', 'normalized', ...
        'Position', [-.14 .51 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String','Radius ra / ri [km]:');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [-0.14 .39 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String', 'Spacing hor / depth [km]:');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [-0.14 .27 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String', 'Min. number of events:');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [-0.14 .15 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String', 'Fixed b-value:');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [0.5 0.27 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String', 'Number of runs:');

    if term == 1 ; whitebg(gcf,[1 1 1 ]);end
    set(gcf,'visible','on');
    watchoff
end   % if sel == in

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% the seimicity and selecting the ni neighbors
% to each grid point

if sel == 'ca'

    figure_w_normalized_uicontrolunits(xsec_fig)
    hold on

    if bGridEntireArea % Use entire area for grid
        vXLim = get(gca, 'XLim');
        vYLim = get(gca, 'YLim');
        x = [vXLim(1); vXLim(1); vXLim(2); vXLim(2)];
        y = [vYLim(2); vYLim(1); vYLim(1); vYLim(2)];
        clear vXLim vYLim;
    else
        messtext=...
            ['To select a polygon for a grid.       '
            'Please use the LEFT mouse button of   '
            'or the cursor to the select the poly- '
            'gon. Use the RIGTH mouse button for   '
            'the final point.                      '
            'Mac Users: Use the keyboard "p" more  '
            'point to select, "l" last point.      '
            '                                      '];
        welcome('Select Polygon for a grid',messtext);

        x = [];
        y = [];
        hold on
        but=1;
        while but==1 | but == 112
            [xi,yi,but] = ginput(1);
            mark1 =    plot(xi,yi,'+b','era','back'); % doesn't matter what erase mode is
            % used so long as its not NORMAL
            set(mark1,'MarkerSize',8,'LineWidth',1.0)
            n = n + 1;
            % mark2 =     text(xi,yi,[' ' int2str(n)],'era','normal');
            % set(mark2,'FontSize',15,'FontWeight','bold')

            x = [x; xi];
            y = [y; yi];

        end  % while but
        welcome('Message',' Thank you .... ')
    end % of if bGridEntireArea

    x = [x ; x(1)];
    y = [y ; y(1)];     %  closes polygon

    plos2 = plot(x,y,'b-','era','xor');        % plot outline
    sum3 = 0.;
    pause(0.3)

    %create a rectangular grid
    xvect=[min(x):dx:max(x)];
    yvect=[min(y):dd:max(y)];
    gx = xvect;gy = yvect;
    tmpgri=zeros((length(xvect)*length(yvect)),2);
    n=0;
    for i=1:length(xvect)
        for j=1:length(yvect)
            n=n+1;
            tmpgri(n,:)=[xvect(i) yvect(j)];
        end
    end
    %extract all gridpoints in chosen polygon
    XI=tmpgri(:,1);
    YI=tmpgri(:,2);

    m = length(x)-1;      %  number of coordinates of polygon
    l = 1:length(XI);
    l = (l*0)';
    ll = l;               %  Algorithm to select points inside a closed
    %  polygon based on Analytic Geometry    R.Z. 4/94
    for i = 1:m

        l= ((y(i)-YI < 0) & (y(i+1)-YI >= 0)) & ...
            (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0) | ...
            ((y(i)-YI >= 0) & (y(i+1)-YI < 0)) & ...
            (XI-x(i)-(YI-y(i))*(x(i+1)-x(i))/(y(i+1)-y(i)) < 0);

        if i ~= 1
            ll(l) = 1 - ll(l);
        else
            ll = l;
        end         % if i

    end         %
    %grid points in polygon
    newgri=tmpgri(ll,:);


    % Plot all grid points
    plot(newgri(:,1),newgri(:,2),'+k','era','back')

    if length(xvect) < 2  ||  length(yvect) < 2
        errordlg('Selection too small! (not a matrix)');
        return
    end

    itotal = length(newgri(:,1));
    if length(gx) < 4  ||  length(gy) < 4
        errordlg('Selection too small! ');
        return
    end


    welcome(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = newa(1,3)  ;
    n = length(newa(:,1));
    teb = newa(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3,length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    avg = zeros(length(newgri),10)*nan;
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','a-value grid - percent done');;
    drawnow
    %
    % loop


    % overall b-value
    [bv magco stan av me mer me2,  pr] =  bvalca3(newa,inb1,inb2);
    bo1 = bv; no1 = length(newa(:,1));
    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
        [s,is] = sort(l);
        b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise


        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            l4 = l <= ri;
            b = a(l3,:);        % new data per grid point (b) is sorted in distance
            bri = a(l4,:);
            rd = ra;
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            rd = s(ni);

        end

        % Number of earthquakes per node
        [nX,nY] = size(b);

        %estimate the completeness and b-value
        newt2 = b;

        if length(b) >= Nmin  % enough events?

            if inb1 == 1;   % Calculation ofa-value by const b-value, and Mc
                bv2 = fFixbValue;           % read fixed bValue to the bv2
                magco=calc_Mc(b, 1, 0.1);
                l = b(:,6) >= magco-0.05;
                if length(b(l,:)) >= Nmin   % calculation of thea-value according to determined Mc (magco)
                    faValue = calc_MaxLikelihoodA(b, bv2);
                    mea = NaN;
                    stan2 = NaN;
                    bv = NaN;
                else
                    bv = NaN; bv2 = NaN; magco = NaN; av = NaN; faValue = NaN; stan2 = NaN; stan = NaN;
                end

                % a(0) for Mc(MAxCurv) + Mc(Corr)
            elseif inb1 == 2
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                magco = magco + 0.2;    % Add 0.2 to Mc (Tobias)
                l = b(:,6) >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [mea bv2 stan2,  faValue] =  bmemag(b(l,:));
                else
                    bv = NaN; bv2 = NaN, magco = NaN; av = NaN; faValue = NaN;
                end

            elseif inb1 == 3; % a(0) for Mc(EMR)
                [magco, bv2, faValue, stan2, stan] = calc_McEMR(b, 0.1);
                l = b(:,6) >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    faValue = calc_MaxLikelihoodA(b, bv2);
                else
                    bv = NaN; bv2 = NaN, magco = NaN; av = NaN; faValue = NaN;
                end

            elseif inb1 == 4
                % a(0) by r1 and Mc by r2
                if length(b) >= Nmin
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                    magco = magco + 0.2;    % Add 0.2 to Mc (Tobias)
                    bv2 = fFixbValue;
                    l = bri(:,6) >= magco-0.05;
                    faValue = calc_MaxLikelihoodA(bri(l,:), bv2);
                else
                    bv = NaN; bv2 = NaN, magco = NaN; av = NaN; faValue = NaN;
                end
            end


            % Perform random simulation
            if bRandom
                nNumberPerNode = length(b);
                %        [fAverageBValue, fAverageStdDev] = calc_RandomBValue(newa, nNumberPerNode, nRandomRuns);
                [fStdDevB, fStdDevMc, q1, q2] = calc_BootstrapB(b, nRandomRuns, Nmin);
            else
                fStdDevB = NaN;
                fStdDevMc = NaN;
            end

        else % of if length(b) >= Nmin
            bv = NaN; bv2 = NaN; stan = NaN; stan2 = NaN; prf = NaN; magco = NaN; av = NaN; faValue = NaN; fStdDevB = NaN; fStdDevMc = NaN;
            b = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
            nX = NaN;
        end
        mab = max(b(:,6)) ; if isempty(mab)  == 1; mab = NaN; end
        avg(allcount,:)  = [bv magco x y rd bv2 stan2 av stan faValue ];
        waitbar(allcount/itotal)
    end  % for  newgri

    if bRandom
        clear nNumberPerNode q1 q2 fStdDevB fStdDevMc;
    end
    clear bRandom;
    % save data
    %
    drawnow
    gx = xvect;gy = yvect;

    catSave3 =...
        [ 'welcome(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile([ ''*.mat''], ''Grid Datafile Name?'') ;',...
        'sapa2=[''save '' path1 file1 '' ll a tmpgri newgri lat1 lon1 lat2 lon2 wi  avg xvect yvect gx gy dx dd par1 newa maex maey maix maiy ''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    save across2.mat ll a tmpgri newgri lat1 lon1 lat2 lon2 wi  avg ra xvect yvect gx gy dx dd par1 newa ;


    % reshape a few matrices
    %

    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= avg(:,1);
    bls=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= avg(:,5);
    reso=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= avg(:,6);
    bValueMap=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= avg(:,2);
    MaxCMap=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= avg(:,7);
    MuMap=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= avg(:,8);
    avm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= avg(:,9);
    SigmaMap=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= avg(:,10);
    aValueMap=reshape(normlap2,length(yvect),length(xvect));


    re3 = aValueMap;
    kll = ll;
    % View thea-value map
    view_av2

end   %  if sel = ca

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'a-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        xsecx = newa(:,length(newa(1,:)))';
        xsecy = newa(:,7);
        xvect = gx; yvect = gy;
        tmpgri=zeros((length(xvect)*length(yvect)),2);

        normlap2=ones(length(tmpgri(:,1)),1)*nan;
        normlap2(ll)= avg(:,1);
        bls=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= avg(:,5);
        reso=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= avg(:,6);
        bValueMap=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= avg(:,2);
        MaxCMap=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= avg(:,7);
        MuMap=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= avg(:,8);
        avm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= avg(:,9);
        SigmaMap=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= avg(:,10);
        aValueMap=reshape(normlap2,length(yvect),length(xvect));


        re3 = aValueMap;

        nlammap
        [xsecx xsecy,  inde] =mysect(a(:,2)',a(:,1)',a(:,7),wi,0,lat1,lon1,lat2,lon2);
        % Plot all grid points
        hold on
        plot(newgri(:,1),newgri(:,2),'+k','era','back')
        view_av2
    else
        return
    end
end

