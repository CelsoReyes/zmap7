function [vRate,vTime] = plot_LogOmori(mCatalog,mMain)
    % function [vRate,vBin] = plot_LogOmori(mCatalog,fTMain)
    % -------------------------------------------------------
    % Create daily rate plot of aftershock sequence in loglog space
    %
    % Outgoing:
    % vRate : Events per day
    % vTime : Time bin

    vAfdate = datenum(floor(mCatalog(:,3)),mCatalog(:,4),mCatalog(:,5),mCatalog(:,8),mCatalog(:,9),mCatalog(:,10));
    fTmain = datenum(floor(mMain(:,3)),mMain(:,4),mMain(:,5),mMain(:,8),mMain(:,9),mMain(:,10));
    vTime = vAfdate-fTmain;

    [vRate,vTime] = hist(vTime,0:1:ceil(max(vTime)));

    figure
    loglog(vTime,vRate,'s','Linestyle','none','Markersize',8,'Color',[0 0 0]);
    xlabel('Time [years]','FontSize',14,'Fontweight','bold');
    ylabel('Number of events [per day]','FontSize',14,'Fontweight','bold');
