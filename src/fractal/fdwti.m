%
% Calculates the time necessary for the calculation of the correlation dimension.
%
%
%
%
org = [2];
startfd;
radm=[];
rasm=[];
tim=[];
nvt=[];


for m= 250:250:3750

    E=ran(1:m,:);
    tic;
    pdc3nofig;
    tim=toc;
    nvt =[nvt; tim];
    E = ran;

end

figure;
ax = gca;
plot(m,nvt,'ko');
xlabel('Number of Points', 'fontsize',12);
ylabel('Seconds', 'fontsize',12);
Title('D-value Computation Time', 'fontsize',14);
set(ax,'fontsize',11);
