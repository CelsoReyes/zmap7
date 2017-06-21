report_this_filefun(mfilename('fullpath'));

dt = 2;

dT = max(a.Date) - min(a.Date);
tp = [];

for t = min(newt2.Date):dt/10:max(newt2.Date)-dt
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
