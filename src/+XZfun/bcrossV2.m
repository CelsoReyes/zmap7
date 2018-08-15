classdef bcrossV2 < ZmapVGridFunction
    % BCROSSV2 calculate b-values along a cross section
    properties
        
        mc_choice    McMethods              = McMethods.MaxCurvature % magnitude of completion method
        wt_auto    LSWeightingAutoEstimate  = true
        mc_auto    McAutoEstimate           = true
    end
    
    properties(Constant)
        PlotTag         = 'bcrossV2'
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            '','',''...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields      = {} % cell array of charstrings, matching into ReturnDetails.Names
        
        ParameterableProperties = []; % array of strings matching into obj.Properties
    end
    
    methods
        function obj=bcrossV2(zap, varargin)
            % BCROSSV2
            % obj = BCROSSV2() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = BCROSSV2(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapVGridFunction(zap, 'b_value');
            
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
            [res,okPressed] = zdlg.Create('B-Value Parameters [xsec]');
            if ~okPressed
                return
            end
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj, res)
            % called when the dialog's OK button is pressed
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
            label='b-value V2[xsec]';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XZfun.bcrossV2(zapFcn()));
        end
    end
end

function bcrossV2_orig(sel)
    % The bvalue in each volume around a grid point will be calculated as well 
    % as the magnitude of completeness
    %   Stefan Wiemer 1/95
    
    report_this_filefun();
    
    
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
        'Position',[ ZG.welcome_pos + [200, -200], 550, 300]);
    axis off
    
    labelList2=['Weighted LS - automatic Mcomp | Weighted LS - no automatic Mcomp '];
    labelPos = [0.2 0.7  0.6  0.08];
    hAutoWt=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2);
    
    
    
    labelList=['Maximum likelihood - automatic Mcomp | Maximum likelihood  - no automatic Mcomp '];
    labelPos = [0.2 0.8  0.6  0.08];
    hMcAutoEst=uicontrol(... % McAutoEstimate
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList);
    
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
        'callback',@cb_go,...
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
    
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seismicity and selectiong the ni neighbors
    % to each grid point
    
    function my_calculation() % 'ca'
        figure(xsec_fig());
        set(gca,'NextPlot','add')
        
        ax=findobj(gcf,'Tag','mainmap_ax');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        
        
        plos2 = plot(x,y,'b-');        % plot outline
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
        
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = newa.DateRange() ;
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
        set(wai,'NumberTitle','off','Name','b-value grid - percent done');
        drawnow
        %
        % loop
        
        
        % overall b-value
        [bv] =  bvalca3(newa.Magnitude,ZG.UseAutoEstimate);
        overall_b_value = bv;
        ZG.overall_b_value = bv;
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
            if b.Count >= 50
                % call the b-value function
                [bv, magco, stan, av, pr] =  bvalca3(b.Magnitude,ZG.UseAutoEstimate, overall_b_value);
                l2 = sort(l);
                b2 = b;
                if wt_auto
                    l = b.Magnitude >= magco;
                    b2 = b(l,:);
                end
                [bv2] = calc_bmemag(b2.Magnitude, 0.1);
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
        catsave3('bcrossV2_orig');
        
        close(wai)
        watchoff
        
        % reshape a few matrices
        %
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap2(ll)= bvg(:,1);
        valueMap=reshape(normlap2,length(yvect),length(xvect));
        
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
        
        old = valueMap;
        
        % View the b-value map
        view_bv2([],valueMap)
        
    end
    
    % Load exist b-grid
    function my_load()
        load_existing_bgrid_version_A
    end
    
    
    function callbackfun_003(mysrc,myevt)
        ra=str2double(mysrc.String);
    end
    
    function callbackfun_004(mysrc,myevt)
        dx=str2double(mysrc.String);
    end
    
    function callbackfun_005(mysrc,myevt)
        dd=str2double(mysrc.String);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function cb_go(mysrc,myevt)

        mc_auto = hMcAutoEst.Value; % McAutoEstimate
        wt_auto = hAutoWt.Value; % LSWeightinghAutoEstimate
        close;
        my_calculate();
    end
end
