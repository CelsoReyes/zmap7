function [os1,os2,newt3]=cambf(newt2)

    report_this_filefun(mfilename('fullpath'));
    clear a1 a2
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

    a2=a1;

    for i=1:size(a2,1)
        if and(a2(i,6)==0,not(a2(i,10)==0));
            a2(i,6)=round(10*(a2(i,10)*p(1)+p(2)))/10;
        end
    end

    os1=p(1);
    os2=p(2);
    newt3=a2;

    %a2
    %a1=a3;
    %clear('a2')
    %clear('a3')
