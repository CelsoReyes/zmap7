

if length(a(1,:))== 7
    a(:,3) = decyear(a(:,3:5));
elseif length(a(1,:))>=9       %if catalog includes hr and minutes
    a(:,3) = decyear(a(:,[3:5 8 9]));
end

% Sort the catalog in time just to make sure ...
[s,is] = sort(a(:,3));
a = a(is(:,1),:) ;
minmag = max(a(:,6)) -0.2;       %  as a default to be changed by inpu

inpu
