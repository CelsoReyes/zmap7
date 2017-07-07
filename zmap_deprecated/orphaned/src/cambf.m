function [newt3,os1,os2,ou1,ou2]=cambf(newt2)

    report_this_filefun(mfilename('fullpath'));

    a1=zeros(size(newt2));
    a2=zeros(size(newt2));
    a3=zeros(size(newt2));
    a1=newt2;

    exfig=figure_exists('Mb=f(Ms)',0);
    if exfig==0
        ui=figure_w_normalized_uicontrolunits('Name','Mb=f(Ms)',...
            'NumberTitle','off');
        figure_w_normalized_uicontrolunits(ui)
    end

    hold on
    [p,r]=corrmbms2(a1(:,10),a1(:,6),1,'Ms','Mb');
    hold off

    os1=p(1)
    os2=p(2)

    a2=a1;

    for i=1:size(a2,1)
        if and(a2(i,6)==0,not(a2(i,10)==0));
            a2(i,6)=round(10*(a2(i,10)*p(1)+p(2)))/10;
        end
    end

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

    ou1=p(1)
    ou2=p(2)

    a3=a2;

    for i=1:size(a3,1)
        if and(a3(i,6)==0,not(a3(i,11)==0));
            a3(i,6)=round(10*(a3(i,11)*p(1)+p(2)))/10;
        end
    end

    newt3=a3;
    %clear('a2')
    %clear('a3')
