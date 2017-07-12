% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95


disp ('This is /src/bdepth_ratio.m');
%% disp  ('PLEASE SET my_dir TO YOUR WORKING DIRECTORY!!!!!');

global no1 bo1 inb1 inb2

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 0.1;
    dy = 0.1 ;
    ni = 1000;
    Nmin = 50;
    stan2 = nan;
    stan = nan;
    prf = nan;
    av = nan;
    mid_point = 5;
    top_zonet = 0;
    top_zoneb = 5;
    bot_zonet = 7;
    bot_zoneb = 15;
    topstan2 = nan;
    botstan2 = nan;
    topstan = nan;
    botstan = nan;
    topav = nan;
    botav = nan;
    use_old_win = 1;
    lab1 = 'b-value-depth-ratio:';


    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Depth Ratio Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 650 300]);
    axis off
    labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature)'];

    labelPos = [0.2 0.60 0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2=hndl2.Value; ');

    % set(hndl2,'value',5);


    % creates a dialog box to input grid parameters
    %
    %

    % mid_point_field=uicontrol('Style','edit',...
    %     'Position',[.47 .80 .12 .08],...
    %     'Units','normalized','String',num2str(mid_point),...
    %     'Callback','mid_point=str2double(mid_point_field.String); mid_point_field.String=num2str(mid_point);');

    top_zonet_field=uicontrol('Style','edit',...
        'Position',[.36 .80 .06 .06],...
        'Units','normalized','String',num2str(top_zonet),...
        'Callback','top_zonet=str2double(top_zonet_field.String); top_zonet_field.String=num2str(top_zonet);');
    top_zoneb_field=uicontrol('Style','edit',...
        'Position',[.36 .74 .06 .06],...
        'Units','normalized','String',num2str(top_zoneb),...
        'Callback','top_zoneb=str2double(top_zoneb_field.String); top_zoneb_field.String=num2str(top_zoneb);');

    bot_zonet_field=uicontrol('Style','edit',...
        'Position',[.78 .80 .06 .06],...
        'Units','normalized','String',num2str(bot_zonet),...
        'Callback','bot_zonet=str2double(bot_zonet_field.String); bot_zonet_field.String=num2str(bot_zonet);');
    bot_zoneb_field=uicontrol('Style','edit',...
        'Position',[.78 .74 .06 .06],...
        'Units','normalized','String',num2str(bot_zoneb),...
        'Callback','bot_zoneb=str2double(bot_zoneb_field.String); bot_zoneb_field.String=num2str(bot_zoneb);');

    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(freq_field.String); freq_field.String=num2str(ni);tgl2.Value=0; tgl1.Value=1;');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.70 .50 .12 .08],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(freq_field0.String); freq_field0.String=num2str(ra); tgl2.Value=1; tgl1.Value=0;');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .12 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(freq_field2.String); freq_field2.String=num2str(dx);');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .08],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(freq_field3.String); freq_field3.String=num2str(dy);');

    tgl1 = uicontrol('Style','checkbox',...
        'string','Number of Events:',...
        'Position',[.09 .50 .2 .08], 'Callback','tgl2.Value=0;',...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('Style','checkbox',...
        'string','OR: Constant Radius',...
        'Position',[.47 .50 .2 .08], 'Callback','tgl1.Value=0;',...
        'Units','normalized');


    freq_field4=uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .08],...
        'Units','normalized','String',num2str(Nmin),...
        'Callback','Nmin=str2double(freq_field4.String); % freq_field4.String=num2str(Nmin);');


    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback',' inb1=hndl2.Value;tgl1=tgl1.Value;tgl2=tgl2.Value;close,sel =''ca'', bdepth_ratio',...
        'String','Go');
    Nmin;
    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 .75 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Please choose an Mc estimation option   ');

    mid_txt=text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.24 1.0 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Depth limits for depth ratio calculation  ');

    top_txt=text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.10 .85 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Top and bottom for TOP zone(km):');

    bot_txt=text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.40 .85 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Top and bottom for BOTTOM zone(km):');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.64 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.06 0.40 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.06 0.29 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.06 0.17 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. No. of events > Mc:');



    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0


% for plotting number of events used (ni) in view_bdepth
ni_plot = ni;


% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'

    [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.hodi, '*.mat'), 'Grid Datafile Name?') ;


    selgp
    itotal = length(newgri(:,1));
    if length(gx) < 4  ||  length(gy) < 4
        errordlg('Selection too small! (Dx and Dy are in degreees! ');
        return
    end


    zmap_message_center.set_info(' ','Running bdepth_ratio... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(ZG.a.Date)  ;
    n = ZG.a.Count;
    teb = ZG.a.Date(n) ;
    tdiff = round(days(teb-t0b)/par1);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    nobv = 0;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow


    % sort by depth

    % [s,is] = sort(ZG.a.Depth);
    % adepth = a(is(:,1),:);

    % find row index of ratio midpoint
    l = ZG.a.Depth >= top_zonet & ZG.a.Depth <  top_zoneb;
    top_zone = ZG.a.subset(l);

    l = ZG.a.Depth >= bot_zonet & ZG.a.Depth <  bot_zoneb;
    bot_zone = ZG.a.subset(l);



    %
    % overall b-value
    [bv magco stan av me mer me2,  pr] =  bvalca3(top_zone,inb1,inb2);
    tbo1 = bv; tno1 = length(top_zone(:,1));

    [bv magco stan av me mer me2,  pr] =  bvalca3(bot_zone,inb1,inb2);
    bbo1 = bv; bno1 = length(bot_zone(:,1));

    depth_ratio = tbo1/bbo1;

    disp(depth_ratio);

    % loop over all points
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            b = ZG.a.subset(l3);      % new data per grid point (b) is sorted in distanc  (from center point)
            rd = ra;
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);

        end


        %estimate the completeness and b-value
        ZG.newt2 = b;

        % sort by depth

        l = b.Depth >= top_zonet & b.Depth <  top_zoneb;
        topb = b(l,:);
        per_in_top = (length(topb)/length(b))*100.0;
        l = b.Depth >= bot_zonet & b.Depth <  bot_zoneb;
        botb = b(l,:);
        per_in_bot = (length(botb)/length(b))*100.0;





       if length(topb) >= Nmin  && length(botb) >= Nmin

            if inb1 == 3
                ZG.newt2 = topb;
                mcperc_ca3;
                l = topb(:,6) >= Mc90-0.05; magco = Mc90;
                n1 = length(topb(l,:));
                if length(topb(l,:)) >= Nmin
                    [topbv magco stan av me mer me2,  pr] =  bvalca3(topb(l,:),2,2);
                    [topav2 topbv2 topstan2 ] =  bmemag(topb(l,:));
                else  topbv = nan; topbv2 = nan, magco = nan; av = nan; topav2 = nan;
                    nobv = nobv + 1;
                end
                ZG.newt2 = botb;
                mcperc_ca3;
                l = botb(:,6) >= Mc90-0.05; magco = Mc90;
                n2 = length(botb(l,:));
                if length(botb(l,:)) >= Nmin
                    [botbv magco stan av me mer me2,  pr] =  bvalca3(botb(l,:),2,2);
                    [botav2 botbv2 botstan2 ] =  bmemag(botb(l,:));

                else  botbv = nan; botbv2 = nan; magco = nan; av = nan; botav2 = nan;
                    nobv = nobv + 1;
                end

            elseif inb1 == 4
                ZG.newt2 = topb;
                mcperc_ca3;
                l = topb(:,6) >= Mc95-0.05; magco = Mc95;
                n1 = length(topb(l,:));

                if length(topb(l,:)) >= Nmin
                    [topbv magco topstan topav topme topmer topme2,  toppr] =  bvalca3(topb(l,:),2,2);
                    [topav2 topbv2 topstan2 ] =  bmemag(topb(l,:));
                else
                    topbv = nan; topbv2 = nan, magco = nan; topav = nan; topav2 = nan;
                    nobv = nobv + 1;
                end
                ZG.newt2 = botb;
                mcperc_ca3;
                l = botb(:,6) >= Mc90-0.05; magco = Mc95;
                n2 = length(botb(l,:));

                if length(botb(l,:)) >= Nmin
                    [botbv magco botstan botav botme botmer botme2,  botpr] =  bvalca3(botb(l,:),2,2);
                    [botav2 botbv2 botstan2 ] =  bmemag(botb(l,:));
                else
                    botbv = nan; botbv2 = nan, magco = nan; botav = nan; botav2 = nan;
                    nobv = nobv + 1;
                end

            elseif inb1 == 5
                ZG.newt2 = topb;
                mcperc_ca3;
                if isnan(Mc95) == 0 
                    magco = Mc95;
                elseif isnan(Mc90) == 0 
                    magco = Mc90;
                else
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                end

                l = topb(:,6) >= magco-0.05;
                n1 = length(topb(l,:));
                if length(topb(l,:)) >= Nmin
                    [topbv magco topstan topav topme topmer topme2,  toppr] =  bvalca3(topb(l,:),2,2);
                    [topav2 topbv2 topstan2 ] =  bmemag(topb(l,:));
                else
                    topbv = nan; topbv2 = nan, magco = nan; topav = nan; topav2 = nan;
                    nobv = nobv + 1;
                end

                ZG.newt2 = botb;
                mcperc_ca3;
                l = botb(:,6) >= magco-0.05;
                n2 = length(botb(l,:));

                if length(botb(l,:)) >= Nmin
                    [botbv magco botstan botav botme botmer botme2,  botpr] =  bvalca3(botb(l,:),2,2);
                    [botav2 botbv2 botstan2 ] =  bmemag(botb(l,:));
                else
                    botbv = nan; botbv2 = nan, magco = nan; botav = nan; bottopav2 = nan;
                    nobv = nobv + 1;
                end

            elseif inb1 == 1
                % ZG.newt2 = topb;
                % mcperc_ca3;
                [topbv magco topstan topav topme topmer topme2,  toppr] =  bvalca3(topb,1,1);
                l = topb(:,6) >= magco-0.05;
                if length(topb(l,:)) >= Nmin
                    [topav2 topbv2 topstan2 ] =  bmemag(topb(l,:));
                    n1 = length(topb(l,:));
                else
                    topbv = nan; topbv2 = nan; magco = nan; topav = nan; topav2 = nan;
                    n1 = nan;


                    nobv = nobv + 1;
                end
                %    ZG.newt2 = botb;
                %    mcperc_ca3;
                [botbv magco botstan botav botme botmer botme2,  botpr] =  bvalca3(botb,1,1);
                l = botb(:,6) >= magco-0.05;
                if length(botb(l,:)) >= Nmin
                    [botav2 botbv2 botstan2 ] =  bmemag(botb(l,:));
                    n2 = length(botb(l,:));

                else
                    botbv = nan; botbv2 = nan; magco = nan; botav = nan; botav2 = nan;
                    n2 = nan;
                    nobv = nobv + 1;
                end

            elseif inb1 == 2
                [topbv magco topstan topav topme topmer topme2,  toppr] =  bvalca3(topb,2,2);
                n1 = length(topb);
                [topav2 topbv2 topstan2 ] =  bmemag(topb);

                [botbv magco botstan botav botme botmer botme2,  botpr] =  bvalca3(botb,2,2);

                n2 = length(botb);
                [botav2 botbv2 botstan2 ] =  bmemag(botb);

            end

        else
            topbv = nan; topbv2 = nan; magco = nan; topav = nan; topav2 = nan;
            botbv = nan; botbv2 = nan; magco = nan; botav = nan; botav2 = nan;
            nobv = nobv + 1;

        end

        bv = topbv/botbv; bv2 = topbv2/botbv2; stan2 = topstan2/botstan2; av = topav/botav;
        stan = topstan/botstan;
        n = n1+n2; bo1 = topbv; b2 = botbv;
        da = -2*n*log(n) + 2*n1*log(n1+n2*bo1/b2) + 2*n2*log(n1*b2/bo1+n2) - 2;
        pr = (1  -  exp(-da/2-2))*100;

        ltopb = length(topb);
        lbotb = length(botb);
        bvg = [bvg ; bv magco x y rd bv2 av pr topbv botbv per_in_top per_in_bot];
        waitbar(allcount/itotal)

    end

    mean_in_top = mean(per_in_top);
    mean_in_bot = mean(per_in_bot);
    snobv = num2str(nobv);
    spnobv = num2str((nobv/allcount)*100.0);
    disp(['Not enough EQs to calculate b values for ', snobv, ' gridnodes. This is ',spnobv,'% of the total'])

    % for newgr
    %save cnssgrid.mat
    %quit
    % save data
    %

    if file1 ~= 0
        catSave3 =...
            [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
            ' sapa2 = [''save '' path1 file1 '' bvg gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll depth_ratio top_zonet top_zoneb bot_zoneb bot_zonet ni_plot''];',...
            ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)
        %%%%%%        '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Grid Datafile Name?'') ;',...
        close(wai)
        watchoff
    end

    % plot the results
    % old and re3 (initially ) is the b-value matrix
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,6);
    meg=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    old1=reshape(normlap2,length(yvect),length(xvect));


    normlap2(ll)= bvg(:,7);
    avm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,8);
    Prmap=reshape(normlap2,length(yvect),length(xvect));


    normlap2(ll)= bvg(:,9);
    top_b=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,10);
    bottom_b=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,11);
    per_top=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,12);
    per_bot=reshape(normlap2,length(yvect),length(xvect));

    %  normlap2(ll)= bvg(:,13);
    %  ltopb=reshape(normlap2,length(yvect),length(xvect));

    % normlap2(ll)= bvg(:,14);
    % lbotb=reshape(normlap2,length(yvect),length(xvect));

    old = re3;

    % View the b-value map
    view_bdepth

end   % if sel = na

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        normlap2=ones(length(tmpgri(:,1)),1)*nan;


        normlap2(ll)= bvg(:,1);
        re3=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,5);
        r=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,6);
        meg=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,2);
        old1=reshape(normlap2,length(yvect),length(xvect));

        %  normlap2(ll)= bvg(:,7);
        %  pro=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,7);
        avm=reshape(normlap2,length(yvect),length(xvect));

        %  normlap2(ll)= bvg(:,9);
        % stanm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,8);
        Prmap=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,9);
        top_b=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,10);
        bottom_b=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,11);
        per_top=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,12);
        per_bot=reshape(normlap2,length(yvect),length(xvect));

        %    normlap2(ll)= bvg(:,13);
        %    ltopb=reshape(normlap2,length(yvect),length(xvect));

        %   normlap2(ll)= bvg(:,14);
        %  lbotb=reshape(normlap2,length(yvect),length(xvect));

        old = re3;

        view_bdepth
    else
        return
    end
end
