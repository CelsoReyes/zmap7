report_this_filefun(mfilename('fullpath'));

% This is a comleteness determinationm test


[bv magco0 stan av ] =  bvalca3(newt2,inb1,inb2);

b = newt2;
dat = [];
D = [  8 9 10 11 12 13 14 15 16 17 18 ]
ld = length(D);
ln = 24 - ld;
b0 = newt2;

for i = magco0 - 1.5:0.1:magco0+1.5
    l = b0(:,6) <= i;
    b = b0(l,:);
    l = ismember(b(:,8),D);
    day = b(l,:);
    nig = b;
    nig(l,:) = [];
    rat = length(day(:,1))/length(nig(:,1)) * ln/ld;
    dat = [dat ; i rat];
end



figure
axes('pos',[0.2 0.55 0.7 0.4])
plot(dat(:,1),dat(:,2),'bo')
hold on
plot(dat(:,1),dat(:,3),'rx')
set(gca,'XTickLabels',[]);
legend('predicted','observed')
ylabel('Number of events')


axes('pos',[0.2 0.12 0.7 0.4])
plot(dat(:,1),dat(:,4),'r')
hold on
plot(dat(:,1),dat(:,4),'bo')
lin = [magco0-0.5 1 ; magco0+0.9 1 ]
plot(lin(:,1),lin(:,2),'k-.')
xlabel('Magnitude')
ylabel('Ratio observed/predicted')



