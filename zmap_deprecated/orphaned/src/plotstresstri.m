


figure
triplot
hold on

X = rand(100,2)*50;
X1 = [X 100-X(:,1)-X(:,2)];
X = rand(100,2)*50;
X2 = [100-X(:,1)-X(:,2) X ];
X = rand(100,2)*50;
X3 = [X(:,1) 100-X(:,1)-X(:,2) X(:,2)];

X = [X1 ; X2 ; X3];


x = X(:,1);
y = X(:,2);
z = X(:,3);
xscale = 2/sqrt(3);
yy = -(100-z)/100;
x3 = x*xscale/100;
x2 = z/173.2;     %tan 60 is 1.732
xx = xscale - x2 - x3;

for i = 1:length(X(:,1));

    pl = plot(xx(i),yy(i),'sr', 'linewidth',1,'Markersize',20);
    hold on
    set(pl,'LineWidth',.1,'Markerfacecolor',[x(i)/100  y(i)/100 z(i)/100 ],'Markeredgecolor',[x(i)/100  y(i)/100 z(i)/100 ])
end

text(-0.05,-1,'X');
text(1.2,-1,'Y');
text(0.55,0.05,'Z')
