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
    
    
    ppos=get(groot,'PointerLocation');
    mpos=get(groot,'MonitorPositions');
    whichmonitor = ppos(1)>=mpos(:,1) & ...
        ppos(1)<= (mpos(:,1) + mpos(:,3)) & ...
        ppos(2)>=mpos(:,2) & ...
        ppos(2)<=(mpos(:,2)+mpos(:,4));
    
    mpos_curr=mpos(whichmonitor,:);
    
    % if width is a percent
    if isa(w,'Percent'), w=double(w) .* mpos_curr(3); end
    if isa(h,'Percent'), h=double(h) .* mpos_curr(4); end
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