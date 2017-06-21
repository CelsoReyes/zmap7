% tHis subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

global no1 bo1 inb1 inb2

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
    Nmin = 10;
    stan2 = NaN;
    stan = NaN;
    prf = NaN;
    av = NaN;



    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'units','points',...
        'Visible','on', ...
        'Position',[ wex+200 wey-200 550 300]);
    axis off

    labelList2=[' Michaels method | sorry, no other option'];
    labelPos = [0.2 0.77  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Units','normalized','Position',labelPos,...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',1);


    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .50 .12 .10],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Units','normalized','Position',[.70 .50 .12 .10],...
        'String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .40 .12 .10],...
        'String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .30 .12 .10],...
        'String',num2str(dd),...
        'Callback','dd=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dd));');

    tgl1 = uicontrol('Style','checkbox',...
        'string','Number of Events:',...
        'Units','normalized','Position',[.05 .50 .2 .10], 'Callback','set(tgl2,''value'',0)');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('Style','checkbox',...
        'string','OR: Constant Radius',...
        'Units','normalized','Position',[.47 .50 .2 .10], 'Callback','set(tgl1,''value'',0)');



    close_button=uicontrol('Style','Pushbutton',...
        'Units','normalized','Position',[.50 .05 .15 .12 ],...
        'Callback','close;done','String','Cancel');


    go_button1=uicontrol('Style','Pushbutton',...
        'Units','normalized','Position',[.20 .05 .15 .12 ],...
        'Callback','inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');close,sel =''ca'', bcross_stress',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 1.0 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose and Mc estimation option ');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.67 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Horizontal Spacing [km]');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Depth spacing [km]:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.2 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m,...
        'FontWeight','bold',...
        'String','Min No. of events:');

    if term == 1 ; whitebg(gcf,[1 1 1 ]);end
    set(gcf,'visible','on');
    watchoff

end   % if sel == in

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'

    figure_w_normalized_uicontrolunits(xsec_fig)
    hold on

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

    plos2 = plot(x,y,'b-');        % plot outline
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
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % loop

    % create bvg
    bvg = NaN(length(newgri),9);

    %
    hodis = fullfile(hodi, 'external');
    do = ['cd  ' hodis ]; eval(do)


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

            tmpi = [newt2(:,10:12)];

            fid = fopen('data2','w');
            str = ['Inversion data'];str = str';

            fprintf(fid,'%s  \n',str');
            fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');

            fclose(fid);

            delete data2.slboot Xtemp.slboot

            try
                unix(' slfast data2 ');
                load data2.slboot
                d0 = data2;
            catch
                d0 = [NaN NaN NaN NaN NaN NaN NaN NaN  ; NaN NaN NaN NaN NaN NaN NaN NaN ];
            end

            [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
            l = b(:,6) >= magco-0.05;
            if length(b(l,:)) >= Nmin
                [mea bv2 stan2,  av2] =  bmemag(b(l,:));
            else
                bv = NaN; bv2 = NaN, magco = NaN; av = NaN; av2 = NaN;
            end

            bvg(allcount,:) = [d0(2,2:7) d0(1,1) rd bv2];


        end % if Nmin
        waitbar(allcount/itotal)

    end  % for  newgri

    % save data
    %
    %  set(txt1,'String', 'Saving data...')
    drawnow
    gx = xvect;gy = yvect;


    close(wai)
    watchoff
    normlap2=NaN(length(tmpgri(:,1)),1);

    normlap2(ll)= bvg(:,8);
    rama=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,7);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,9);
    bmp=reshape(normlap2,length(yvect),length(xvect));
    re3 = r;old1 = re3;
    view_xstress


end

