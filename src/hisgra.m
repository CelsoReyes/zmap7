function h=hisgra(mycat, opt, ax)
    %plots histogram in cumulative number window
    %vari1 depends on input parameter
    %histogram.m                               A.Allmann
    
    %modified by Reyes 2017
    
    global histo hisvar strii1 strii2
    h=gobjects(0);
    try
        [vari1, bins] = get_histparams(mycat, opt);
    catch ME
        return;
    end
    if isempty(vari1)
        return
    end
    
    if exist('ax','var') && isvalid(ax)
        % plot into the axes instead of creating a new figure;
        h=plotIntoAxes();
    else
        h=plotIntoFigure();
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
            uimenu(op1,'Label','Change Number of Bins...',Futures.MenuSelectedFcn,@callback_change_nBins);
            uimenu(op1,'Label','Change Bin Edges...',Futures.MenuSelectedFcn,@callback_change_bVector);
            uimenu(op1,'Label','Default',Futures.MenuSelectedFcn,@callback_reset);
            addAboutMenuItem();
        end
        
        histogram(vari1, bins);
        h=findobj(histo,'Type','histogram');
        
        titlestr = [stri2, stri1, ' : ', mycat.Name];
        
        th= title(titlestr,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');
        th.Interpreter='none';
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','TickDir','out','Ticklength',[ 0.01 0.01],'LineWidth',1,'Box','on');
        if strcmp(stri2,stri3)
            stri2='Duration in days';
        elseif strcmp(stri2,stri4)
            stri2='Foreshock Duration in days';
        end
        xlabel(stri2,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('  Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    end
    
    function hg=plotIntoAxes()
        
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
            'TickDir','out','Ticklength',[ 0.01 0.01],'LineWidth',1,'Box','on');
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
            uimenu(c,'Label','Change Number of Bins...',Futures.MenuSelectedFcn,@callback_change_nBins);
            uimenu(c,'Label','Change Bin Edges...',Futures.MenuSelectedFcn,@callback_change_bVector);
            uimenu(c,'Label','Default',Futures.MenuSelectedFcn,@callback_reset);
            uimenu(c,'Label','Open as new figure',Futures.MenuSelectedFcn,@open_as_new_fig); %TOFIX
            addcontext(opt,c);
            ax.UIContextMenu=c;
        else
            ax.UIContextMenu=mycontextmenu;
        end
        
        
        %c=uicontextmenu('Tag',['histogram ' opt ' scale']);
        %uimenu(c,'Label','Use Log Scale',Futures.MenuSelectedFcn,{@logtoggle,ax,'Y'});
        uimenu(c,'Label','Use Log Scale',Futures.MenuSelectedFcn,{@logtoggle,'Y'});
        yl.UIContextMenu=c;
        
    end
    
    %% callback functions
    function callback_change_nBins(~,~)
        h=findobj(ax,'Type','histogram');
        def = num2str(h(1).NumBins);
        binsS = inputdlg('Choose number of bins','Histogram Params',1, {def});
        set(h,'NumBins',str2double(binsS{1}));
    end
    
    function callback_change_bVector(~,~)
        h=findobj(ax,'Type','histogram');
        mainh=h(1);
        %edges= num2str(h.BinEdges);
        if isduration(mainh.BinEdges(1))
            fmt = mainh.BinEdges(1).Format;
            switch fmt
                case 'm'
                    units='minutes';
                    numedges=minutes(mainh.BinEdges);
                case 'h'
                    units='hours';
                    numedges=hours(mainh.BinEdges);
                case 'y'
                    units='years';
                    numedges=years(mainh.BinEdges);
                otherwise
                    units='days';
                    numedges=days(mainh.BinEdges);
            end
            def=[num2str(numedges(1)), ' : ',...
                num2str(mode(diff(numedges))),' : ',...
                num2str(numedges(end))];
            %def = num2str(h.BinEdges);
            binsS = inputdlg(['Vector of bin edges (e.g. 0:5:20) in ' units],'Histogram Params',1,{def});
            switch fmt
                case 'm'
                    binEdgeValues=minutes(str2num(binsS{1})); %#ok<ST2NM>
                case 'h'
                    binEdgeValues=hours(str2num(binsS{1})); %#ok<ST2NM>
                case 'y'
                    binEdgeValues=years(str2num(binsS{1})); %#ok<ST2NM>
                otherwise
                    binEdgeValues=days(str2num(binsS{1})); %#ok<ST2NM>
            end
        elseif isdatetime(mainh.BinEdges(1))
            prompt={'Starting Date [year month day hour minute second]',...
                'Date step [year month day hour minute second]',...
                'Ending Date [year month day hour minute second]'};
            delt= mode(diff(mainh.BinEdges));
            def = {num2str(fix(datevec(mainh.BinEdges(1)))), ... starting date
                num2str(fix(datevec(mode(diff(mainh.BinEdges))))),... difference
                num2str(fix(datevec(mainh.BinEdges(end))))}; % ending date
            binsS = inputdlg(prompt,'Histogram Params',1,def);
            dur = datetime(str2num(binsS{2})) - datetime([0 0 0 0 0 0]);
            binEdgeValues=datetime(str2num(binsS{1})) : dur : datetime(str2num(binsS{3}));
            
        else
            def=[num2str(mainh.BinEdges(1)), ' : ',...
                num2str(mode(diff(mainh.BinEdges))),' : ',...
                num2str(mainh.BinEdges(end))];
            %def = num2str(h.BinEdges);
            binsS = inputdlg('Vector of bin edges (e.g. 1:0.1:7)','Histogram Params',1,{def});
            binEdgeValues=str2num(binsS{1}); %#ok<ST2NM>
        end
        
         set(h,'BinEdges',binEdgeValues);
         set(ax,'xlim',mainh.BinLimits);
         
    end
    
    function addcontext(opt, c)
        h=findobj(ax,'Type','histogram');
        switch opt
            case 'Date'
                uimenu(c,'separator','on','Label','Snap to Day',Futures.MenuSelectedFcn,@(~,~)cb_snap_to_datetime(h,'day'));
                uimenu(c,'Label','Snap to Week',Futures.MenuSelectedFcn,@(~,~)cb_snap_to_datetime(h,'week'));
                uimenu(c,'Label','Snap to Month',Futures.MenuSelectedFcn,@(~,~)cb_snap_to_datetime(h,'month'));
                uimenu(c,'Label','Snap to Year',Futures.MenuSelectedFcn,@(~,~)cb_snap_to_datetime(h,'year'));
        end
        function cb_snap_to_datetime(h,x)
            newEdges=dateshift(h.BinEdges,'start',x,'nearest');
            newEdges=unique(newEdges);
            if numel(newEdges) ~= numel(h.BinEdges)
                warning('One or more bins have been removed');
            end
            set(findobj(ax,'Type','histogram'),'BinEdges',newEdges);
        end
                    
    end
    
    function [vari1, bins] = get_histparams(mycat, binByField)
        % GET_HISTPARAMS(catalog, binbyfield)
        % vari1 is the data to be binned
        % bins may be a vector of bin edges, or the number of bins.
        
        switch binByField
            case 'Magnitude'
                vari1 = mycat.(binByField);
                bins=floor(min(vari1)):0.1:ceil(max(vari1));
            case {'Depth','Date'}
                vari1 = mycat.(binByField);
                bins=50;
            case 'Hour'
                vari1 = hours(mycat.Date.(binByField));
                bins= hours(0:1:24);
            case 'Quality'
                error('unimplemented');
                vari1 = mycat.Quality;
                bins = -0.1:0.01:1.1;
                
            otherwise
                errtxt=sprintf('Unknown histogram option:%s', binByField);
                errordlg(errtxt,'Error:histograms');
                error(errtxt);
        end
    end
    
    function callback_reset(src,ev)
        [~, bins] = get_histparams(mycat, opt);
        ax=gca;
        h=findobj(ax,'Type','histogram');
        if numel(bins)==1
            fld='NumBins';
        else
            fld='BinEdges';
        end
        set(h,fld,bins);
        axis(ax,'tight')
        %histogram(ax,vari1,bins);
    end
    
    function open_as_new_fig(~,~)
        
              titlestr = [opt, ' Histogram', ' : ', mycat.Name];
              histo= figure_w_normalized_uicontrolunits( ...
                  'NumberTitle','off','Name',titlestr);
              
              add_menu_divider();
              op1 = uimenu('Label','Display');
              uimenu(op1,'Label','Change Number of Bins...',Futures.MenuSelectedFcn,@callback_change_nBins);
              uimenu(op1,'Label','Change Bin Edges...',Futures.MenuSelectedFcn,@callback_change_bVector);
              uimenu(op1,'Label','Default',Futures.MenuSelectedFcn,@callback_reset);
              copyobj(ax,histo)
              
              th= title(titlestr,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');
              th.Interpreter='none';
    end
end

