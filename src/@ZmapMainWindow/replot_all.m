function replot_all(obj,metaProp,eventData)
    % REPLOT all the windows
    % REPLOT_ALL(obj, metaProp, eventData)
    
    obj.AllAxes=findobj(gcf,'Type','axes');
    
    if ~exist('eventData','var') || eventData.EventName == "PostSet"
        eventName='ReplotAll';
    else
        eventName = eventData.EventName;
    end
    disp(['*** REPLOTTING BECAUSE: ' eventName]);
    
    %warning('ReplotStack')
    md=[];
    k={};
    
    s=sprintf('Created by: ZMAP %s , %s',ZmapData.zmap_version, char(datetime));
    set(findobj(obj.fig,'Tag','zmap_watermark','-and','Type','uicontrol','-and','Style','text'),...
        'String',s);
    
    obj.replotting=true;
    switch eventName
        case 'XsectionAdded'
            disp('add a cross section to plots')
            k=obj.XSectionTitles;
            if numel(k)>1
                k = k(~ismember(k,get(obj.xsgroup.Children,'Title')));
            end
            
        case {'XsectionRemoved'}
            disp('remove cross section from plots')
            
        case {'XsectionChanged'}
            disp('replot cross sections')
            k=obj.XSectionTitles;
            
        case 'XsectionEmptied'
            
        case {'CatalogChanged','ReplotAll','DateRangeChanged','ShapeChanged'}
            disp('replot everything touched by catalog')
            k=obj.XSectionTitles;
            if eventName=="ShapeChanged"
                disp(eventData.Source);
                disp(metaProp);
                obj.shape=eventData.Source;
            end
            obj.undohandle.Enable=tf2onoff(~isempty(obj.prev_states));
            [obj.catalog, md, ~, mall]=obj.filtered_catalog(); %md:mask date, ms:mask shape   % only show events if they aren't all selected
            evs=findobj(obj.maintab,'Tag','all events');
            if all(mall)
                evs.Visible='off';
            else
                if numel(evs.XData)==numel(obj.rawcatalog.Count)
                evs.XData(mall)=nan;
                evs.XData(~mall)=obj.rawcatalog.Longitude(~mall);
                else
                    % catalog is out of sync. replot
                    evs.XData=obj.rawcatalog.Longitude;
                    evs.YData=obj.rawcatalog.Latitude;
                    evs.ZData=obj.rawcatalog.Depth;
                    evs.XData(mall)=nan;
                end
                evs.Visible='on';
                
            end
            obj.plotmainmap();
        otherwise
            k=obj.XSectionTitles;
            fprintf('uncaught event: [%s]\n',eventName);
    end
    
    if ~isvalid(obj.fig)
        errordlg('Figure associated with this ZmapMainWindow has been deleted!');
        return
    end
    
    currcatsummary = obj.catalog.summary('stats');
    for j=1:numel(k)
        plot_xsection(obj,k{j},currcatsummary,md);
    end
    
    obj.fmdplot('UR plots');
    obj.plothist('Magnitude',obj.catalog.Magnitude,'UR plots');
    obj.cumplot('LR plots');
    
    obj.plothist('Depth',obj.catalog.Depth,'UR plots');
    obj.plothist('Date',obj.catalog.Date,'UR plots');
    obj.plothist('Hour',hours(obj.catalog.Date.Hour),'UR plots');
    obj.cummomentplot('LR plots');
    obj.time_vs_something_plot('Time-Mag', TimeMagnitudePlotter, 'LR plots');
    obj.time_vs_something_plot('Time-Depth', TimeDepthPlotter, 'LR plots');
    
    obj.replotting=false;
    drawnow nocallbacks
    
    rearrange_axes_items(obj)
end

function rearrange_axes_items(obj)
    % rearrange main axes items into specific order
    ch=obj.map_axes.Children;
    items.map = startsWith(get(ch,'Tag'),'mainmap_');
    items.grid = startsWith(get(ch,'Tag'),'grid_');
    items.bgevents = get(ch,'Tag') == "all events";
    items.fgevents = get(ch,'Tag') == "active quakes";
    items.shape = startsWith(get(ch,'Tag'),'shape');
    items.other = ~(items.map | items.grid | items.shape | items.bgevents | items.fgevents);
    obj.map_axes.SortMethod='childorder';
    obj.map_axes.Children = [  ch(items.shape); ch(items.fgevents); ch(items.other); ch(items.bgevents); ch(items.map);ch(items.grid)];   
end

function plot_xsection(obj, k, currcatsummary,md)
    % plot into the xsection tab area
    set(gca,'NextPlot','add')
    idx = strcmp(obj.XSectionTitles,k);
    
    % only reproject if the catalog is changed since memorizing
    %if ~isequal(currcatsummary,obj.xscatinfo(k))
        
        % store the projected catalog. only events within the strip [ignoring shape] are stored
        if ~isempty(md)
            obj.xscats(k)=obj.CrossSections(idx).project(obj.rawcatalog.subset(md));
        else
            obj.xscats(k)=obj.CrossSections(idx).project(obj.rawcatalog);
        end
        
        % store the information about the current catalog used to project
        obj.xscatinfo(k)=currcatsummary;
        
        % plot
        mytab=findobj(obj.xsgroup,'Title',k,'-and','Type','uitab');
        myax=findobj(mytab,'Type','axes');
        obj.CrossSections(idx).plot_events_along_strike(myax,obj.xscats(k),true);
        myax.Title=[];
    %end
end

