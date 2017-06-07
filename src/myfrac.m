report_this_filefun(mfilename('fullpath'));

% fracdim

b = newt2;
i = 1;
le = length(b(:,1));
fr = zeros(le,le);

for i = 1:le
    fr(:,i)  = (distance(b(:,1),b(:,2),repmat(b(i,1),le,1),repmat(b(i,2),le,1)));
end

f2 = reshape(tril(fr),le*le,1);
l = f2 == 0; f2(l) = [];
f2 = sort(f2);

[fval,xt2] = hist(f2,0:0.5:30);
fvalsum = 2*cumsum(fval)/(le*le-1); %


figure
loglog((xt2),(fvalsum),'s')


figure
plot(log10(xt2),log10(fvalsum),'s')

