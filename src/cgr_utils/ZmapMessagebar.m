function ZmapMessagebar(message)
    % ZmapMessagebar
        
    zmb = findobj('Tag','ZmapMessageBar');
    
    if ~exist('message', 'var')
        set(zmb,'Visible','off');
        return
    end
    if ~isempty(zmb)
        zmb.Name=['Message from Zmap: "', message, '"'];
        set(zmb,'Visible','on');
    else
        r=groot;
        f=figure('Name',message,'Units','Pixels',...
            'Position',r.MonitorPositions(end,:).*[1.20 1 .8 0],...
            'MenuBar','none','NumberTitle','off',...
            'Tag','ZmapMessageBar',...
            'Visible','off');
        f.Position=f.Position+[100 0 100 0];
        frames=java.awt.Frame.getFrames();
        frames(end).setAlwaysOnTop(1);
        f.Visible='on';
    end
end