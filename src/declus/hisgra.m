function hisgra(mycat, opt)
    %histogram.m                               A.Allmann
    %plots histogram in cumulative number window
    %vari1 depends on input parameter
    
    %modified by Reyes 2017
    
    global histo hisvar strii1 strii2
    catname=mycat.Name;
    
    try
        [vari1, bins] = get_histparams(opt);
    catch ME
        return;
    end
    
    stri1='Histogram';
    stri2=opt;
    strii1=stri1;
    strii2=stri2;
    stri3='Duration ';
    stri4='Foreshock Duration ';
    hisvar=vari1;
    tm1=[];
    % Find out of figure already exists
    %
    histo = findobj(0,'Name','Histogram');
    if  ~isempty(histo)
        figure(histo);
        delete(findobj(histo,'Type','Axes'));
    else
        histo= figure_w_normalized_uicontrolunits( ...
            'NumberTitle','off','Name',stri1,...
            'NextPlot','new', ...
            'Visible','off');
        
        %Menuline for options
        add_menu_divider();
        op1 = uimenu('Label','Display');
        uimenu(op1,'Label','Bin Number','Callback',@callback_change_nBins);
        uimenu(op1,'Label','Bin Vector','Callback',@callback_change_bVector);
        uimenu(op1,'Label','Default','Callback',@callback_reset);
    end
    
    axis('off')
    hold on
    
    orient portrait
    rect = [0.25,  0.18, 0.60, 0.70];
    axes('position',rect)
    hold on
    
    histogram(vari1, bins);
    h=findobj(histo,'Type','histogram');
    
    titlestr = [stri2, stri1, ' : ', catname];
    
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
    set(gcf,'Visible','on')
    
    function callback_change_nBins(~,~)
        h=findobj(histo,'Type','histogram');
        def = num2str(h.NumBins);
        binsS = inputdlg('Choose number of bins','Histogram Params',1, {def});
        h.NumBins = str2double(binsS{1});
    end
    
    function callback_change_bVector(~,~)
        h=findobj(histo,'Type','histogram');
        edges= num2str(h.BinEdges);
        def=[num2str(h.BinLimits(1)), ' : ',...
            num2str((h.BinLimits(2)-h.BinLimits(1))/(h.NumBins+1)),' : ',...
            num2str(h.BinLimits(2))];
            %def = num2str(h.BinEdges);
        binsS = inputdlg('Vector of bin edges (e.g. 1:0.1:7)','Histogram Params',1,{def});
        h.BinEdges=str2num(binsS{1});
        figure(histo);
        delete(findobj(histo,'Type','Axes'));
        histogram(vari1,bins);
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
                vari1 = mycat.Date.(opt);
                bins=-0.5:1:24.5;
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
end
