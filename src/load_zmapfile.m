function load_zmapfile()%
    % load_zmapfile
    %  load zmap file
    %  load volcanoes
    %
    % This is the startup file for the program "MagSig". To run
    % it your startup.m file in the local directory must include several
    % searchpathes pointing to several supplementary .m files.
    %
    % load_zmapfile file will ask you for an input file name. The data
    % format is at this point:
    %
    %  Columns 1 through 7
    %
    %    34.501      116.783       81         3         29       1.7      13
    %
    %    lat          lon        year       month      day       mag     depth
    %
    %  Columns 8 and 9
    %     10     51
    %    hour   min
    %
    % Any catalog is generally loaded once as an unformatted ascii file
    % and then saved as variable "a" in  <name>_cata.mat .
    %
    %   Matlab scriptfile written by Stefan Wiemer
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    report_this_filefun(mfilename('fullpath'));
    
    format short
    global a vo typele
    
    % start program and load data:
    show_load_instructions();
    
    [file1,path1] = uigetfile('*.mat',' Earthquake Datafile');
    
    if length(path1) < 2 % cancelled o
        zmap_message_center.clear_message();
        done
        return
    else
        if exist(fullfile(path1,file1),'file')
            S=whos('-file','tempout.mat','a'); % get info about "a"
            if ~isempty(S) %a exists
                a = loadCatalog(path1, file1);
            else
                errordlg('File did not contain variable "a" - Nothing was loaded');
            end
        else
            errordlg('File could not be found');
        end
            
    end
    if isempty(a)
        a=ZmapCatalog();
        a.Name='no catalog';
    end
    
    if max(a.Magnitude) > 10
        errdisp = ' Error -  Magnitude greater than 10 detected - please check magnitude!!';
        warndlg(errdisp)
    end   % if
    
    vo = load_volcanoes();
    
    % read the world coast + political ines if none are present
    %do = ['load worldlo'];
    %eval(do,' ')
    %if exist('coastline') == 0;  coastline = []; end
    %if isempty('coastline') == 0
    %   if exist('POline') >0
    %      Plong = [POline(1).long ; POline(2).long];
    %      Plat = [POline(1).lat;  POline(2).lat];
    %      coastline = [Plong Plat];
    %  end
    %end
    
    % Sort the catalog in time just to make sure ...
    a.sort('Date');
    
    % org = a;                         %  org is to remain unchanged
    
    %  ask for input parameters
    %
    watchoff
    clear s is
    typele = 'dep';
    
    setUpDefaultValues(a);
    %{
    %  default values
    t0b = min(a.Date);
    teb = max(a.Date);
    tdiff = (teb - t0b)*365;
    if exist('par1') == 0
        if tdiff>10                 %select bin length respective to time in catalog
            par1 = ceil(tdiff/100);
        elseif tdiff<=10  &&  tdiff>1
            par1 = 0.1;
        elseif tdiff<=1
            par1 = 0.01;
        end
    end
    minmag = max(a.Magnitude) -0.2;
    dep1 = 0.3*max(a.Depth);
    dep2 = 0.6*max(a.Depth);
    dep3 = max(a.Depth);
    minti = min(a.Date);
    maxti  = max(a.Date);
    minma = min(a.Magnitude);
    maxma = max(a.Magnitude);
    mindep = min(a.Depth);
    maxdep = max(a.Depth);
    ra = 5;
    mrt = 6;
    met = 'ni';
    %}
    
    zmap_message_center.update_catalog();
    a = catalog_overview(a);
    
end

function setUpDefaultValues(a)
    global t0b teb par1 minmag dep1 dep2 dep3 minti maxti minma maxma mindep maxdep ra mrt met
    %  default values
    t0b = min(a.Date);
    teb = max(a.Date);
    tdiff = (teb - t0b)*365;
    if ~exist('par1','var')
        if tdiff>10                 %select bin length respective to time in catalog
            par1 = ceil(tdiff/100);
        elseif tdiff<=10  &&  tdiff>1
            par1 = 0.1;
        elseif tdiff<=1
            par1 = 0.01;
        end
    end
    minmag = max(a.Magnitude) -0.2;
    dep1 = 0.3*max(a.Depth);
    dep2 = 0.6*max(a.Depth);
    dep3 = max(a.Depth);
    minti = min(a.Date);
    maxti  = max(a.Date);
    minma = min(a.Magnitude);
    maxma = max(a.Magnitude);
    mindep = min(a.Depth);
    maxdep = max(a.Depth);
    ra = 5;
    mrt = 6;
    met = 'ni';
end

function show_load_instructions()
    messtext=...
        ['Please select an earthquake datafile.'
        'This file needs to be in matlab *.mat'
        'Format. If you do not have a *.mat   '
        'file use <create *.mat Datafile> in  '
        'the menu                             '];
    zmap_message_center.set_message('Load Data',messtext);
end

function show_loading_status()
    
    messtext=...
        ['Thank you! Now loading data'
        'Hang on...                 '];
    zmap_message_center.set_message('  ',messtext)
end


function   a = loadCatalog(path, file)
    % 
    % by the time this is called, it should be already known that 'a' exists
    lopa = fullfile(path, file);
    show_loading_status()
    
    %set(action_button,'String','Loading Data...');
    watchon;
    drawnow
    
    try
        a=[];
        load(lopa,'a')
    catch ME
        error_handler(ME, 'Error loading data! Are they in the right *.mat format?');
    end
    
    if ~exist('a','var') || isempty(a)
        errordlg(' Error - No catalog data loaded !');
        return;
    end
    
    if isnumeric(a)
        % convert to a ZmapCatalog
        a = ZmapCatalog(a);
    end
    a.Name = file;
    zmap_message_center.clear_message();
    
end