
function cat = SelectPoly(catalog,vert)

%This function selects out the part of the catalog that occurs within a
%regular, closed polygon whose vertices are given as [lat lon] input in the
%vert matrix.

%Note: This program is built to run from the outside like the old
%SelectPoly.m code (now SelectPolyOld.m) but calls inpoly.m from Matlab
%Central File Exchange


%Starting the program!


[in,bnd] = inpoly([catalog(:,8) catalog(:,7)],[vert(:,2) vert(:,1)]);

a = find(in==1);

cat = catalog(a,:);

catxy = catalog;
