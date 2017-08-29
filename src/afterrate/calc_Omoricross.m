function calc_Omoricross()
    % Calculate Omori parameters on cross section using different choices for Mc
    % Data is displayed with view_Omoricross.m
    %
    % J. Woessner
    % last update: 20.10.04
    ZG=ZmapGlobal
    report_this_filefun(mfilename('fullpath'));
    wCat='a'; % working catalog name
    
    myvalues=table;
    myvalues.Properties.Description='Omori cross-section parameters';
    mygrid=ZG.calcgrid;
    
    % Set the grid parameter
    % initial values
    %
    ZG.inb2 = 1;
    dd = 1.00; % Depth spacing in km
    dx = 1.00 ; % X-Spacing in km
    ni = 100;   % Number of events
    bv2 = NaN;
    Nmin = 50;  % Minimum number of events
    bGridEntireArea = 0;
    time = 100; % days
    timef= 0; % No forecast done, but needed for functions
    bootloops = 50;
    ra = 5;
    fMaxRadius = 5;
    fBinning = 0.1;
    
    % cut catalog at mainshock time:
    l = ZG.(wCat).Date > ZG.maepi.Date(1);
    ZG.(wCat)=ZG.(wCat).subset(l);
    
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
    labelList2=[' Fixed Mc (Mc = Mmin) | Automatic Mc (max curvature) | EMR-method'];
    hndl2=uicontrol(...
        'Style','popup',...
        'Units','normalized','Position',[ 0.2 0.8  0.6  0.08],...
        'String',labelList2,...
        'BackgroundColor','w',...
        'callback',@callbackfun_001);
    
    % Set selection to 'Fix Mc'
    set(hndl2,'value',1);
    
    % Edit fields, radiobuttons, and checkbox
    ni_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .70 .12 .08],...
        'String',num2str(ni),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_002);
    
    ra_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .60 .12 .08],...
        'String',num2str(ra),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_003);
    
    dx_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .40 .12 .08],...
        'String',num2str(dx),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_004);
    
    dd_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .30 .12 .08],...
        'String',num2str(dd),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_005);
    
    time_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.68 .40 .12 .080],...
        'String',num2str(time),...
        'callback',@callbackfun_006);
    
    bootloops_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.68 .60 .12 .080],...
        'String',num2str(bootloops),...
        'callback',@callbackfun_007);
    
    maxradius_field=uicontrol('Style','edit',...
        'Units','normalized','Position',[.68 .70 .12 .080],...
        'String',num2str(fMaxRadius),...
        'callback',@callbackfun_008);
    
    tgl1 = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','radiobutton',...
        'string','Number of events:',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'Units','normalized','Position',[.02 .70 .28 .08], 'callback',@callbackfun_009);
    
    % Set to constant number of events
    set(tgl1,'value',1);
    
    tgl2 =  uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','radiobutton',...
        'string','Constant radius [km]:',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'Units','normalized','Position',[.02 .60 .28 .08], 'callback',@callbackfun_010);
    
    nmin_field =  uicontrol('Style','edit',...
        'Units','normalized','Position',[.30 .20 .12 .08],...
        'String',num2str(Nmin),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_011);
    
    chkGridEntireArea = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','checkbox',...
        'string','Create grid over entire area',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'Units','normalized','Position',[.02 .06 .40 .08], 'Units','normalized', 'Value', 0);
    
    % Buttons
    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized','Position', [.80 .05 .15 .12], ...
        'Callback', 'close;done', 'String', 'Cancel');
    
    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized','Position', [.60 .05 .15 .12], ...
        'Callback',@callback_ok,...
        'String', 'OK');
    
    % Labels
    text('Units', 'normalized', ...
        'Position', [0.2 1 0], 'HorizontalAlignment', 'left',...
        'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Please select a Mc estimation option');
    
    text('Units', 'normalized', ...
        'Position', [-.14 .42 0], 'HorizontalAlignment', 'left', ...
        'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String','Horizontal spacing [km]:');
    
    text('Units', 'normalized', ...
        'Position', [-0.14 0.30 0], 'HorizontalAlignment', 'left', ...
        'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Depth spacing [km]:');
    
    text('Units', 'normalized', ...
        'Position', [-0.14 0.18 0],'HorizontalAlignment', 'left', ...
        'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Min. number of events:');
    
    text(...
        'Position',[0.42 0.43 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Learning period:');
    
    text(...
        'Position',[0.42 0.66 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Bootstrap samples:');
    
    text(...
        'Position',[0.42 0.78 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Max. Radius /[km]:');
    
    set(gcf,'visible','on');
    watchoff
    
    function my_calculate() % 'ca'
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
                'gon. Use the RIGHT mouse button for   '
                'the final point.                      '
                'Mac Users: Use the keyboard "p" more  '
                'point to select, "l" last point.      '
                '                                      '];
            zmap_message_center.set_message('Select Polygon for a grid',messtext);
            
            
            ax = findobj('Tag','main_map_ax');
            [x,y, mouse_points_overlay] = select_polygon(ax);
            zmap_message_center.set_info('Message',' Thank you .... ')
        end % of if bGridEntireArea
        
        % CREATE THE GRID (NEW WAY)
        mygrid = ZmapGrid('omoricross',min(x),dx,max(x),min(y),dy,max(y),'km');
        mygrid = mygrid.MaskWithPolygon(x,y);
        mygrid.plot();
        ll=mygrid.ActivePoints; % holdover.
        
        if tgl1
            % get ni closest events
            gridcats = mygrid.associateWithEvents(ZG.newa,fMaxRadius,ni,min(ZG.maepi.Date),[]);
        else
            % get events within ra
            gridcats = mygrid.associateWithEvents(ZG.newa,ra,[],min(ZG.maepi.Date),[]);
        end
        
        % Set itotal for waitbar
        itotal = length(mygrid);
        
        
        % loop over  all points
        mCross = []; % NaN(length(newgri),20);
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Omori grid - percent done');
        drawnow
        
        % if fixed magnitude of completeness, request from user
        if ZG.inb2 == 1
            def = {'1.5'};
            lines = 1;
            title = ['Fixed Mc input'];
            prompt = {'Enter Mc: '};
            answer  = inputdlg(prompt,title,lines,def);
            fMcFix = str2double(answer{1});
        end
        
        mCross=nan(numel(gridcats),20);
        % Loop over grid nodes
        for i= 1:numel(gridcats)
            % Grid coordinates
            allcount = allcount + 1.;
            
            b = gridcats(i);  %already subset by date and radius/number events
            
            if ZG.inb2 == 1
                fMc = fMcFix;
            elseif ZG.inb2 == 2 %Maximum curvature
                nMethod = 1;
            else % ZG.inb2 == 3 % EMR method
                nMethod = 6;
                [fMc] = calc_Mc(b, nMethod, fBinning); % if this fails, once defaulted to nan.. but it shouldn't fail. right?
            end % END if ZG.inb2
            
            
            % for some reason this was only associatdd with radius
            if ~isnan(fMc)
                b=b.subset(b.Magnitude >= fMc);
            end
            
            
            fMaxDist = max(b.epicentralDistanceTo(mygrid.X(i),mygrid.Y(i)));
            
            %Set catalog after selection
            ZG.newt2 = b; %WHY? probably delete this
            % Number of events per gridnode
            nY=b.Count;
            
            
            % Calculate the relative rate change, p, c, k, resolution
            if length(b) >= Nmin  % enough events?
                nMod = 1; % Single Omori law
                [mResult] = calc_Omoriparams(b,time,timef,bootloops,ZG.maepi,nMod);
                
                % Result matrix
                mCross(i,:) = [mResult.pval1 mResult.pmeanStd1 mResult.cval1 mResult.cmeanStd1...
                    mResult.kval1 mResult.kmeanStd1 mResult.nMod nY fMaxDist...
                    mResult.pval2 mResult.pmeanStd2 mResult.cval2 mResult.cmeanStd2 mResult.kval2 mResult.kmeanStd2 mResult.H...
                    mResult.KSSTAT mResult.P mResult.fRMS fMc];
            else
                if isempty(fMaxDist)
                    fMaxDist = NaN;
                end
                mCross(i,:) = [NaN NaN NaN NaN NaN NaN NaN nY fMaxDist NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN fMc];
            end
            waitbar(allcount/itotal)
        end  % for newgr
        
        drawnow
        
        catsave3('calc_Omoricross')
        
        close(wai)
        watchoff
        
        myvalues = array2table(mCross,'VariableNames',...
            {'p-value',... mPval, p-Value
            'p-value std',... mPvalstd, p-value standard deviation
            'c-value',... mCval, c-value 
            'c-value std',...mCvalstd, c-value standard deviation
            'k-value',... mKval, k-value
            'k-value std',... mKvalstd, k-value standard deviation
            'model',... mMod, Chosen fitting model
            'Number of Events',...mNumevents, Number of events per grid node
            'Radius [km]',... vRadiusRes,  Radii of chosen events, Resolution
            'p-value2',... mPval, p-Value2 UNUSED(?)
            'p-value2 std',... mPvalstd, p-value2 standard deviation UNUSED(?)
            'c-value2',... mCval, c-value2  UNUSED(?)
            'c-value2 std',...mCvalstd, c-value2 standard deviation UNUSED(?)
            'k-value2',... mKval, k-value UNUSED(?)
            'k-value2 std',... mKvalstd, k-value standard deviation UNUSED(?)
            'KS-Test H',... mKstestH, KS-Test (H-value) binary rejection criterion at 95% confidence level
            'KS-Test stat',... mKsstat, KS-Test statistic for goodness of fit
            'KS-Test P-value', ...  mKsp, KS-Test p-value
            'RMS', ... mRMS, RMS value for goodness of fit
            'Mc value' ... mMc, Mc value
            });
        
        
        % could also add myvalues.Properties.Description
        % and myvalues.Properties.VariableUnits
        
        
        
        %{
        % Prepare plotting
        normlap2=NaN(length(mygrid),1);
        
        %%% p,c,k- values for period before large aftershock or just modified Omori law
        % p-value
        normlap2(ll)= mCross(:,1);
        mPval=reshape(normlap2,length(yvect),length(xvect));
        
            % and so on... and so on... 
        %}
        % View the map
        view_Omoricross(myvalues, mygrid, 'p-value');
        
    end
    
    function my_save()
        % save myvalues,mygrid,  maybe the catalog, too.
        
    end
    
    % Load existing cross section
    function my_load() % 'lo'
        [file1,path1] = uigetfile(['*.mat'],'Omori parameter cross section');
        if length(path1) > 1
            
            %{ 
             ... was
            load([path1 file1])
            
            normlap2=NaN(length(tmpgri(:,1)),1);
            %%% p,c,k- values for period before large aftershock or just modified Omori law
            % p-value
            normlap2(ll)= mCross(:,1);
            mPval=reshape(normlap2,length(yvect),length(xvect));
            ... etc
            %}
            tmp=load(fullfile(path1, file1));
            myvalues=tmp.myvalues;
            mygrid=tmp.mygrid;
            clear tmp
            
            ... old stuff follows again
            % Initial map set to relative rate change
            re3 = mPval;
            nlammap
            [xsecx, xsecy inde] =mysect(ZG.(wCat).Latitude',ZG.(wCat).Longitude',ZG.(wCat).Depth,ZG.xsec_width_km,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            hold on
            
            % Plot
            view_Omoricross(myvalues, mygrid, 'p-value');
        else
            return
        end
    end
    
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb2=hndl2.Value;
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        update_editfield_value(mysrc);
        ni=mysrc.Value;
        tgl2.Value=0;
        tgl1.Value=1;
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        update_editfield_value(mysrc);
        ra=mysrc.Value;
        tgl2.Value=1;
        tgl1.Value=0;
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        update_editfield_value(mysrc);
        dx=mysrc.Value;
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        update_editfield_value(mysrc);
        dd=mysrc.Value;
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        time_field.Value=str2double(time_field.String);
        time=days(time_field.Value);
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        update_editfield_value(mysrc);
        bootloops=mysrc.Value;
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fMaxRadius=str2double(maxradius_field.String);
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl2.Value=0;
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl1.Value=0;
    end
    
    function callbackfun_011(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        update_editfield_value(mysrc);
        Nmin=mysrc.Value;
    end
    function callback_ok(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl1=tgl1.Value;
        tgl2=tgl2.Value;
        bGridEntireArea = get(chkGridEntireArea, 'Value');
        close
        my_calculate();
    end
end
