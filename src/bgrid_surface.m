% This subroutine assigns creates a 3D grid with
% spacing dx,dy, dz (in degreees). The size will
% be selected interactiVELY. The pvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/98

report_this_filefun(mfilename('fullpath'));
global no1 bo1 inb1 inb2

if sel == 'i1'
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
    R = 5; Nmin = 50;

    labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature)'];
    labelPos = [0.2 0.77  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',5);


    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .10],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.70 .50 .12 .10],...
        'Units','normalized','String',num2str(R),...
        'Callback','R=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(R)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');


    tgl1 = uicontrol('Style','checkbox',...
        'string','Number of Events:',...
        'Position',[.05 .50 .2 .10], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('Style','checkbox',...
        'string','OR: Constant Radius',...
        'Position',[.47 .50 .2 .10], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');


    freq_field4 = uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .10],...
        'Units','normalized','String',num2str(Nmin),...
        'Callback','Nmin=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(Nmin));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.50 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    help_button=uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Help');


    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');close,sel =''ca'', bgrid_surface',...
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

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.2 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m,...
        'FontWeight','bold',...
        'String','Min No. of events:');

end  % if sel = i1
if sel == 'in'
    % get the grid parameter
    % initial values
    %



    % sel = 'ca'; bgrid_surface


end   % if sel == 'in'

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'

    itotal = length(slabc(:,1));
    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    bvg = zeros(itotal,12)*nan;

    t0b = min(a.Date)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    Rconst = R;
    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name',' 3D gridding - percent done');;
    drawnow
    %
    %

    z0 = 0; x0 = 0; y0 = 0; dt = 1;
    % loop over all points
    for il =1:length(slabc(:,1))

        x = slabc(il,3);
        y = slabc(il,4);
        z = slabc(il,13)+20;

        allcount = allcount + 1.;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + ((a.Depth - z)).^2 ) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        if tgl1 == 0   % take point within r
            l3 = l <= R;
            b = a.subset(l3);      % new data per grid point (b) is sorted in distanc
            rd = length(b(:,1));
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);

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
                    bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
                end

            elseif inb1 == 4
                mcperc_ca3;  l = b(:,6) >= Mc95-0.05; magco = Mc95;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    [mea bv2 stan2 av2 ] =  bmemag(b(l,:));
                else
                    bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
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
                    bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan; dP = 0;
                end

            elseif inb1 == 1
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                l = b(:,6) >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [mea bv2 stan2,  av2] =  bmemag(b(l,:));
                else
                    bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
                end

            elseif inb1 == 2
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,2,2);
                [mea  bv2 stan2 av2 ] =  bmemag(b);
            end
            newt2 = b;
            %  predi_ca

        else
            bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan; prf = nan; dP = 0;
        end


        bvg(allcount,:) = [  bv magco x y z rd bv2 stan2 av stan prf av2] ;


        waitbar(allcount/itotal)
    end  % for t5

    % save data
    %

    close(wai)
    watchoff

    % old and re3 (initially ) is the b-value matrix
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    bls=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    reso=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,7);
    bml=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    old1=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,8);
    pro=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,9);
    avm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,10);
    stanm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,11);
    Prmap=reshape(normlap2,length(yvect),length(xvect));

    kll = ll;

    re3 = bml;
    old = re3;

    % View the b-value map
    view_bva

end  % if cal






