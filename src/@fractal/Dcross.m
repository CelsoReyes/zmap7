function Dcross(sel)
    % Calculate the Dvalue for a volume around a grid points.
    %
    % see DCPARAIN.
    %
    %   Stefan Wiemer 1/95
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    global eq0p
    
    % the new data vector to be analysed is called Da, relative to the center of the x-section and already in km
    % D = [x,y,z ]
    catalog=ZG.primeCatalog; % points to same thing
    Da = [eq0p(1,:)' eq0p(2,:)' catalog.Date catalog.Date.Month catalog.Date.Day catalog.Magnitude catalog.Depth];
    Da = Da.subset(-2.99 < Da(:,7));
    if exist('sel','var')
        switch sel
            case 'ca'
                my_calculate();
            case 'lo'
                my_load();
        end
        % get the grid parameter
        % initial values
        %
        dd = 1.00;
        dx = 1.00 ;
        ni = 600;
        Nmin = 600; %on line 303 it has been replaced by ni
        stan2 = nan;
        stan = nan;
        prf = nan;
        av = nan;
        
        
        
        % make the interface
        %
        figure_w_normalized_uicontrolunits(...
            'Name','Grid Parameters',...
            'NumberTitle','off', ...
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
            'callback',@callbackfun_001);
        
        
        freq_field0=uicontrol('Style','edit',...
            'Position',[.80 .57 .12 .08],...
            'Units','normalized','String',num2str(ra),...
            'callback',@callbackfun_002);
        
        freq_field2=uicontrol('Style','edit',...
            'Position',[.32 .44 .12 .08],...
            'Units','normalized','String',num2str(dx),...
            'callback',@callbackfun_003);
        
        freq_field3=uicontrol('Style','edit',...
            'Position',[.32 .31 .12 .08],...
            'Units','normalized','String',num2str(dd),...
            'callback',@callbackfun_004);
        
        tgl1 = uicontrol('Backgroundcolor', [0.8 0.8 0.8], 'Fontweight','bold',...
            'FontSize', 10, 'Style','checkbox',...
            'string','Number of Events:',...
            'Position',[.05 .56 .2 .10],...
            'callback',@callbackfun_005,...
            'Units','normalized');
        
        set(tgl1,'value',1);
        
        tgl2 =  uicontrol('BackGroundColor', [0.8 0.8 0.8],'Style','checkbox',...
            'string','Constant Radius:','Fontweight','bold','FontSize', 10,...
            'Position',[.55 .56 .2 .1],...
            'callback',@callbackfun_006,...
            'Units','normalized');
        
        set(tgl2, 'ForegroundColor', 'w');
        
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.45 .05 .15 .13 ],...
            'Units','normalized', 'Callback', @callbackfun_007,'String','Cancel');
        
        help_button=uicontrol('Style','Pushbutton',...
            'Position',[.70 .05 .15 .13 ],...
            'Units','normalized', 'Callback', @callbackfun_008,'String','Help');
        
        
        go_button1=uicontrol('Style','Pushbutton',...
            'Position',[.20 .05 .15 .13 ],...
            'Units','normalized',...
            'callback',@callbackfun_009,...
            'String','Go');
        
        
        txt3 = text(...
            'Position',[0.35 0.9 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String',' Grid Parameters');
        txt5 = text(...
            'Position',[-0.07 0.46 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','Horizontal Spacing [km]:');
        
        txt6 = text(...
            'Position',[-0.07 0.30 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','Depth spacing [km]:');
        
        txt7 = text(...
            'Position',[0.45 0.62 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Color', 'r',...
            'String','OR');
        
        
        set(gcf,'visible','on');
        watchoff
        
        
        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % the seismicity and selectiong the ni neighbors
        % to each grid point
        
        functin my_calculate()
        
        figure(xsec_fig);
        figure;
        ax = plot(Da(:,1),-Da(:,7),'o');
        xlabel('Distance in [km]')
        ylabel('Depth in [km]')
        
        set(gca,'NextPlot','add')
        ax=findobj(gcf,'Tag','mainmap_ax');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        
        
        
        plos2 = plot(x,y,'b-', 'Color', 'r');        % plot outline
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
        if length(gx) < 4  ||  length(gy) < 4
            errordlg('Selection too small! ');
            return
        end
        
        
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = bounds(newa.Date) ;
        n = newa.Count;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        bvg = [];
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','D-value grid - percent done', 'position', [250 80 270 50]);
        drawnow;
        %
        
        %
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            i2 = i2+1;
            
            % calculate distance from center point and sort wrt distance
            
            l = sqrt(((Da(:,1) - x)).^2 + ((Da(:,7) + y)).^2 + (Da(:,2).^2)) ;
            [s,is] = sort(l);
            b = Da(is(:,1),:) ;       % re-orders matrix to agree row-wise
            
            
            if tgl1 == 0   % take point within r
                l3 = l <= ra;
                b = Da.subset(l3);      % new data per grid point (b) is sorted in distanc
                rd = ra;
            else
                % take first ni points
                b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l);
                rd = l2(ni);
                
            end
            
            
            %estimate the completeness and b-value, and take the zero depth events away.
            %ZG.newt2 = [b.Longitude b.Latitude zeros(size(b,1),1) zeros(size(b,1),1) zeros(size(b,1),1) zeros(size(b,1),1) b.Date];
            %
            ZG.newt2  = b;
            E = ZG.newt2;
            
            if b.Count >= ni  % enough events?
                
                dtokm = 0;
                [bv magco0 stan av pr] =  bvalca3(b.Magnitude,McAutoEstimate.auto);
                
                
                if range == 1 | range == 2
                    
                    pdc3nofig(E);
                    
                elseif range == 3
                    
                    pdc3;
                    pause;
                    
                end %if range = 1|2
                
                D = coef(1,1);
                fdallfig;
                
                
            else
                D = nan;
                bv = nan;
                
            end %if length >= ni
            
            bvg = [bvg ; D x y rd bv deltar];
            waitbar(allcount/itotal)
            
        end  % for  newgri
        
        figure(HCIfig);
        cb = colorbar('horiz');
        set(cb, 'position', [0.32 0.08 0.4 0.03], 'XTickLabel', col);
        axes('pos',[0 0 1 1]); axis off; set(gca,'NextPlot','add');
        te= text('string','D-value','pos',[0.49,0.01], 'fontsize',8,'FontWeight','bold')
        set(gcf,'visible','on');
        % save data
        %
        %  set(txt1,'String', 'Saving data...')
        
        drawnow
        gx = xvect;gy = yvect;
        
        catsave3('Dcross');
        %corrected the window positioning error
        close(wai)
        watchoff
        
        %
        % reshape a few matrices
        %
        normlap2=nan(length(tmpgri(:,1)),1)
        
        reshaper=@(v)reshape(v,length(yvect),length(xvect));
        normlap2(ll)= bvg(:,1);
        valueMap=reshaper(normlap2);
        
        normlap2(ll)= bvg(:,4);
        reso = reshaper(normlap2);
        
        normlap2(ll)= bvg(:,5);
        BM=reshaper(normlap2);
        
        
        old = valueMap;
        
        % View the b-value map
        view_Dv(valueMap, lab1, Da)
        
    end
    
    % Load exist D-grid
    function my_load()
        [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            xsecx = newa(:,end)';
            xsecy = newa(:,7);
            xvect = gx; yvect = gy;
            tmpgri=zeros((length(xvect)*length(yvect)),2);
            
            normlap2=nan(length(tmpgri(:,1)),1)
            normlap2(ll)= bvg(:,1);
            valueMap=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,4);
            r=reshape(normlap2,length(yvect),length(xvect));
            
            
            old = valueMap;
            
            nlammap
            [xsecx xsecy,  inde] =mysect(catalog.Latitude',catalog.Longitude',catalog.Depth,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            set(gca,'NextPlot','add')
            plot(newgri(:,1),newgri(:,2),'+k')
            view_Dv(valueMap, lab1, Da)
        else
            return
        end
    end
    
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2double(freq_field.String);
        freq_field.String=num2str(ni);
        tgl2.Value=0;
        tgl1.Value=1;
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ra=str2double(freq_field0.String);
        freq_field0.String=num2str(ra);
        tgl2.Value=1;
        tgl1.Value=0;
    end
    
    function callbackfun_003(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(freq_field2.String);
        freq_field2.String=num2str(dx);
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dd=str2double(freq_field3.String);
        freq_field3.String=num2str(dd);
    end
    
    function callbackfun_005(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(tgl2,'Value',0, 'ForegroundColor', 'w');
        set(tgl1, 'ForegroundColor', 'k');
    end
    
    function callbackfun_006(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(tgl1,'Value',0,'ForegroundColor', 'w');
        set(tgl2, 'ForegroundColor', 'k');
    end
    
    function callbackfun_007(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_008(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_009(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl1=tgl1.Value;
        tgl2=tgl2.Value;
        close;
        gobut = 3;
        org = 1;
        startfd(1, , gobut);
    end
    
end
