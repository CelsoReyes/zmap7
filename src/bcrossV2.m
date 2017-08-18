function bcrossV2(sel)
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
        
        % make the interface
        %
        figure_w_normalized_uicontrolunits(...
            'Name','Grid Input Parameter',...
            'NumberTitle','off', ...
            'units','points',...
            'Visible','off', ...
            'Position',[ ZG.wex+200 ZG.wey-200 550 300]);
        axis off
        
        labelList2=['Weighted LS - automatic Mcomp | Weighted LS - no automatic Mcomp '];
        labelPos = [0.2 0.7  0.6  0.08];
        hndl2=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','normalized',...
            'String',labelList2,...
            'callback',@callbackfun_001);
        
        
        
        labelList=['Maximum likelihood - automatic Mcomp | Maximum likelihood  - no automatic Mcomp '];
        labelPos = [0.2 0.8  0.6  0.08];
        hndl1=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','normalized',...
            'String',labelList,...
            'callback',@callbackfun_002);
        
        % creates a dialog box to input grid parameters
        %
        freq_field=uicontrol('Style','edit',...
            'Position',[.60 .50 .22 .10],...
            'Units','normalized','String',num2str(ra),...
            'callback',@callbackfun_003);
        
        freq_field2=uicontrol('Style','edit',...
            'Position',[.60 .40 .22 .10],...
            'Units','normalized','String',num2str(dx),...
            'callback',@callbackfun_004);
        
        freq_field3=uicontrol('Style','edit',...
            'Position',[.60 .30 .22 .10],...
            'Units','normalized','String',num2str(dd),...
            'callback',@callbackfun_005);
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.60 .05 .15 .12 ],...
            'Units','normalized','callback',@callbackfun_006,'String','Cancel');
        
        go_button1=uicontrol('Style','Pushbutton',...
            'Position',[.20 .05 .15 .12 ],...
            'Units','normalized',...
            'callback',@callbackfun_007,...
            'String','Go');
        
        text(...
            'Position',[0.20 1.0 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String','Automatically estimate magn. of completeness?   ');
        
        txt3 = text(...
            'Position',[0.30 0.65 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String',' Grid Parameter');
        txt5 = text(...
            'Position',[0. 0.42 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','Spacing along projection [km]');
        
        txt6 = text(...
            'Position',[0. 0.32 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','Spacing in depth in km:');
        
        txt1 = text(...
            'Position',[0. 0.53 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            'FontWeight','bold',...
            'String','Radius in km');
        
        set(gcf,'visible','on');
        watchoff
        
    end   % if sel == in
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % thge seimicity and selectiong the ni neighbors
    % to each grid point
    
    if sel == 'ca'
        
        figure(xsec_fig);
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
        
        if length(xvect) < 2 || length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        itotal = length(newgri(:,1));
        
        zmap_message_center.set_info(' ','Running... ');think
        %  make grid, calculate start- endtime etc.  ...
        %
        t0b = min(newa.Date)  ;
        n = newa.Count;
        teb = max(newa.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_days);
        loc = zeros(3, length(gx)*length(gy));
        
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
        
        
        % overall b-value
        [bv magco stan av me mer me2,  pr] =  bvalca3(newa,inb1,inb2);
        bo1 = bv;
        no1 = newa.Count;
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
            b = newa.subset(l);      % new data per grid point (b) is sorted in distance
            
            if isempty(b); b = newa.subset(1); end
            if b.Count >= 50;
                % call the b-value function
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,inb1,inb2);
                l2 = sort(l);
                b2 = b;
                if inb2 ==  1
                    l = b.Magnitude >= magco;
                    b2 = b(l,:);
                end
                [av2 bv2 stan2 ] =  bmemag(b2);
                bvg = [bvg ; bv magco x y b.Count bv2 pr av stan  max(b.Magnitude)];
            else
                bvg = [bvg ; NaN NaN x y NaN NaN NaN NaN NaN  NaN];
            end
            waitbar(allcount/itotal)
        end  % for  newgri
        
        % save data
        %
        %  set(txt1,'String', 'Saving data...')
        drawnow
        gx = xvect;gy = yvect;
        
        catSave3 =...
            [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
            '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Grid Datafile Name?'') ;',...
            ' sapa2 = [''save '' path1 file1 '' ll a tmpgri newgri lat1 lon1 lat2 lon2 wi  bvg xvect yvect gx gy dx dd ZG.bin_days newa maex maey maix maiy ''];',...
            ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)
        
        close(wai)
        watchoff
        
        % reshape a few matrices
        %
        normlap2=nan(length(tmpgri(:,1)),1)
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
        
        % View the b-value map
        view_bv2([],re3)
        
    end   %  if sel = ca
    
    % Load exist b-grid
    if sel == 'lo'
        load_existing_bgrid_version_A
    end
    
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inb2=hndl2.Value;
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inb1=hndl1.Value;
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ra=str2double(freq_field.String);
        freq_field.String=num2str(ra);
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(freq_field2.String);
        freq_field2.String=num2str(dx);
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dd=str2double(freq_field3.String);
        freq_field3.String=num2str(dd);
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        done;
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inb1=hndl1.Value;
        inb2=hndl2.Value;
        close;
        sel ='ca';
        bcrossV2(sel);
    end
end
