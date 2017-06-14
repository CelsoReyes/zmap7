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
    ra = 5;

    % get the time periods of interest

    t1 = t0b;
    t4 = teb;
    t2 = t0b + (teb-t0b)/2;
    t3 = t2+0.01;


    def = {num2str(t1),num2str(t2),num2str(t3),num2str(t4),num2str(100)}
    tit ='differntial b-value map ';
    prompt={'T1 = ', 'T2= ', 'T3 = ', 'T4= ','Nmin'};

    ni2 = inputdlg(prompt,tit,1,def);
    l = ni2{5};
    Nmin = str2double(l);
    l = ni2{4};
    t4 = str2double(l);
    l = ni2{3};
    t3 = str2double(l);
    l = ni2{2};
    t2 = str2double(l);
    l = ni2{1};
    t1 = str2double(l);


    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 550 300]);
    axis off

    labelList2=['Weighted LS - automatic Mcomp | Weighted LS - no automatic Mcomp '];
    labelPos = [0.2 0.7  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');



    labelList=['Maximum likelihood - automatic Mcomp | Maximum likelihood  - no automatic Mcomp '];
    labelPos = [0.2 0.8  0.6  0.08];
    hndl1=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList,...
        'Callback','inb1 =get(hndl1,''Value''); ');

    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ra));');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dd),...
        'Callback','dd=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dd));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','inb1 =get(hndl1,''Value'');inb2 =get(hndl2,''Value'');close,sel =''ca'', bcrossVt2',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 1.0 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String','Automatically estimate magn. of completeness?   ');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.65 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing along projection [km]');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in depth in km:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.53 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m,...
        'FontWeight','bold',...
        'String','Radius in km');
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

    welcome('Select Polygon for a grid',messtext);

    hold on
ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);
    welcome('Message',' Thank you .... ')

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
    plot(newgri(:,1),newgri(:,2),'+k')

    if length(xvect) < 2  ||  length(yvect) < 2
        errordlg('Selection too small! (not a matrix)');
        return
    end

    itotal = length(newgri(:,1));

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
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % loop

    % set mainshock magnitude to  minmag
    % f = find(newa(:,6) == max(newa(:,6)))
    % newa(f,6) = min(newa(:,6));


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
        %[s,is] = sort(l);
        %b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % take first ni points
        l = l <= ra;
        b = newa(l,:);      % new data per grid point (b) is sorted in distance

        if isempty(b) == 1; b = newa(1,:); end
        if length(b(:,1)) >= Nmin;
            % call the b-value function
            lt =  b(:,3) >= t1 &  b(:,3) <t2 ;
            if  length(b(lt,1)) > Nmin/2;
                [bv magco stan av me mer me2,  pr] =  bvalca3(b(lt,:),inb1,inb2);
                bo1 = bv; no1 = length(newa(:,1));
            else
                bv = NaN; pr = 50;
            end
            lt = b(:,3) >= t3 &  b(:,3) < t4 ;
            if  length(b(lt,1)) > Nmin/2;
                [bv2 magco stan av me mer me2,  pr] =  bvalca3(b(lt,:),inb1,inb2);
            else
                bv2 = NaN; pr = 50;
            end

            if pr >=99
                bvg = [bvg ; bv magco x y length(b(:,1)) bv2 pr av stan  max(b(:,6)) bv-bv2  pr bv2/bv*100-100];
            else
                bvg = [bvg ; 0 NaN x y NaN NaN NaN NaN NaN  NaN 0 NaN NaN];
            end
        else
            bvg = [bvg ; NaN NaN x y NaN NaN NaN NaN NaN  NaN 0 NaN NaN];
        end
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
        ' sapa2 = [''save '' path1 file1 '' ll tmpgri bvg xvect yvect gx gy ni dx dd par1 ni newa maex maey maix maiy ''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)
    %corrected window postioning error
    close(wai)
    watchoff

    % reshape a few matrices
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,6);
    meg=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    old1 =reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,7);
    pro=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,8);
    avm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,9);
    stanm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,10);
    maxm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,11);
    db12=reshape(normlap2,length(yvect),length(xvect));
    db12 = -db12;

    normlap2(ll)= bvg(:,13);
    dbperc=reshape(normlap2,length(yvect),length(xvect));


    re3 = db12;
    old = re3;

    % View the b-value map
    view_bvt

end   %  if sel = ca

% Load exist b-grid
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

        normlap2(ll)= bvg(:,5);
        r=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,6);
        meg=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,2);
        old1 =reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,7);
        pro=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,8);
        avm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,9);
        stanm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,10);
        maxm=reshape(normlap2,length(yvect),length(xvect));

        old = re3;

        view_bv2
    else
        return
    end
end

