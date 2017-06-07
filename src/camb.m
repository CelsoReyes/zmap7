report_this_filefun(mfilename('fullpath'));

clear a1 a2 a3 a4 a5
a1=zeros(size(newt2));
a2=zeros(size(newt2));
a3=zeros(size(newt2));
a4=zeros(size(newt2));
a5=zeros(size(newt2));
a6=zeros(size(newt2));
bins=160
c1=0.9;
c2=0.9;
c3=0.9;
a1=newt2;
nmb=sum(a1(:,6)==0);
n=size(a1,1);
str1=['Anteil mit Mb=0: ' num2str(nmb/n*100) '%'];
disp(str1)

disp(' ')
exfig=figure_exists('Mb=f(Ms)',0);

if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Mb=f(Ms)',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end

hold on
[p,r]=corrmbms2(a1(:,10),a1(:,6),1,'Ms','Mb');
hold off

a2=a1;

for i=1:size(a2,1)
    if and(a2(i,6)==0,not(a2(i,10)==0));
        a2(i,6)=round(10*(a2(i,10)*p(1)+p(2)))/10;
        a4(i,1)=a2(i,6);
    end
end

nmb=sum(a2(:,6)==0);
n=size(a2,1);
str1=['Anteil mit Mb=0: ' num2str(nmb/n*100) '%'];
disp(str1)
disp(' ')

for i=1:size(a2,1)
    if a2(i,11)>10;
        a2(i,11)=0;
    end
end

exfig=figure_exists('Mb=f(???)',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits('Name','Mb=f(???)',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end

hold on
[p,r]=corrmbms2(a2(:,11),a2(:,6),1,'???','mb');
hold off

a3=a2;

for i=1:size(a3,1)
    if and(a3(i,6)==0,not(a3(i,11)==0));
        a3(i,6)=round(10*(a3(i,11)*p(1)+p(2)))/10;
        a5(i,1)=a3(i,6);
    end
end

nmb=sum(a3(:,6)==0);
n=size(a3,1);
str1=['Anteil mit Mb=0: ' num2str(nmb/n*100) '%'];
disp(str1)
disp(' ')
disp('Unbenutzbare Eintr�ge')
str1=num2str(sum((a(:,6)==0&a(:,10)==0)&a(:,11)==0)+sum((a(:,6)==0&a(:,10)==0)&a(:,11)>10));
disp(str1)

bins=0.05:.1:9;

exfig=figure_exists('Mb Histogram',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Mb Histogram',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
%subplot(2,3,1)
lo=not(a1(:,6)==0);
ah=a1(lo,:);
bar(bins, histc(ah(:,6),bins))
Xlim([1 9.5])
Xlabel('Mb')

exfig=figure_exists('Ms Histogram',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Ms Histogram',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
%subplot(2,3,2)
lo=a1(:,6)==0&not(a1(:,10)==0);
ah=a1(lo,:);
bar(bins, histc(ah(:,10),bins))
Xlim([1 9.5])
Xlabel('Ms')

exfig=figure_exists('Mu Histogram',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Mu Histogram',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
%subplot(2,3,3)
lo=a2(:,6)==0&a2(:,10)==0&not(a2(:,11)==0);
ah=a1(lo,:);
bar(bins, histc(ah(:,11),bins))
Xlim([1 9.5])
Xlabel('Mu')

exfig=figure_exists('Mb + Histogram',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Mb + Histogram',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
%subplot(2,3,4)
bar( bins,histc(a3(:,6),bins))
Xlim([1 9.5])
Xlabel('Mb +')

exfig=figure_exists('Mb aus Ms Histogram',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Mb aus Ms Histogram',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
%subplot(2,3,5)
bar( bins,histc(a4(:,1),bins))
Xlabel('Mb aus Ms')
Xlim([1 9.5])

exfig=figure_exists('Mb aus Mu Histogram',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Mb aus Mu Histogram',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
%subplot(2,3,6)
bar( bins,histc(a5(:,1),bins))
Xlabel('Mb aus Mu')
Xlim([1 9.5])


%a1=a3;
%clear('a2')
%clear('a3')
