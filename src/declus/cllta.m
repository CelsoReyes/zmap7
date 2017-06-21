function cllta(var1)
    %cllta.m                             A.Allmann
    %function to calculate the LTA-function of a givenn graph
    %calculates a z-value useing a given window length iwl
    %operates on ttcat
    %
    %Last modification 6/95
    global ttcat par1 xt cumu cumu2 newt2 pyy
    global file1 freq_field freq_slider iwl3 par5

    a=newt2;

    % initial values
    %
    max_freq = 20;
    min_freq = par5/365;
    if var1==1                       %default
        iwl = 13*par5            % for bin of 28 days, iwl = 13 is about 1 year

    elseif var1==2
        iwl = round(iwl3*365/par5);

        if (iwl<min_freq)
            iwl=min_freq;
        end
        if (iwl>max_freq)
            iwl=max_freq;
        end
        pause(0.1)
        set(freq_field,'String',num2str(iwl3));
        set(freq_slider,'Value',iwl3);
    end

    t0b = a(1,3);
    n = a.Count;
    teb = a(n,3);
    tdiff = round((teb - t0b)*365/par5);
    iwl3 = iwl*par5/365;                 % iwl3 is window in years

    pause(0.1)
    %
    % make the interface
    %
    clf reset
    orient tall
    rect = [0.2,  0.25, 0.65, 0.70];
    axes('position',rect)
    str2 = [file1];
    title(str2)
    set(gcf,'Units','normalized');

    freq_field=uicontrol('Style','edit',...
        'Position',[.40 .00 .12 .06],...
        'Units','normalized','String',num2str(iwl3),...
        'Callback','iwl3=str2double(get(freq_field,''String''));delete(pyy); cllta(2);');

    freq_slider=uicontrol('BackGroundColor',[ 0.8 0.8 0.8],'Style','slider',...
        'Position',[.30 .10 .45 .06],...
        'Units','normalized','Value',iwl3,'Max',max_freq,'Min',min_freq,...
        'Callback','iwl3=get(freq_slider,''Value'');delete(pyy); cllta(2);');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.9 .30 .10 .05],...
        'Units','normalized','Callback','close;pyy=[];','String','Close');

    %uicontrol('Units','normal','Position',[.9 .90 .10 .05],'String','Print ', 'Callback','print')

    %uicontrol('Units','normal','Position',[.9 .80 .10 .05],'String','Save', 'Callback','sav_lta')

    uicontrol('Units','normal','Position',[.9 .70 .10 .05],'String','Back ', 'Callback',' clf; cltiplot(3);')

    uicontrol('Units','normal','Position',[.9 .60 .10 .05],'String','Info ', 'Callback',' clinfo(5);')



    %
    % calculate the lta value
    %
    ncu=length(xt);
    lta=1:1:ncu;
    lta=lta*0;
    iwl=round(iwl3*365/par1);
    %
    %  calculated mean, var etc
    %
    for i = 1:tdiff-iwl
        mean1 = mean(cumu(1:ncu));
        mean2 = mean(cumu(i:i+iwl));
        var1 = cov(cumu(1:ncu));
        var2 = cov(cumu(i:i+iwl));
        lta(i+round(iwl/2)) = (mean1 - mean2)/(sqrt(var1/ncu+var2/(iwl)));
    end     % for i

    %
    % plot  the data
    %
    hold off
    pyy = plotyy(xt,cumu2,'ob',xt,lta,'r',[0 0 0 NaN NaN NaN NaN min(lta)*3-1 max(lta*3)+1  ]);

    xlabel('Time in [years]')
    ylabel('Cumulative Number')
    str2 = ['LTA of ' file1];
    title(str2)

    y2label('z-value')
    grid


    drawnow;


