function [tt1,tt2]=timesel(tagn)
    % TIMESEL select time intervals for further examination
    % when selecting time, pressing the y,m,d,h keys will shift the
    % date to the beginning of the nearest break.
    %
    % [TT1, TT2] = timesel(figuretag)
    %
    % timesel                       originally Alexander Allmann
    % additional functionality: Celso G Reyes
    
    ZG=ZmapGlobal.Data;
    report_this_filefun();
    
    %timeselection with mouse in cumulative number plot
    f=findobj('Tag',tagn,'-and','Type','Figure');
    if isempty(f)
        errordlg('no figure with tag [%s] found.',tagn);
        return
    end
    figure(f);
    ax = gca;
    
    set(gca,'NextPlot','add')
    seti = uicontrol('Style','text','Units','normal',...
        'Position',[.4 .01 .2 .05],...
        'String','Select Time 1',...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold', 'ForegroundColor',[.2 0 .8]);
    % XLim=get(tiplot2,'Xdata');
    
    msg.infodisp(sprintf('[%20s to %20s]   %s',...
        'CLICK ON PLOT',...
        ' ------------------ ',...
        ' Choose the STARTING date using the mouse (or y m d h keys)'),'Choose start date');
    
    [M1b, ~, ymdh] = ginput_datetime(ax,1);
    M1b = shiftDateByKey(M1b,ymdh);
    tt1 = M1b;
    p(1)=plot(ax,[tt1; tt1],ylim,'o--');
    msg.infodisp(...
        sprintf('[%20s to %20s]   %s',...
            char(M1b,'uuuu-MM-dd HH:mm:ss'),...
            'CLICK ON PLOT',...
            ' Choose the ENDING date using the mouse (or y m d h keys)'),'Choose end date');
    seti.String ='Select Time 2';
    seti.ForegroundColor=[.8 .4 .4];
    drawnow
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
    zmg.infodisp(...
        sprintf('[%20s to %20s] was Chosen',...
            char(M1b,'uuuu-MM-dd HH:mm:ss'),...
            char(M2b,'uuuu-MM-dd HH:mm:ss')),'Chosen Cut');
    
    ZG.hold_state=false;
end