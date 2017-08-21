function calc_across(sel)
    % This subroutine assigns creates a grid with
    % spacing dx,dy (in degreees). The size will
    % be selected interactively.
    % The aValue, Mc and a resolution estimation in each
    % volume around a grid point, or defined by a radius
    % (ra for Mc, ri for aValue) containing ni earthquakes
    % will be calculated
    %
    %   This subroutine provides 4 methods for calculation:
    % 1. calculatea-value for const b-value
    % 2. calculatea-value by maxlikelihood (MaxLikelihoodA.m)
    %    of b-value and Mc defined by MaxC
    % 3. calculatea-value by maxlikelihood (MaxLikelihoodA.m)
    %    of b-value and Mc defined by Mc(EMR)
    % 4. calculatea-value within the radius ri and Mc within ra, where ra > ri
    %
    %   This subrouting is based on bcross.m
    %       by Stefan Wiemer 1/95
    %   and was modified
    %       by Thomas van Stiphout 3/2004
    
    report_this_filefun(mfilename('fullpath'));
    
    % Do we have to create the dialogbox?
    if sel == 'in'
        % Set the grid parameter
        % initial values
        %
        ra=10;
        ri=5;
        dd = 1.00;
        dx = 1.00 ;
        ni = 100;
        fFixbValue=0.9
        bv2 = NaN;
        Nmin = 50;
        stan2 = NaN;
        stan = NaN;
        prf = NaN;
        av = NaN;
        nRandomRuns = 1000;
        bGridEntireArea = 0;
        
        % Create the dialog box
        figure_w_normalized_uicontrolunits(...
            'Name','Grid Input Parameter',...
            'NumberTitle','off', ...
            'units','points',...
            'Visible','on', ...
            'Position',[ ZG.wex+200 ZG.wey-200 550 300], ...
            'Color', [0.8 0.8 0.8]);
        axis off
        
        % Dropdown list
        labelList2=[' a(M=0) for fixed b | a(M=0) for Mc(MaxC) + M(corr) | a(M=0) for M(EMR) | a(M=0) by r1 & Mc by r2 '];
        hndl2=uicontrol(...
            'Style','popup',...
            'Position',[ 0.2 0.77  0.6  0.08],...
            'Units','normalized',...
            'String',labelList2,...
            'BackgroundColor','w',...
            'callback',@callbackfun_001);
        
        % Set selection to 'Radius check'
        set(hndl2,'value',1);
        
        % Edit fields, radiobuttons, and checkbox
        freq_field=uicontrol('Style','edit',...
            'Position',[.30 .60 .12 .06],...
            'Units','normalized','String',num2str(ni),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_002);
        
        freq_field0=uicontrol('Style','edit',...
            'Position',[.30 .50 .06 .06],...
            'Units','normalized','String',num2str(ra),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_003);
        
        freq_field1=uicontrol('Style','edit',...
            'Position',[.36 .50 .06 .06],...
            'Units','normalized','String',num2str(ri),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_004);
        
        freq_field2=uicontrol('Style','edit',...
            'Position',[.30 .40 .06 .06],...
            'Units','normalized','String',num2str(dx),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_005);
        
        freq_field3=uicontrol('Style','edit',...
            'Position',[.36 .40 .06 .06],...
            'Units','normalized','String',num2str(dd),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_006);
        
        tgl1 = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
            'Style','radiobutton',...
            'string','Number of events:',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Position',[.02 .60 .28 .06], 'callback',@callbackfun_007,...
            'Units','normalized');
        
        % Set to constant number of events
        set(tgl1,'value',1);
        
        tgl2 =  uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','radiobutton',...
            'string','Constant radius [km]:',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Position',[.52 .60 .40 .06], 'callback',@callbackfun_008,...
            'Units','normalized');
        
        chkRandom = uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','checkbox',...
            'String', 'Additional random simulation',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Position',[.52 .40 .40 .06],...
            'Units','normalized');
        txtRandomRuns = uicontrol('Style','edit',...
            'Position',[.80 .30 .12 .06],...
            'Units','normalized','String',num2str(nRandomRuns),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_009);
        
        freq_field4 =  uicontrol('Style','edit',...
            'Position',[.30 .30 .12 .06],...
            'Units','normalized','String',num2str(Nmin),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_010);
        
        freq_field5 =  uicontrol('Style','edit',...
            'Position',[.30 .20 .12 .06],...
            'Units','normalized','String',num2str(fFixbValue),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_011);
        
        chkGridEntireArea = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
            'Style','checkbox',...
            'string','Create grid over entire area',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Position',[.52 .50 .40 .06], 'Units','normalized', 'Value', 0);
        
        % Buttons
        uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.80 .05 .15 .10], ...
            'Callback', 'close;done', 'String', 'Cancel');
        
        uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.60 .05 .15 .10], ...
            'Callback', 'ZG.inb1=hndl2.Value;tgl1=tgl1.Value;tgl2=tgl2.Value;bRandom = get(chkRandom, ''Value''); bGridEntireArea = get(chkGridEntireArea, ''Value'');close,sel =''ca'', calc_across(sel)',...
            'String', 'OK');
        
        % Labels
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [0.2 1 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
            'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Please select a Mc estimation option');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [0.3 0.75 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
            'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Grid parameters');
        
        text('Color',[0 0 0], 'EraseMode','normal', 'Units', 'normalized', ...
            'Position', [-.14 .51 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String','Radius ra / ri [km]:');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [-0.14 .39 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Spacing hor / depth [km]:');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [-0.14 .27 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Min. number of events:');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [-0.14 .15 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Fixed b-value:');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [0.5 0.27 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Number of runs:');
        
        
        set(gcf,'visible','on');
        watchoff
    end
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seimicity and selecting the ni neighbors
    % to each grid point
    
    if sel == 'ca'
        
        figure(xsec_fig);
        hold on
        
        if bGridEntireArea % Use entire area for grid
            vXLim = get(gca, 'XLim');
            vYLim = get(gca, 'YLim');
            x = [vXLim(1); vXLim(1); vXLim(2); vXLim(2)];
            y = [vYLim(2); vYLim(1); vYLim(1); vYLim(2)];
            x = [x ; x(1)];
            y = [y ; y(1)];     %  closes polygon
            clear vXLim vYLim;
        else
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
        end % of if bGridEntireArea
        
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
        t0b = min(newa.Date)  ;
        n = newa.Count;
        teb = max(newa.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_days);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        avg = nan(length(newgri),10);
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','a-value grid - percent done');;
        drawnow
        %
        % loop
        
        
        % overall b-value
        [bv magco stan av me mer me2,  pr] =  bvalca3(newa,ZG.inb1);
        ZG.bo1 = bv; no1 = newa.Count;
        %
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
                l4 = l <= ri;
                b = ZG.a.subset(l3);        % new data per grid point (b) is sorted in distance
                bri = ZG.a.subset(l4);
                rd = ra;
            else
                % take first ni points
                b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                rd = s(ni);
                
            end
            
            % Number of earthquakes per node
            [nX,nY] = size(b);
            
            %estimate the completeness and b-value
            ZG.newt2 = b;
            
            if length(b) >= Nmin  % enough events?
                
                if ZG.inb1 == 1;   % Calculation ofa-value by const b-value, and Mc
                    bv2 = fFixbValue;           % read fixed bValue to the bv2
                    magco=calc_Mc(b, 1, 0.1);
                    l = b.Magnitude >= magco-0.05;
                    if length(b(l,:)) >= Nmin   % calculation of thea-value according to determined Mc (magco)
                        faValue = calc_MaxLikelihoodA(b, bv2);
                        mea = NaN;
                        stan2 = NaN;
                        bv = NaN;
                    else
                        bv = NaN; bv2 = NaN; magco = NaN; av = NaN; faValue = NaN; stan2 = NaN; stan = NaN;
                    end
                    
                    % a(0) for Mc(MAxCurv) + Mc(Corr)
                elseif ZG.inb1 == 2
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1);
                    magco = magco + 0.2;    % Add 0.2 to Mc (Tobias)
                    l = b.Magnitude >= magco-0.05;
                    if length(b(l,:)) >= Nmin
                        [mea bv2 stan2,  faValue] =  bmemag(b(l,:));
                    else
                        bv = NaN; bv2 = NaN, magco = NaN; av = NaN; faValue = NaN;
                    end
                    
                elseif ZG.inb1 == 3; % a(0) for Mc(EMR)
                    [magco, bv2, faValue, stan2, stan] = calc_McEMR(b, 0.1);
                    l = b.Magnitude >= magco-0.05;
                    if length(b(l,:)) >= Nmin
                        faValue = calc_MaxLikelihoodA(b, bv2);
                    else
                        bv = NaN; bv2 = NaN, magco = NaN; av = NaN; faValue = NaN;
                    end
                    
                elseif ZG.inb1 == 4
                    % a(0) by r1 and Mc by r2
                    if length(b) >= Nmin
                        [bv magco stan av me mer me2,  pr] =  bvalca3(b,1);
                        magco = magco + 0.2;    % Add 0.2 to Mc (Tobias)
                        bv2 = fFixbValue;
                        l = bri(:,6) >= magco-0.05;
                        faValue = calc_MaxLikelihoodA(bri(l,:), bv2);
                    else
                        bv = NaN; bv2 = NaN, magco = NaN; av = NaN; faValue = NaN;
                    end
                end
                
                
                % Perform random simulation
                if bRandom
                    nNumberPerNode = length(b);
                    %        [fAverageBValue, fAverageStdDev] = calc_RandomBValue(newa, nNumberPerNode, nRandomRuns);
                    [fStdDevB, fStdDevMc, q1, q2] = calc_BootstrapB(b, nRandomRuns, Nmin);
                else
                    fStdDevB = NaN;
                    fStdDevMc = NaN;
                end
                
            else % of if length(b) >= Nmin
                bv = NaN; bv2 = NaN; stan = NaN; stan2 = NaN; prf = NaN; magco = NaN; av = NaN; faValue = NaN; fStdDevB = NaN; fStdDevMc = NaN;
                b = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
                nX = NaN;
            end
            mab = max(b.Magnitude) ; 
            if isempty(mab); mab = NaN; end
            avg(allcount,:)  = [bv magco x y rd bv2 stan2 av stan faValue ];
            waitbar(allcount/itotal)
        end  % for  newgri
        
        if bRandom
            clear nNumberPerNode q1 q2 fStdDevB fStdDevMc;
        end
        clear bRandom;
        % save data
        %
        drawnow
        gx = xvect;gy = yvect;
        
        catsave3('calc_across');
        close(wai)
        watchoff
        
        save across2.mat ll a tmpgri newgri lat1 lon1 lat2 lon2 ZG.xsec_width_km  avg ra xvect yvect gx gy dx dd ZG.bin_days newa ;
        
        
        % reshape a few matrices
        %
        
        normlap2=nan(length(tmpgri(:,1)),1)
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
        kll = ll;
        % View thea-value map
        view_av2
        
    end
    
    % Load exist b-grid
    if sel == 'lo'
        [file1,path1] = uigetfile(['*.mat'],'a-value gridfile');
        if length(path1) > 1
            think
            load([path1 file1])
            xsecx = newa(:,length(newa(1,:)))';
            xsecy = newa(:,7);
            xvect = gx; yvect = gy;
            tmpgri=zeros((length(xvect)*length(yvect)),2);
            
            normlap2=nan(length(tmpgri(:,1)),1)
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
            
            nlammap
            [xsecx xsecy,  inde] =mysect(ZG.a.Latitude',ZG.a.Longitude',ZG.a.Depth,ZG.xsec_width_km,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            hold on
            plot(newgri(:,1),newgri(:,2),'+k','era','back')
            view_av2
        else
            return
        end
    end
    
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb2=hndl2.Value;
        ;
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2double(freq_field.String);
        freq_field.String=num2str(ni);
        tgl2.Value=0;
        tgl1.Value=1;
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ra=str2double(freq_field0.String);
        freq_field0.String=num2str(ra);
        tgl2.Value=1;
        tgl1.Value=0;
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ri=str2double(freq_field1.String);
        freq_field1.String=num2str(ri);
        tgl2.Value=1;
        tgl1.Value=0;
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(freq_field2.String);
        freq_field2.String=num2str(dx);
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dd=str2double(freq_field3.String);
        freq_field3.String=num2str(dd);
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl2.Value=0;
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl1.Value=0;
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nRandomRuns=str2double(txtRandomRuns.String);
        txtRandomRuns.String=num2str(nRandomRuns);
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        Nmin=str2double(freq_field4.String);
        freq_field4.String=num2str(Nmin);
    end
    
    function callbackfun_011(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fFixbValue=str2double(freq_field4.String);
        freq_field4.String=num2str(fFixbValue);
    end
end
