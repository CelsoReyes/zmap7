function view_Omoricross(src_table, mygrid, field_name)
    % view_Omoricross Plot Modified Omori law / nested MOL parameters calculated with calc_Omoricross.m.
    %
    %     The b and p -Value Map Window
    %
    %           This window displays b-values and p-values
    %           using a color code.
    %           Some of the menu-bar options are
    %           described below:
    %
    %           Threshold: You can set the maximum size that
    %             a volume is allowed to have in order to be
    %             displayed in the map. Therefore, areas with
    %             a low seismicity rate are not displayed.
    %             edit the size (in km) and click the mouse
    %             outside the edit window.
    %          FixAx: You can chose the minimum and maximum
    %                  values of the color-legend used.
    %          Polygon: You can select earthquakes in a
    %           polygon either by entering the coordinates or
    %           defining the corners with the mouse
    %
    %          Circle: Select earthquakes in a circular volume:
    %                Ni, the number of selected earthquakes can
    %                be edited in the upper right corner of the
    %                window.
    %           Refresh Window: Redraws the figure, erases
    %                 selected events.
    %
    %           zoom: Selecting Axis -> zoom on allows you to
    %                 zoom into a region. Click and drag with
    %                 the left mouse button. type <help zoom>
    %                 for details.
    %           Aspect: select one of the aspect ratio options
    %           Text: You can select text items by clicking.The
    %                 selected text can be rotated, moved, you
    %                 can change the font size etc.
    %                 Double click on text allows editing it.
    
    % j.woessner@sed.ethz.ch
    
    myFigName='Omoricros-section';
    
    report_this_filefun();
    ZG = ZmapGlobal.Data;
    
    if ~exist('field_name','var')
        field_name='p-value';
    end
    
    % Set up the Seismicity Map window Enviroment
    % Find out if figure already exists
    %
    hOmoricross=@() findobj('Type','Figure','-and','Name',myFigName);
    
    if ~isempty(hOmoricross)
        hOmoricross = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        create_my_menu();
        
        %valueMap = pvalg;
        ZG.tresh_km = nan;
        
        colormap(jet)
        %minpe = nan;
        %Mmin = nan;
        %minsd = nan;
        plot(field_name)
        activateMenuItem(field_name);
        
        
    end   % This is the end of the figure setup.
    
    function activateMenuItem(name)
        h=findobj(hOmoricross,'Tag',name,'-and','Type','uimenu');
        my_plot(name);
        h.Checked='on';
    end
    
    % There is no deactivateMenuItem, because it is handled in the menu
    
    function my_plot(field_name)
        ax=findobj(hOmoricross,'Type','axes');
        hSurf = findobj(ax,'Type','surface');
        delete(hSurf);
        
        
        % Plot the cross section
        figure(hOmoricross);
        if isempty(ax)
            ax=axes('Position', [0.18,  0.10, 0.7, 0.75],...
                'Visible','off',...
                'FontSize',ZG.fontsz.s,...
                'FontWeight','bold',...
                'LineWidth',1.5,...
                'TickDir','out',...
                'Box','on');
            axis(ax,[ min(mygrid.X) max(mygrid.X) min(mygrid.Y) max(mygrid.Y)]);
        end
        
        % find max and min of data for automatic scaling
        ZG.maxc = fix(max(src_table.(field_name)))+1;
        ZG.minc = fix(min(src_table.(field_name)))-1;
        
        % Plot surface
        hold on
        pcolor(ax, mygrid.X, mygrid.Y, src_table.(field_name));
        
        
        axis image
        hold on
        
        shading(ZG.shading_style)
        

        fix_caxis.ApplyIfFrozen(gca); 
        
        % Labeling
        title([name ';  '   num2str(ZG.t0b) ' to ' num2str(ZG.teb) ],'FontSize',ZG.fontsz.s,...
            'Color','r','FontWeight','bold')
        
        xlabel('Distance [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
        ylabel('Depth [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
        
        % Plot overlay
        %
        hold on
        [nYnewa,nXnewa] = size(newa);
        ploeq = plot(newa(:,nXnewa),-newa.Depth,'k.');
        set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
        hzma = gca;
        
        % Create a colorbar
        h5 = colorbar('horiz');
        %{
        set(h5,'Pos',[0.35 0.07 0.4 0.02],...
            'FontWeight','bold','FontSize',ZG.fontsz.s,'TickDir','out')
        rect = [0.00,  0.0, 1 1];
        axes(h5,'position',rect)
        axis(h5,'off')
        %}
        
        %  Text Object Creation
        txt1 = text(...
            'Units','normalized',...
            'Position',[ 0.33 0.075 0 ],...
            'HorizontalAlignment','right',...
            'FontSize',ZG.fontsz.s,....
            'FontWeight','bold',...
            'String',field_name);
        
        ax.Visible='on';
        
        figure(hOmoricross);
    end
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        add_symbol_menu('eq_plot');
        
        % Menus
        options = uimenu('Label',' Analyze ');
        uimenu(options,'Label','Refresh ',Futures.MenuSelectedFcn,@callbackfun_001)
        %    uimenu(options,'Label','Select EQ in Circle',...
        %        Futures.MenuSelectedFcn,@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            'Enable','off',...
            Futures.MenuSelectedFcn,@callbackfun_003)
        uimenu(options,'Label','Select EQ with const. number',...
            'Enable','off',...
            Futures.MenuSelectedFcn,@callbackfun_004)
        
        
        op1 = uimenu('Label',' Maps ');
        
        %Menu for adjusting several parameters.
        adjmenu = uimenu(op1,'Label','Adjust Map Display Parameters'),...
            uimenu(adjmenu,'Label','Adjust Mmin cut',...
            'Enable','off',...
            Futures.MenuSelectedFcn,@callbackfun_005)
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            'Enable','off',...
            Futures.MenuSelectedFcn,@callbackfun_006)
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            'Enable','off',...
            Futures.MenuSelectedFcn,@callbackfun_007)
        uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
            'Enable','off',...
            Futures.MenuSelectedFcn,@callbackfun_008)
        
        % Add all the map options to the figure
        viewable={'p-value','p-value';... 8, p-Value
            'p-value std','p-value std';... 9, p-value standard deviation
            'c-value','c-value';... 10, c-value
            'c-value std','c-value std';... 11, c-value standard deviation
            'k-value','k-value';... 12, k-value
            'k-value std','k-value std';... 13, k-value standard deviation
            'Resolution Map (Number of Events)','Number of Events';...6, Number of events per grid node
            'Resolution Map (Radii)','Radius [km]';... 7,  Radii of chosen events, Resolution
            'Model','model';... 1, Chosen fitting model
            'KS Rejection','KS-Test H';...  2, KS-Test (H-value) binary rejection criterion at 95% confidence level
            'KS Distance','KS-Test stat';... 3, KS-Test statistic for goodness of fit
            'KS-Test p-value','KS-Test p-value'; ...  mKsp, KS-Test p-value
            'RMS','RMS'; ...  RMS value for goodness of fit
            'Magnitude of Completeness','Mc value' ...  Mc value
            };
        
        for j = 1 : length(viewable)
            uimenu(op1, 'Label',viewable{j,1},'Tag',viewable{j,2},...
                Futures.MenuSelectedFcn,{@callback_changeplot,viewable{j,2}}); %Table header IS the title AND tag
        end
        add_display_menu(1)
    end
    
    %% callback functions
    function callback_changeplot(mysrc,~,fieldname)
        mysrc.Checked='off';
        h=findobj(hOmoricross,'Tag',fieldname,'-and','Type','uimenu');
        my_plot(fieldname);
        h.Checked='on';
    end
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        my_plot(field_name);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ni';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirpva;
        watchoff(hOmoricross);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        plot_circbootfit_a2;
        watchoff(hOmoricross);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state2=true;
        ZG.hold_state=true;
        plot_constnrbootfit_a2;
        watchoff(hOmoricross);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'mag';
        adju2;
        view_Omoricross(field_name,valueMap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'rmax';
        adju2;
        view_Omoricross(field_name,valueMap);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'gofi';
        adju2;
        view_Omoricross(field_name,valueMap);
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'pstdc';
        adju2;
        view_Omoricross(field_name,valueMap);
    end
    
end
