function bcross(sel)
    % This subroutine  creates a grid with
    % spacing dx,dy (in degreees). The size will
    % be selected interactively or grids the entire cross section.
    % The b-value in each volume is computed around a grid point containing ni earthquakes
    % or in between a certain radius
    % The standard deviation is calcualted either with the max. likelihood or by bootstrapping, when that box is checked.
    % If not, both options can be assigned by the additional run assignment.
    % Standard deviation of b-value in non-bootstrapping case is calculated from Aki-formula!
    % Org: Stefan Wiemer 1/95
    % last update: J. Woessner, 02.04.2005
    
    % JW: Removed Additional random runs for uncertainty determination since
    % this is incorporated in new functions to determine Mc and B with
    % bootstrapping
    report_this_filefun(mfilename('fullpath'));
    
    global inb1 inb2
    
    % Do we have to create the dialogbox?
    if sel == 'in'
        % Set the grid parameter
        % initial values
        %
        dd = 1.00;
        dx = 1.00 ;
        ni = 100;
        bv2 = NaN;
        Nmin = 50;
        stan2 = NaN;
        stan = NaN;
        prf = NaN;
        av = NaN;
        %nRandomRuns = 1000;
        bGridEntireArea = 0;
        nBstSample = 100;
        fMccorr = 0;
        fBinning = 0.1;
        bBst_button = 0;
        fMcFix = 1.5;
        
        % Get list of Mc computation possibilities
        [labelList2] = calc_Mc;
        % Create the dialog box
        figure_w_normalized_uicontrolunits(...
            'Name','Grid Input Parameter',...
            'NumberTitle','off', ...
            'units','points',...
            'Visible','on', ...
            'Units','normalized','Position',[ ZG.wex+200 ZG.wey-200 550 300], ...
            'Color', [0.8 0.8 0.8]);
        axis off
        
        % Dropdown list
        hndl2=uicontrol(...
            'Style','popup',...
            'Units','normalized','Position',[ 0.2 0.77  0.6  0.08],...
            'String',labelList2,...
            'BackgroundColor','w',...
            'callback',@callbackfun_001);
        
        % Set selection to 'Best combination'
        set(hndl2,'value',1);
        
        % Edit fields, radiobuttons, and checkbox
        freq_field=uicontrol('Style','edit',...
            'Units','normalized','Position',[.30 .60 .12 .10],...
            'String',num2str(ni),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_002);
        
        freq_field0=uicontrol('Style','edit',...
            'Units','normalized','Position',[.80 .60 .12 .10],...
            'String',num2str(ra),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_003);
        
        freq_field2=uicontrol('Style','edit',...
            'Units','normalized','Position',[.30 .40 .12 .10],...
            'String',num2str(dx),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_004);
        
        freq_field3=uicontrol('Style','edit',...
            'Units','normalized','Position',[.30 .30 .12 .10],...
            'String',num2str(dd),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_005);
        
        tgl1 = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
            'Style','radiobutton',...
            'string','Number of events:',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Units','normalized','Position',[.02 .6 .28 .10], 'callback',@callbackfun_006);
        
        % Set to constant number of events
        set(tgl1,'value',1);
        
        % Checkbox and radiobuttons
        tgl2 =  uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','radiobutton',...
            'string','Constant radius [km]:',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Units','normalized','Position',[.52 .60 .28 .10], 'callback',@callbackfun_007);
        
        
        chkGridEntireArea = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
            'Style','checkbox',...
            'string','Create grid over entire area',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'Units','normalized','Position',[.02 .005 .40 .10], 'Value', 0);
        
        chKBst_button = uicontrol('BackGroundColor', [0.8 0.8 0.8],'Style','checkbox',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,'FontWeight','bold','string','Bootstraps:',...
            'Units','normalized','Position',[.52 .3 .28 .10], 'Value', 0);
        
        % Editable fields
        freq_field4 =  uicontrol('Style','edit',...
            'Units','normalized','Position',[.30 .20 .12 .10],...
            'Units','normalized','String',num2str(Nmin),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_008);
        
        freq_field5 =  uicontrol('Style','edit',...
            'Units','normalized','Position',[.80 .30 .12 .10],...
            'String',num2str(nBstSample),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_009);
        
        freq_field6 =  uicontrol('Style','edit',...
            'Units','normalized','Position',[.80 .40 .12 .10],...
            'String',num2str(fMccorr),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_010);
        
        freq_field7 =  uicontrol('Style','edit',...
            'Units','normalized','Position',[.30 .50 .12 .10],...
            'String',num2str(fMcFix),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_011);
        
        freq_field8 =  uicontrol('Style','edit',...
            'Units','normalized','Position',[.80 .50 .12 .10],...
            'String',num2str(fBinning),...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'callback',@callbackfun_012);
        
        uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.80 .005 .15 .12], ...
            'Callback', 'close;done', 'String', 'Cancel');
        
        uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.60 .005 .15 .12], ...
            'Callback', 'inb1=hndl2.Value;tgl1=tgl1.Value;tgl2=tgl2.Value; bBst_button = get(chKBst_button, ''Value''); bGridEntireArea = get(chkGridEntireArea, ''Value'');close,sel =''ca'', bcross(sel)',...
            'String', 'OK');
        
        % Labels
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [0.2 1 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
            'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Please select a Mc estimation option');
        
        text('Color',[0 0 0], 'EraseMode','normal', 'Units', 'normalized', ...
            'Position', [-.14 .54 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String','Fixed Mc:');
        
        text('Color',[0 0 0], 'EraseMode','normal', 'Units', 'normalized', ...
            'Position', [-.14 .42 0], 'HorizontalAlignment', 'left', 'Rotation', 0, ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String','Horizontal spacing [km]:');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [-0.14 0.30 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Depth spacing [km]:');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [-0.14 0.18 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Min. number of events:');
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [0.52 0.42 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Mc correction:');
        
        
        text('Color', [0 0 0], 'EraseMode', 'normal', 'Units', 'normalized', ...
            'Position', [0.52 0.535 0], 'Rotation', 0, 'HorizontalAlignment', 'left', ...
            'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Magnitude binning:');
        
        
        set(gcf,'visible','on');
        watchoff
    end   % if sel == in
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seimicity and selecting the ni neighbors
    % to each grid point
    
    if sel == 'ca'
        
        % Select and reate grid
        [newgri, xvect, yvect, ll] = ex_selectgrid(xsec_fig, dx, dd, bGridEntireArea);
        
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k','era','normal')
        
        
        zmap_message_center.set_info(' ','Running... ');think
        %  make grid, calculate start- endtime etc.  ...
        %
        t0b = min(newa.Date)  ;
        n = newa.Count;
        teb = max(newa.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_days);
        
        % loop over  all points
        % Set size for output matrix
        bvg = NaN(length(newgri),12);
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','b-value grid - percent done');
        drawnow
        itotal = length(newgri(:,1));
        %
        % loop
        %
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            
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
            
            % Number of earthquakes per node
            [nX,nY] = size(b);
            
            %estimate the completeness and b-value
            ZG.newt2 = b;
            
            if length(b) >= Nmin  % enough events?
                % Added to obtain goodness-of-fit to powerlaw value
                mcperc_ca3;
                [fMc] = calc_Mc(b, inb1, fBinning, fMccorr);
                l = b.Magnitude >= fMc-(fBinning/2);
                if length(b(l,:)) >= Nmin
                    [fMeanMag, fBValue, fStd_B, fAValue] =  calc_bmemag(b(l,:), fBinning);
                else
                    %fMc = NaN;
                    fBValue = NaN; fStd_B = NaN; fAValue= NaN;
                end
                
                % Bootstrap uncertainties
                if bBst_button == 1
                    % Check Mc from original catalog
                    l = b.Magnitude >= fMc-(fBinning/2);
                    if length(b(l,:)) >= Nmin
                        [fMc, fStd_Mc, fBValue, fStd_B, fAValue, fStd_A, vMc, mBvalue] = calc_McBboot(b, fBinning, nBstSample, inb1);
                    else
                        %fMc = NaN;
                        %fStd_Mc = NaN;
                        fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A= NaN;
                    end
                else
                    % Set standard deviation ofa-value to NaN;
                    fStd_A= NaN; fStd_Mc = NaN;
                end
                
            else % of if length(b) >= Nmin
                fMc = NaN; fStd_Mc = NaN; fBValue = NaN; fStd_B = NaN; fAValue= NaN; fStd_A = NaN;
                %bv = NaN; bv2 = NaN; stan = NaN; stan2 = NaN; prf = NaN; magco = NaN; av = NaN; av2 = NaN;
                prf = NaN;
                b = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
                nX = NaN;
            end
            mab = max(b.Magnitude) ;
            if isempty(mab)
                mab = NaN;
            end
            
            % Result matrix
            %bvg(allcount,:)  = [bv magco x y rd bv2 stan2 av stan prf  mab av2 fStdDevB fStdDevMc nX];
            bvg(allcount,:)  = [fMc fStd_Mc x y rd fBValue fStd_B fAValue fStd_A prf mab nX];
            waitbar(allcount/itotal)
        end  % for  newgri
        
        drawnow
        gx = xvect;gy = yvect;
        
        catSave3 =...
            [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
            '[file1,path1] = uiputfile([ ''*.mat''], ''Grid Datafile Name?'') ;',...
            'sapa2=[''save '' path1 file1 '' ll a newgri lat1 lon1 lat2 lon2 wi  bvg xvect yvect gx gy dx dd ZG.bin_days newa maex maey maix maiy ''];',...
            ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)
        %corrected window positioning error
        close(wai)
        watchoff
        
        % initialize a few matrices
        [mMc, mStdMc, mRadRes, mBvalue, mStdB, mAvalue, mStdA, Prmap, ro, mNumEq] = deal(NaN(length(yvect), length(xvect)));
        % replace the indexed values within
        
        mMc(ll) = bvg(:,1);         % Mc map
        mStdMc(ll) = bvg(:,2);       % Standard deviation Mc
        mRadRes(ll) = bvg(:,5);     % Radius resolution
        mBvalue(ll) = bvg(:,6);      % b-value
        mStdB(ll) = bvg(:,7);        % Standard deviation b-value
        mAvalue(ll) = bvg(:,8);      % a-value M(0)
        mStdA(ll) = bvg(:,9);        % Standard deviation a-value
        Prmap(ll) = bvg(:,10);       % Goodness of fit to power-law map
        ro(ll) = bvg(:,11);          % Whatever this is
        mNumEq(ll) = bvg(:,12);     % number of events
        
        re3 = mBvalue;
        kll = ll;
        % View the b-value map
        view_bv2([],re3)
        
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
            
            
            normlap2=NaN(length(tmpgri(:,1)),1); % no longer used(?)
            % initialize a few matrices
            [mMc, mStdMc, mRadRes, mBvalue, mStdB, mAvalue, mStdA, Prmap, ro, mNumEq] = deal(NaN(length(yvect), length(xvect)));
            % replace the indexed values within
            
            mMc(ll) = bvg(:,1);         % Magnitude of completness
            mStdMc(ll) = bvg(:,2);       % Standard deviation Mc
            mRadRes(ll) = bvg(:,5);     % Radius resolution
            mBvalue(ll) = bvg(:,6);      % b-value
            mStdB(ll) = bvg(:,7);        % Standard deviation b-value
            mAvalue(ll)= bvg(:,8);      % a-value M(0)
            mStdA(ll) = bvg(:,9);        % Standard deviation a-value
            Prmap(ll) = bvg(:,10);       % Goodness of fit to power-law map
            ro(ll) = bvg(:,11);          % Whatever this is
            mNumEq(ll) = bvg(:,12);     % number of events
            
            re3 = mBvalue;
            
            nlammap
            [xsecx xsecy,  inde] =mysect(ZG.a.Latitude',ZG.a.Longitude',ZG.a.Depth,wi,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            hold on
            plot(newgri(:,1),newgri(:,2),'+k','era','back')
            view_bv2([],re3)
        else
            return
        end
    end
    
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inb2=hndl2.Value;
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
        tgl2.Value=0;
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl1.Value=0;
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        Nmin=str2double(freq_field4.String);
        freq_field4.String=num2str(Nmin);
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nBstSample=str2double(freq_field5.String);
        freq_field5.String=num2str(nBstSample);
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fMccorr=str2double(freq_field6.String);
        freq_field6.String=num2str(fMccorr);
    end
    
    function callbackfun_011(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fMcFix=str2double(freq_field7.String);
        freq_field7.String=num2str(fMcFix);
    end
    
    function callbackfun_012(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fBinning=str2double(freq_field8.String);
        freq_field8.String=num2str(fBinning);
    end
    
end