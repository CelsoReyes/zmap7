function [sel] = bpvalgrid()
    % This subroutine assigns creates a grid with
    % spacing dx,dy (in degreees). The size will
    % be selected interactively. The b-value and p-value in each
    % volume around a grid point containing between Nmin and ni earthquakes
    % will be calculated as well as the magnitude of completness.
    %   Stefan Wiemer 1/95
    %
    %For the execution of this program, the "Cumulative Window" should have been opened before.
    %Otherwise the matrix "ZG.maepi", used by this program, does not exist.
    
    global minThreshMag
    
    % TOFIX ll isn't guaranteed to be here. it is the index of the events within the polygon
    ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));

    minThreshMag = min(ZG.a.Magnitude);
    
    % get the grid parameter
    % initial values
    
    % cut catalog at mainshock time:
    l = ZG.a.Date > ZG.maepi.Date(1);
    ZG.newt2 = ZG.a.subset(l);
    
    % cut cat at selected magnitude threshold
    l = ZG.newt2.Magnitude >= minThreshMag;
    ZG.newt2 = ZG.newt2.subset(l);
    
    ZG.hold_state2=true;
    timeplot(ZG.newt2)
    ZG.hold_state2=false;
    
    dx = 0.025;
    dy = 0.025;
    ni = 150;
    Nmin = 100;
    
    %The definitions in the following line were present in the initial bvalgrid.m file.
    %stan2 = nan; stan = nan; av = nan;
    
    % make the interface
    createGui(dx, dy, ni, Nmin)
    
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % thge seimicity and selectiong the ni neighbors
    % to each grid point
    
    function my_calculate()
        %In the following line, the program selgp.m is called, which creates a rectangular grid from which then selects,
        %on the basis of the vector ll, the points within the selected poligon.
        
        % get new grid if needed
        if load_grid
            [file1,path1] = uigetfile('*.mat','previously saved grid');
            if length(path1) > 1
                think
                load([path1 file1])
            end
            plot(newgri(:,1),newgri(:,2),'k+')
        elseif ~(load_grid ==0  || prev_grid)
            selgp
            if length(gx) < 4  ||  length(gy) < 4
                errordlg('Selection too small! (Dx and Dy are in degreees! ');
                return
            end
        elseif prev_grid
            plot(newgri(:,1),newgri(:,2),'k+')
        end
        
        gll = ll;
        
        if save_grid
            zmap_message_center.set_info('Saving Grid','  ');
            think;
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Grid File Name?') ;
            gs = ['save ' path1 file1 ' newgri dx dy gx gy xvect yvect newgri ll'];
            if length(file1) > 1
                eval(gs);
            end
            done;
        end
        
        %   selgp
        itotal = length(newgri(:,1));
        
        prompt = {'If you wish a fixed c in Omori formula, please enter a negative value'};
        title = 'Input parameter';
        lines = 1;
        valeg2 = 2;
        def = {num2str(valeg2)};
        answer = inputdlg(prompt,title,lines,def);
        valeg2=str2double(answer{1});
        
        if valeg2 <= 0
            prompt = {'Enter c'};
            title = 'Input parameter';
            lines = 1;
            CO = 0;
            def = {num2str(CO)};
            answer = inputdlg(prompt,title,lines,def);
            CO=str2double(answer{1});
        end
        zmap_message_center.set_info(' ','Running... ');think
        %  make grid, calculate start- endtime etc.  ...
        %
        t0b = min(ZG.a.Date)  ;
        n = ZG.a.Count;
        teb = max(ZG.a.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        bpvg = [];
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','bp-value grid - percent done');
        drawnow
        %
        % overall b-value
        [bv, magco, stan, av, me, mer, me2, pr] =  bvalca3(ZG.a,ZG.inb1);
        ZG.bo1 = bv;
        no1 = ZG.a.Count;
        
        % loop over all points
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            i2 = i2+1;
            
            if tgl1 == 0   % take point within r
                b = selectRadius(obj, y, x, ra);
                rd = ra;
            else
                [b, max_km] = selectClosestEvents(obj, y, x, [], ni);
                rd = max_km;
                
            end
            
            
            %estimate the completeness and b-value
            ZG.newt2 = b;
            num_atnode = ZG.newt2.Count();
            return_nans = true;
            if length(b) >= Nmin  % enough events?
                switch ZG.inb1
                    
                    case 1
                        [bv, magco, stan, av, me, mer, me2,  pr] =  bvalca3(b,1);
                        maxcat = b.subset(b.Magnitude >= magco-0.05);
                        if maxcat.Count()  >= Nmin
                            [magnm, bv2, stan2,  av2] =  bmemag(maxcat);
                            maxmg = max(maxcat.Magnitude);
                            [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                            return_nans = false;
                        end
                        
                    case 2
                        [bv, magco, stan, av, me, mer, me2,  pr] =  bvalca3(b,2);
                        [magnm, bv2, stan2,  av2] =  bmemag(b);
                        maxcat = b(l,:); % TOFIX there is no l here.
                        maxmg = max(maxcat(:,6));
                        [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(b.subset(l),'days',valeg2,CO,minThreshMag);
                        return_nans = false;
                        
                    case 3
                        [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
                        maxcat = b.subset(b.Magnitude >= Mc90-0.05)
                        magco = Mc90;
                        if maxcat.Count()  >= Nmin
                            [bv, magco0, stan, av, me, mer, me2,  pr] =  bvalca3(maxcat,2);
                            [magnm, bv2, stan2,  av2] =  bmemag(maxcat);
                            maxmg = max(maxcat.Magnitude);
                            [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                            return_nans = false;
                        end
                        
                    case 4
                        [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
                        maxcat= b.subset(b.Magnitude >= Mc95-0.05);
                        magco = Mc95;
                        if maxcat.Count() >= Nmin
                            [bv, magco0, stan, av, me, mer, me2,  pr] =  bvalca3(maxcat,2);
                            [magnm, bv2, stan2,  av2] =  bmemag(maxcat);
                            maxmg = max(maxcat.Magnitude);
                            [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                            return_nans = false;
                        end
                    case 5
                        [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
                        if ~isnan(Mc95)
                            magco = Mc95;
                        elseif ~isnan(Mc90)
                            magco = Mc90;
                        else
                            [bv, magco, stan, av, me, mer, me2, pr] =  bvalca3(b,1);
                        end
                        maxcat= b.subset(b.Magnitude >= magco-0.05);
                        if maxcat.Count()  >= Nmin
                            [bv, magco0, stan, av, me, mer, me2,  pr] =  bvalca3(maxcat,2);
                            maxmg = max(maxcat.Magnitude);
                            [magnm, bv2, stan2,  av2] =  bmemag(maxcat);
                            [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                            return_nans = false;
                        end
                    otherwise
                        error('invalid number for ZG.inb1')
                end %switch
                
            else
                return_nans = true;
            end
            
            if return_nans
                [bv, bv2, magco, av, av2, stan2, stan, pv, pstd, maxmg, pr, cv, cstd, kv, mmav, mbv, kstd] = deal(nan);
            end
            
            bpvg = [bpvg ; bv magco x y rd bv2 stan2 av stan prf pv pstd maxmg cv tgl1 mmav kv mbv num_atnode];
            %bpvg = [bpvg ; bv magco x y rd bv2 stan2 av stan prf pv pstd maxmg pr];
            
            waitbar(allcount/itotal)
        end  % for newgr
        %save cnssgrid.mat
        %quit
        % save data
        %
        try
            zmap_message_center.set_info('Save Grid','  ');
            think;
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'), 'Grid Datafile Name?') ;
            sapa2 = ['save ' path1 file1 ' bpvg gx gy dx dy ZG.bin_dur tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll ZG.bo1 newgri gll'];
            if length(file1) > 1
                eval(sapa2)
            end
            done;
        catch
            error('problem saving bgrid')
        end
        close(wai)
        watchoff
        
        % plot the results
        % old and re3 (initially ) is the b-value matrix
        %
        gridstats = array2gridstats(pbvg, ll);
        gridstats.re3 = gridstats.pvalg;
        lab1 = 'p-value';
        
        % View the b-value and p-value map
        view_bpva(lab1,gridstats.re3)
        
    end
    
    function my_load()
        % Load exist b-grid
        [file1,path1] = uigetfile('*.mat','b-value gridfile');
        if length(path1) > 1
            think
            gridstats=load_existing_bgrid(fullfile(path1, file1));
            view_bpva(lab1,gridstats.re3)
        else
            return
        end
    end
    
    function createGui(dx, dy, ni, Nmin)
        % make the interface
        
        % creates a dialog box to input grid parameters
        %
        %% UI Parts
        % ComputationMethod (popup)
        % plot in current figure (checkbox)
        % use:number of events (radio)
        %     number of events (edit)
        % use: radius (radio)
        %     redius (edit)
        %
        % load grid (button)
        % save grid (button)
        %
        
        figure_w_normalized_uicontrolunits(...
            'Name','Grid Input Parameter',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'units','points',...
            'Visible','off', ...
            'Position',[ ZG.wex+200 ZG.wey-200 650 250]);
        axis off
        
        
        
        labelList2={'Automatic Mcomp (max curvature)',...
            'Fixed Mc (Mc = Mmin)',...
            'Automatic Mcomp (90% probability)',...
            'Automatic Mcomp (95% probability)',...
            'Best (?) combination (Mc95 - Mc90 - max curvature)',...
            'Constant Mc'};
        labelPos = [0.2 0.8  0.6  0.08];
        
        text(...
            'Position',[0.10 0.98 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String','Please choose an Mc estimation option   ');
        
        uicontrol('Style','popup',...
            'Position',labelPos,...
            'Units','normalized',...
            'String',labelList2,...
            'callback',@callbackfun_001,...
            'Tag','hndl2',...
            'Value',5);
        
        
        % creates a dialog box to input grid parameters
        
        oldfig_button = uicontrol('Style','checkbox','string','Plot in Current Figure',...
            'BackGroundColor',[.60 .92 .84], ...
            'Position',[.78 .52 .20 .08],...
            'Units','normalized',...
            'Tag','oldfig_button');
        
        set(oldfig_button,'Value',1);
        
        
        freq_field=uicontrol('Style','edit','String',num2str(ni),...
            'Position',[.30 .60 .12 .08],...
            'Units','normalized',...
            'callback',@callbackfun_002);
        
        
        freq_field0=uicontrol('Style','edit','String',num2str(ra),...
            'Position',[.30 .50 .12 .08],...
            'Units','normalized',...
            'callback',@callbackfun_003);
        
        freq_field2=uicontrol('Style','edit','String',num2str(dx),...
            'Position',[.30 .40 .12 .08],...
            'Units','normalized',...
            'callback',@callbackfun_004);
        
        freq_field3=uicontrol('Style','edit','String',num2str(dy),...
            'Position',[.30 .30 .12 .080],...
            'Units','normalized',...
            'callback',@callbackfun_005);
        
        rgroup1 = uibuttongroup('Title','event grouping','Position',[0.05 0.48 0.25 0.25]);
        rgroup2 = uibuttongroup('Title','grid source','Position',[.48 0.3 0.28 0.39]);
        
        tgl1 = uicontrol(rgroup1,'Style','radiobutton',...
            'string','Number of Events:',...
            'Position',[.08 .6 .9 .35],...[.05 .60 .2 .0800],...
            'Units','normalized', 'Tag', 'tgl1');
        
        set(tgl1,'Value',1);
        
        tgl2 =  uicontrol(rgroup1,'Style','radiobutton','string','Constant Radius:',...
            'Position',[0.08 0.1 .9 .35],...
            ...'Position',[.05 .50 .2 .080],...
            'Units','normalized', 'Tag', 'tgl2');
        
        create_grid =  uicontrol(rgroup2,'Style','radiobutton','string','Calculate a new grid',...
            'Position',[.05 .7 .8 .25],...[.55 .55 .2 .080],...
            'Units','normalized', 'Tag', 'create_grid');
        
        set(create_grid,'value',1);
        
        prev_grid =  uicontrol(rgroup2,'Style','radiobutton','string','Reuse the previous grid',...
            'Position',[.05 .4 .8 .25],...[.55 .45 .2 .080],...
            'Units','normalized', 'Tag', 'prev_grid');
        
        
        load_grid =  uicontrol(rgroup2,'Style','radiobutton','string','Load a saved grid',...
            'Position',[.05 .1 .8 .25],...[.55 .35 .2 .080],...
            'Units','normalized', 'Tag', 'load_grid');
        
        save_grid =  uicontrol('Style','checkbox','string','Save selected grid to file',...
            'Position',[.55 .22 .2 .080],...
            'Units','normalized', 'Tag', 'save_grid');
        
        uicontrol('Style','edit','String',num2str(Nmin),...
            'Position',[.30 .20 .12 .080],...
            'Units','normalized',...
            'callback',@callbackfun_006);
        
        
        close_button=uicontrol('Style','Pushbutton','String','Cancel',...
            'Position',[.60 .05 .15 .12 ],...
            'Units','normalized','callback',@callbackfun_007);
        
        go_button1=uicontrol('Style','Pushbutton','String','Go',...
            'Position',[.20 .05 .15 .12 ],...
            'Units','normalized',...
            'Callback',@go_callback);
        
        text('String',' Grid Parameter',...
            'Position',[0.30 0.75 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l);
        text(...
            'Position',[-0.1 0.4 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'String','Spacing in x (dx) in deg:');
        
        text(...
            'Position',[-0.1 0.3 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'String','Spacing in y (dy) in deg:');
        
        text(...
            'Color',[0 0 0 ],...
            'Position',[-0.1 0.18 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'String','Min. No. of events > Mc:');
        
        %
        %
        set(gcf,'visible','on');
        watchoff
    end
    
    function gridstats = array2gridstats(pbvg, ll)
        % move from the array bpvg to the gridstats struct
        % ll is some sort of mask/index (points within the polygon)
        
        % pbvg columns
        fields_and_representations = {'re3', 1;
            'old1', 2;
            'r',5;
            'meg', 6;
            'pro', 7;
            'avm', 8;
            'stanm', 9;
            'Prmap', 10;
            'pvalg',11;
            'pvstd',12;
            'maxm',13;
            'cmap2',14};
        
        normlap2=nan(length(tmpgri(:,1)),1);
        
        reshaper = @(x) reshape(x,length(yvect),length(xvect));
        
        for i=1:length(fields_and_representations)
            fldnum = fields_and_representations{i,2};
            fldnam = fields_and_representations{i,1};
            normlap2(ll)= bpvg(:,fldnum);
            gridstats.(fldnam) = reshaper(normlap2);
            
        end
        
        gridstats.old = gridstats.re3;
    end
    
    function gridstats = load_existing_bgrid(fn)
        load(fn)
        gridstats = array2gridstats(pbvg, ll);
    end
    
    function go_callback(src, ~)
        
        ZG.inb1=get(findobj(src.Parent,'Tag','hndl2'),'Value');
        tgl1=get(findobj(src.Parent,'Tag','tgl1'),'Value');
        tgl2=get(findobj(src.Parent,'Tag','tgl2'),'Value');
        prev_grid=get(findobj(src.Parent,'Tag','prev_grid'),'Value');
        create_grid=get(findobj(src.Parent,'Tag','create_grid'),'Value');
        load_grid=get(findobj(src.Parent,'Tag','load_grid'),'Value');
        save_grid=get(findobj(src.Parent,'Tag','save_grid'),'Value');
        oldfig_button=get(findobj(src.Parent,'Tag','oldfig_button'),'Value');
        my_calculate();
    end
    
    
    function callbackfun_001(mysrc,myevt)
        ZG.inb2=mysrc.Value;
    end
    
    function callbackfun_002(mysrc,myevt)
        % toggle number of events
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2double(freq_field.String);
        freq_field.String=num2str(ni);
        tgl2.Value=0;
        tgl1.Value=1;
    end
    
    function callbackfun_003(mysrc,myevt)
        %toggle radius
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ra=str2double(freq_field0.String);
        freq_field0.String=num2str(ra);
        tgl2.Value=1;
        tgl1.Value=0;
    end
    
    function callbackfun_004(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(mysrc.String);
    end
    
    function callbackfun_005(mysrc,myevt)
        dy=str2double(mysrc.String);
    end
    
    function callbackfun_006(mysrc,myevt)
        Nmin=str2double(mysrc.String);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        done;
    end
end
