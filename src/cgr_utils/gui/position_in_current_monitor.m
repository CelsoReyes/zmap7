function position = position_in_current_monitor(w,h,alignment, border)
    % POSITION_IN_CURRENT_MONITOR get coordinates for a figure, within active monitor
    %
    % POS = POSITION_IN_CURRENT_MONITOR( W , H ) will provide a position that can be used to
    %       create a figure. If possible, the figure will be created on the screen occupied
    %       by the mouse.  If the figure is too tall for the screen, then it will appear on
    %       a screen that is tall enough
    %
    %       POS is of the format [ LowerLeftX lowerLeftY Width, Height]
    %
    % POS = POSITION_IN_CURRENT_MONITOR( W, H, ALIGNMENT) where ALIGNMENT is 'center','left', 
    %       or 'right' will control where adjust the position accordingly.
    %       The default is 'center'
    %
    % POS = POSITION_IN_CURRENT_MONITOR( W, H, ALIGNMENT, BORDER) will pad the position
    %       so that the figure is BODER pixels away from the edge of the screen. THis only
    %       works when the ALIGNMENT is not center.
    %
    %  Example.
    %       % create figure box (500w x 450h) in center of current screen
    %       f=figure('Name','test','Position',position_in_current_monitor(500,450))
    
    persistent gave_monitor_warning
    ppos=get(groot,'PointerLocation');
    mpos=get(groot,'MonitorPositions');
    whichmonitor = ppos(1)>=mpos(:,1) & ...
        ppos(1)<= (mpos(:,1) + mpos(:,3)) & ...
        ppos(2)>=mpos(:,2) & ...
        ppos(2)<=(mpos(:,2)+mpos(:,4));
    
    if whichmonitor==0
        if  isempty(gave_monitor_warning)
            % perhaps monitor status changed (added?) since MATLAB started
            s=sprintf(['MATLAB might have incorrect monitor positions.\nMATLAB is configured for %d monitor(s),',...
                ' but your pointer location suggests otherwise.  This information is stored at startup, so if',...
                ' you added a monitor since starting MATLAB, then restarting MATLAB should correct the issue.\n\n',...
                'This message will not repeat until the next time you restart zmap.'], size(mpos,1));
            gave_monitor_warning = true;
            h=errordlg(s,'MATLAB might not currently recognize a monitor','modal');
            waitfor(h);
        end
        whichmonitor=1;
    end
    mpos_curr=mpos(whichmonitor,:);
        
        
    % if width is a percent
    if isa(w,'Percent')
        tmp=double(w) .* mpos_curr(3);
        w=tmp;
    end
    if isa(h,'Percent')
        tmp=double(h) .* mpos_curr(4); 
        h=tmp;
    end
    % try to ensure dialog box is shown on screen large enough to accomodate it
    if h > mpos_curr(4)
        tallEnough=mpos(:,4)>=h;
        if any(tallEnough)
            mpos_curr=mpos(find(tallEnough,1,'first'),:);
        end
    end
    
    if ~exist('alignment','var') || isempty(alignment)
        alignment='center';
    end
    if ~exist('border')
        border=0;
    end
    
    switch alignment
        case 'left'
            vcenter=mpos_curr(2)+mpos_curr(4)/2;
            position =[ mpos_curr(1)+border vcenter-(h/2) w h];
        case 'right'
            vcenter=mpos_curr(2)+mpos_curr(4)/2;
            position = [mpos_curr(1)+mpos_curr(3)-(border+w) vcenter-(h/2) w h];
        otherwise % assume center
            mcenter=[mpos_curr(1)+ mpos_curr(3)/2 , mpos_curr(2)+mpos_curr(4)/2];
            position=[mcenter(1)-(w/2) mcenter(2)-(h/2) w h];
    end
    
end