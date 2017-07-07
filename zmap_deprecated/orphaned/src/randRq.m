% This file compute the pecentile contous for the day/nightime ratio

report_this_filefun(mfilename('fullpath'));

N = 50; nr = 50000;
p95 = []; p50 = []; p99 = []; p5 = []; p1 =[]; p = [];
for N= 50:50:400
    rat = [];
    N
    for i = 1:10000;
        s = rand(N,1)*24;
        l = s < 10;
        da = s(l);
        nig = s;
        nig(l) = [];

        rat = [rat ; (length(da)/10)/((length(nig))/14)];
    end

    p95 = [p95 ; prctile2(rat,95) N ];
    p99 = [p99 ; prctile2(rat,99) N ];
    p50 = [p50 ; prctile2(rat,50) N ];
    p5 = [p5 ; prctile2(rat,5) N ];
    p1 = [p1 ; prctile2(rat,1) N ];
    p =  [ p ; prctile2(rat,90:0.01:100)];
end

figure
plot(p95(:,2),p95(:,1),'b'); hold on
plot(p99(:,2),p99(:,1),'r'); hold on
plot(p50(:,2),p50(:,1),'k'); hold on
plot(p5(:,2),p5(:,1),'b'); hold on
plot(p1(:,2),p1(:,1),'r'); hold on
plot(p95(:,2),p95(:,1),'sk'); hold on
plot(p99(:,2),p99(:,1),'^k'); hold on
plot(p50(:,2),p50(:,1),'ok'); hold on
plot(p5(:,2),p5(:,1),'sk'); hold on
plot(p1(:,2),p1(:,1),'^k'); hold on

