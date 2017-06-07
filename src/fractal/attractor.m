Eat = [E(:,1).*111, E(:,2).*111, E(:,7)];
Eatlon = newt2(:,1).*111;
Eatran = ran(:,1).*111;
Eattim = newt2(:,3);
incr = a(:,3);
eat = [((Eat(:,1).^2 + Eat(:,2).^2 + Eat(:,3)).^0.5)];
%
%
%
p = min(a(:,3));


tim2 = [];
tim3 = [];

tim1 = [];
tic;
for p = min(a(:,3)):0.0000011:max(a(:,3))

    match1 = find(a(:,3)< (p + 0.0000005) & a(:,3)> (p - 0.0000005));
    tim1 = [tim1; match1];

end
toc;

time = a(tim1,3);
Eatlon = [a(tim1,:)]; %[a(tim,1), a(tim,2), a(tim,7)];



for p = min(a(:,3)):0.001+0.01:max(a(:,3))
    match2 = find(a(:,3)< (p + 0.0001) & a(:,3)> (p - 0.0001));
    tim2 = [tim2; match2];
end
Eat2 = [eat(tim2)];


for p = min(a(:,3)):0.001+0.02:max(a(:,3))
    match3 = find(a(:,3)< (p + 0.0001) & a(:,3)> (p - 0.0001));
    tim3 = [tim3; match3];
end
Eat3 = [eat(tim3)];

Eat = [Eat1 Eat2 Eat3];


for m = 0:6

    time1(1:3202,(m+1)) = (E(:,3)+ 0.005*m);
    %Eat(1:3202,(m)) = [Eat(:,1) eat(:,2)+0.005*m;
end

ea = find(E(:,3)>min(E(:,3))+0.05*4);
E = E(ea,:);

%
%
%

m = 1:5:2435; %size(pairdist,1);
figure;
%plot3(eat (m-2), eat(m-1,:), eat(m,:), 'k.', 'Markersize', 0.5);
%plot3(a((m+40),3), a(m+20,3), a(m,3), 'k.', 'Markersize', 0.5);
u = plot3(eat(m),eat(m+10),eat(m+20));%,'k.');
clear m;
%
%
%

k = 1:798;
u = [eat(k),eat(k+0.75),eat(k+1.5)];%,eat(k+2.25),eat(k+3),eat(k+3.75)];
figure;
%plot3(u(:,1),u(:,2), u(:,3), 'k.', 'Markersize', 0.5);%u(m-2,:)
xlabel('kt');
ylabel('kt+T');
zlabel('kt+2T');

k = 1:10:3012245;
figure;
plot3(pairdist(k),pairdist(k+20), pairdist(k+40));%,'k.', 'Markersize', 0.5);

%plot(E(n-1,1), E(n,1),'k.', 'Markersize', 0.5);
%plot(E(n-1,2), E(n,2),'k.', 'Markersize', 0.5);
%plot(E(n-1,7), E(n,7),'k.', 'Markersize', 0.5);

k = 1:1:3193;
E = [Eatlon(k),Eatlon(k+2),Eatlon(k+3), Eatlon(4), Eatlon(k+5), Eatlon(6), Eatlon(k+7), Eatlon(k+8)];

mEatlon = sum(Eatlon,1)/3202;
Eatlon = Eatlon-mEatlon;
HSig = figure;
plot(Eattim, Eatlon);
axis([2500 3000 -10 -15]);

[ps,freq] = spectrum(Eatlon,256,0,[],0.0634);
Hpws = figure;
plot(freq,ps(:,1));
axis([0 0.01 0 30]);
spectrum(Eatlon);
