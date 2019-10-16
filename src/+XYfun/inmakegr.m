classdef inmakegr < ZmapHGridFunction
    properties
        depth_km  double
    end
    properties(Constant)
        ReturnDetails   = cell2table({... VariableNames, VariableDescriptions, VariableUnits
            'nEvents_top',      'number of events in top layer','';...
            'mean_mag_top',     'mean magnitude of events in top layer','mag';...
            'nEvents_bottom',   'number of events in bottom layer','';...
            'mean_mag_bottom',  'mean magnitude of events in bottom layer','mag';...
            'ratio',            'number of events in top to bottom',''...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        % CalcFields is the label for each column coming out of the Calculate function
        % and should match items first column of ReturnDetails
        CalcFields = {'nEvents_top', 'mean_mag_top', 'nEvents_bottom', 'mean_mag_bottom'};
        
        ParameterableProperties = "depth_km";
            
        PlotTag      = 'inmakegr';
        References = "";
    end
    
    methods
        function obj=inmakegr(zap, varargin)
            obj@ZmapHGridFunction(zap, 'shallow_mag');
            report_this_filefun();
            obj.parseParameters(varargin);
            warning('ZMAP:unimplemented','apparently still broken');
                
            obj.StartProcess();
        end
    end
end

function orig_inmakegr(catalog) 
    % This subroutine assigns Parameter values for the grid
    % which is used to calculate a Max Z value map.
    % dx, dy is the grid spacing in degrees.
    % For each one of the grid points, Ni events are counted.
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    % initial values
    %
    dx = 1.00;
    dy = 1.00 ;
    ni = 100;
    
    %
    % make the interface
    %
    fig=figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'MenuBar','none',...
        'Position',[ ZG.welcome_pos + [200, -200], 650, 250]);
    axis off
    
    zdlg = ZmapDialog();
    zdlg.AddDurationEdit('ts', 'Time step', ZG.bin_dur,'time step in days',@days);
    zdlg.AddEventSelector('evsel', obj.EventSelector);
    
    text(...
        'Position',[0. 0.20 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time steps in days:');
    
    uicontrol('Style','edit',...
        'Position',[.60 .20 .22 .10],...
        'Units','normalized','String',num2str(days(ZG.bin_dur)),...
        'callback',@cb_bindur);
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized', 'Callback', @callbackfun_cancel,'String','Cancel');
    
    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_gomakegr,...
        'String','ZmapGrid');
    
    go_button2=uicontrol('Style','Pushbutton',...
        'Position',[.40 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_genasgrid,...
        'String','GenasGrid');
    
    set(gcf,'visible','on');
    watchoff
    
    function makegrid() 
        %
        %   This .m file creates a rectangular grid and calculates the
        %   cumulative number curve at each grid point. The grid is
        %   saved in the file "cumugrid.mat".
        %                        Operates on catalogue "primeCatalog"
        %
        % define size of the area
        %
        % ________________________________________________________________________
        %  Please use the left mouse button or the cursor to select the lower
        %  left corner of the area of investigation. Please use the left
        %  mouse again to select the upper right corner. The calculation might take
        %  some time. This time can be reduced by using a smaller area and/or
        %  a larger grid-spacing! The amount of calculation done will be displayed
        %  in percent of the total time.
        %
        %_________________________________________________________________________
        % turned into function by Celso G Reyes 2017
        
        txt= ['Please wait until cursor changes to a CROSS and select the edges',...
            'of a polygon on the map (using the left mouse buton).',...
            'Mac Users: Use the character "p" on your      ',...
            'keyboard. Use the right mouse button to select ',...
            'the final point (or charcter "l")'  ];
        infodlg(txt);
        ZG=ZmapGlobal.Data; % used by get_zmap_globals
        
        report_this_filefun();
        
        selgp
        
        itotal = length(newgri(:,1));
        if length(gx) < 2  ||  length(gy) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        try close(gpf); end
        try close(gh); end
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = bounds(catalog.Date) ;
        n = catalog.Count;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        cumu = zeros(length(t0b:days(ZG.bin_dur):teb)+2);
        ncu = length(cumu);
        cumuall = zeros(ncu,length(newgri(:,1)));
        loc = zeros(3,length(newgri(:,1)));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        allcount = 0.;
        %
        % loop for all grid points
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Makegrid - Percent completed');
        drawnow
        cvg = [];
        
        for i= 1:length(newgri(:,1))
            
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            i2 = i2+1;
            % calculate distance from center point and sort wrt distance
            %
            l=catalog.epicentralDistanceTo(y,x);
            [s,is] = sort(l);
            b = catalog.selectClosestEvents(y,x,ni) ;       % re-orders matrix to agree row-wise
            
            cumu = cumu * 0;
            % time (bin) calculation
            n = b.Count;
            cumu = histogram(b.Date(1:n), t0b:ZG.bin_dur:teb);
            cumu2 = cumsum(cumu);
            %calcsimp
            %cvg = [cvg ; cv rcv];
            % end
            
            l = sort(l);
            cumuall(:,allcount) = [cumu';  x; l(ni)];
            loc(:,allcount) = [x ; y; l(ni)];
            
            waitbar(allcount/itotal)
            
        end  % for x0
        
        %
        % save data
        %
        %  set(txt1,'String', 'Saving data...')
        close(wai)
        drawnow
        %save cumugrid.mat cumuall ZG.bin_dur ni dx dy gx gy tdiff t0b teb loc
        
        catsave3('makegrid');
        
        watchoff
        zmapmenu()
        return
        
        figure(mess);
        clf
        set(gca,'visible','off')
        
        te = text(0.01,0.95,'The cumulative number array \newlinehas been saved in \newlinefile cumugrid.mat \newlinePlease rename it \newlineto protect if from overwriting.');
        set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        
        uicontrol('Units','normal','Position',...
            [.7 .10 .2 .12],'String','Options ', 'callback',@(~,~)zmapmenu)
        
        uicontrol('Units','normal','Position',...
            [.3 .10 .2 .12],'String','Back', 'Callback',@(~,~)close())
        
        return
        
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap2(ll)= cvg(:,1);
        valueMap=reshape(normlap2,length(yvect),length(xvect));
        Prmap = valueMap;
        old1 = valueMap;
        view_bva(lab1,valueMap);
    end
    
    function cb_bindur(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.bin_dur = days(str2double(mysrc.String));
    end
    
    function callbackfun_cancel(mysrc,myevt)
        close;
    end
    
    function callbackfun_gomakegr(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        % TODO maybe set dx,dy,ni, or load grid here?
        makegrid();
    end
    
    function callbackfun_genasgrid(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=gridOpt.dx;
        dy=gridOpt.dy;
        ni=selOpt.Ni;
        if gridOpt.LoadGrid
            loadgrid
        end
        close;
        
        genascum();
    end
    
end
