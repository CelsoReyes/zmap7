report_this_filefun(mfilename('fullpath'));

R = 0:1:150;
r = sqrt(R.^2 + 5.57^2);


M = 5.5;
Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) ;

Y = 10.^Y;
figure
plot(R,Y)

M = 6.5;
Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) ;

Y = 10.^Y;
hold on; plot(R,Y,'r')

M = 7.5;
Y = -0.136 + 0.229*(M-6) - 0.778 * log10(r) ;
Y = 10.^Y;
hold on; plot(R,Y,'g')
