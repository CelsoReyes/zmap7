report_this_filefun(mfilename('fullpath'));


%mbmsa(x3,y3)
%mbmsb(x3,y3)
%mbmua(x3,y3)
%mbmub(x3,y3)
mt1=3
mt2=5
mt3=7

bu= [];
bs=[];
ncat=[];
dx=10
dy=10
cmeq=50
xin3=[0 1 2 3 4 5 6 7 8]

for x3=-180:dx:170
    for y3=-90:dy:80
        str=[num2str(x3) ' ' num2str(y3)];
        disp(str)
        x2=[x3;x3+dx;x3+dx;x3];
        y2=[y3;y3;y3+dy;y3+dy];

        %think
        x2 = [x2 ; x2(1)];
        y2 = [y2 ; y2(1)];      %  closes polygon


        figure_w_normalized_uicontrolunits(cufi)
        plos2 = plot(x2,y2,'b-','era','xor');        % plot outline
        sum3 = 0.;
        pause(0.3)
        % calculate points with a polygon

        XI = a.Longitude;          % this substitution just to make equation below simple
        YI = a.Latitude;
        l2 = polygon_filter(x,y, XI, YI, 'inside');
        newt2 = a.subset(l2);                  % newcat is created
        %a = newcat;                      % a and newcat now equal to reduced catalogue
        %newt2 = newcat;                  % resets newt2

        if sum(not(newt2.Magnitude==0) & not(newt2(:,10)==0))>cmeq  &&  sum(newt2.Magnitude==0  &&  not(newt2(:,10)>0))>0
            [b1,b2,newt3]=camsf(newt2);
            bs = [bs ; x3 y3 b1 b2];
            newt2=newt3;
        end

        if sum(not(newt2.Magnitude==0) & not(newt2(:,11)==0) & newt2(:,11)<10)>cmeq  &&  sum(newt2.Magnitude==0  &&  not(newt2(:,10)>0))>0
            [b1,b2,newt3]=camuf(newt2);
            bu = [bu ; x3 y3 b1 b2];
            newt2=newt3;
        end

        ncat = [ncat; newt2];
        if size(ncat,1)>0
            bins=0.05:.1:9;
            exfig=figure_exists('Mb+ Histogram gr',0);
            if exfig==0
                ui=figure_w_normalized_uicontrolunits( 'Name','Mb+ Histogram gr',...
                    'NumberTitle','off');
                figure_w_normalized_uicontrolunits(ui)
            end
            clf
            bar(bins, histc(ncat(:,6),bins))
            Xlim([1 9.5])
            Xlabel('Mb')
        end

    end
end

[ncat,ps1,ps2,pu1,pu2]=cambf(ncat);



figure
Xlim([-180 180])
Ylim([-90 90])
patch([-180 180 180 -180],[-90 -90 90 90],ps1*mt1+ps2-mt1)
for i3=1:size(bs,1)
    patch([bs(i3,1) bs(i3,1)+dx bs(i3,1)+dx bs(i3,1)] ,[bs(i3,2) bs(i3,2) bs(i3,2)+dy bs(i3,2)+dy],round(10*(bs(i3,3)*mt1+bs(i3,4)-mt1))/10)
end
title('Ms=3')
colorbar

figure
Xlim([-180 180])
Ylim([-90 90])
patch([-180 180 180 -180],[-90 -90 90 90],ps1*mt2+ps2-mt2)
for i3=1:size(bs,1)
    patch([bs(i3,1) bs(i3,1)+dx bs(i3,1)+dx bs(i3,1)] ,[bs(i3,2) bs(i3,2) bs(i3,2)+dy bs(i3,2)+dy],round(10*(bs(i3,3)*mt2+bs(i3,4)-mt2))/10)
end
title('Ms=5')
colorbar


figure
Xlim([-180 180])
Ylim([-90 90])
patch([-180 180 180 -180],[-90 -90 90 90],ps1*mt3+ps2-mt3)
for i3=1:size(bs,1)
    patch([bs(i3,1) bs(i3,1)+dx bs(i3,1)+dx bs(i3,1)] ,[bs(i3,2) bs(i3,2) bs(i3,2)+dy bs(i3,2)+dy],round(10*(bs(i3,3)*mt3+bs(i3,4)-mt3))/10)
end
title('Ms=7')
colorbar

figure
Xlim([-180 180])
Ylim([-90 90])
patch([-180 180 180 -180],[-90 -90 90 90],pu1*mt1+pu2-mt1)
for i3=1:size(bu,1)
    patch([bu(i3,1) bu(i3,1)+dx bu(i3,1)+dx bu(i3,1)] ,[bu(i3,2) bu(i3,2) bu(i3,2)+dy bu(i3,2)+dy],round(10*(bu(i3,3)*mt1+bu(i3,4)-mt1))/10)
end
title('Mu=3')
colorbar

figure
Xlim([-180 180])
Ylim([-90 90])
patch([-180 180 180 -180],[-90 -90 90 90],pu1*mt2+pu2-mt2)
for i3=1:size(bu,1)
    patch([bu(i3,1) bu(i3,1)+dx bu(i3,1)+dx bu(i3,1)] ,[bu(i3,2) bu(i3,2) bu(i3,2)+dy bu(i3,2)+dy],round(10*(bu(i3,3)*mt2+bu(i3,4)-mt2))/10)
end
title('Mu=5')
colorbar

figure
Xlim([-180 180])
Ylim([-90 90])
patch([-180 180 180 -180],[-90 -90 90 90],pu1*mt3+pu2-mt3)
for i3=1:size(bu,1)
    patch([bu(i3,1) bu(i3,1)+dx bu(i3,1)+dx bu(i3,1)] ,[bu(i3,2) bu(i3,2) bu(i3,2)+dy bu(i3,2)+dy],round(10*(bu(i3,3)*mt3+bu(i3,4)-mt3))/10)
end
title('Mu=7')
colorbar

figure
hold on
for i3=1:size(bu,1)
    plot(xin3,polyval([bu(i3,3) bu(i3,4)],xin3))
end

bins=0.05:.1:9;
exfig=figure_exists('Mb+ Histogram gr',0);
if exfig==0
    ui=figure_w_normalized_uicontrolunits( 'Name','Mb+ Histogram gr',...
        'NumberTitle','off');
    figure_w_normalized_uicontrolunits(ui)
end
clf
bar(bins, histc(ncat(:,6),bins))
Xlim([1 9.5])
Xlabel('Mb')


%save('c:/juerg/kncat.mat', 'ncat')
%save('c:/juerg/kbs.mat', 'bs')
%save('c:/juerg/kbu.mat', 'bu')
%quit
