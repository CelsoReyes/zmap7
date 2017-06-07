% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The Dvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated. This code is called from dcparain.m.
%   Stefan Wiemer 1/95

global no1 bo1 inb1 inb2 eq0p

% the new data vector to be analysed is called Da, relative to the conter of the x-section and already in km
% D = [x,y,z ]
%a(:,1) = (a(:,1)./111);
%a(:,2) = (a(:,2)./111);

Da = [eq0p(1,:)' eq0p(2,:)' a(:,3) a(:,4) a(:,5) a(:,6) a(:,7)];
Da0 = find(Da(:,7) > 0);
Da = Da(Da0,:);

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 600;
    Nmin = 500; %on line 303 it has been replaced by ni
    stan2 = nan;
    stan = nan;
    prf = nan;
    av = nan;



    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Parameters',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'units','points',...
        'Visible','on', ...
        'Position',[ 100 200 500 200]);
    axis off
    % Francesco ...


    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.32 .57 .12 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.80 .57 .12 .08],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.32 .44 .12 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.32 .31 .12 .08],...
        'Units','normalized','String',num2str(dd),...
        'Callback','dd=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dd));');

    tgl1 = uicontrol('Backgroundcolor', [0.8 0.8 0.8], 'Fontweight','bold',...
        'FontSize', 10, 'Style','checkbox',...
        'string','Number of Events:',...
        'Position',[.05 .56 .2 .10],...
         'Callback','set(tgl2,''value'',0, ''ForegroundColor'', ''w''); set(tgl1, ''ForegroundColor'', ''k'')',...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('BackGroundColor', [0.8 0.8 0.8],'Style','checkbox',...
        'string','Constant Radius:','Fontweight','bold','FontSize', 10,...
        'Position',[.55 .56 .2 .1],...
         'Callback','set(tgl1,''value'',0,''ForegroundColor'', ''w''); set(tgl2, ''ForegroundColor'', ''k'')',...
        'Units','normalized');

    set(tgl2, 'ForegroundColor', 'w');


    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.45 .05 .15 .13 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    help_button=uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .15 .13 ],...
        'Units','normalized','Callback','close;done','String','Help');


    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .13 ],...
        'Units','normalized',...
        'Callback','tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');close; org = 10; startfd; ',...
        'String','Go');


    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.35 0.9 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameters');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.07 0.46 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Horizontal Spacing [km]:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.07 0.30 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Depth spacing [km]:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.45 0.62 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'Color', 'r',...
        'String','OR');

    if term == 1 ; whitebg(gcf,[1 1 1 ]);end
    set(gcf,'visible','on');
    watchoff

end   % if sel == in

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% the seimicity and selectiong the ni neighbors
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

    welcome('Select Polygon for a grid',messtext);

    figure;
    plot(Da(:,1), -Da(:,7),'o');
    xlabel('Distance in [km]')
    ylabel('Depth in [km]')

    x = [];
    y = [];
    hold on
    but=1;
    while but==1 | but == 112
        [xi,yi,but] = ginput(1);
        mark1 =    plot(xi,yi,'ob','era','back'); % doesn't matter what erase mode is
        % used so long as its not NORMAL
        set(mark1,'MarkerSize',8,'LineWidth',1.0, 'Color', 'r')
        n = n + 1;
        % mark2 =     text(xi,yi,[' ' int2str(n)],'era','normal');
        % set(mark2,'FontSize',15,'FontWeight','bold')

        x = [x; xi];
        y = [y; yi];

    end  % while but
    welcome('Message',' Thank you .... ')

    x = [x ; x(1)];
    y = [y ; y(1)];     %  closes polygon

    plos2 = plot(x,y,'b-','era','xor', 'Color', 'r');        % plot outline
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
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','D-value grid - percent done', 'position', [250 80 270 50]);;
    drawnow
    %

    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        % Francesco: please check if the distance  l is right

        l = sqrt(((Da(:,1) - x)).^2 + ((Da(:,7) + y)).^2 + (Da(:,2).^2)) ;
        [s,is] = sort(l);
        b = Da(is(:,1),:) ;       % re-orders matrix to agree row-wise


        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            b = Da(l3,:);      % new data per grid point (b) is sorted in distanc
            rd = ra;
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l);
            rd = l2(ni);

        end


        %estimate the completeness and b-value, and take the zero depth events away.
        %newt2 = [b(:,1) b(:,2) zeros(size(b,1),1) zeros(size(b,1),1) zeros(size(b,1),1) zeros(size(b,1),1) b(:,3)];
        %
        newt2  = b;
        E = newt2;

        if length(b) >= Nmin  % enough events?

            dtokm = 0;

            if dim == 2

                pdc2nofig;

            elseif dim == 3

                pdc3nofig;

            else
                str5 = 'Not an appropriate input value';
                msg3 = msgbox(str5, 'Input Error');
                waitforbuttonpress;
                close(msg3);
                org = 1;
                startfd;

            end %if dim

            D = coef(1,1);
            fdallfig;
            %cb = colorbar('horiz');
            %set(cb, 'position', [0.3 0.05 0.4 0.05], 'XTickLabel', col);

        else
            D = nan;
        end

        bvg = [bvg ; D x y rd ];
        waitbar(allcount/itotal)

    end  % for  newgri

    % save data
    %
    %  set(txt1,'String', 'Saving data...')

    drawnow
    gx = xvect;gy = yvect;

    catSave3 =...
        [ 'welcome(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
        'sapa2=[''save '' path1 file1 '' ll a tmpgri newgri lat1 lon1 lat2 lon2 wi  bvg xvect yvect gx gy dx dd par1 newa maex maey maix maiy''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    %cb=colorbar('horiz');
    %set(cb, 'pos', [0.3 0.05 0.4 0.04], 'XTickLabel', col, 'fontsize', 9, 'title', 'D-value');

    % reshape a few matrices
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,4);
    r=reshape(normlap2,length(yvect),length(xvect));

    old = re3;

    % View the b-value map
    view_Dv

end   %  if sel = ca

% Load exist D-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        xsecx = newa(:,length(newa(1,:)))';
        xsecy = newa(:,7);
        xvect = gx; yvect = gy;
        tmpgri=zeros((length(xvect)*length(yvect)),2);

        normlap2=ones(length(tmpgri(:,1)),1)*nan;
        normlap2(ll)= bvg(:,1);
        re3=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,4);
        r=reshape(normlap2,length(yvect),length(xvect));


        old = re3;

        nlammap
        [xsecx xsecy,  inde] =mysect(a(:,2)',a(:,1)',a(:,7),wi,0,lat1,lon1,lat2,lon2);
        % Plot all grid points
        hold on
        plot(newgri(:,1),newgri(:,2),'+k','era','back')
        view_Dv
    else
        return
    end
end

