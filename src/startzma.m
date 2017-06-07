%
% This is the startup file for the program "MagSig". To run
% it your startup.m file in the local directory must include several
% searchpathes pointing to several supplementary .m files.
%
% startzma file will ask you for an input file name. The data
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
%   last revision:    August 1994
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

report_this_filefun(mfilename('fullpath'));

format short
global hodi c1 c2 c3 sys fontsz bfig xsec_fig teb t0b ho a sax1 sax2
global mess  cum freq_field histo hisvar strii1 strii2 fontsz
global torad Re scale cb1 cb2 cb3 lat1 lon1 lat2 lon2 leng pos
global freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button maepi
global seismap dx dy ni xt3 bvalsum3 bmapc newa2 b1 b2 n1 n2 aw bw si ew mrt

% start program and load data:
messtext=...
    ['Please select an earthquake datafile.'
    'This file needs to be in matlab *.mat'
    'Format. If you do not have a *.mat   '
    'file use <create *.mat Datafile> in  '
    'the menu                             '];
welcome('Load Data',messtext)

% Get eq data
[file1,path1] = uigetfile([ '*.mat'],' Earthquake Datafile','Location',[400 400]);

if length(path1) < 2
    welcome(' ',' ');done
    return
else
    lopa = [path1 file1];
    name = file1;
    messtext=...
        ['Thank you! Now loading data'
        'Hang on...                 '];
    welcome('  ',messtext)

    try
        set(action_button,'String','Loading Data...');
    catch ME
        error_handler(ME,@do_nothing);
        welcome
    end
    watchon;
    drawnow

    try
        load(lopa)
    catch ME
        error_handler(ME, 'Error lodaing data! Are they in the right *.mat format?');
    end

    if exist('a')==0   ; errordlg(' Error - No catalog data loaded !');return; end
    if isempty(a)==1   ; errordlg(' Error - No catalog data loaded !');return; end

    if max(a(:,3)) < 100;
        a(:,3) = a(:,3)+1900;
        errdisp =    ['The catalog dates appear to have 2 digits years. Action taken: added 1900 for Y2K compliance'];
        welcome('Error!  Alert!',errdisp)
        warndlg(errdisp)
    end


end % if length
global uiInput1 uiInput2

if max(a(:,6)) > 10
    errdisp = ' Error -  Magnitude greater than 10 detected - please check magnitude!!';
    warndlg(errdisp)
end   % if

try
    load volcano.mat
catch ME
    error_handler(ME, @do_nothing);
end
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

%R calculate time in decimals and substitute in column 3 of file  "a"
if length(a(1,:))== 7
    a(:,3) = decyear(a(:,3:5));
elseif length(a(1,:))>=9       %if catalog includes hr and minutes
    a(:,3) = decyear([floor(a(:,3)) a(:,4:5) a(:,8) a(:,9)]);
end

% Sort the catalog in time just to make sure ...
[s,is] = sort(a(:,3));
a = a(is(:,1),:) ;


% org = a;                         %  org is to remain unchanged
minmag = max(a(:,6)) - 0.2;       %  as a default to be changed by inpu

%  ask for input parameters
%
watchoff
clear s is
typele = 'dep';
do = 'view';

%  default values
t0b = min(a(:,3));
teb = max(a(:,3));
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
minmag = max(a(:,6)) -0.2;
dep1 = 0.3*max(a(:,7));
dep2 = 0.6*max(a(:,7));
dep3 = max(a(:,7));
minti = min(a(:,3));
maxti  = max(a(:,3));
minma = min(a(:,6));
maxma = max(a(:,6));
mindep = min(a(:,7));
maxdep = max(a(:,7));
ra = 5;
mrt = 6;
met = 'ni';

inpu

