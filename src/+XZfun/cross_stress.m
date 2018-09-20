classdef cross_stress < ZmapVGridFunction
    % CROSS_STRESS calculate stress parameters along cross section
    properties
        stress_method = 'michaels' % 1
        
        
    end
    
    properties(Constant)
        PlotTag         = 'stressgrid [xsec]';
        ReturnDetails   = cell2table({ ...
            ...
            'S1Trend',  'S1Trend','';...
            'S1Plunge', 'S1Plunge','';...
            'S2Trend',  'S2Trend','';...
            'S2Plunge', 'S2Plunge','';...
            'S3Trend',  'S3Trend','';...
            'S3Plunge', 'S3Plunge','';...
            'Variance', 'Variance',''...
            }, 'VariableNames', {'Names','Descriptions','Units'});
        
        CalcFields = {...
            'S1Trend',  'S1Plunge',...
            'S2Trend',  'S2Plunge',...
            'S3Trend',  'S3Plunge',...
            'Variance'};
        
        ExtDir = fullfile(ZmapGlobal.Data.hodi, 'external');
        ParameterableProperties = [];
        References="";
    end
    
    methods
        function obj=cross_stress(zap, varargin)
            % CROSS_STRESS
            % obj = CROSS_STRESS() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CROSS_STRESS(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapVGridFunction(zap, 'S1Trend');
            
            report_this_filefun();
            unimplemented_error()
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            %% make the interface
            zdlg = ZmapDialog();
            
            zdlg.AddHeader('Choose stuff');
            zdlg.Create('Name', 'stress parameters [xsec]',obj,'OkFcn', @obj.doIt);
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the values in the grid by sorting the
            % seismicity and selecting the appropriate neighbors to each grid point
            
            
            function out=calculation_function(catalog)
                % calulate values at a single point
            end
        end
        
        function ModifyGlobals(obj)
        end
    end
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='stress map [xsec]';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XZfun.cross_stress(zapFcn()));
        end
    end
end

function cross_stress_orig() 
    % cross_stress_orig creates a grid with spacing dx,dy (in degreees). The size will
    % be selected interactively or on the entire region.
    %
    % Parameters to be calculated:
    % fTS1     : Trend of Maximum compressive principal stress axis
    % fPS1     : Plunge of the Maximum compressive principal stress axis
    % fTS2     : Trend of Intermediate compressive principal stress axis
    % fPS2     : Plunge of the Intermediate compressive principal stress axis
    % fTS3     : Trend of Minimum compressive principal stress axis
    % fPS3     : Plunge of the Minimum compressive principal stress axis
    % fPhi     : Relative magnitude of principal stresses
    % fSigma   : Variance of stress tensor inversion
    %
    % updated: J. Woessner, 08.03.2004
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    ZG = ZmapGlobal.Data;
    
    % Get the grid parameter
    % Set initial values
    dd = 1.00;  % Depth spacing [km]
    dx = 1.00 ; % Horizontal spacing [km]
    ni = 50;   % Constant number of events
    Nmin = 30;  % Minimum number of events
    ra = 3;     % Radius [km]
    fMaxRad = 3;  % Maximum radius [km] in case of constant number of events
    fStrike = 0;  % Strike of fault plane (0-179.9999)
    bGridEntireArea=true;
    save_grid=false;
    load_grid=false;
    % Create interface
    
    
    labelList2=[' Michaels method | sorry, no other option'];
    
    zdlg = ZmapDialog();
    
    zdlg.AddHeader('Stress Variance Parameters');
    zdlg.AddPopup('stress_method', 'stress tensor inversion method:',labelList2,1,...
        'Choose the calculation method for stress tensor inversion');
    zdlg.AddEventSelector('selOpts',obj.EventSelector);
    zdlg.AddGridSpacing('gridOpts',dx,'km',[],[],dd,'km');
    zdlg.AddEdit('fStrike','Strike [deg]',fStrike,'Strike');
    [zparam,okPressed]=zdlg.Create('Name', 'Stress Variance input parameters');
    if ~okPressed
        return
    end

    selOpts=zparam.selOpts;
    gridOpts=zparam.gridOpts;
    fStrike=zparam.fStrike;
    
    useRadius = selOpts.UseEventsInRadius;
    ni=selOpts.NumClosestEvents;
    ra=selOpts.RadiusKm;
    bGridEntireArea = logical(gridOpts.GridEntireArea);
    dd=gridOpts.dz;
    dx=gridOpts.dx;
    save_grid=gridOpts.SaveGrid;
    load_grid=gridOpts.LoadGrid;
    
    my_calculate();
    
    %
    fig=figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off',...
        'units','points',...
        'Visible','on', ...
        'MenuBar','none',...
        'Position',[ ZG.welcome_pos + [200, -200], 650, 300]);
    axis off
    
    labelList2=[' Michaels method | sorry, no other option'];
    labelPos = [0.2 0.77  0.6  0.08];
    
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seismicity and selectiong the ni neighbors
    % to each grid point
    
    function my_calculate()
        figure(xsec_fig());
        set(gca,'NextPlot','add')
        if load_grid == 1
            [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
            if length(path1) > 1
                
                load([path1 file1])
                plot(newgri(:,1),newgri(:,2),'k+')
            end
        elseif (load_grid == 0  &&  bGridEntireArea) % Use entire area for grid
            vXLim = get(gca, 'XLim');
            vYLim = get(gca, 'YLim');
            x = [vXLim(1); vXLim(1); vXLim(2); vXLim(2)];
            y = [vYLim(2); vYLim(1); vYLim(1); vYLim(2)];
            x = [x ; x(1)];
            y = [y ; y(1)];     %  closes polygon
            clear vXLim vYLim;
        else % Interactive gridding
          
            set(gca,'NextPlot','add')
            ax=findobj(gcf,'Tag','mainmap_ax');
            [x,y, mouse_points_overlay] = select_polygon(ax);
            
        end % of if bGridEntireArea
        
        % Plot outline if grid is interactively chosen or when gridding
        % entirely
        if load_grid ~= 1
            % Plot outline
            plos2 = plot(x,y,'b-');
            pause(0.3)
            % Create a rectangular grid
            xvect=[min(x):dx:max(x)];
            yvect=[min(y):dd:max(y)];
            gx = xvect;
            gy = yvect;
            
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
        end % END of load_grid ~= 1
        
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k')
        
        if length(xvect) < 2  ||  length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        if save_grid == 1
            ZmapMessageCenter.set_info('Saving Grid','  ');
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data,'*.mat'), 'Grid File Name?') ;
            vlist = split('newgri dx dy gx gy xvect yvect tmpgri ll dd dx ra ni Nmin fMaxRad tgl1 xsecx xsecy')
            if length(file1) > 1
                save(fullfile(path1,file1),vlist{:})
            end

        end
        
        % Total number of grid points (needed for waitbar)
        itotal = length(newgri(:,1));
        
        
        %  make grid, calculate start- endtime etc.  ...
        %
        % loop over  all points
        %
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Percent done');
        drawnow
        
        % create mResult
        mResult = nan(length(newgri),15);
        
        % Path
        sPath = pwd;
        
        % Path to Stress Inversion program
        hodis = fullfile(ZG.hodi, 'external');
        cd(hodis)
        
        
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
            else  % Take first ni points
                % Set minimum number to constant number of events
                Nmin = ni;
                if b.Count < ni
                    b = b;
                    rd = s(ni); % rd: Maximum distance [km]
                else
                    b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                    rd = s(ni);
                end % Check on length of b
                % Check for maximum radius
                fMaxDist = s(ni);
                if fMaxDist > fMaxRad
                    b = b(1:round(ni/2),:); % This reduces the number so that no computation occurs
                end
            end
            
            % New catalog to work on
            ZG.newt2 = b;
            
            % Number of events in catalog
            fNumEvents = b.Count;
            
            % Check for minimum number of events
            if length(b) >= Nmin
                % Take the focal mechanism from actual catalog
                % tmpi-input: [dip direction (East of North), dip , rake (Kanamori)]
                tmpi = [ZG.newt2(:,10:12)];
                % Take the first thousand FMS (Restriction by slfast.c)
                if length(tmpi(:,1)) >=1000
                    tmpi = tmpi(1:999,:);
                end
                % Create file for inversion
                fid = fopen('data2','w');
                str = ['Inversion data'];
                str = str';
                fprintf(fid,'%s  \n',str');
                fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');
                fclose(fid);
                
                % slick calculates the best solution for the stress tensor according to
                % Michael(1987): creates data2.oput
                switch(computer)
                    % all files were relative to current directory '.'
                    case 'GLNX86'
                        unix([fullfile(ZG.hodi ,'slick_linux'),' data2 ']);
                    case 'MAC'
                        unix([fullfile(ZG.hodi ,'slick_macppc'),' data2 ']);
                    case 'MACI'
                        unix([fullfile(ZG.hodi ,'slick_maci'),' data2 ']);
                    otherwise
                        dos([fullfile(ZG.hodi ,'slick.exe'),' data2 ']);
                end
                
                % Get data from data2.oput
                sFilename = ['data2.oput'];
                [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename)
                
                % Delete existing data2.slboot
                sData2 = fullfile(ZG.hodi, 'external', 'data2.slboot');
                delete(sData2);
                
                % Stress tensor inversion
                switch(computer)
                    case 'GLNX86'
                        unix(fullfile(ZG.hodi, 'external','slfast_linux'),' data2 ');
                    case 'MAC'
                        unix(fullfile(ZG.hodi, 'external','slfast_macpcc'),' data2 ');
                    case 'MACI'
                        unix(fullfile(ZG.hodi, 'external','slfast_maci'),' data2 ');
                    otherwise
                        dos(fullfile(ZG.hodi, 'external','slfast.exe'),' data2 ');
                end
                sGetFile = fullfile(ZG.hodi, 'external', 'data2.slboot');
                load(sGetFile)
                d0 = data2;
                
                % Result matrix containing
                % Phi fTS1 fPS1 fTS2 fPS2 fTS3 fPS3 Variance Resolution
                % Number of events
                mResult(allcount,:) = [d0(2,1:7) d0(1,1) rd fNumEvents fBeta fStdBeta fAvgTau fStdTau fTauFit];
            else
                mResult(allcount,:) = [NaN NaN NaN NaN NaN NaN NaN NaN NaN fNumEvents NaN NaN NaN NaN NaN];
            end % if Nmin
            waitbar(allcount/itotal)
        end  % for  newgri
        close(wai);
        watchoff
        % Back to original directory
        cd(sPath)
        % Compute equivalent angles for fTS1 relative to strike
        [vTS1Rel] = calc_Rel2Strike(fStrike,mResult(:,2));
        
        % Compute equivalent angles for fTS1 relative to north
        vSel = mResult(:,2) < 0;
        mResult(vSel,2) = mResult(vSel,2)+180;
        
        
        % Add vTS1Rel to mResult
        mResult = [mResult vTS1Rel];
        
        % save data
        save Result_Crossstress.mat mResult gx gy dx dy fMaxRad a newa main faults mainfault coastline yvect xvect tmpgri ll newgri ra Nmin dd dx ni ZG.maepi xsecx xsecy tgl1
        %
        drawnow
        gx = xvect;gy = yvect;
        
        % Create output matrix to view results
        normlap2=nan(length(tmpgri(:,1)),1)
        
        % Martix Phi
        normlap2(ll)= mResult(:,1);
        mPhi=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Trend S1
        normlap2(ll)= mResult(:,2);
        mTS1=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Plunge S1
        normlap2(ll) = mResult(:,3);
        mPS1 = reshape(normlap2,length(yvect),length(xvect));
        % Matrix Trend S2
        normlap2(ll)= mResult(:,4);
        mTS2=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Plunge S2
        normlap2(ll) = mResult(:,5);
        mPS2 = reshape(normlap2,length(yvect),length(xvect));
        % Matrix Trend S3
        normlap2(ll)= mResult(:,6);
        mTS3=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Plunge S3
        normlap2(ll) = mResult(:,7);
        mPS3 = reshape(normlap2,length(yvect),length(xvect));
        % Matrix Variance
        normlap2(ll)= mResult(:,8);
        mVariance=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Resolution: km
        normlap2(ll)= mResult(:,9);
        mResolution=reshape(normlap2,length(yvect),length(xvect));
        % Matrix ResolutionL Number of Events
        normlap2(ll)= mResult(:,10);
        mNumber=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Beta
        normlap2(ll)= mResult(:,11);
        mBeta=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Beta standard deviation
        normlap2(ll)= mResult(:,12);
        mBetaStd=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Tau
        normlap2(ll)= mResult(:,13);
        mTau=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Tau Standard deviation
        normlap2(ll)= mResult(:,14);
        mTauStd=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Tau Ratio
        normlap2(ll)= mResult(:,15);
        mTauRatio=reshape(normlap2,length(yvect),length(xvect));
        % Matrix S1 relative to strike
        normlap2(ll) = mResult(:,16);
        mTS1Rel = reshape(normlap2,length(yvect),length(xvect));
        
        lab1 = 'Trend S1';
        valueMap = mTS1;
        old1 = valueMap;
        
        % View results
        view_xstress
    end
    
    function my_load()
        [file1,path1] = uigetfile(['*.mat'],'Load grid and result file');
        if length(path1) > 1
            
            load([path1 file1])
        end
        % Create output matrix to view results
        normlap2=nan(length(tmpgri(:,1)),1);
        
        % Martix Phi
        normlap2(ll)= mResult(:,1);
        mPhi=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Trend S1
        normlap2(ll)= mResult(:,2);
        mTS1=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Plunge S1
        normlap2(ll) = mResult(:,3);
        mPS1 = reshape(normlap2,length(yvect),length(xvect));
        % Matrix Trend S2
        normlap2(ll)= mResult(:,4);
        mTS2=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Plunge S2
        normlap2(ll) = mResult(:,5);
        mPS2 = reshape(normlap2,length(yvect),length(xvect));
        % Matrix Trend S3
        normlap2(ll)= mResult(:,6);
        mTS3=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Plunge S3
        normlap2(ll) = mResult(:,7);
        mPS3 = reshape(normlap2,length(yvect),length(xvect));
        % Matrix Variance
        normlap2(ll)= mResult(:,8);
        mVariance=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Resolution: km
        normlap2(ll)= mResult(:,9);
        mResolution=reshape(normlap2,length(yvect),length(xvect));
        % Matrix ResolutionL Number of Events
        normlap2(ll)= mResult(:,10);
        mNumber=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Beta
        normlap2(ll)= mResult(:,11);
        mBeta=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Beta standard deviation
        normlap2(ll)= mResult(:,12);
        mBetaStd=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Tau
        normlap2(ll)= mResult(:,13);
        mTau=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Tau Standard deviation
        normlap2(ll)= mResult(:,14);
        mTauStd=reshape(normlap2,length(yvect),length(xvect));
        % Matrix Tau Ratio
        normlap2(ll)= mResult(:,15);
        mTauRatio=reshape(normlap2,length(yvect),length(xvect));
        try
            % Matrix S1 relative to strike
            normlap2(ll) = mResult(:,16);
            mTS1Rel = reshape(normlap2,length(yvect),length(xvect));
            lab1 = 'S1 trend [deg]';
            valueMap = mTS1;
            old1 = valueMap;
        catch
        end
        % View results
        view_xstress()
    end
    
end
