function s = report_this_filefun(level)
    % this script replaced all the individual "disp('This is ...') messages
    % it can be used to track which files are used, or do some function/file specific
    % setup
    %  REPORT_THIS_FILEFUN() display message if ANY level has been set
    %  REPORT_THIS_FILEFUN( LEVEL ) print message if
    
    
    %called by script or function?
    % modified from: http://blogs.mathworks.com/loren/2013/08/26/what-kind-of-matlab-file-is-this/
    
    ZG = ZmapGlobal.Data;
    
    %% change debugging behavior
    if nargin==0
        level=1;
    end
    
    if ~ZG.debug || level < ZG.debugLevel
        return
    end
    
    %% ok. Now do the reporting
    
    dbk=dbstack('-completenames');
    
    thecaller = 'user interaction';
    thefun = '- none -'; %#ok<NASGU>
    thefilename = '<anon. funct>'; %#ok<NASGU>
    line = nan;
    
    switch numel(dbk)
        case 1
            msg.dbdisp('nothing to report. [no stack to speak of]')
            return
        case 2
            thefun = dbk(2).name;
            thefilename=dbk(2).file;
        otherwise
            thefun = dbk(2).name;
            thefilename=dbk(2).file;
            thecaller = dbk(3).name;
            line = dbk(3).line;
    end
    % test to see if it is a script
    
    try
        [~] = nargin(thefun); % errors if not a function
        fn_id_tag = 'function';
    catch ME
        if strcmp(ME.identifier, 'MATLAB:nargin:isScript')
            fn_id_tag = 'script';
        else
            fn_id_tag =  '';
        end
    end
    if nargin > 0
        s=sprintf('%s %s [%s]\n  called by %s line %d\n\n', fn_id_tag, thefun, thefilename, thecaller, line);
    else
        s=sprintf('[%s]\n  called by %s line %d\n', thefilename, thecaller, line);
    end
    msg.dbdisp(s,['in ' fn_id_tag ' [' thefun ']']);
end