% Time to failure:  program developed by C. Bufe, USGS, 1989-1993.
% Forecasts time and magnitude of earthquake, based on preceding seismicity.
% Uses cumulative seismic release (i.e.; Mo, Mo^0.5, E^0.5, 10^M, #'s)
% Set constants and desig at beginning of code
% Required minimum input: event# year month day magnitude
echo off
format short e
clc

report_this_filefun(mfilename('fullpath'));

%clear variables
global tdat ydat qdat pon maxen tf kf Aeq ratio mag con cor time rms bound
kf(1) = 1.5; kf(2) = 9.1;  desig = 'Mo in Nm'
%kf(1) = .75; kf(2) = 4.55;  desig = ' (Mo in Nm)^0.5 '
%kf(1) = .75; kf(2) = 2.4;  desig = 'Benioff strain (E in Nm)^0.5'
%kf(1) = 0; kf(2) = 0;      desig = '# of eqs'
%kf(1) = 1.0; kf(2) = 0;    desig = '10^M'

% I am taking the choices away so that this can be automatically run
%datab = input('type name of data set, and return  ','s');
load Idata.m;
%eval(datab);
[m,n]=size(Idata);
%maggie = input('type col(s) # for mag, i.e. 5, 9 or [10 11 12] for Mmax');
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
for i=1:m
    Ida(i) = Idata(i,4)-0.5;
    if ((Idata(i,2))/4) > fix((Idata(i,2))/4)
        if Idata(i,3) == 12
            Jday(i) = Ida(i) + 334;
        elseif Idata(i,3) == 11
            Jday(i) = Ida(i) + 304;
        elseif Idata(i,3) == 10
            Jday(i) = Ida(i) + 273;
        elseif Idata(i,3) == 9
            Jday(i) = Ida(i) + 243;
        elseif Idata(i,3) == 8
            Jday(i) = Ida(i) + 212;
        elseif Idata(i,3) == 7
            Jday(i) = Ida(i) + 181;
        elseif Idata(i,3) == 6
            Jday(i) = Ida(i) + 151;
        elseif Idata(i,3) == 5
            Jday(i) = Ida(i) + 120;
        elseif Idata(i,3) == 4
            Jday(i) = Ida(i) + 90;
        elseif Idata(i,3) == 3
            Jday(i) = Ida(i) + 59;
        elseif Idata(i,3) == 2
            Jday(i) = Ida(i) + 31;
        elseif Idata(i,3) == 1
            Jday(i) = Ida(i);
        end
        Idata(i,time) = Idata(i,2) + Jday(i)/365;
    else
        if Idata(i,3) == 12
            Jday(i) = Ida(i) + 335;
        elseif Idata(i,3) == 11
            Jday(i) = Ida(i) + 305;
        elseif Idata(i,3) == 10
            Jday(i) = Ida(i) + 274;
        elseif Idata(i,3) == 9
            Jday(i) = Ida(i) + 244;
        elseif Idata(i,3) == 8
            Jday(i) = Ida(i) + 213;
        elseif Idata(i,3) == 7
            Jday(i) = Ida(i) + 182;
        elseif Idata(i,3) == 6
            Jday(i) = Ida(i) + 152;
        elseif Idata(i,3) == 5
            Jday(i) = Ida(i) + 121;
        elseif Idata(i,3) == 4
            Jday(i) = Ida(i) + 91;
        elseif Idata(i,3) == 3
            Jday(i) = Ida(i) + 60;
        elseif Idata(i,3) == 2
            Jday(i) = Ida(i) + 31;
        elseif Idata(i,3) == 1
            Jday(i) = Ida(i);
        end
        Idata(i,time) = Idata(i,2) + Jday(i)/366;
    end
end

%I took most of this code from morel.m
figure
pl = plot(Idata(:,time),Idata(:,8:9),'+')

%title([ datab ]);
choice = input('type 1 to select range with cursor, 2 to input event numbers');
if choice == 1
    [x,y] = ginput(2)
    i = find(Idata(:,time)>=x(1));
    j = find(Idata(:,time)<=x(2));
    mi = min(i);
    mj = max(j);
    range = 'mi:mj';
else
    range=input('type first and last event no, separated by colon, and return ','s');
    %le = length(Idata(:,1));
    %range = '5:le';
end
bound = input('type 8 for upper, 9 for lower, 10 for mid, and return ');
bound = 10;
%pon=input('type m in cum Mo = c2 + c1*(tf-t)^m,(10=free,1=linear) and return, m= ');
pon = 10;
tdat=Idata(eval(range),time);
ydat=Idata(eval(range),bound);
if abs(pon) < 0.01
    par = fmins('mzerofit',2000', .005);
elseif pon==10
    par = fmins('ttofit',[2000 -.8]', .000001);
else
    par = fmins('ttofixfit',2000', .005);
    %I took the ; off of the 'end'
end
dummy=0;
if pon==10
    dummy=10;
    pon=par(2);
    %I took the ';' off of the 'end'
end
tint = (max(tdat) - min(tdat))*0.005
clg
if pon>0.001
    if tf<max(tdat)
        tset=(min(tdat):tint:max(tdat));
        yset=con(2) + (con(1)*abs((tf-tset)).^pon);
        plot(tset,yset,tdat,ydat,'ok',tf,maxen,'x')
    else
        tset=(min(tdat)-.05:tint:tf);
        yset=con(2) + (con(1)*((tf-tset)).^pon);
        plot(tset,yset,tdat,ydat,'ok',tf,maxen,'x');
        %I took the ';' off of the 'end'
    end
elseif abs(pon)<0.001
    tset=(min(tdat)-.05:tint:max(tdat));
    yset=con(2) + (con(1)*log10(tf-tset));
    plot(tset,yset,tdat,ydat,'ok')
else
    tset=(min(tdat)-.05:tint:max(tdat));
    yset=con(2) + (con(1)*(tf-tset).^pon);
    plot(tset,yset,tdat,ydat,'ok');
    %I took the ';' off of the 'end'
end
if dummy==10
    text(min(tset),max(yset),[' tf = ' sprintf('%7.3f',(tf))]);
    text(min(tset),min(yset)+0.8*(max(yset)-min(yset)),[' mfree =  ' num2str(pon)]);
else
    text(min(tset),max(yset),[' tf = ' sprintf('%7.3f',(tf))]);
    text(min(tset),min(yset)+0.8*(max(yset)-min(yset)),[' mfixed =  ' num2str(pon)]);
end
if kf(1) < 0.001
    text(min(tset),min(yset)+0.9*(max(yset)-min(yset)),[' mag indeterminate '])
elseif pon>0.001
    text(min(tset),min(yset)+0.9*(max(yset)-min(yset)),[' mag =  ' num2str(mag) ])
else
    text(min(tset),min(yset)+0.9*(max(yset)-min(yset)),[' equivalent mag = ' num2str(mag) ' ']);

end
text(min(tset),min(yset)+0.7*(max(yset)-min(yset)),[' corcoef = ' num2str(cor(2,1))])
text(min(tset),min(yset)+0.6*(max(yset)-min(yset)),[' c= ' num2str(con(1)) '  ' num2str(con(2))])
if bound==8 abound='U'
elseif bound==9 abound='L'
elseif bound==10 abound='M'
end
if choice==1
    title([ ' ' num2str(abound) ' ' num2str(mi) ':' num2str(mj) ' '  desig]);
else
    % num2str used to be "datab" but I changed it to "Idata", now I took it out all together
    % title([ num2str(Idata) ' ' num2str(abound) ' ' num2str(range) ' ' desig]);
end

%adding x and y labels again...
xlabel('Time in years ','FontWeight','bold')
ylabel('Cumulative Moment ','FontWeight','bold')

disp('   tf       magnitude    exponent    corrcoeff     c(1)        c(2) ')
disp([tf mag pon cor(2,1) con(1) con(2)])

set(gca,'visible','on','FontWeight','bold','LineWidth',1.5)

hold on
grid

done
