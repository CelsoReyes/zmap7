function [fTafshock] = calc_Afseqlength(fPval1,fCval1,fKval1,fBgrate,fTlength,bPlot)
    % function [fTafshock] = calc_Afseqlength(fPval1,fCval1,fKval1,fBgrate,fTlength,bPlot)
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
    %fBgrate = fBgrate;
    % Use analytical solution
    % Compute length of aftershock sequence
    fLogTime = 1./fPval1.*log10(fKval1/fBgrate);
    fTafshock = 10.^fLogTime-fCval1;

    if exist('bPlot','var')
        vT = [0:0.01:fTlength];
        vT = vT';
        vKval = ones(length(vT),1)*fKval1;
        vCval = ones(length(vT),1)*fCval1;
        vPval = ones(length(vT),1)*fPval1;
        vCumEv = vKval./((vT+vCval).^vPval);

        figure
        hOmori=loglog(vT,vCumEv,'k','Linestyle','-');
        hold on
        hBg = loglog([0.01 vT(end)],[fBgrate fBgrate]);
        set(hBg,'Linewidth',2,'Color',[0.5 0.5 0.5])
        legend([hOmori hBg],'Omori law','Background rate','Location','SouthWest');
        sText = ['t_a = ' num2str(fTafshock) ' years'];
        text(fTafshock/2,1/3*vCumEv(1),sText,'FontSize',12,'Fontweight','bold');
        xlabel('Time [year]','FontSize',14,'Fontweight','bold');
        ylabel('Number of events [per day]','FontSize',14,'Fontweight','bold');
        set(gca,'Xlim',[0 fTlength],'FontSize',12,'Fontweight','bold')
    else
        return;
    end
