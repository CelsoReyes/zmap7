% Script: stressgrid.m
%
% Script to create a grid (interactively), calculate stress tensor using
% Michaels or Gephards code
%
% Incoming data:
% Columns 10-12 of newa must be
% 10: dip direction (East of North
% 11: dip
% 12: rake (Kanamori convention)
%
% Output:
% Matrix: bvg
% original: Stefan Wiemer 1/95
%
% last update: J. Woessner, 15.02.2005

report_this_filefun(mfilename('fullpath'));

global no1 bo1 inb1 inb2
fs=filesep;
ZG=ZmapGlobal.Data;
if sel == 'in'
    % get the grid parameter
    % initial values
    %

    if size(a(1,:)) < 12
        errordlg('You need 12 columns of input data (i.e., fault plane solutions) to calculate a stress tensor!');
        return
    end

    dx = 0.1;
    dy = 0.1 ;
    ni = 50;
    Nmin = 0;
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
        'Visible','on', ...
        'Position',[ 100 100 650 250]);
    axis off
    labelList2=[' Michaels Method | sorry, no other options'];
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


    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .60 .12 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .08],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .12 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .080],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

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
        'Callback',' inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');prev_grid = get(prev_grid,''Value'');create_grid = get(create_grid,''Value''); load_grid = get(load_grid,''Value''); save_grid = get(save_grid,''Value'');  close,sel =''ca'', stressgrid',...
        'String','Go');

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
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.3 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.18 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. no. of evts. (const R):');




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
            errordlg('Selection too small! (Dx and Dy are in degreees! ');
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

    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(a.Date)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','stress map grid - percent done');;
    drawnow
    %
    % create bvg
    bvg = zeros(length(newgri),9)*nan;


    hodis = fullfile(ZG.hodi, 'external');
    cd(hodis);

    % loop over all points
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            b = a.subset(l3);      % new data per grid point (b) is sorted in distance
            rd = ra;
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);

        end


        %estimate the completeness and b-value
        newt2 = b;
        if length(b) >= Nmin  % enough events?
            % Take the focal mechanism from actual catalog
            % tmpi-input: [dip direction (East of North), dip , rake (Kanamori)]
            tmpi = [newt2(:,10:12)];

            % Create file for inversion
            fid = fopen('data2','w');
            str = ['Inversion data'];str = str';
            fprintf(fid,'%s  \n',str');
            fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');
            fclose(fid);

            % slick calculates the best solution for the stress tensor according to
            % Michael(1987): creates data2.oput
            switch computer
                case 'GLNX86'
                    unix(['".' fs 'slick_linux" data2 ']);
                case 'MAC'
                    unix(['".' fs 'slick_macppc" data2 ']);
                case 'MACI'
                    unix(['".' fs 'slick_maci" data2 ']);
                case 'MACI64'
                    unix(['".' fs 'slick_maci64" data2 ']);
                otherwise
                    dos(['".' fs 'slick.exe" data2 ']);
            end
            %unix([ZG.hodi fs 'external/slick data2 ']);
            % Get data from data2.oput
            sFilename = ['data2.oput'];
            [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename);

            % Delete existing data2.slboot

            sData2 = fullfile(ZG.hodi, 'external', 'data2.slboot');

            delete(sData2);

            % Stress tensor inversion
            switch computer
                case 'GLNX86'
                    unix(['"' ZG.hodi fs 'external/slfast_linux" data2 ']);
                case 'MAC'
                    unix(['"' ZG.hodi fs 'external/slfast_macpcc" data2 ']);
                case 'MACI'
                    unix(['"' ZG.hodi fs 'external/slfast_maci" data2 ']);
                case 'MACI64'
                    unix(['"' ZG.hodi fs 'external/slfast_maci64" data2 ']);
                otherwise
                    dos(['"' ZG.hodi fs 'external' fs 'slfast.exe" data2 ']);
            end
            %unix([ZG.hodi fs 'external/slfast data2 ']);
            sGetFile = fullfile(ZG.hodi, 'external', 'data2.slboot');
            load(sGetFile); % Creates variable data2 in workspace
            % Description of data2
            % Line 1: Variance S11 S12 S13 S22 S23 S33 => Variance and components of
            % stress tensor (S = sigma)
            % Line 2: Phi S1t S1p S2t S2p S3t S3p
            % Phi is relative size S3/S1, t=trend, p=plunge (other description)
            d0 = data2;

            bv2 = nan;
            % Result matrix
            % S1Trend S1Plunge S2Trend S2Plunge S3Trend S3Plunge Variance Radius b-value
            bvg(allcount,:) = [d0(2,2:7) d0(1,1) rd bv2];
        end % if Nmin
        waitbar(allcount/itotal)
    end  % for newgr
    close(wai)
    watchoff
    view_stressmap
end
