m = find(tm(:,22)<0);
avr = sum(tm(:,22))/size(m,1);
var1 = (tm(:,22)-avr).^2;
var = sum(var1)/size(m,1);
stdev = var.^(1/2);
