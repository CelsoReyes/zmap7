report_this_filefun(mfilename('fullpath'));

d = length(D);
ln = 24 - ld;
Rq = [];


for i = 0:1:20
    l = a(:,7) >= i & a(:,7) <= i+5;
    b = a(l,:);

    l = ismember(b(:,8),D);
    day = b(l,:);
    nig = b;
    nig(l,:) = [];
    rat = length(day(:,1))/length(nig(:,1)) * ln/ld;
    Rq = [Rq ; rat i+2.5 ];
end


figure
plot(Rq(:,1),-Rq(:,2))



d = length(D);
ln = 24 - ld;
Rq = [];


for i = 1:0.1:5
    l = a(:,6) >= i ;
    b = a(l,:);

    l = ismember(b(:,8),D);
    day = b(l,:);
    nig = b;
    nig(l,:) = [];
    rat = length(day(:,1))/length(nig(:,1)) * ln/ld;
    Rq = [Rq ; rat i+ 0.25 ];
end


figure
plot(Rq(:,1),Rq(:,2))


