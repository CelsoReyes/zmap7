% tHis subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

global no1 bo1 inb1 inb2

% Do we have to create the dialogbox?
if sel == 'in'
    % Set the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
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
    labelList2=[' Automatic Mc (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mc (90% probability) | Automatic Mc (95% probability) | Best combination (Mc95 - Mc90 - max curvature)'];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',[ 0.2 0.77  0.6  0.08],...
        'Units','normalized',...
        'String',labelList2,...
        'BackgroundColor','w',...
        'Callback','inb2 =get(hndl2,''Value''); ');

    % Set selection to 'Best combination'
    set(hndl2,'value',5);

    % Edit fields, radiobuttons, and checkbox
    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .10],...
        'Units','normalized','String',num2str(ni),...
        'FontSize',fontsz.m ,...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');

    freq_field0=uicontrol('Style','edit',...
        'Position',[.80 .50 .12 .10],...
        'Units','normalized','String',num2str(ra),...
        'FontSize',fontsz.m ,...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .12 .10],...
        'Units','normalized','String',num2str(dx),...
        'FontSize',fontsz.m ,...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .10],...
        'Units','normalized','String',num2str(dd),...
        'FontSize',fontsz.m ,...
        'Callback','dd=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dd));');

    tgl1 = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','radiobutton',...
        'string','Number of events:',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.02 .50 .28 .10], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    % Set to constant number of events
    set(tgl1,'value',1);

    tgl2 =  uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','radiobutton',...
        'string','Constant radius [km]:',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.52 .50 .28 .10], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');

    chkRandom = uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','checkbox',...
        'String', 'Additional random simulation',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.52 .35 .38 .10],...
        'Units','normalized');
    txtRandomRuns = uicontrol('Style','edit',...
        'Position',[.80 .25 .12 .10],...
        'Units','normalized','String',num2str(nRandomRuns),...
        'FontSize',fontsz.m ,...
        'Callback','nRandomRuns=str2double(get(txtRandomRuns,''String'')); set(txtRandomRuns,''String'',num2str(nRandomRuns));');

    freq_field4 =  uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .10],...
        'Units','normalized','String',num2str(Nmin),...
        'FontSize',fontsz.m ,...
        'Callback','Nmin=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(Nmin));');

    chkGridEntireArea = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','checkbox',...
        'string','Create grid over entire area',...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.02 .06 .38 .10], 'Units','normalized', 'Value', 0);

    % Buttons
    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized', 'Position', [.80 .05 .15 .12], ...
        'Callback', 'close;done', 'String', 'Cancel');

    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized', 'Position', [.60 .05 .15 .12], ...
        'Callback', 'inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');bRandom = get(chkRandom, ''Value''); bGridEntireArea = get(chkGridEntireArea, ''Value'');close,sel =''ca'', rand_b_diff_cross',...
        'String', 'OK');

    % Labels
    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [0.2 1 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
        'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Please select a Mc estimation option');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [0.3 0.7 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
        'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Grid parameters');

    text('Color',[0 0 0], 'EraseMode','normal', 'Units', 'normalized', ...
        'Position', [-.14 .42 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String','Horizontal spacing [km]:');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [-0.14 0.30 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String', 'Depth spacing [km]:');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [-0.14 0.18 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
        'FontSize',fontsz.m, 'FontWeight', 'bold', 'String', 'Min. number of events:');

    text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
        'Position', [0.5 0.24 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
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
        x = [x ; x(1)];
        y = [y ; y(1)];     %  closes polygon
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
        zmap_message_center.set_message('Select Polygon for a grid',messtext);
        hold on
        ax = findobj('Tag','main_map_ax');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        zmap_message_center.set_info('Message',' Thank you .... ')
    end; % of if bGridEntireArea


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

    ll = polygon_filter(x,y, XI, YI, 'inside');
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


    zmap_message_center.set_info(' ','Running... ');think
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
    bvg = NaN(length(newgri),14);
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % loop

    mValues = [];
    fMc = calc_Mc(newa, 5);
    vSel = newa(:,6) >= fMc;
    fBValue = bmemag(newa(vSel,:));
    mTmpCatalog = newa;

    for nCnt = 1:nRandomRuns
        newa = syn_create_magnitudes(mTmpCatalog, fBValue, fMc, 0.1);
        allcount = 0.;


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
                b = newa.subset(l3);      % new data per grid point (b) is sorted in distanc
                rd = ra;
            else
                % take first ni points
                b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                rd = s(ni);

            end


            %estimate the completeness and b-value
            newt2 = b;
            if length(b) >= Nmin  % enough events?

                if inb1 == 3
                    mcperc_ca3;  l = b(:,6) >= Mc90-0.05; magco = Mc90;
                    if length(b(l,:)) >= Nmin
                        [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                        [mea bv2 stan2 av2 ] =  bmemag(b(l,:));
                    else
                        bv = NaN; bv2 = NaN; magco = NaN; av = NaN; av2 = NaN;
                    end

                elseif inb1 == 4
                    mcperc_ca3;  l = b(:,6) >= Mc95-0.05; magco = Mc95;
                    if length(b(l,:)) >= Nmin
                        [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                        [mea bv2 stan2 av2 ] =  bmemag(b(l,:));
                    else
                        bv = NaN; bv2 = NaN; magco = NaN; av = NaN; av2 = NaN;
                    end
                elseif inb1 == 5
                    mcperc_ca3;
                    if isnan(Mc95) == 0 
                        magco = Mc95;
                    elseif isnan(Mc90) == 0 
                        magco = Mc90;
                    else
                        [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                    end
                    l = b(:,6) >= magco-0.05;
                    if length(b(l,:)) >= Nmin
                        [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                        [mea bv2 stan2,  av2] =  bmemag(b(l,:));
                    else
                        bv = NaN; bv2 = NaN; magco = NaN; av = NaN; av2 = NaN;
                    end

                elseif inb1 == 1
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                    l = b(:,6) >= magco-0.05;
                    if length(b(l,:)) >= Nmin
                        [mea bv2 stan2,  av2] =  bmemag(b(l,:));
                    else
                        bv = NaN; bv2 = NaN; magco = NaN; av = NaN; av2 = NaN;
                    end

                elseif inb1 == 2
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,2,2);
                    [mea bv2 stan2,  av2] =  bmemag(b);
                end
                dP = NaN;

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
                bv = NaN; bv2 = NaN; stan = NaN; stan2 = NaN; dP = NaN; magco = NaN; av = NaN; av2 = NaN; fStdDevB = NaN; fStdDevMc = NaN; b = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
            end
            mab = max(b(:,6)) ; if isempty(mab)  == 1; mab = NaN; end

            bvg(allcount,:)  = [bv magco x y rd bv2 stan2 av stan dP  mab av2 fStdDevB fStdDevMc];
        end  % for  newgri

        fMax = max(bvg(:,6));
        fMin = min(bvg(:,6));
        fDiff = fMax-fMin;

        mValues = [mValues; fDiff fMax fMin];
        waitbar(nCnt/nRandomRuns)
    end
    if bRandom
        clear nNumberPerNode, q1, q2, fStdDevB, fStdDevMc;
    end
    clear bRandom;
    % save data
    %
    drawnow
    gx = xvect;gy = yvect;

    catSave3 =...
        [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile([ ''*.mat''], ''Grid Datafile Name?'') ;',...
        'sapa2=[''save '' path1 file1 '' mValues ''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    figure
    histogram(mValues(:,1));
end   %  if sel = ca

