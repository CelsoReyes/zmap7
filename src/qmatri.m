report_this_filefun(mfilename('fullpath'));

R = 0.3:1:20;
Tw = 0.1:0.1:4.5;
aa = a;

%maepi = [ -116.5 34.25 1992.48 6 6 7.2 10  ];
M = zeros(length(R),length(Tw))*nan; i1 = 0; i2 = 0;
maepi(1,3) = 1992.48;
an = maepi(1,:);
y = an(1,2),x = an(1,1); z = an(:,7); Te = an(:,3);
%figure_w_normalized_uicontrolunits(map)
axes(hs);
[x,y] = ginput(1)
Te = max(a(:,3))
z = 5

l = a(:,3) < Te;
a = a(l,:);


dT = max(a(:,3)) - min(a(:,3));
di = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + (a(:,7)-z).^2) ;


N =[];
for i1 = 1:1:length(R)
    ;
    % take first ni points
    %
    l = di <= R(i1);
    b = a(l,:);      % ne
    for i2 = 1:1:length(Tw)

        l = b(:,3) >= Te-Tw(i2) & b(:,3) < Te;
        Q = length(b(l,3)) ;   % This is the annual rate
        B = length(b(:,1))*Tw(i2)/dT;
        P = poisscdf(Q,B);


        M(i1,i2) = P;

    end
    N =[N ;  length(b)];
    i2 = 0;
end
i1 = 0;

% plot the results
plotqmatri;

a = aa;
