function hisgra(mycat, opt, ax)
    %plots histogram in cumulative number window
    %vari1 depends on input parameter
    %histogram.m                               A.Allmann
    
    %modified by Reyes 2017
    
    global histo hisvar strii1 strii2
    
    try
        [vari1, bins] = get_histparams(opt);
    catch ME
        return;
    end
    if exist('ax','var') && isvalid(ax)
        % plot into the axes instead of creating a new figure;
        plotIntoAxes();
    else
        plotIntoFigure();
    end
    
    function plotIntoFigure()
        myFigName='Histogram';
        myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
        
        stri1=myFigName;
        stri2=opt;
        strii1=stri1;
        strii2=stri2;
        stri3='Duration ';
        stri4='Foreshock Duration ';
        hisvar=vari1;
        tm1=[];
        % Find out if figure already exists
        %
        histo = myFigFinder();
        if  ~isempty(histo)
            figure(histo);
            delete(findobj(histo,'Type','Axes'));
        else
            histo= figure_w_normalized_uicontrolunits( ...
                'NumberTitle','off','Name',stri1,...
                'NextPlot','new', ...
                'Visible','off');
            
            add_menu_divider();
            op1 = uimenu('Label','Display');
            uimenu(op1,'Label','Change Number of Bins...','Callback',@callback_change_nBins);
            uimenu(op1,'Label','Change Bin Edges...','Callback',@callback_change_bVector);
            uimenu(op1,'Label','Default','Callback',@callback_reset);
            addAboutMenuItem();
        end
        
        histogram(vari1, bins);
        h=findobj(histo,'Type','histogram');
        
        titlestr = [stri2, stri1, ' : ', mycat.Name];
        
        th= title(titlestr,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');
        th.Interpreter='none';
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','TickDir','out','Ticklength',[ 0.01 0.01],'LineWidth',1.,'Box','on');
        if strcmp(stri2,stri3)
            stri2='Duration in days';
        elseif strcmp(stri2,stri4)
            stri2='Foreshock Duration in days';
        end
        xlabel(stri2,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('  Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    end
    
    function plotIntoAxes()
        
        %myFigName='Histogram';
        
        %stri1=myFigName;
        stri2=opt;
        stri3='Duration ';
        stri4='Foreshock Duration ';
        
        hg=histogram(ax,vari1, bins);
        
        ax.XLim=hg.BinLimits;
        %titlestr = [stri2, stri1, ' : ', mycat.Name];
        
        %th= title(ax,titlestr,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');
        %th.Interpreter='none';
        set(ax,'visible','on',...
            'TickDir','out','Ticklength',[ 0.01 0.01],'LineWidth',1.,'Box','on');
        if strcmp(stri2,stri3)
            stri2='Duration in days';
        elseif strcmp(stri2,stri4)
            stri2='Foreshock Duration in days';
        end
        xlabel(ax,stri2)
        yl = ylabel(ax,'Number');
        mycontextmenu=findobj(gcf,'uicontextmenu','-and','Tag',['histogram ' opt]);
        if isempty(mycontextmenu)
            c=uicontextmenu('Tag',['histogram ' opt]);
            uimenu(c,'Label','Change Number of Bins...','Callback',@callback_change_nBins);
            uimenu(c,'Label','Change Bin Edges...','Callback',@callback_change_bVector);
            uimenu(c,'Label','Default','Callback',@callback_reset);
            uimenu(c,'Label','Open as new figure','Callback',@open_as_new_fig); %TOFIX
            addcontext(opt,c);
            ax.UIContextMenu=c;
        else
            ax.UIContextMenu=mycontextmenu;
        end
        
        
        c=uicontextmenu('Tag',['histogram ' opt ' scale']);
        uimenu(c,'Label','Use Log Scale','Callback',{@logtoggle,ax,'Y'});
        yl.UIContextMenu=c;
        
    end
    
    %% callback functions
    function callback_change_nBins(~,~)
        h=findobj(ax,'Type','histogram');
        def = num2str(h.NumBins);
        binsS = inputdlg('Choose number of bins','Histogram Params',1, {def});
        h.NumBins = str2double(binsS{1});
    end
    
    function callback_change_bVector(~,~)
        h=findobj(ax,'Type','histogram');
        %edges= num2str(h.BinEdges);
        if isduration(h.BinEdges(1))
            fmt = h.BinEdges(1).Format;
            switch fmt
                case 'm'
                    units='minutes';
                    numedges=minutes(h.BinEdges);
                case 'h'
                    units='hours';
                    numedges=hours(h.BinEdges);
                case 'y'
                    units='years';
                    numedges=years(h.BinEdges);
                otherwise
                    units='days';
                    numedges=days(h.BinEdges);
            end
            def=[num2str(numedges(1)), ' : ',...
                num2str(mode(diff(numedges))),' : ',...
                num2str(numedges(end))];
            %def = num2str(h.BinEdges);
            binsS = inputdlg(['Vector of bin edges (e.g. 0:5:20) in ' units],'Histogram Params',1,{def});
            switch fmt
                case 'm'
                    h.BinEdges=minutes(str2num(binsS{1})); %#ok<ST2NM>
                case 'h'
                    h.BinEdges=hours(str2num(binsS{1})); %#ok<ST2NM>
                case 'y'
                    h.BinEdges=years(str2num(binsS{1})); %#ok<ST2NM>
                otherwise
                    h.BinEdges=days(str2num(binsS{1})); %#ok<ST2NM>
            end
        elseif isdatetime(h.BinEdges(1))
            prompt={'Starting Date [year month day hour minute second]',...
                'Date step [year month day hour minute second]',...
                'Ending Date [year month day hour minute second]'};
            delt= mode(diff(h.BinEdges));
            def = {num2str(fix(datevec(h.BinEdges(1)))), ... starting date
                num2str(fix(datevec(mode(diff(h.BinEdges))))),... difference
                num2str(fix(datevec(h.BinEdges(end))))}; % ending date
            binsS = inputdlg(prompt,'Histogram Params',1,def);
            dur = datetime(str2num(binsS{2})) - datetime([0 0 0 0 0 0]);
            h.BinEdges=datetime(str2num(binsS{1})) : dur : datetime(str2num(binsS{3}));
            
        else
            def=[num2str(h.BinEdges(1)), ' : ',...
                num2str(mode(diff(h.BinEdges))),' : ',...
                num2str(h.BinEdges(end))];
            %def = num2str(h.BinEdges);
            binsS = inputdlg('Vector of bin edges (e.g. 1:0.1:7)','Histogram Params',1,{def});
            h.BinEdges=str2num(binsS{1}); %#ok<ST2NM>
        end
    end
    
    function addcontext(opt, c)
        h=findobj(ax,'Type','histogram');
        switch opt
            case 'Date'
                uimenu(c,'separator','on','Label','Snap to Day','Callback',@(~,~)cb_snap_to_datetime(h,'day'));
                uimenu(c,'Label','Snap to Week','Callback',@(~,~)cb_snap_to_datetime(h,'week'));
                uimenu(c,'Label','Snap to Month','Callback',@(~,~)cb_snap_to_datetime(h,'month'));
                uimenu(c,'Label','Snap to Year','Callback',@(~,~)cb_snap_to_datetime(h,'year'));
        end
        function cb_snap_to_datetime(h,x)
            newEdges=dateshift(h.BinEdges,'start',x,'nearest');
            newEdges=unique(newEdges);
            if numel(newEdges) ~= numel(h.BinEdges)
                warning('One or more bins have been removed');
            end
            h.BinEdges=newEdges;
        end
                    
    end
    
    function [vari1, bins] = get_histparams(opt)
        switch opt
            case 'Magnitude'
                vari1 = mycat.(opt);
                bins=floor(min(vari1)):0.1:ceil(max(vari1));
            case 'Depth'
                vari1 = mycat.(opt);
                bins=50;
            case 'Date'
                vari1 = mycat.(opt);
                bins=50;
            case 'Hour'
                vari1 = hours(mycat.Date.(opt));
                bins= hours(0:1:24);
            case 'Quality'
                error('unimplemented');
                vari1 = mycat.Quality;
                bins = -0.1:0.01:1.1;
                
            otherwise
                errtxt=sprintf('Unknown histogram option:%s', opt);
                errordlg(errtxt,'Error:histograms');
                error(errtxt);
        end
    end
    
    function callback_reset(~,~)
        [vari1, bins] = get_histparams(opt);
        figure(histo);
        delete(findobj(histo,'Type','Axes'));
        histogram(vari1,bins);
    end
    
    function open_as_new_fig(~,~)
        
              titlestr = [opt, ' Histogram', ' : ', mycat.Name];
              histo= figure_w_normalized_uicontrolunits( ...
                  'NumberTitle','off','Name',titlestr);
              
              add_menu_divider();
              op1 = uimenu('Label','Display');
              uimenu(op1,'Label','Change Number of Bins...','Callback',@callback_change_nBins);
              uimenu(op1,'Label','Change Bin Edges...','Callback',@callback_change_bVector);
              uimenu(op1,'Label','Default','Callback',@callback_reset);
              copyobj(ax,histo)
              
              th= title(titlestr,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');
              th.Interpreter='none';
    end
end

