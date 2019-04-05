function pltopo(plt, h1)
    % This plot a DEM map plus eq on top...
    %
    
    import zmaptopo.* %#ok<NSTIMP>
    % TODO: change this from the prime catalog to the active catalog
    
    ZG = ZmapGlobal.Data;
    globalcatalog = ZG.primeCatalog;
    switch(plt)
        
        case 'lo3' % 3 arc second resolution (USGS DEM)
            lo3();
            
        case 'lo30' % 30 arc second resolution (GTOPO 30)
            lo30();
            
        case 'lo5' % 5 degree resolution (ETOPO 5, Terrain base) load tbase.bin
            lo5();
            
        case 'lo2' % 2 degree resolution (ETOPO 2) load topo_8.2.img
            lo2();
            
        case 'lo1' % 30 arc second resolution (GLOBE DEM)
            lo1();
            
        case 'yourdem'
            yourdem();
                                 
        case 'err'  % Tbase data not found
            cb_err();
            
        case 'err2'  % Tbase data not found
            cb_err2();
                        
        case 'genhelp'  % Tbase data not found
            genhelp();
            
        case 'loadmydem'  %
            loadmydem();
            
    end
    
    %%
    function f = find_topo_figure()
        f = findobj('Type','Figure','-and','Name','Topographic Map');
    end
    
    function genhelp()
        showweb('topo');
    end
    
    function [fac, cancelled] = get_decimation_factor(default)
        st.prompt = 'Decimation factor for DEM data?';
        st.value = default;
        [~, cancelled, fac] = smart_inputdlg('Decimition', st);
    end
    
    function lo3()
        % load 3 arc second resolution (USGS DEM)
        [~, s4_south, s3_north, s2_west, s1_east] = limits2region(h1);
        fac = get_decimation_factor(3);
        
        hodis = fullfile(ZG.hodi, 'external');
        cd(hodis);
        
        if ~exist('pathdem', 'var')
            if exist('dem','dir')
                pathdem = fullfile(ZG.hodi, 'dem');
            else
                [~, pathdem] = uigetfile( '*.mat','Directory containing dem data? (select any file)');
            end
        end
        cd(pathdem)
        
        
        usgsdems( [s4_south s3_north], [s2_west s1_east])
        
        [file1, path1] = uigetfile('*',' Which USGS 3 arc sec data DEM ?');
        
        try
            [tmap, tmapleg] = usgsdem([path1 file1], fac, [s4_south s3_north], [s2_west s1_east]);
        catch ME
            cb_err2();
        end
        
        my = s4_south : 1/tmapleg(1) : s3_north+0.1;
        mx = s2_west : 1/tmapleg(1) : s1_east+0.1;
        toflag = TopoToFlag.five;
        plo(mx, my, tmap);
    end
    
    function lo30()
        % load 30 arc second resolution (GTOPO 30)
        [~, s4_south, s3_north, s2_west, s1_east] = limits2region(h1);
        fac = 1;
        if range([s4_south, s3_north]) > 10 || range([s1_east, s2_west]) > 10
            fac = get_decimation_factor(3);
        end
        [tmap, tmapleg] = gtopo302(fullfile(ZG.hodi, 'dem', 'gtopo30'),fac,[s4_south s3_north],[s2_west s1_east]);
        cd(ZG.hodi)
        my = s4_south:1/tmapleg(1):s3_north+0.1;
        mx = s2_west:1/tmapleg(1):s1_east+0.1;
        vlon = mx;
        vlat = my;
        toflag = TopoToFlag.five;
        plo(mx, my, tmap);
    end
    
    function lo5()
         % load 5 degree resolution (ETOPO 5, Terrain base) 
         % from tbase.bin
        [~, s4_south, s3_north, s2_west, s1_east] = limits2region(h1);
        fac = 1;
        if range([s4_south, s3_north]) > 10 || range([s1_east, s2_west]) > 10
            fac = get_decimation_factor(3);
        end
        
        if ~exist('tbase.bin', 'file')
            cb_err();
        else
            
            try
                [tmap, tmapleg] = tbase(fac, [s4_south s3_north], [s2_west s1_east]);
            catch ME
                helpdlg('The right GTOPO30 file could not be found - is it in the dem/gtopo30 directory?');
                return
            end
        end
        
        my = s4_south:1/tmapleg(1):s3_north+0.1;
        mx = s2_west:1/tmapleg(1):s1_east+0.1;
        toflag = TopoToFlag.five;
        plo(mx, my, tmap);
    end
    
    function lo2()
        % load 2 degree resolution (ETOPO 2)
        % from topo_8.2.img
        expected_file = fullfile('dem','topo_8.2.img');
        zip_file = [expected_file, '.zip'];
        
        if ~exist(expected_file, 'file')
            if exist(zip_file,'file')
                error('TODO: implement code to unzip the topo 8.2 file')
                %unzip(fullfile)
            end
            helpdlg('You do not have the topo_8.2.img database in your search path. It should be in the ./dem directory. If you have a different version of topo, please rename it to topo_8.2.img ','Error')
            return
        end
        
        region = limits2region(h1);
        
        toflag = TopoToFlag.two;
        [tmap,vlat,vlon] = mygrid_sand(region);
        plo2(vlon, vlat, tmap);
    end
    
    function lo1()
        % load 30 arc second resolution (GLOBE DEM)  
        cd(ZG.hodi);
        if ~exist('pathdem', 'var')
            if exist('dem','dir')
                pathdem = fullfile(ZG.hodi, 'dem');
            else
                [~, pathdem] = uigetfile('*.mat', 'Directory containing dem data? (select any file)');
            end
        end
        cd(pathdem)
        [~, s4_south, s3_north, s2_west, s1_east] = limits2region(h1);
        
        fac = 1;
        if range([s4_south, s3_north]) > 4 || range([s1_east, s2_west]) > 4
            fac = get_decimation_factor(3);
        end
        
        fname = globedems([s4_south s3_north], [s2_west s1_east]);
        
        try
            [tmap, tmapleg] = globedem(fname{1}, fac, [s4_south s3_north], [s2_west s1_east]);
        catch ME
            do_nothing();
        end
        
        my = s4_south: 1/tmapleg(1) : s3_north+0.1;
        mx = s2_west : 1/tmapleg(1) : s1_east+0.1;
        toflag = TopoToFlag.three;
        plo(mx, my, tmap);
    end
    
    function yourdem(mydem, mx, my)
        
        [~, s,nor,w,e] = limits2region(h1);
        
        % is mydem defined?
        if ~exist('mydem', 'var')
            loadmydem();
        end
        % cut the data
        l2 = find(mx >= w, 1 );
        l1 = find(mx <= e, 1, 'last' );
        l3 = find(my <= nor, 1, 'last' );
        l4 = find(my >= s, 1 );
        
        toflag = TopoToFlag.one;
        
        
        tmap = mydem(l4:l3, l2:l1);
        vlat = my(l4:l3);
        vlon = mx(l2:l1);
        
        plo_yourdem(vlon, vlat, tmap, [w,e,s,nor]);
    end
    
    
    function [fig, ax] = prepfig(xx,yy,zz)
        fig = find_topo_figure();
        
        if isempty(fig)
            ac3 = 'new';
            overtopo;
            fig = find_topo_figure();
        else
            figure(fig)
            delete(findobj(fig,'Type','axes'));
        end
        
        set(gca,'NextPlot','add');
        axis off
        
        ax = axes('position',[0.13,  0.13, 0.65, 0.7]);
        pcolor(ax, xx, yy, zz);
        shading(ax, 'flat');
    end
    
    function postfig(ax, fig)
        set(ax,'NextPlot','add')
        set(ax, 'FontSize', 12, 'FontWeight', 'bold', 'TickDir', 'out', 'Ticklength', [0.02 0.02])
        set(fig, 'Color', 'w', 'InvertHardcopy', 'off', 'renderer', 'zbuffer')
        set(ax, 'dataaspect', [1 cosd(mean(globalcatalog.Latitude)) 1])
    end
    
    function plo(mx, my, tmap)       
        [n,m] = size(tmap);
        [to1, h1topo] = prepfig(mx(1:n), my(1:m), tmap);
        demcmap(tmap);
        set(h1topo, 'color', [ 0.341 0.776 1.000 ]);
        
        postfig(h1topo, to1);
    end
    
    function plo2(vlon, vlat, tmap)
        
        if max(vlon) > 180
            vlon = vlon - 360; 
        end
        
        % tmapleg = [30 max(vlat) min(vlon)];
        [xx, yy] = meshgrid(vlon,vlat);
        
        [to1, ax] = prepfig(xx, yy, tmap);
        demcmap(tmap, 256);
        xlabel(ax, 'Longitude'),
        ylabel(ax, 'Latitude')
        
        postfig(ax, to1);
    end
    
    function plo_yourdem(vlon, vlat, tmap, ax_lims)
        [to1, ax] = prepfig(vlon, vlat, tmap);
        demcmap(tmap);
        
        axis(ax, ax_lims)
        postfig(ax, to1);
    end
        
    function loadmydem()
        butt =    questdlg('Please load a *.mat file containing the DEM data in 2D matrix mydem, and the lat/long vextors my and mx', ...
            'Load mydem ', ...
            'OK', 'Help', 'Cancel', 'Cancel');
        
        switch butt
            case 'OK'
                [file1, path1] = uigetfile( '*.mat','File containing  mydem, mx, my ');
                if length(path1) >= 2
                    lopa = fullfile(path1, file1);
                    mydem=[]; mx=[]; my=[];
                    load(lopa, 'mydem', 'mx', 'my')
                    yourdem(mydem, mx, my);
                end
            case 'Help'
                genhelp();
                
            case 'Cancel'
                return;
                
        end %swith butt
    end
    
    function cb_err()
        
        butt =    questdlg('Please define the path to your Terrain base 5 min DEM (tbase.bin) data', ...
            'DEM data not found!', ...
            'OK', 'Help', 'Cancel', 'Cancel');
        
        switch butt
            case 'OK'
                
                [~, path1] = uigetfile('*.bin', ' Terrain base global 5 min grid path (tbase.bin)');
                
                if length(path1) < 2
                    return
                else
                    addpath(path1);
                    lo5();
                end
            case 'Help'
                try
                    web(fullfile(fullfile(ZG.hodi , 'help','plottopo.htm')));
                catch
                    errordlg('Error while opening, please open the browser first and try again or open the file ./help/topo.hmt manually');
                end
            case 'Cancel'
                return
                
        end %swith butt
    end
    
    function cb_err2()
        [~, path1] = uigetfile( '*.img',' Please define the path to the file topo_8.2.img (2 min DEM)');
        
        if length(path1) >= 2
            addpath(path1);
            lo2();
        end
        
        %errordlg('Error loading data - sorry');
    end
    
    
end
function [region_snwe, s4_south, s3_north, s2_west, s1_east] = limits2region(h)
        xl  = get(h,'XLim');
        s1_east = xl(2); 
        s2_west = xl(1);
        yl  = get(h,'YLim');
        s3_north = yl(2); 
        s4_south = yl(1);
        region_snwe = [s4_south, s3_north, s2_west, s1_east];
end