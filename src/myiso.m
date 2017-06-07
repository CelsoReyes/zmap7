report_this_filefun(mfilename('fullpath'));


hold on

V = smooth3(zv2);
p = patch(isosurface(X,Y,Z,V, 0.7), 'FaceColor', 'red', 'EdgeColor', 'none');
%p2 = patch(isocaps(X,Y,Z,V, 0.7,'enclose','below'), 'FaceColor', 'interp', 'EdgeColor', 'none');
view(3);
colormap(jet(20))
camlight; lighting gouraud
isonormals(X,Y,Z,V, p);
caxis([ 0.55 0.96])

box on; rotate3d on ;
;
