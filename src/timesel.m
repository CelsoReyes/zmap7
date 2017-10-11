function [tt1,tt2]=timesel(tagn)
    % function to select time intervalls for further examination
    % when selecting time, pressing the y,m,d,h keys will shift the
    % date to the beginning of the nearest break.
    %
    % timesel                       originally Alexander Allmann
    % additional functionality: Celso G Reyes
    
    ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
    
    %timeselection with mouse in cumulative number plot
    f=findobj('Tag',tagn,'-and','Type','Figure');
    if isempty(f)
        errordlg('no figure with tag [%s] found.',tagn);
        return
    end
    figure(f);
    ax = gca;
    
    hold on
    seti = uicontrol('Style','text','Units','normal',...
        'Position',[.4 .01 .2 .05],...
        'String','Select Time 1 ','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold', 'ForegroundColor',[.2 0 .8]);
    % XLim=get(tiplot2,'Xdata');
    
    zmap_message_center.set_info('Choose start date',sprintf('[%20s to %20s]   %s',...
        'CLICK ON PLOT',...
        ' ------------------ ',...
        ' Choose the STARTING date using the mouse (or y m d h keys)'));
    
    [M1b, ~, ymdh] = ginput_datetime(ax,1);
    M1b = shiftDateByKey(M1b,ymdh);
    tt1 = M1b;
    p(1)=plot(ax,[tt1; tt1],ylim,'o--');
    zmap_message_center.set_info('Choose end date',...
        sprintf('[%20s to %20s]   %s',...
            char(M1b,'uuuu-MM-dd hh:mm:ss'),...
            'CLICK ON PLOT',...
            ' Choose the ENDING date using the mouse (or y m d h keys)'));
    
    set(gcf,'Pointer','cross')
    [M2b, ~, ymdh] = ginput_datetime(ax,1);
    M2b = shiftDateByKey(M2b,ymdh);
    
    p(2)=plot(ax,[M2b M2b],ylim,'o--');
    pause(1)
    tt2= M2b;
    delete(seti)
    delete(p);
    if tt1>tt2     % if start and end time are switched
        tmp=tt2;
        tt2=tt1;
        tt1=tmp;
    end
    zmap_message_center.set_info('Chosen Cut',...
        sprintf('[%20s to %20s] was Chosen',...
            char(M1b,'uuuu-MM-dd hh:mm:ss'),...
            char(M2b,'uuuu-MM-dd hh:mm:ss')));
    
    ZG.hold_state=false;
end