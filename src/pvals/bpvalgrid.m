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
    
    InCatalogName={'primeCatalog'};
    OutCatalogName='newt2';
    Grid=[];
    EventSelector=[];
    % TOFIX ll isn't guaranteed to be here. it is the index of the events within the polygon
    ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
    
    minThreshMag = min(ZG.primeCatalog.Magnitude);
    
    % get the grid parameter
    % initial values
    if ~ensure_mainshock()
        return
    end
    % cut catalog at mainshock time:
    l = ZG.primeCatalog.Date > ZG.maepi.Date(1);
    ZG.newt2 = ZG.primeCatalog.subset(l);
    
    % cut cat at selected magnitude threshold
    l = ZG.newt2.Magnitude >= minThreshMag;
    ZG.newt2 = ZG.newt2.subset(l);
    ff=gcf
    ZG.hold_state2=true;
    timeplot()
    ZG.hold_state2=false;
    figure(ff)
    dx = 0.025;
    dy = 0.025;
    ni = 150;
    Nmin = 100;
    valeg2 = 2;
    %The definitions in the following line were present in the initial file.
    %stan2 = nan; stan = nan; av = nan;
    
    % make the interface
    [res, okpressed] = createGui(dx, dy, ni, Nmin)
    if ~okpressed
        return
    end
    Grid=ZmapGrid('bpvalgrid',res.Grid);
    EventSelector=res.EventSelector;
    ZG.inb1=res.mc_methods;
    valeg2=res.c_val;
    if res.use_const_c
        CO=res.const_c;
        valeg2 = -valeg2; %duplicating original inputs
    else
        CO=0;
    end
    
    minpe=res.minpe; %min goodness of fit (%)
        
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % thge seimicity and selectiong the ni neighbors
    % to each grid point
    
    ReturnFields={'bv','magco',...
        'x','y','rd',... to be replaced by x, y, and radius afterward
        'bv2','stan2','av','stan','prf','pv',...
        'pstd','maxmg','cv','tgl1','mmav','kv','mbv',...
        'num_atnode'... to be replaced by the # of events afterward
        };
    ReturnFieldTitles={'b-value map (WLS)',...1
        'Mag of completness map',...2
        'x','y','radius in km',... to be replaced by x, y, and radius afterward
        'b(max likelihood) map',... 6:
        'Error in b',...7 {pro}
        'a-value',...8
        'stamn',... 9:
        'Prmap',...
        'p-value',... 11:
        'p-valstd',... 12: 
        'Mmax',... 13
        'c in days',... 14
        'tgl1','mmav','kv','mbv',...
        'num_atnode'... to be replaced by the # of events afterward
        };
        sel=my_calculate();
    
        lab1 = 'p-value';
        
        % View the b-value and p-value map
        view_bpva(sel, 11)
    
    function obj=my_calculate()
        %In the following line, the program selgp.m is called, which creates a rectangular grid from which then selects,
        %on the basis of the vector ll, the points within the selected poligon.
        
        %   selgp
       %{ 
        prompt = {'If you wish a fixed c in Omori formula, please enter a negative value'};
        title = 'Input parameter';
        lines = 1;
        valeg2 = 2;
        def = {num2str(valeg2)};
        answer = inputdlg(prompt,title,lines,def);
        valeg2=str2double(answer{1});
        CO=0;
        if valeg2 <= 0
            prompt = {'Enter c'};
            title = 'Input parameter';
            lines = 1;
            CO = 0;
            def = {num2str(CO)};
            answer = inputdlg(prompt,title,lines,def);
            CO=str2double(answer{1});
        end
        %}
        %  make grid, calculate start- endtime etc.  ...
        %[t0b, teb] = ZG.primeCatalog.DateRange() ;
        %n = ZG.primeCatalog.Count;
        %tdiff = round((teb-t0b)/ZG.bin_dur);
        %loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        %i2 = 0.;
        %i1 = 0.;
        %bpvg = [];
        %
        % overall b-value
        [bv, magco, stan, av,  pr] =  bvalca3(ZG.primeCatalog,ZG.inb1);
        ZG.bo1 = bv;
        
        
        mycalcmethods= {@calcguts_opt1,...
            @calcguts_opt2,...
            @calcguts_opt3,...
            @calcguts_opt4,...
            @calcguts_opt5};
        calculation_function=mycalcmethods{ZG.inb1};
        tgl1=double(EventSelector.useNumNearbyEvents);
        % calculate at all points
        [bpvg,nEvents,maxDists,maxMag, ll]=gridfun(calculation_function,...
            ZG.primeCatalog,Grid, EventSelector, numel(ReturnFields));
        
        bpvg(:,strcmp('rd',ReturnFields))=maxDists;
        bpvg(:,strcmp('num_atnode',ReturnFields))=nEvents;
        bpvg(:,strcmp('maxmg',ReturnFields))=maxMag;
        bpvg(:,strcmp('x',ReturnFields))=Grid.X;
        bpvg(:,strcmp('y',ReturnFields))=Grid.Y;
     
        
        % prepare output to dektop
        obj=struct();
        obj.Result.values=array2table(bpvg,'VariableNames',ReturnFields);
        obj.Result.values.Properties.VariableDescriptions=ReturnFieldTitles;
        obj.Result.InCatalogName=InCatalogName;
        obj.Result.OutCatalogName=OutCatalogName;
        obj.Result.Grid=Grid;
        obj.Result.EventSelector=EventSelector;
        obj.Result.minpe=minpe; %min goodness of fit (%)
        assignin('base','bpvalgrid_result',obj.Result);
        
        
        
        % plot the results
        % old and valueMap (initially ) is the b-value matrix
        %
        % gridstats = array2gridstats(bpvg, ll);
        % gridstats.valueMap = gridstats.pvalg;
        
        
        function bpvg = calcguts_opt1(b)
            [bv, magco, stan, av,   pr] =  bvalca3(b,1);
            maxcat = b.subset(b.Magnitude >= magco-0.05);
            if maxcat.Count()  >= Nmin
                [bv2, stan2,  av2] =  bmemag(maxcat);
                maxmg = max(maxcat.Magnitude);
                [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                
                bpvg = [bv magco nan nan nan bv2 stan2 av stan nan pv pstd maxmg cv tgl1 mmav kv mbv nan];
            else
                bpvg = nan(1,numel(ReturnFields));
            end
        end
        
        function bpvg = calcguts_opt2(b)
            [bv, magco, stan, av,   pr] =  bvalca3(b,2);
            [bv2, stan2,  av2] =  bmemag(b);
            maxcat = b(l); % TOFIX there is no l here.
            maxmg = max(maxcat.Magnitude);
            [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(b.subset(l),'days',valeg2,CO,minThreshMag);
            
            bpvg = [bv magco nan nan nan bv2 stan2 av stan nan pv pstd maxmg cv tgl1 mmav kv mbv nan];
        end
        
        function bpvg = calcguts_opt3(b)
            [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
            maxcat = b.subset(b.Magnitude >= Mc90-0.05)
            magco = Mc90;
            if maxcat.Count()  >= Nmin
                [bv, magco0, stan, av,   pr] =  bvalca3(maxcat,2);
                [bv2, stan2,  av2] =  bmemag(maxcat);
                maxmg = max(maxcat.Magnitude);
                [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                bpvg = [bv magco nan nan nan bv2 stan2 av stan prf pv pstd maxmg cv tgl1 mmav kv mbv nan];
            else
                bpvg = nan(1,numel(ReturnFields));
            end
        end
        
        function bpvg = calcguts_opt4(b)
            [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
            maxcat= b.subset(b.Magnitude >= Mc95-0.05);
            magco = Mc95;
            if maxcat.Count() >= Nmin
                [bv, magco0, stan, av,   pr] =  bvalca3(maxcat,2);
                [bv2, stan2,  av2] =  bmemag(maxcat);
                maxmg = max(maxcat.Magnitude);
                [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                
                bpvg = [bv magco nan nan nan bv2 stan2 av stan prf pv pstd maxmg cv tgl1 mmav kv mbv nan];
            else
                bpvg = nan(1,numel(ReturnFields));
            end
        end
        
        function bpvg = calcguts_opt5(b)
            [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3();
            if ~isnan(Mc95)
                magco = Mc95;
            elseif ~isnan(Mc90)
                magco = Mc90;
            else
                [bv, magco, stan, av,  pr] =  bvalca3(b,1);
            end
            maxcat= b.subset(b.Magnitude >= magco-0.05);
            if maxcat.Count()  >= Nmin
                [bv, magco0, stan, av,   pr] =  bvalca3(maxcat,2);
                maxmg = max(maxcat.Magnitude);
                [bv2, stan2,  av2] =  bmemag(maxcat);
                [pv, pstd, cv, cstd, kv, kstd, mmav,  mbv] = mypval2m(maxcat,'days',valeg2,CO,minThreshMag);
                bpvg = [bv magco nan nan nan bv2 stan2 av stan prf pv pstd maxmg cv tgl1 mmav kv mbv nan];
            else
                bpvg = nan(1,numel(ReturnFields));
            end
        end
        
    end
    
    function my_load()
        % Load exist b-grid
        [file1,path1] = uigetfile('*.mat','b-value gridfile');
        if length(path1) > 1
            
            gridstats=load_existing_bgrid(fullfile(path1, file1));
            view_bpva(lab1,gridstats.valueMap)
        else
            return
        end
    end
    
    function [res,okpressed] = createGui(dx, dy, ni, Nmin)
        % make the interface
        
        zdlg = ZmapFunctionDlg();
        
        
        McMethods={'Automatic Mcomp (max curvature)',...
            'Fixed Mc (Mc = Mmin)',...
            'Automatic Mcomp (90% probability)',...
            'Automatic Mcomp (95% probability)',...
            'Best (?) combination (Mc95 - Mc90 - max curvature)',...
            'Constant Mc'};
        
        zdlg.AddBasicPopup('mc_methods','Mc  Method:',McMethods,5,...
            'Please choose an Mc estimation option');
        
        zdlg.AddGridParameters('Grid',dx,'deg',dy,'deg',[],'');
        zdlg.AddEventSelectionParameters('EventSelector', ni, ZG.ra, Nmin)
        zdlg.AddBasicEdit('c_val','omori c parameter', valeg2,' input parameter (varying)');
        zdlg.AddBasicCheckbox('use_const_c','fixed c', false,{'const_c'},'keep the Omori C parameter fixed');
        zdlg.AddBasicEdit('const_c','omori c parameter', valeg2, 'C-parameter parameter (fixed)');
        zdlg.AddBasicEdit('minpe','min goodness %', nan, 'Minimum goodness of fit (percentage)');
        % zdlg.AddBasicEdit('Mmin','minMag', nan, 'Minimum magnitude');
        % TOFIX min number of events should be the number > Mc
        
        [res, okpressed]=zdlg.Create('B P val grid');
        if ~okpressed
            return
        end
        disp(res)
        
        
    end
    %{
    function gridstats = array2gridstats(pbvg, ll)
        % move from the array bpvg to the gridstats struct
        % ll is some sort of mask/index (points within the polygon)
        
        % TODO: unravel this
        % pbvg columns
        fields_and_representations = {'valueMap', 1;
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
        
        normlap2=nan(length(Grid.X),1);
        
        reshaper = @(x) reshape(x,length(Grid.Xvector),length(Grid.Yvector));
        
        for i=1:length(fields_and_representations)
            fldnum = fields_and_representations{i,2};
            fldnam = fields_and_representations{i,1};
            normlap2(ll)= bpvg(:,fldnum);
            gridstats.(fldnam) = reshaper(normlap2);
            
        end
        
        gridstats.old = gridstats.valueMap;
    end
    
    function gridstats = load_existing_bgrid(fn)
        load(fn)
        gridstats = array2gridstats(pbvg, ll);
    end
    %}
    %{
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
   %}
end
