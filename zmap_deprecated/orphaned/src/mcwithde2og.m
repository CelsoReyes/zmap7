report_this_filefun(mfilename('fullpath'));

cmp = [140 40 ,
    130 -5,
    70  40,
    -68 -20,
    -150   60]
rad=750
n=8
bap=zeros(5,n+1)
exfig=figure_exists('Compare Mcwde',0);

if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Compare Mcwde',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
hold on
for ib=1:5
    xa0=cmp(ib,1);
    ya0=cmp(ib,2);

    ll = sqrt(((a.Longitude-xa0)*cos(pi/180*ya0)*111).^2 + ((a.Latitude-ya0)*111).^2) ;
    %ll=distance(a.Longitude,a.Latitude,xa0,ya0,'km')
    l = ll < rad;
    newt2 = a.subset(l);

    BV = [];
    BV3 = [];
    mag = [];
    me = [];
    av2=[];

    Nmin = 50;
    keepcat = newt2;
    %def = {'15'};
    %ni2 = inputdlg('Depth extend?','Input',1,def);
    %l = ni2{:};
    intdep = 15 %str2double(l);
    think
    [s,is] = sort(newt2.Depth);
    newt1 = newt2(is(:,1),:) ;
    watchon;

    for dep = 0:intdep/4:500

        % calculate b-value based an weighted LS
        l = newt1(:,7) > dep  & newt1(:,7) <= dep + intdep*4;
        b = newt1(l,:);
        newt2 = b;
        length(b(:,1))
        if length(b(:,1)) > 30;

            clear Mc95 Mc90
            mcperc_ca3;
            if isnan(Mc95) == 0 
                magco = Mc95;
                %                Mc95
            elseif isnan(Mc90) == 0 
                magco = Mc90;
                %                Mc90
            else
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
            end

        else

            magco = nan;
        end

        %l = b(:,6) >= magco-0.05;
        %if length(b(l,:)) >= Nmin
        %[bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
        %  [mea bv stan,  av] =  bmemag(b(l,:));
        %else
        %   bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
        %end
        %[bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);

        BV = [BV ; magco dep ; magco dep+intdep  ; inf inf];
        BV3 = [BV3 ; magco dep  ];
        %mag = [mag ; av newt1(t+round(ni/2),7)];

        % calculate b-value based on maximum likelihood
        %av2 = [av2 ;   av  newt1(t+round(ni/2),7) stan bv];

    end
    watchoff
    newt2 = keepcat;

    x=BV3(:,1);
    y=BV3(:,2);
    l = x > 0 & y > 0;
    x = x(l); y = y(l);
    [bap(ib,:),s1_east]=polyfit(y,x,n);
    ymaxb(ib)=max(y);

    if ib==1
        plot(BV3(:,1),-BV3(:,2),'g.','MarkerSize',4);
    elseif ib==2
        plot(BV3(:,1),-BV3(:,2),'r.','MarkerSize',4);
    elseif ib==3
        plot(BV3(:,1),-BV3(:,2),'b.','MarkerSize',4);
    elseif ib==4
        plot(BV3(:,1),-BV3(:,2),'m.','MarkerSize',4);
    else
        plot(BV3(:,1),-BV3(:,2),'c.','MarkerSize',4);
    end
end

Ylim([-600 0])
y=1:1:ymaxb(1);
plot(polyval(bap(1,:),y),-y,'g')
y=1:1:230;
plot(polyval(bap(2,:),y),-y,'r')
y=1:1:ymaxb(3);
plot(polyval(bap(3,:),y),-y,'b')
y=1:1:ymaxb(4);
plot(polyval(bap(4,:),y),-y,'m')
y=1:1:ymaxb(5);
plot(polyval(bap(5,:),y),-y,'c')
hold off
xlabel('Mc')
ylabel('Depth [km]')
stra=[ 'A: ' 'Long ' num2str(cmp(1,1)) '  Lat ' num2str(cmp(1,2))]
strb=[ 'B: ' 'Long ' num2str(cmp(2,1)) '  Lat ' num2str(cmp(2,2))]
strc=[ 'C: ' 'Long ' num2str(cmp(3,1)) '  Lat ' num2str(cmp(3,2))]
strd=[ 'D: ' 'Long ' num2str(cmp(4,1)) '  Lat ' num2str(cmp(4,2))]
stre=[ 'E: ' 'Long ' num2str(cmp(5,1)) '  Lat ' num2str(cmp(5,2))]
set(gca,'FontSize',9)
legend(stra, strb,strc,strd,stre,'location', 'NorthWest')

