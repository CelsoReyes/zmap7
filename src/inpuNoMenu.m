%  This scriptfile ask for several input parameters that can be setup
%  at the beginning of each session. The default values are the
%  extrema in the catalog
%
%a = org;        % resets the main catalogue "a" to initial state

%special version of the inpu script for Mapseis, it does not open a
%parameter selection window is the catalog should be already filtered.

report_this_filefun(mfilename('fullpath'));

%  default values
t0b = min(a(:,3));
teb = max(a(:,3));
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


think;
sele_sub;

