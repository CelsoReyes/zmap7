
load cmap.dat;

minz = min(min(tmap));
if minz < -490;  minz = -490 ; end
maxz = max(max(tmap));

in1 = max(find(minz > cmap(:,1))) ;
in2 = min(find(maxz < cmap(:,1))) ;

cmap2 = cmap(in1:in2,2:4);

colormap(cmap2/255)

