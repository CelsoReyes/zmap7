function [onoff, currlevel, s] = report_this_filefun(level, newlevel)
% this script replaced all the individual "disp('This is ...') messages
% it can be used to track which files are used, or do some function/file specific
% setup
%  REPORT_THIS_FILEFUN() display message if ANY level has been set
%  REPORT_THIS_FILEFUN( LEVEL ) print message if 
%  REPORT_THIS_FILEFUN( 'set', NEWLEVEL) set the minimum debug level for reporting
%  REPORT_THIS_FILEFUN('off') clear (stop) debugging
%  REPORT_THIS_FILEFUN('on') start debugging at whatever level was previously defined
%  [isActive, level] = REPORT_THIS_FILEFUN('status');


%called by script or function?
% modified from: http://blogs.mathworks.com/loren/2013/08/26/what-kind-of-matlab-file-is-this/

persistent debugLevel debugging
if isempty(debugging)
    debugging = false;
end

if isempty(debugLevel)
    debugLevel=1;
end

behaviorchange=  exist('level','var') && ischar(level);

%% change debugging behavior


if behaviorchange
    switch level
        case 'on'
            debugging=true;
        case 'off'
            debugging=false;
        case 'set'
            assert(exist('newlevel','var') && isnumeric(newlevel));
            debugLevel=newlevel;
        case 'status'
            fprintf('report_this_filefun Status [debugging: %d , level: %d]\n',debugging, debugLevel);
        case 'test'
            dotest();
        otherwise
            error('unknown debugging option')
    end
elseif nargin==0
    level=1;
end

%% 
onoff=debugging;
currlevel=debugLevel;
s='';

if ~debugging || behaviorchange || level < debugLevel
    return
end
    
%% ok. Now do the reporting

dbk=dbstack('-completenames');

thecaller = 'user interaction';
thefun = '- none -';
thefilename = '<anon. funct>';
line = nan;

switch numel(dbk)
    case 1
        disp('nothing to report. [no stack to speak of]')
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
    maxInputs = nargin(thefun); % errors if not a function
    fn_id_tag = 'function';
catch ME
    if strcmp(ME.identifier, 'MATLAB:nargin:isScript')
        fn_id_tag = 'script';
    else
        fn_id_tag =  '';
    end
end

fprintf('\n- %s %s [%s]\n  called by %s line %d\n\n', fn_id_tag, thefun, thefilename, thecaller, line);

if nargout==3
    s=sprintf('\n- %s %s [%s]\n  called by %s line %d\n\n', fn_id_tag, thefun, thefilename, thecaller, line);
end

function dotest
    [orig_onoff, orig_lev] = report_this_filefun();
    assert(report_this_filefun('off')==false);
    
    [onoff,lev]=report_this_filefun('set',3);
    assert( onoff==false && lev==3 );
    
    report_this_filefun('on');
    report_this_filefun('set',2);
    [onoff,lev]=report_this_filefun('status');
    assert(onoff==true && lev==2);
    
    [~,~,s]=report_this_filefun(3); 
    assert(~isempty(s));
    [~,~,s]=report_this_filefun(2);
    assert(~isempty(s));
    [~,~,s]=report_this_filefun(1);
    assert(isempty(s));
    
    assert(onoff==true && lev==2);
    
    if orig_onoff
        report_this_filefun('on');
    else
        report_this_filefun('off');
    end
    report_this_filefun('set',orig_lev);
    
    [onoff,lev]=report_this_filefun('status');
    assert(onoff==orig_onoff && lev==orig_lev);
    
    