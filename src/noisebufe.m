% Time to failure:  program developed by C. Bufe, USGS, 1989-1993.
% (With a lot of changes by Margaret Boettcher 1996)
% Forecasts time and magnitude of earthquake, based on preceding seismicity.
% Uses cumulative seismic release (i.e.; Mo, Mo^0.5, E^0.5, 10^M, #'s)
% Set constants and desig at beginning of code
% Required minimum input: event# year month day magnitude

%it is set up for doing a noise test now...
%!!!problems with the index size being wrong for Idata???

report_this_filefun(mfilename('fullpath'));

echo off
format short e
clc
rantf = [];ranmag=[];
global tdat ydat qdat pon maxen tf kf Aeq ratio mag con cor time rms bound
kf(1) = 1.5; kf(2) = 9.1;  desig = 'Mo in Nm'
%kf(1) = .75; kf(2) = 4.55;  desig = ' (Mo in Nm)^0.5 '
%kf(1) = .75; kf(2) = 2.4;  desig = 'Benioff strain (E in Nm)^0.5'
%kf(1) = 0; kf(2) = 0;      desig = '# of eqs'
%kf(1) = 1.0; kf(2) = 0;    desig = '10^M'
yset2 = [];mag2 = [];

load Idata.m;
[m,n]=size(Idata);
maggie = 5;
for i = 1:m
    Idata(i,5)=max(Idata(i,maggie));
end

%noise test:
for z = 1:100
    z
    ra = rand(m,1);
    ra = ra/2.5-0.2;
    Idata(:,5) = ra + Idata(:,5);   %for the noise test
    magn = 5;
    time = 6;
    Idata(:,7)=exp((kf(1)*(Idata(:,magn))+kf(2))*log(10));
    Idata(:,8)=[cumsum(Idata(:,7))];
    Idata(:,9)=[Idata(:,8)-Idata(:,7)];
    Idata(:,10)=[(Idata(:,9)+Idata(:,8))/2];
    Idata(:,6) = a(:,3);

    if z == 1
        manual = input('type 1 for manual choosing of first and last points, or 2 to do it automatically');
        if manual == 1
            figure
            pl = plot(Idata(:,time),Idata(:,8:9),'b+')
            
            matdraw
            disp('with mouse choose first and last event')
            [x,y] = ginput(2)
            hold
            plot(x,y,'or')
            i = find(Idata(:,time)>=x(1));
            j = find(Idata(:,time)<=x(2));
        else
            i = 1;
            j = m;
        end
    end
    mi = min(i);
    mj = max(j);
    range = 'mi:mj';
    pon = 10;  		%the pon variable creates a free or a linear plot
    boundchoice = 2;
    bound = 8;

    clg;

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
    mag2 = [mag2, mag tf];
    if bound == 8
        magup = mag;
        tfup = tf;
        rantf = [rantf tf];
        ranmag = [ranmag mag];
    end
end

disp('   tf    magnitude    exponent    corrcoeff     c(1)        c(2) ')
disp([tf mag pon cor(2,1) con(1) con(2)])

hold on
grid


matdraw

figure
histogram(ranmag);
grid

matdraw

figure
histogram(rantf);
grid

matdraw

done


