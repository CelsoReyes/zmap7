%  This scriptfile ask for several input parameters that can be setup
%  at the beginning of each session. The default values are the
%  extrema in the catalog
%
%a = org;        % resets the main catalogue "a" to initial state

%special version of the inpu script for Mapseis, it does not open a
%parameter selection window is the catalog should be already filtered.

report_this_filefun(mfilename('fullpath'));

%  default values
t0b = min(a.Date);
teb = max(a.Date);
tdiff = (teb - t0b)*365;

if ~exist('par1','var')
    %  if tdiff>10                 %select bin length respective to time in catalog
    %     par1 = ceil(tdiff/100);
    %  elseif tdiff<=10 & tdiff>1
    %     par1 = 0.1;
    %  elseif tdiff<=1
    %     par1 = 0.01;
    %  end
    par1 = 30;
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


think;
sele_sub;

