% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactively. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

global no1 bo1 inb1 inb2

report_this_filefun(mfilename('fullpath'));

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    ra=10;
    ri=5;
    dx = 1.00;
    dy = 1.00 ;
    ni = 100;
    fFixbValue = 0.9;
    Nmin = 50;
    stan2 = nan;
    stan = nan;
    prf = nan;
    av = nan;

    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 850 250]);
    axis off
    labelList2=[' a(0) for fixed Mc(b(0),Mc(0)) | a(0) for Mc(MaxCurv) + M(corr) | a(0) for M(EMR) | a(0) by r1 & Mc by r2 '];
    labelPos = [0.2 0.8  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',1);


    % creates a dialog box to input grid parameters
    %

    oldfig_button = uicontrol('BackGroundColor',[.60 .92 .84], ...
        'Style','checkbox','string','Plot in Current Figure',...
        'Position',[.78 .52 .20 .08],...
        'Units','normalized');

    set(oldfig_button,'value',1);


    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .60 .12 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.30 .50 .06 .08],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field1=uicontrol('Style','edit',...
        'Position',[.36 .50 .06 .08],...
        'Units','normalized','String',num2str(ri),...
        'Callback','ri=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(ri)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .06 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.36 .40 .06 .080],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    % Read input parameter (fixed b(0))
    freq_field4=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .080],...
        'Units','normalized','String',num2str(fFixbValue),...
        'Callback','fFixbValue=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(fFixbValue));');

    tgl1 = uicontrol('Style','radiobutton',...
        'string','Number of Events:',...
        'Position',[.05 .60 .2 .0800], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('Style','radiobutton',...
        'string','OR: Constant Radius',...
        'Position',[.05 .50 .2 .080], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');

    create_grid =  uicontrol('Style','radiobutton',...
        'string','Calculate a new grid', 'Callback','set(load_grid,''value'',0), set(prev_grid,''value'',0)','Position',[.55 .55 .2 .080],...
        'Units','normalized');

    set(create_grid,'value',1);

    prev_grid =  uicontrol('Style','radiobutton',...
        'string','Reuse the previous grid', 'Callback','set(load_grid,''value'',0),set(create_grid,''value'',0)','Position',[.55 .45 .2 .080],...
        'Units','normalized');


    load_grid =  uicontrol('Style','radiobutton',...
        'string','Load a previously saved grid', 'Callback','set(prev_grid,''value'',0),set(create_grid,''value'',0)','Position',[.55 .35 .2 .080],...
        'Units','normalized');

    save_grid =  uicontrol('Style','checkbox',...
        'string','Save selected grid to file',...
        'Position',[.55 .22 .2 .080],...
        'Units','normalized');

    freq_field4 = uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .080],...
        'Units','normalized','String',num2str(Nmin),...
        'Callback','Nmin=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(Nmin));');


    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback',' inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');prev_grid = get(prev_grid,''Value'');create_grid = get(create_grid,''Value''); load_grid = get(load_grid,''Value''); save_grid = get(save_grid,''Value''); oldfig_button = get(oldfig_button,''Value''); close,sel =''ca'', calc_avalgrid',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.10 0.98 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose an Mc estimation option   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.75 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) / y (dy) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.3 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Fixed b-value:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.18 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. No. of events > Mc:');

    % New field for input parameter of .....


    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    % get new grid if needed
    if load_grid == 1
        [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
        if length(path1) > 1
            think
            load([path1 file1])
            plot(newgri(:,1),newgri(:,2),'k+')
        end
    elseif load_grid ==0  &&  prev_grid == 0
        selgp
        if length(gx) < 4  ||  length(gy) < 4
            errordlg('Selection too small! (Dx and Dy are in degreees!) ');
            return
        end
    end

    if save_grid == 1
        grid_save =...
            [ 'zmap_message_center.set_info(''Saving Grid'',''  '');think;',...
            '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir,''*.mat''), ''Grid File Name?'') ;',...
            ' gs = [''save '' path1 file1 '' newgri dx dy gx gy xvect yvect tmpgri ll''];',...
            ' if length(file1) > 1, eval(gs),end , done']; eval(grid_save)
    end


    itotal = length(newgri(:,1));

    % Specify Mc manually
    %     if inb1 == 7
    %         dlg1_prompt={'Enter Mc:'};
    %         dlg1_def={'3.0'};
    %         dlg1_Title='Please input the completeness value';
    %         dlg1_line=1;
    %         dlg1_answer= (inputdlg(dlg1_prompt,dlg1_Title,dlg1_line,dlg1_def));
    %         fMc_spec = str2double(dlg1_answer{1});
    %     end

    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(ZG.a.Date)  ;
    n = ZG.a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    avg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow


    % loop over all points
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2);
        [s,is] = sort(l);
        b = a(is(:,1),:);       % re-orders matrix to agree row-wise

        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            l4 = l <= ri;
            b = ZG.a.subset(l3);        % new data per grid point (b) is sorted in distance
            bri = ZG.a.subset(l4);      % new data per grid point (b) is sorted in distance for calculation ofa-value
            rd = ra;
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);
        end


        %estimate the completeness and b-value
        ZG.newt2 = b;


        if length(b) >= Nmin  % enough events?

            if inb1 == 1;   % Calculation ofa-value by const b-value, and Mc
                bv2 = fFixbValue;           % read fixed bValue to the bv2
                magco=calc_Mc(b, 1, 0.1);
                l = b.Magnitude >= magco-0.05;
                if length(b(l,:)) >= Nmin   % calculation of thea-value according to determined Mc (magco)
                    faValue = calc_MaxLikelihoodA(b, bv2);
                    mea = nan;
                    stan2 = nan;
                    bv = nan;
                else
                    bv = nan; bv2 = nan; magco = nan; av = nan; faValue = nan; stan2 = nan; stan = nan;
                end

                % a(0) for Mc(MAxCurv) + Mc(Corr)
            elseif inb1 == 2
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                magco = magco + 0.2;    % Add 0.2 to Mc (Tobias)
                l = b.Magnitude >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [mea bv2 stan2,  faValue] =  bmemag(b(l,:));
                else
                    bv = nan; bv2 = nan, magco = nan; av = nan; faValue = nan;
                end

            elseif inb1 == 3; % a(0) for Mc(EMR)
                [magco, bv2, faValue, stan2, stan] = calc_McEMR(b, 0.1);
                l = b.Magnitude >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    faValue = calc_MaxLikelihoodA(b, bv2);
                else
                    bv = nan; bv2 = nan, magco = nan; av = nan; faValue = nan;
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
                    bv = nan; bv2 = nan, magco = nan; av = nan; faValue = nan;
                end
            end
        else
            bv = nan; bv2 = nan; magco = nan; av = nan; faValue = nan;
        end

        if tgl1 == 0   % take point within r
            rd = b.Count;
        end

        avg(allcount,:)  = [bv magco x y rd bv2 stan2 av stan faValue ];
        waitbar(allcount/itotal)

    end  % for newgr
    %save cnssgrid.mat
    %quit
    % save data
    %
    catSave3 =...
        [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Grid Datafile Name?'') ;',...
        ' sapa2 = [''save '' path1 file1 '' avg gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll ''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix
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

    kll = ll;

    re3 = aValueMap;
    % old = re3;

    % View the b-value map
    view_aValue

end   % if sel = na

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        % plot the results
        % old and re3 (initially ) is the b-value matrix
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
        %         old = re3;

        view_aValue

    else
        return
    end
end
