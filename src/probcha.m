report_this_filefun(mfilename('fullpath'));

dt = 2;

dT = max(a(:,3)) - min(a(:,3));
tp = [];

for t = min(newt2(:,3)):dt/10:max(newt2(:,3))-dt
    ;
    b = newt2;;      % ne

    l = b(:,3) < t |  b(:,3) >= t + dt;
    Q = length(b(l,3))/(dT-dt) ;   % This is the annual rate outside
    B = (length(b(:,1))-length(b(l,1)))/dt;

    P = poisscdf(B,Q);

    tp =  [ tp ; t+dt/2 P];


end


figure
plot(tp(:,1),log10(tp(:,2)));

hold on
plot(tp(:,1),log10(1-tp(:,2)),'r');
