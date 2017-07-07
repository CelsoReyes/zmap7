function [fTafshock] = plot_Afseqlength(mCatalog,mMain,fPval1,fCval1,fKval1,fBgrate,fTlength,bPlot)
    % function [fTafshock] = plot_Afseqlength(mCatalog,mMain,fPval1,fCval1,fKval1,fBgrate,fTlength,bPlot)
    % ------------------------------------------------------------------------
    % Compute length of aftershock sequence as intersection point between modified Omori law and fixed background rate
    % fPval1,fCval1,fKval1 can also be vectors!
    % Background rate is for a dataset above a fixed Mc
    %
    % Incoming:
    % fPval1   : Modified Omori law p-value
    % fCval1   : Modified Omori law c-value
    % fKval1   : Modified Omori law k-value
    % fBgrate  : Background rate of events above Mc [years]
    % fTlength : Time period to plot [years]
    % bPlot    : Use only for single p-,c-,k-values
    %
    % Outgoing:
    % fTafshock : Length of aftershock sequence in years
    %
    % last update: 08.07.04
    % jochen.woessner@sed.ethz.ch

    if ~exist('bPlot','var')
        fTlength =10;
    end
    fBgrate = fBgrate/365;
    % Use analytical solution
    % Compute length of aftershock sequence
    fLogTime = 1./fPval1.*log10(fKval1/fBgrate);
    fTafshock = 10.^fLogTime-fCval1;

    % Create aftershock times
    vAfdate = datenum(floor(mCatalog(:,3)),mCatalog(:,4),mCatalog(:,5),mCatalog(:,8),mCatalog(:,9),mCatalog(:,10));
    fTmain = datenum(floor(mMain(:,3)),mMain(:,4),mMain(:,5),mMain(:,8),mMain(:,9),mMain(:,10));
    vTime = vAfdate-fTmain;
    % Determine daily rate
    [vRate,vTime] = hist(vTime,0:1:ceil(max(vTime)));

    if exist('bPlot','var')
        vT = [0:0.5:ceil(fTafshock)];
        vT = vT';
        vKval = ones(length(vT),1)*fKval1;
        vCval = ones(length(vT),1)*fCval1;
        vPval = ones(length(vT),1)*fPval1;
        vCumEv = vKval./((vT+vCval).^vPval);

        figure
        hOmori=loglog(vT,vCumEv,'k','Linestyle','-');
        hold on
        loglog(vTime,vRate,'s','Linestyle','none','Markersize',8,'Color',[0 0 0]);
        hBg = loglog([0.01 vT(end)],[fBgrate fBgrate]);
        set(hBg,'Linewidth',2,'Color',[0.5 0.5 0.5])
        legend([hOmori hBg],'Omori law','Background rate','Location','SouthWest');
        sText = ['t_a = ' num2str(fTafshock/365) ' years'];
        text(0.1,1,sText,'FontSize',12,'Fontweight','bold');
        xlabel('Time [days]','FontSize',14,'Fontweight','bold');
        ylabel('Number of events [per day]','FontSize',14,'Fontweight','bold');
        set(gca,'Xlim',[0 ceil(fTafshock)],'FontSize',12,'Fontweight','bold')
    else
        return;
    end
