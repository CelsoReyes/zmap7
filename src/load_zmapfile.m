function load_zmapfile()%
    % load_zmapfile
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
    %
    % Any catalog is generally loaded once as an unformatted ascii file
    % and then saved as variable "a" in  <name>_cata.mat .
    %
    %   Matlab scriptfile written by Stefan Wiemer
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    report_this_filefun(mfilename('fullpath'));
    
    format short
    ZG=ZmapGlobal.Data; % get zmap globals
    
    % start program and load data:
    show_load_instructions();
    
    [file1,path1] = uigetfile('*.mat',' Earthquake Datafile');
    
    if length(path1) < 2 % cancelled
        zmap_message_center.clear_message();
        done
        return
    else
        if exist(fullfile(path1,file1),'file')
            S=whos('-file',fullfile(path1,file1),'a'); % get info about "a"
            if ~isempty(S) %a exists
                ZG.a=loadCatalog(path1, file1);
            else
                errordlg('File did not contain variable "a" - Nothing was loaded');
            end
        else
            errordlg('File could not be found');
        end
            
    end
    if isempty(ZG.a)
        ZG.a=ZmapCatalog();
        ZG.a.Name='no catalog';
    end
    
    if max(ZG.a.Magnitude) > 10
        errdisp = ' Error -  Magnitude greater than 10 detected - please check magnitude!!';
        warndlg(errdisp)
    end   % if
    
    % Sort the catalog in time just to make sure ...
    ZG.a.sort('Date');
    
    % org = a;                         %  org is to remain unchanged
    
    %  ask for input parameters
    %
    watchoff
    clear s is
    ZG.mainmap_plotby='depth';
    
    setUpDefaultValues(ZG.a);
    
    zmap_message_center.update_catalog();
    ZG.a=catalog_overview(ZG.a);
    
end

function setUpDefaultValues(A)
    
    ZG=ZmapGlobal.Data; % get zmap globals
    
    %  default values
    t0b = min(A.Date);
    teb = max(A.Date);
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
    ZG.big_eq_minmag = max(A.Magnitude) -0.2;
    dep1 = 0.3*max(A.Depth);
    dep2 = 0.6*max(A.Depth);
    dep3 = max(A.Depth);
    minti = min(A.Date);
    maxti  = max(A.Date);
    minma = min(A.Magnitude);
    maxma = max(A.Magnitude);
    mindep = min(A.Depth);
    maxdep = max(A.Depth);
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


function   A=loadCatalog(path, file)
    % 
    % by the time this is called, it should be already known that 'a' exists
    lopa = fullfile(path, file);
    show_loading_status()
    
    watchon;
    drawnow
    
    try
        A=[];
        tmp = load(lopa,'a');
    catch ME
        error_handler(ME, 'Error loading data! Are they in the right *.mat format?');
    end
    
    
    if ~isfield(tmp,'a') || isempty(tmp.a)
        errordlg(' Error - No catalog data loaded !');
        return;
    end
    A=tmp.a;
    clear tmp
    if isnumeric(A)
        % convert to a ZmapCatalog
        A=ZmapCatalog(A);
    end
    A.Name = file;
    zmap_message_center.clear_message();
    
end