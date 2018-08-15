function [] = plot_cluster_win()
    % Plots the distance window length and the time window length against magnitude in one figure
    % [] = plot_cluster_win();
    % ---------------------------------
    %
    %
    % J Woessner, woessner@seismo.ifg.ethz.ch
    % updated: 12.08.02
    
    %% Magntiude areas
    vMagnitude = (0:0.1:10);
    vMagnitudea = (0:0.1:6.5);
    vMagnitudeb = (6.5:0.1:10);
    
    % Gardener and Knopoff, 1974
    vSpaceGaKn74 = 10.^(0.1238*vMagnitude+0.983);
    vTimeGaKn74 = 10.^(0.5409*vMagnitudea-0.547);
    vTimeGaKn74b = 10.^(0.032*vMagnitudeb+2.7389); % M>=6.5
    
    % Gruenthal, pers. communication
    vSpaceGr = exp(1.77+sqrt(0.037+1.02*vMagnitude));
    vTimeGra = exp(-3.95+sqrt(0.62+17.32*vMagnitudea));
    vTimeGrb = 10.^(2.8+0.024*vMagnitudeb); % M >= 6.5
    
    % Uhrhammer 1986
    vSpaceUr = exp(-1.024+0.804*vMagnitude);
    vTimeUr = exp(-2.87+1.235*vMagnitude);
    
    %%%% These are other windows that are not used %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Gruenthal, 1985
    % vSpaceGr85 = 10.^(0.1060*vMagnitude+1.0982);
    % vTimeGr85 = 10.^(0.5055*vMagnitude-0.1329);
    %
    % % Youngs, 1987
    % %% Maximum window limits
    % %% Space
    % vMagY1 = (0:0.01:2.43);
    % vMagY2 = (2.43:0.01:5.87);
    % vMagY3 = (5.87:0.01:10);
    % vSpaceY1 = 20+0*vMagY1;
    % vSpaceY2 = 10.^(0.1159*vMagY2+1.0197);
    % vSpaceY3 = 10.^(0.5281*vMagY3-1.3937);
    % %% Time
    % vMagTY1 = (0:0.01:3.89);
    % vMagTY2 = (3.89:0.01:10);
    % vTimeY1 = 30+0*vMagTY1;
    % vTimeY2 = 10.^(0.4916*vMagTY2-0.4317);
    %
    % %% Minimum window limits
    % %% Space
    % vMinY1 = (0:0.01:4.41);
    % vMinY2 = (4.41:0.01:4.98);
    % vMinY3 = (4.98:0.01:6.42);
    % vMinY4 = (6.42:0.01:10);
    % vSpaceMinY1 = 10+0*vMinY1;
    % vSpaceMinY2 = 10.^(0.5281*vMinY2-1.3290);
    % vSpaceMinY3 = 10.^(0.3313*vMinY3-0.3490);
    % vSpaceMinY4 = 10.^(0.1154*vMinY4+1.0371);
    % %% Time
    % vMinTY1 = (0:0.01:5);
    % vMinTY2 = (5:0.01:10);
    % vTimeMinY1 = 5+0*vMinTY1;
    % vTimeMinY2 = 10.^(1.0526*vMinTY2-4.561);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Figures
    if exist('hd1_win_fig','var') & ishandle(hd1_win_fig)
        set(0,'Currentfigure',hd1_win_fig);
        disp('Figure exists');
    else
        hd1_win_fig=figure_w_normalized_uicontrolunits('tag','fig_win','Name','Window length in time and space','Units','normalized','Nextplot','add',...
            'Numbertitle','off','Position',[0.4 0.2 .4 .6],'Menubar','none');
    end
    
    % Plotting time window
    subplot(2,1,1);
    %hAxe = axes('tag','ax_timewindow','Nextplot','replace','box','on');
    set(gca,'tag','ax_timewindow','Nextplot','replace','box','on','Xticklabel', [0 10 100]);
    axs1=findobj('tag','ax_timewindow');
    axes(axs1(1));
    semilogy(vMagnitudea,vTimeGaKn74,'Color',[1 0 0],'Linewidth', 2);
    set(gca,'NextPlot','add');
    %semilogy(vMagnitude,vTimeGr85,'Color',[0 0.5 0],'Linewidth', 2);
    semilogy(vMagnitudea,vTimeGra,'Color',[0 0.8 0],'Linewidth', 2);
    semilogy(vMagnitude,vTimeUr,'Color',[0.5 0 0],'Linewidth', 2);
    %semilogy(vMagTY1,vTimeY1,vMagTY2,vTimeY2,'Color',[0 0 1],'Linewidth', 2);
    semilogy(vMagnitudeb,vTimeGaKn74b,'Color',[1 0 0],'Linewidth', 2);
    %semilogy(vMinTY1,vTimeMinY1,vMinTY2,vTimeMinY2,'Color',[0 0 1],'Linewidth', 2);
    semilogy(vMagnitudeb,vTimeGrb,'Color',[0 0.8 0],'Linewidth', 2);
    %legend('Gardner & Knopoff (1974)','Gruenthal (1985)','Gruenthal (pers.)','Urhammer (1976)','Mod. Young (1987)');
    legend('Gardner & Knopoff (1974)','Gruenthal (pers.comm.)','Urhammer (1986)','Location','NorthWest');
    xlabel('Magnitude');
    ylabel('Time / [days]');
    set(gca,'Xlim',[0 9]);%,'Ylim',[0.1 3000],'Yticklabel', [0.1 1 10 100 1000]);
    grid on;
    set(gca,'NextPlot','replace');
    
    % Plotting space window
    subplot(2,1,2);
    %hAxe2 = axes('tag','ax_spacewindow','Nextplot','replace','box','on');
    set(gca,'tag','ax_spacewindow','Nextplot','replace','box','on');
    axs2=findobj('tag','ax_spacewindow');
    axes(axs2(1));
    semilogy(vMagnitude,vSpaceGaKn74,'Color',[1 0 0],'Linewidth', 2);
    set(gca,'NextPlot','add');
    %semilogy(vMagnitude,vSpaceGr85,'Color',[0 0.5 0],'Linewidth', 2);
    semilogy(vMagnitude,vSpaceGr,'Color',[0 0.8 0],'Linewidth', 2);
    semilogy(vMagnitude,vSpaceUr,'Color',[0.5 0 0],'Linewidth', 2);
    %semilogy(vMagY1,vSpaceY1,vMagY2,vSpaceY2,vMagY3,vSpaceY3,'Color',[0 0 1],'Linewidth', 2);
    %semilogy(vMinY1,vSpaceMinY1,vMinY2,vSpaceMinY2,vMinY3,vSpaceMinY3,vMinY4,vSpaceMinY4,'Color',[0 0 1],'Linewidth', 2);
    %legend('Gardner & Knopoff (1974)','Gruenthal (1985)','Gruenthal (pers. comm)','Urhammer (1976)','Mod. Young (1987)');
    legend('Gardner & Knopoff (1974)','Gruenthal (pers. comm.)','Urhammer (1986)','Location','NorthWest');
    ylabel('Distance / [km]')
    xlabel('Magnitude');
    set(gca,'Xlim',[0 9],'Ylim', [5 300],'Yticklabel', [10 100]);
    grid on;
end