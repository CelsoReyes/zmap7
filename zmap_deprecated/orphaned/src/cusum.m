function ci =  cusum(cat)
    % This function calculates the CUMSUm function (Page 1954).
    %

    report_this_filefun(mfilename('fullpath'));

    [existFlag,figNumber]=figure_exists('CUSUM',1); %find figure with name 'CUSUM', and do not pop to foreground

    if existFlag
        cfig = figNumber;
    else
        cfig=figure_w_normalized_uicontrolunits(...                  %build figure for plot
            'Units','normalized','NumberTitle','off',...
            'Name','CUSUM',...
            'MenuBar','none',...
            'visible','off',...
            'pos',[ 0.300  0.3 0.4 0.6]);
        ho=false;
        
        matdraw
    end   % if fig exist


    m  = cat(:,6);
    me = mean(m);
    i = (1:1:length(m));
    ci = cumsum(m)' - i.*me;

    figure_w_normalized_uicontrolunits(cfig)
    delete(gca);delete(gca);
    plot(cat(:,3),ci,'o')
    %plot(i,ci,'o')
    set(gca,'visible','on','FontSize',10,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1.0,...
        'Box','on')
    xlabel('Time [yrs]')
    ylabel('CUSUM [yrs]')
    grid


