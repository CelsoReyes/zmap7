% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

%short test for parallel processing
%This version will at the moment use the local setup for the parallel
%processing. It can be change by replacing the string "local" after the
%matlabpool command with the name of the configuration wanted to be used.


global no1 bo1 inb1 inb2
report_this_filefun(mfilename('fullpath'));

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 1.00;
    dy = 1.00; dz =50;
    ni = 100;

    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 450 250]);
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
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','inb1 =get(hndl1,''Value'');inb2 =get(hndl2,''Value'');close,sel =''ca'', removequar_par',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 1.0 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Automatically estimate magn. of completeness?   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.64 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.53 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'String','Number of Events (Ni):');
    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    selgp3d
    gz = 50:dz:200;
    itotal = length(gx)*length(gz)*length(gy);
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

    load pqr.mat % this file contains the random simulation results nessesary to convert to probabilities
    maxq = 99.9; q = []; count2 = 0;
    parpool open local
    while maxq > 99

        zvg = NaN(length(gx),length(gy),length(gz));%x0 = 0; y0 = 0; z0 = 0;
        raq = NaN(length(gx),length(gy),length(gz));%x0 = 0; y0 = 0; z0 = 0;
        count2 = count2 + 1
        allcount = 0.;
        %wai = waitbar(0,' Please Wait ...  ');
        %  set(wai,'NumberTitle','off','Name','remove blast events -  percent done');;
        drawnow
        ld = length(D);
        ln = 24 - ld;
        %have to be done that way because of the parallel loop
        x_array = min(gx):dx:max(gx);
        y_array = min(gy):dy:max(gy);
        z_array = min(gz):dz:max(gz);
        x_numar = 1:numel(x_array);
        y_numar = 1:numel(y_array);
        z_numar = 1:numel(z_array);


        [xx yy,  zz] =meshgrid(x_array,y_array,z_array);
        [x_number y_number,  z_number] =meshgrid(x_numar,y_numar,z_numar);
        %clear xtemp;
        %clear ytemp;
        elementnumber=numel(xx);

        % loop over all points
        parfor elementindex=1:elementnumber
            %x0 = 1:numel(x_array)
            x = xx(elementindex);
            %for y0 = 1:numel(y_array)
            y = yy(elementindex);
            %   for z0 = 1:numel(z_array)
            z = zz(elementindex);
            %allcount = allcount + 1.;
            i2 = i2+1;
            z0=z_number(elementindex);

            % calculate distance from center point and sort wrt distance
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
            [s,is] = sort(l);
            b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

            % take first ni points
            b = b(1:z,:);      % new data per grid point (b) is sorted in distance


            l2 = sort(l);
            l = ismember(b(:,8),D);
            day = b(l,:);
            nig = b;
            nig(l,:) = [];
            rat = length(day(:,1))/(length(nig(:,1)));
            rat = rat*ln/ld;
            c = abs(p(z0,:)-rat);
            pr = 89.99 + min(find(c == min(c)))/10;
            %zvg(x0,y0,z0) = pr;
            %raq(x0,y0,z0)  = rat;

            zvg(elementindex) = pr;
            raq(elementindex) = rat;
            %  end  % for z
            % z0 = 0;
            %waitbar(allcount/itotal)
            %    end  % for y
            %y0 = 0;
        end  % for x
        %x0 = 0;


        %in = find(zvg == max(max(max(zvg))));
        %[i,j,k] = ind2sub(size(zvg),in)
        %i=x_number(in);j=y_number(in);k=z_number(in);
        %maxq = zvg(i(1),j(1),k(1))
        %rx = gx(i(1))
        %ry = gy(j(1))
        %rni = gz(k(1))

        %rewritten
        maxq=max(max(max(zvg)));
        logind=zvg==maxq;
        rx=xx(logind);
        rx=rx(1);
        ry=yy(logind);
        ry=ry(1);
        rni=zz(logind);
        rni=rni(1);
        nislide=z_number(logind);
        nislide=nislide(1)
        re3 = zvg(:,:,nislide)'; r = re3; view_qva;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((a.Longitude-rx)*cos(pi/180*ry)*111).^2 + ((a.Latitude-ry)*111).^2) ;
        [s,is] = sort(l);
        ld2 = sort(l); di = ld2(rni);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        l2 = ismember(a.Date.Hour,D) & l <= di;
        %l2 = a.Date.Hour >= 8 & a.Date.Hour <= 17 & l <= di;
        % take first ni points
        q = [q ; a(l2,:)];
        a(l2,:) = [];      % new data per grid point (b) is sorted in distance

        allcount = 0;
        %close(wai)
    end % While maxq
    parpool close
    return

    %close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix
    %
    normlap2=NaN(length(tmpgri(:,1)),1);
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,4);
    r=reshape(normlap2,length(yvect),length(xvect));

    old = re3;

    % View the b-value map
    view_qva

end   % if sel = na

