%    Create  reduced (in time and magnitude) catalogues "a" and "newcat"
%

report_this_filefun(mfilename('fullpath'));

%l = org(:,6) >= minma  & org(:,6) <= maxma  &  org(:,3) >= minti & org(:,3) <= maxti & org(:,7) >= mindep & org(:,7) <= maxdep;
l = a(:,6) >= minma  & a(:,6) <= maxma  &  a(:,3) >= minti & a(:,3) <= maxti & a(:,7) >= mindep & a(:,7) <= maxdep;

a = a(l,:);
%org2 = a;       % org2 is catalogue after general selection of parameters
% not changed unless a new set of general parameters is entered
newcat = [];     % newcat is created to store the last subset data
newt2 = [];      %  newt2 is a subset to be changed during analysis

% recompute depth and Magnitude display variables
%minmag = max(a(:,6)) -0.2;      % to startzma
dep1 = 0.3*(max(a(:,7))-min(a(:,7)))+min(a(:,7));
dep2 = 0.6*(max(a(:,7))-min(a(:,7)))+min(a(:,7));
dep3 = max(a(:,7));

stri1 = file1; %removed []
tim1 = minti;
tim2 = maxti;
minma2 = minma;
maxma2 = maxma;
minde = min(a(:,7));
maxde = max(a(:,7));
rad = 50.;
ic = 0;
ya0 = 0.;
xa0 = 0.;
iwl3 = 1.;
step = 3;

t1p = t0b;
t4p = teb;
t2p = t4p - (t4p-t1p)/2;
t3p = t2p;
tresh = nan;
%create catalog of "big events" if not merged with the original one:
%
l = a(:,6) > minmag ;
maepi = a(l,:);

%sort in time
[s,is] = sort(a(:,3));
a = a(is(:,1),:) ;


clear l
if length(a(:,3)) > 10000
    ty1='.';
    ty2='.';
    ty3='.';
end
subcata
