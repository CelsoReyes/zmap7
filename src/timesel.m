function [tt1,tt2]=timesel(var1)
    % timesel.m                       Alexander Allmann
    % function to select time intervalls for further examination
    
    ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
    
    %timeselection with mouse in cumulative number plot
    if var1==1 || var1==4
        if var1==1
            tagn='ccum'
        else
            tagn='cum'
        end
        figure(findobj('Tag',tagn,'-and','Type','Figure'));
        ax = gca;
        hold on
        seti = uicontrol('Style','text','Units','normal',...
            'Position',[.4 .01 .2 .05],...
            'String','Select Time 1 ','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold', 'ForegroundColor',[.2 0 .8]);
        % XLim=get(tiplot2,'Xdata');
        
        ZmapMessagebar(sprintf('[%20s to %20s]   %s',...
            'CLICK ON PLOT',...
            ' ------------------ ',...
            ' Choose the STARTING date using the mouse'));

        [M1b, ~, ~] = ginput_datetime(ax,1);
        tt1 = M1b;
        plot(tt1,0,'o');        
        ZmapMessagebar(sprintf('[%20s to %20s]   %s',...
            char(M1b,'uuuu-MM-dd hh:mm:ss'),...
            'CLICK ON PLOT',...
            ' Choose the ENDING date using the mouse');
        
        set(gcf,'Pointer','cross')
        [M2b, ~, ~] = ginput_datetime(ax,1);
        plot(M2b,0,'o')
        tt2= M2b;
        delete(seti)
        if tt1>tt2     % if start and end time are switched
            tmp=tt2;
            tt2=tt1;
            tt1=tmp;
        endZmapMessagebar(sprintf('[%20s to %20s] was Chosen',...
            char(M1b,'uuuu-MM-dd hh:mm:ss'),...
            char(M2b,'uuuu-MM-dd hh:mm:ss'));

        ZmapMessagebar();
        ZG.hold_state=false;
    end
end
