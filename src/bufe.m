% Time to failure:  program developed by C. Bufe, USGS, 1989-1993.
% (With a lot of changes by Margaret Boettcher 1996)
% Forecasts time and magnitude of earthquake, based on preceding seismicity.
% Uses cumulative seismic release (i.e.; Mo, Mo^0.5, E^0.5, 10^M, #'s)
% Set constants and desig at beginning of code
% Required minimum input: event# year month day magnitude

echo off
format short e
clc

report_this_filefun(mfilename('fullpath'));

global tdat ydat qdat pon maxen tf kf Aeq ratio mag con cor time rms bound
kf(1) = 1.5; kf(2) = 9.1;  desig = 'Mo in Nm'
%kf(1) = .75; kf(2) = 4.55;  desig = ' (Mo in Nm)^0.5 '
%kf(1) = .75; kf(2) = 2.4;  desig = 'Benioff strain (E in Nm)^0.5'
%kf(1) = 0; kf(2) = 0;      desig = '# of eqs'
%kf(1) = 1.0; kf(2) = 0;    desig = '10^M'
mag2 = [];

load Idata.m;
[m,n]=size(Idata);
maggie = 5;
for i = 1:m
    Idata(i,5)=max(Idata(i,maggie));
end
magn = 5;
time = 6;
Idata(:,7)=exp((kf(1)*(Idata(:,magn))+kf(2))*log(10));
Idata(:,8)=[cumsum(Idata(:,7))];
Idata(:,9)=[Idata(:,8)-Idata(:,7)];
Idata(:,10)=[(Idata(:,9)+Idata(:,8))/2];
Idata(:,6) = a.Date;

figure
pl = plot(Idata(:,time),Idata(:,8:9),'b+')

matdraw

disp('with mouse choose first and last event')
[x,y] = ginput(2)
hold
plot(x,y,'or')
i = find(Idata(:,time)>=x(1));
j = find(Idata(:,time)<=x(2));
mi = min(i);
mj = max(j);
range = 'mi:mj';
pon = 10;  %the pon variable creates a free or a linear plot
boundchoice = input('type 1 for upper, lower, and mid curves or 2 to just choose one, press return');
if boundchoice == 1
    bound = 8;
elseif boundchoice == 2
    bound = input('type 8 for upper, 9 for lower, 10 for mid, and return ');
end
clg;
while bound < 11
    tdat=Idata(eval(range),time);
    ydat=Idata(eval(range),bound);
    par = fmins('ttofit',[2000 -.8]', .000001);
    dummy=10;
    pon=par(2);
    tint = (max(tdat) - min(tdat))*0.005;
    if pon>0.001
        if tf<max(tdat)
            tset=(min(tdat):tint:max(tdat));
            yset=con(2) + (con(1)*abs((tf-tset)).^pon);
        else
            tset=(min(tdat)-.05:tint:tf);
            yset=con(2) + (con(1)*((tf-tset)).^pon);
        end
    elseif abs(pon)<0.001
        tset=(min(tdat)-.05:tint:max(tdat));
        yset=con(2) + (con(1)*log10(tf-tset));
    else
        tset=(min(tdat)-.05:tint:max(tdat));
        yset=con(2) + (con(1)*(tf-tset).^pon);
    end
    if bound == 8
        magup = mag;
        tfup = tf;
        tset8 = tset;
        yset8 = yset;
        maxen8 = maxen;
    elseif bound == 10
        magmid = mag;
        tfmid = tf;
        tset10 = tset;
        yset10 = yset;
        maxen10 = maxen;
    elseif bound == 9
        maglow = mag;
        tflow = tf;
        tset9 = tset;
        yset9 = yset;
        maxen9 = maxen;
    end
    if boundchoice == 1
        bound = bound + 1;
    elseif boundchoice == 2
        clf;
        hold on
        if bound == 8
            plot(tset,yset8,'b');
            text(min(tset), max(yset), ['mag(high) = ' num2str(magup) ' tf= ' sprintf('%7.3f',(tfup))],'sc');
            %			plot(tfup,maxen,'x');
        elseif bound == 9
            plot(tset,yset9,'g');
            text(min(tset), max(yset), ['mag(low) = ' num2str(maglow) ' tf= ' sprintf('%7.3f',(tflow))],'sc');
            %			plot(tflow,maxen,'x');
        elseif bound == 10
            plot(tset10,yset10,'g');
            text(min(tset), max(yset), ['mag(mid) = ' num2str(magmid) ' tf= ' sprintf('%7.3f',(tfmid))],'sc');
            %			plot(tfmid,maxen,'x');
        end
        plot(tdat,ydat,'ok');
        bound = 12;
    end
end

disp('   tf    magnitude    exponent    corrcoeff     c(1)        c(2) ')
disp([tf mag pon cor(2,1) con(1) con(2)])

if boundchoice == 1
    plot(tset8,yset8,'b')
    hold on
    plot(tset9,yset9,'g')
    plot(tset10,yset10,'r')
    legend('High','Low','Mid');
    %plot(tfup,maxen,'xb');
    %plot(tflow,maxen,'xg');
    %plot(tfmid,maxen,'xr');
    plot(tdat,ydat,'ok');

    text(min(tset), max(yset), ['mag(high) = ' num2str(magup) ' tf= ' sprintf('%7.3f',(tfup))],'sc');
    text(min(tset), max(yset)-0.2*(max(yset)-min(yset)), [' mag(mid) = ' num2str(magmid) '  tf= ' sprintf('%7.3f',(tfmid))],'sc');
    text(min(tset), max(yset)-0.4*(max(yset)-min(yset)), [' mag(low) = ' num2str(maglow) '  tf= ' sprintf('%7.3f',(tflow))],'sc');
end

set(gca,'visible','on','FontWeight','bold','LineWidth',1.5)
%adding x and y labels...
xlabel('Time in years ','FontWeight','bold')
ylabel('Cumulative Moment ','FontWeight','bold')

hold on
grid


matdraw

done


