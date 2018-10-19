function h=hisgra(mycat, opt, ax)
    %plots histogram in cumulative number window
    %vari1 depends on input parameter
    %histogram.m                               A.Allmann
    
    %modified by Reyes 2017
    
    h=gobjects(0);
    %try
    [vari1, bins] = get_histparams(mycat, opt);
    %catch ME
    %    return;
    %end
    if isempty(vari1)
        return
    end
    
    if exist('ax','var') && isvalid(ax)
        % plot into the axes instead of creating a new figure;
        h=plotIntoAxes();
    else
        h=plotIntoFigure(opt);
    end
    
    function hg=plotIntoFigure(opt)
        myFigName='Histogram';
        
        stri1=myFigName;
        labelOpts = {'FontWeight', 'bold','FontSize',ZmapGlobal.Data.fontsz.m};
        % Reuse existing figure
        hfig = findobj('Type','Figure','-and','Name',myFigName);
        
        if  ~isempty(hfig)
            figure(hfig);
        else
            hfig= figure('NumberTitle','off','Name', stri1, 'Visible', 'off');
            
            add_menu_divider();
            op1 = uimenu('Label','Display');
            uimenu(op1,'Label','Change Number of Bins...',MenuSelectedField(),@cb_change_nBins);
            uimenu(op1,'Label','Change Bin Edges...',MenuSelectedField(),@cb_change_bVector);
            uimenu(op1,'Label','Default',MenuSelectedField(),@cb_reset);
            addAboutMenuItem(hfig);
        end
        
        delete(findobj(hfig,'Type','Axes'));
        ax = axes(hfig,'Tag','histgra_axes');
        
        hg=histogram(ax,vari1, bins);
        
        titlestr = [opt,' ', stri1, ' : ', mycat.Name];
        
        th= title(titlestr,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');
        th.Interpreter='none';
        set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','TickDir','out','Ticklength',[ 0.01 0.01],'LineWidth',1,'Box','on');
        
        xlabel(ax, getLabel(opt), labelOpts{:})
        ylabel(ax,'# Events per bin', labelOpts{:})
        hfig.Visible = 'on';
    end
    
    function hg=plotIntoAxes()
        
        hg=histogram(ax,vari1, bins);
        
        ax.XLim     = hg.BinLimits;
        ax.TickDir  = 'out';
        ax.TickLength = [0.01 0.01];
        ax.LineWidth = 1;
        ax.Box      = 'on';
        ax.Visible  = 'on';
        ax.Tag      = 'histgra_axes';
        
        xlabel(ax, getLabel(opt));
        yl = ylabel(ax, '# Events per bin');
        c=findobj(ancestor(ax,'figure'),'uicontextmenu','-and','Tag',['histogram ' opt]);
        if isempty(c)
            c=uicontextmenu('Tag',['histogram ' opt]);
            uimenu(c,'Label','Change Number of Bins...',MenuSelectedField(),@cb_change_nBins);
            uimenu(c,'Label','Change Bin Edges...',MenuSelectedField(),@cb_change_bVector);
            uimenu(c,'Label','Default',MenuSelectedField(),@cb_reset);
            uimenu(c,'Label','Open as new figure',MenuSelectedField(),@open_as_new_fig); %FIXME
            addcontext(opt,c);
            ax.UIContextMenu=c;
        else
            ax.UIContextMenu=c;
        end
        
        uimenu(c,'Label','Use Log Scale',MenuSelectedField(),@(s,~)logtoggle(s,'Y'));
        yl.UIContextMenu=c;
        
    end
    
    
    %% callback functions
    function cb_change_nBins(src,~)
        [~,ax,h] = src2handles(src);
        def = num2str(h(1).NumBins);
        binsS = inputdlg('Choose number of bins','Histogram Params',1, {def});
        if isempty(binsS)
            return
        end
        set(h,'NumBins',str2double(binsS{1}));
        
        ax.YLabel.String = sprintf('# Events per bin [ width: %s ]', binWidthDesc(h(1).BinWidth));
        
    end
    
    function cb_change_bVector(src,~)
        [~,ax,h] = src2handles(src);
        mainh=h(1);
        
        switch class(mainh.BinEdges(1))
            case 'duration'
                fmt = mainh.BinEdges(1).Format;
                switch fmt
                    case 'm'
                        units='minutes';
                    case 'h'
                        units='hours';
                    case 'y'
                        units='years';
                    otherwise
                        units='days';
                end
                conversionFcn = str2func(units);
                numedges = conversionFcn(mainh.BinEdges);
                
                def=[num2str(numedges(1)), ' : ',...
                    num2str(mode(diff(numedges))),' : ',...
                    num2str(numedges(end))];
                %def = num2str(h.BinEdges);
                binsS = inputdlg(['Vector of bin edges (e.g. 0:5:20) in ' units],'Histogram Params',1,{def});
                binEdgeValues = conversionFcn(str2num(binsS{1})); %#ok<ST2NM>
                
            case 'datetime'
                
                prompt={'Starting Date [year month day hour minute second]',...
                    'Date step [year month day hour minute second]',...
                    'Ending Date [year month day hour minute second]'};
                delt= mode(diff(mainh.BinEdges));
                def = {num2str(fix(datevec(mainh.BinEdges(1)))), ... starting date
                    num2str(fix(datevec(delt))),... difference
                    num2str(fix(datevec(mainh.BinEdges(end))))}; % ending date
                binsS = inputdlg(prompt,'Histogram Params',1,def);
                if isempty(binsS)
                    return;
                end
                dur = datetime(str2num(binsS{2})) - datetime([0 0 0 0 0 0]);
                binEdgeValues=datetime(str2num(binsS{1})) : dur : datetime(str2num(binsS{3}));
                
            otherwise
                
                def=[num2str(mainh.BinEdges(1)), ' : ',...
                    num2str(mode(diff(mainh.BinEdges))),' : ',...
                    num2str(mainh.BinEdges(end))];
                %def = num2str(h.BinEdges);
                binsS = inputdlg('Vector of bin edges (e.g. 1:0.1:7)','Histogram Params',1,{def});
                binEdgeValues=str2num(binsS{1}); %#ok<ST2NM>
                
        end
        
        set(h,'BinEdges',binEdgeValues);
        set(ax,'xlim',mainh.BinLimits);
        
        ax.YLabel.String = sprintf('# Events per bin [ width: %s ]', binWidthDesc(h(1).BinWidth));
    end
    
    function addcontext(opt, c)
        h=findobj(ax,'Type','histogram');
        switch opt
            case 'Date'
                uimenu(c,'separator','on','Label','Events per Day',MenuSelectedField(),@(~,~)cb_set_to_period(h,'day'));
                uimenu(c,'Label','Events per Week',MenuSelectedField(),@(~,~)cb_set_to_period(h,'week'));
                uimenu(c,'Label','Events per Month',MenuSelectedField(),@(~,~)cb_set_to_period(h,'month'));
                uimenu(c,'Label','Events per Year',MenuSelectedField(),@(~,~)cb_set_to_period(h,'year'));
            otherwise
                do_nothing();
        end
        
        function cb_set_to_period(h,unit)
            mindate=min(h.Data); maxdate = max(h.Data);
            mindate=dateshift(mindate,'start',unit,'previous');
            maxdate=dateshift(maxdate,'start',unit,'next');
            delta=maxdate-mindate;
            switch unit
                case 'day'
                    edges = mindate : days(1) : maxdate;
                case 'week'
                    edges = mindate : days(7) : maxdate;
                case 'year'
                    nyears=ceil(years(delta));
                    edges = mindate + calendarDuration(0:nyears,0,0);
                case 'month'
                    nmonths=ceil(years(delta) .* 12);
                    edges = mindate + calendarDuration(0,0:nmonths,0);
            end
            set(findobj(ax,'Type','histogram'),'BinEdges',edges);
            ax.YLabel.String=['# Events per ' unit];
        end
        
        
    end
    
    
    function cb_reset(src,~)
        [~,ax,h] = src2handles(src);
        [~, bins] = get_histparams(mycat, opt);
        if numel(bins)==1
            fld='NumBins';
        else
            fld='BinEdges';
        end
        h.(fld) = bins;
        axis(ax,'tight')
    end
    
    function open_as_new_fig(~,~)
        
        titlestr = [opt, ' Histogram', ' : ', mycat.Name];
        histo= figure_w_normalized_uicontrolunits( ...
            'NumberTitle','off','Name',titlestr);
        
        add_menu_divider();
        op1 = uimenu('Label','Display');
        uimenu(op1,'Label','Change Number of Bins...',MenuSelectedField(),@cb_change_nBins);
        uimenu(op1,'Label','Change Bin Edges...',MenuSelectedField(),@cb_change_bVector);
        uimenu(op1,'Label','Default',MenuSelectedField(),@cb_reset);
        copyobj(ax,histo)
        
        th= title(titlestr,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k');
        th.Interpreter='none';
    end
    
    
end

function [fig,ax,h] = src2handles(src)
        fig = ancestor(src,'figure');
        ax = findobj(fig.Children,'flat','Type','axes');
        h=findobj(ax,'Type','histogram');
end

function s = getLabel(opt)
    switch lower(strip(opt))
        case 'duration'
            s = 'Duration in days';
        case 'foreshock duration'
            s = 'Foreshock Duration in days';
        otherwise
            s = opt;
    end
end

function s = binWidthDesc(width)
    switch class(width)
        case 'duration'
            d = floor(days(width));
            s = sprintf('%d days %s',d , string(width-d,'hh:mm:ss') );
        otherwise
            s = sprintf('%d', width );
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
            unimplemented_error()
            %vari1 = mycat.Quality;
            %bins = -0.1:0.01:1.1;
            
        otherwise
            errtxt=sprintf('Unknown histogram option:%s', binByField);
            errordlg(errtxt,'Error:histograms');
            error(errtxt);
    end
end


