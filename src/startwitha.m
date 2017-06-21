

if length(a(1,:))== 7
    a.Date = decyear(a(:,3:5));
elseif length(a(1,:))>=9       %if catalog includes hr and minutes
    a.Date = decyear(a(:,[3:5 8 9]));
end

% Sort the catalog in time just to make sure ...
[s,is] = sort(a.Date);
a = a(is(:,1),:) ;
minmag = max(a.Magnitude) -0.2;       %  as a default to be changed by inpu

inpu
