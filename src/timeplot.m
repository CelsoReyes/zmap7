function pl = timeplot 
    % timeplot plots selected events as cummulative # over time
    %
    % operates on catalog newt2 which is set by incomming routine
    % tracks its view using ZG.Views.timeplot
    %
    % original view, when figure first called, is stored in figure's UserData as UserData.View
    %
    %
    %
    %
    % Time of events with a Magnitude greater than ZG.big_eq_minmag will
    % be shown on the curve.  Operates on mycat, resets  b  to mycat
    %     ZG.newcat is reset to:
    %                       - "primeCatalog" if either "Back" button or "Close" button is pressed.
    %
    % Updates:
    % Added callback in op5 for afterschock sequence rate change detection (07.07.03: J. Woessner)
    
    
    % when timeplot is first called (no figure)
    % - set newt2 to desired catalog
    % - creates view, attached to newt2 catalog
    %
    % when primary catalog is replaced from here:
    % [cannot assume catalog matches, so
    % - set primeCatalog to newt2
    % - set primary view to newt2, but change catalog to 'primary'
    %
    %FIXME this is affecting the primaryCatalog, instead of the other catalogs.
    
    CumTimePlot.getInstance()
    pl.reset()
return
