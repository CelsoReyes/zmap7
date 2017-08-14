function [tt1,tt2]=timesel(var1)
    % timesel.m                       Alexander Allmann
    % function to select time intervalls for further examination
    
    
    global ccum cum
    ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
    
    %timeselection with mouse in cumulative number plot
    if var1==1 || var1==4
        messtext=...
            ['To select a time window for further examination'
            'Please select the start- and endtime of the    '
            'sequence with the LEFT mouse button            '];
        zmap_message_center.set_message('Time Selection ',messtext);
        if var1==1
            figure(ccum)
        else
            figure(cum)
        end
        ax = gca;
        hold on
        seti = uicontrol('Style','text','Units','normal',...
            'Position',[.4 .01 .2 .05],...
            'String','Select Time 1 ','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold', 'ForegroundColor',[.2 0 .8]);
        % XLim=get(tiplot2,'Xdata');
        
        [M1b, ~, ~] = ginput_datetime(ax,1);
        tt1 = M1b;
        plot(tt1,0,'o');
        seti.String = 'Select Time 2';
        
        set(gcf,'Pointer','cross')
        [M2b, ~, ~] = ginput_datetime(ax,1);
        plot(M2b,0,'o')
        tt2= M2b;
        delete(seti)
        if tt1>tt2     % if start and end time are switched
            tmp=tt2;
            tt2=tt1;
            tt1=tmp;
        end
        ZG.hold_state=false;
    end
end
