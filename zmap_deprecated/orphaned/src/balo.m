report_this_filefun(mfilename('fullpath'));

[s,is] = sort(newa(:,10));
newt1 = newa(is(:,1),:) ;
bv3 = [];
for i = 1:20:length(newa)-200
    [bv av stan ] =  bvalca2(newt1(i:i+200,:));
    bv3 = [bv3 ; bv newt1(i+100,10) stan ];
end


figure
plot(bv3(:,2),bv3(:,1))


