function replot_all(obj,metaProp,eventData)
    % REPLOT all the windows
    % REPLOT_ALL(obj, metaProp, eventData)

    if ~exist('eventData','var') || strcmp(eventData.EventName,'PostSet')
        eventData.EventName='ReplotAll';
    end
    disp(['*** REPLOTTING BECAUSE: ' eventData.EventName]);
    
    md=[];
    k={};
    
    obj.replotting=true;
    switch eventData.EventName
        case 'XsectionAdded'
            disp('add a cross section to plots')
            k=obj.xsections.keys;
            if numel(k)>1
                k = k(~ismember(k,get(obj.xsgroup.Children,'Title')));
            end
            
        case {'XsectionRemoved'}
            disp('remove cross section from plots')
            
        case 'XsectionEmptied'
            
        case {'CatalogChanged','ReplotAll','DateRangeChanged'}
            disp('replot evererything touched by catalog')
            k=obj.xsections.keys;
            obj.undohandle.Enable=tf2onoff(~isempty(obj.prev_states));
            [obj.catalog, md, ~, mall]=obj.filtered_catalog(); %md:mask date, ms:mask shape   % only show events if they aren't all selected
            evs=findobj(findobj('Tag','mainmap_tab'),'Tag','all events');
            if all(mall)
                evs.Visible='off';
            else
                evs.XData(mall)=nan;
                evs.XData(~mall)=obj.rawcatalog.Longitude(~mall);
                evs.Visible='on';
            end
            obj.plotmainmap();
            
        otherwise
            k=obj.xsections.keys;
            disp('uncaught event')
    end
    
    if ~isvalid(obj.fig)
        errordlg('Figure associated with this ZmapMainWindow has been deleted!');
        return
    end
    
    currcatsummary = obj.catalog.summary('stats');
    for j=1:numel(k)
        plot_xsection(obj,k{j},currcatsummary,md);
    end
    
    obj.plothist('Magnitude',obj.catalog.Magnitude,'UR plots');
    obj.cumplot('LR plots');
    
    obj.plothist('Depth',obj.catalog.Depth,'UR plots');
    obj.plothist('Date',obj.catalog.Date,'UR plots');
    obj.plothist('Hour',hours(obj.catalog.Date.Hour),'UR plots');
    obj.fmdplot('UR plots');
    obj.cummomentplot('LR plots');
    obj.time_vs_something_plot('Time-Mag', TimeMagnitudePlotter, 'LR plots');
    obj.time_vs_something_plot('Time-Depth', TimeDepthPlotter, 'LR plots');
    
    obj.replotting=false;
    
    drawnow
    
    rearrange_axes_items(obj)
end

function rearrange_axes_items(obj)
    % rearrange main axes items into specific order
    ch=obj.map_axes.Children;
    items.map = startsWith(get(ch,'Tag'),'mainmap_');
    items.grid = startsWith(get(ch,'Tag'),'grid_');
    items.bgevents = strcmp(get(ch,'Tag'),'all events');
    items.fgevents = strcmp(get(ch,'Tag'),'active quakes');
    items.shape = startsWith(get(ch,'Tag'),'shape');
    items.other = ~(items.map | items.grid | items.shape | items.bgevents | items.fgevents);
    obj.map_axes.Children = [  ch(items.shape); ch(items.fgevents); ch(items.other); ch(items.bgevents); ch(items.map);ch(items.grid)];   
end

function plot_xsection(obj, k, currcatsummary,md)
    % plot into the xsection tab area
    hold on
    xs=obj.xsections(k);
    
    % only reproject if the catalog is changed since memorizing
    if ~isequal(currcatsummary,obj.xscatinfo(k))
        
        % store the projected catalog. only events within the strip [ignoring shape] are stored
        if ~isempty(md)
            obj.xscats(k)=xs.project(obj.rawcatalog.subset(md));
        else
            obj.xscats(k)=xs.project(obj.rawcatalog);
        end
        
        % store the information about the current catalog used to project
        obj.xscatinfo(k)=currcatsummary;
        
        % plot
        mytab=findobj(obj.xsgroup,'Title',k,'-and','Type','uitab');
        myax=findobj(mytab,'Type','axes');
        xs.plot_events_along_strike(myax,obj.xscats(k),false);
        myax.Title=[];
    end
end

