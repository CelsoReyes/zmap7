report_this_filefun(mfilename('fullpath'));

l3 = [];
for j = 1:max(d2)
    l= find(d2 == j);
    l2 = repmat(l,j,1);
    l3 = [l3 ;  reshape(l2,length(l2(1,:))*j,1)];
end

rose(l3*pi/180);
