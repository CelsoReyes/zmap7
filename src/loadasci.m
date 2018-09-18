function loadasci(da,sa)

    % FIXME this doesn't load data into the globals.
    ZG=ZmapGlobal.Data;
    
    % make the interface
    
    report_this_filefun();
    
    loasci=findobj('Type','Figure','-and','Name','Load ASCII Data');
    
    
    
    % Set up the setup window Enviroment
    %
    if isempty(loasci)
        loasci = figure_w_normalized_uicontrolunits( ...
            'Name','Load ASCII Data',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Position',[ 100 500 950 250]);
        set(gca,'visible','off');
        
        set(gca,'box','off',...
            'SortMethod','childorder','TickDir','out','FontWeight','bold',...
            'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
        
        set(loasci,'Visible','on');
        figure(loasci);
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.65 .13 .25 .10 ],...
            'Units','normalized','callback',@close_callback,'String','Close');
        
        load_button=uicontrol('Style','Pushbutton',...
            'Position',[.15 .13 .25 .10 ],...
            'Units','normalized',...
            'callback',@load_callback,...
            'String','Load ');
        
    end   %if figure exist
    
    % load earthquake data
    %
    switch da
    case 'earthquakes'
        
        te = text(0.03,0.96,'Please setup an ascii file (e.g., data.dat) in the following format:');
        
        t2 = text(0.03,0.82,'lon          lat    year  month   day  mag  depth  hour   min ') ;
        t3 = text(0.03,0.68,' -116.86  34.35   1986        03     27    4.21    15.0   10   25 ') ;
        
        t4 = text(0.03,0.40,'Press <Load> when you are ready to load this file.');
        set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
        set(t3,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t4,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        
        %Load earthquake data
        if sa =='on'
            str = []; sa = 'of';
            [file1, newpath] = uigetfile('*', 'Load EQ Data File');
            if length(newpath) >  1
                drawnow
                xxx = load  ([newpath file1])
                tr=getfilebase(file1);
                a = xxx.(tr);
                clear(xxx)
                %check for 0 in day or month - set to 1
                l = ZG.primeCatalog.Date.Day == 0; a(l,5) = 1;
                l = ZG.primeCatalog.Date.Month == 0; a(l,4) = 1;
                
                if length(a(1,:))== 7
                    ZG.primeCatalog.Date = decyear(a(:,3:5));
                elseif length(a(1,:))>=9       %if catalog includes hr and minutes
                    ZG.primeCatalog.Date = decyear(a(:,[3:5 8 9]));
                end
                
                % Sort the catalog in time just to make sure ...
                [s,is] = sort(ZG.primeCatalog.Date);
                a = a(is(:,1),:) ;
                ZG.CatalogOpts.BigEvents.MinMag = max(ZG.primeCatalog.Magnitude) -0.2;       %  as a default
                
                close;
                [ZG.Views.primary,ZG.maepi,ZG.CatalogOpts.BigEvents.MinMag] = catalog_overview(ZG.Views.primary, ZG.CatalogOpts.BigEvents.MinMag);
                %ZmapMessageCenter.update_catalog();
                %zmap_update_displays();
                setup
            else
                close, setup
            end 
        end
    
    %load focal mechanism data
    case 'focal'
        
        te = text(0.03,0.96,'Please setup an ascii file (e.g., data.dat) in the following format (12 or 13 colums):');
        
        t2 = text(0.03,0.82,'lon          lat    year  month   day  mag  depth  hour   min dip-direction dip  rake (optional: solution uncertainty) ') ;
        t3 = text(0.03,0.68,' -116.86  34.35   86        03     27    4.21    15.0   10   2  5     230      75                 137    ') ;
        
        t4 = text(0.03,0.40,'Press <Load> when you are ready to load this file.');
        set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
        set(t3,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t4,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        
        %load focal mechanism data
        if sa =='on'
            str = []; sa = 'of';
            [file1, newpath] = uigetfile('*.m', 'Load EQ Data File');
            if length(newpath) >  1
                drawnow
                xxx=load  ([newpath file1]);
                tr=getfilebase(file1);
                a = xxx.(tr);
                clear(xxx)
                %check for 0 in day or month - set to 1
                l = ZG.primeCatalog.Date.Day == 0; a(l,5) = 1;
                l = ZG.primeCatalog.Date.Month == 0; a(l,4) = 1;
                
                if length(a(1,:))== 7
                    ZG.primeCatalog.Date = decyear(a(:,3:5));
                elseif length(a(1,:))>=9       %if catalog includes hr and minutes
                    ZG.primeCatalog.Date = decyear(a(:,[3:5 8 9]));
                end
                % create a 13 column if none exists and set it to zero
                
                if length(a(1,:))< 13 ; a = [a ; a(:,12)*0]; end
                
                % Sort the catalog in time just to make sure ...
                [s,is] = sort(ZG.primeCatalog.Date);
                a = a(is(:,1),:) ;
                ZG.CatalogOpts.BigEvents.MinMag = max(ZG.primeCatalog.Magnitude) -0.2;       %  as a default
                % set up the focal mechanism data
                %dall=prepfocal()
                
                close;
                
                [ZG.Views.primary,ZG.maepi,ZG.CatalogOpts.BigEvents.MinMag] = catalog_overview(ZG.Views.primary, ZG.CatalogOpts.BigEvents.MinMag);
                %ZmapMessageCenter.update_catalog();
                %zmap_update_displays();
                setup
            else
                close
                setup
            end % if
        end   %if sa
    
    
    
    % load faults data
    %
    case 'faults'
        
        te = text(0.03,0.96,'Please setup an ascii file in the following format:');
        t2 = text(0.03,0.82,'lon        lat ') ;
        t3 = text(0.03,0.68,' -116.86  34.35 ') ;
        t4 = text(0.03,0.50,'If the file contains more than one fault #use   inf inf   to seperate the faults.#Press <Load> when you are ready to load this file.');
        
        set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
        set(t3,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t4,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        
        %save faults data
        if sa =='on'
            str = []; sa = 'of';
            [file1, newpath] = uigetfile('*.m', 'Load Faults Data File');
            if length(newpath) >  1
                drawnow
                xxx=load  ([newpath file1]);
                tr=getfilebase(file1);
                faults=xxx.(tr);
                clear(xxx)
                close;zmap_update_displays(); setup
            else
                close, setup
            end % if
        end   %if sa
    
    % load main faults data
    %
    case 'mainfaults'
        
        te = text(0.03,0.96,'Please setup an ascii file in the following format:');
        t2 = text(0.03,0.82,'lon        lat ') ;
        t3 = text(0.03,0.68,' -116.86  34.35 ') ;
        t4 = text(0.03,0.50,'If the file contains more than one continous segment #use  <inf inf> to seperate the segments.#Press <Load> when you are ready to load this file.');
        
        set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
        set(t3,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t4,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        
        %save main faults data
        if sa =='on'
            str = []; sa = 'of';
            [file1, newpath] = uigetfile('*.m', 'Load main Faults Data File');
            if length(newpath) >  1
                drawnow
                xxx=load  ([newpath file1])
                tr=getfilebase(file1);
                mainfault=xxx.(tr);
                clear(xxx)
                close;zmap_update_displays(); setup
            else
                close, setup
            end % if
        end   %if sa 
    
    % load mainshock data
    %
    case 'mainshock'
        
        te = text(0.03,0.96,'Please setup an ascii file in the following format:');
        t2 = text(0.03,0.82,'lon        lat ') ;
        t3 = text(0.03,0.68,' -116.86  34.35 ') ;
        t4 = text(0.03,0.50,  'Press <Load> when you are ready to load this file.');
        
        set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
        set(t3,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t4,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        
        %save faults data
        if sa =='on'
            
            str = []; sa = 'of';
            [file1, newpath] = uigetfile('*.m', 'Load Mainshock Data File');
            if length(newpath) >  1
                drawnow
                xxx=load  ([newpath file1])
                tr=getfilebase(file1);
                main = xxx.(tr);
                clear(xxx)
                close; zmap_update_displays();setup
            else
                close, setup
            end % if
        end   %if sa
    end   % if da == ma
    
    % load coastline data
    %
    if da == 'coastline'
        
        te = text(0.03,0.96,'Please setup an ascii file in the following format:');
        t2 = text(0.03,0.82,'lon        lat ') ;
        t3 = text(0.03,0.68,' -116.86  34.35 ') ;
        t4 = text(0.03,0.50,'If the file contains more than one continuos line#use   <inf inf>   to seperate the segments.#Press <Load> when you are ready to load this file.');
        
        set(te,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t2,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','r','FontWeight','bold')
        set(t3,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        set(t4,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold')
        
        %save coastline data
        if sa =='on'
            str = []; sa = 'co';
            [file1, newpath] = uigetfile('*.m', 'Load Coastline Data File');
            if length(newpath) >  1
                drawnow
                xxx=load  ([newpath file1])
                tr = getfilebase(file1);
                coastline = xxx.(tr);
                close; zmap_update_displays();setup
            else
                close, setup
            end % if
        end   %if sa
    end
    
    
    function close_callback(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        setup();
    end
    
    function load_callback(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        loadasci(da,'on');
    end
end

function dall=prepfocal(catalog)
    % PREPFOCAL to prepare the events for inversion based on Lu Zhongs code.
    
    report_this_filefun();
    
    
    tmp = [catalog.Dip(:), catalog.DipDirection(:), catalog.Rake(:)];
    data_inp_file=fullfile(ZmapGlobal.Data.Directories.output,'data.inp');
    try
        save(data_inp_file, 'tmp', '-ascii');
    catch ME
        warning(ME.message);
        errordlg('Error - could not save file %s - permission?', data_inp_file);
        return
    end
    infi = fullfile(ZmapGlobal.Data.Directories.output, 'tmp.inp');
    outfi = fullfile(ZmapGlobal.Data.Directories.output, 'tmp.out');
    
    
    fid = fopen(fullfile(ZmapGlobal.Data.Directories.output, 'inmifi.dat'),'w');
    
    fprintf(fid,'%s\n',infi);
    fprintf(fid,'%s\n',outfi);
    
    fclose(fid);
    try %#ok<TRYNC>
        delete(outfi);
    end
    ddsetupprogram = fullfile(ZmapGlobal.Data.hodi,'external','datasetupDD');
    filetoreadfrom = [ZmapGlobal.Data.Directories.output 'inmifi.dat'];
    [status, result] = system(sprintf('%s < %s',ddsetupprogram,filetoreadfrom))
    
    fid = fullfile(ZmapGlobal.Data.Directories.output, 'tmpout.dat');
    
    format = '%f%f%f%f%f';
    %[d1, d2, d3, d4, d5] = textread(fid,format,'headerlines',1);
    C = textscan(fid,format,'HeaderLines',1); %Problem: "Errorlines" cause crashes.
    dall=[C{:}];
end

function s = getfilebase(s)
    % removes the extension, returning file base
    if contains(s,'.')
        s = extractBefore(s,'.');
    end
end
