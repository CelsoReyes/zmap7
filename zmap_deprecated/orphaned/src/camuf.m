function [ou1,ou2,newt3]=cambf(newt2)

    report_this_filefun(mfilename('fullpath'));

    clear('a1')
    clear('a2')
    a1=newt2;

    for i=1:size(a1,1)
        if a1(i,11)>10;
            a1(i,11)=0;
        end
    end

    exfig=figure_exists('Mb=f(???)',0);
    if exfig==0
        ui=figure_w_normalized_uicontrolunits('Name','Mb=f(???)',...
            'NumberTitle','off');
        figure_w_normalized_uicontrolunits(ui)
    end

    hold on
    [p,r]=corrmbms2(a1(:,11),a1(:,6),1,'mu','mb');
    hold off

    a2=a1;

    for i=1:size(a2,1)
        if and(a2(i,6)==0,not(a2(i,11)==0));
            a2(i,6)=round(10*(a2(i,11)*p(1)+p(2)))/10;
        end
    end

    ou1=p(1);
    ou2=p(2);
    newt3=a2;


    % a2 ist korrigiert
    %clear('a2')
    %clear('a3')
