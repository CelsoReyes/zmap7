function replot_all(obj,status)
    % REPLOT all the windows
    %
    %
    % if something changes the layout, but catalog is unchanged
    % then, set status to 'CatalogUnchanged'
    
    obj.replotting=true;
    % reevaluate cross section catalogs
    if ~exist('status','var')
        status='';
    end
    
    obj.undohandle.Enable=tf2onoff(~isempty(obj.prev_states));
    [obj.catalog,m]=obj.filtered_catalog();
    
    %catChanged = ~strcmp(status,'CatalogUnchanged'); %only partially implemented
    %if catChanged
        k=obj.xsections.keys;
        currcatsummary = obj.catalog.summary('stats');
        for j=1:obj.xsections.Count
            hold on
            xs=obj.xsections(k{j});
            
            % only reproject if the catalog is changed since memorizing
            if ~isequal(currcatsummary,obj.xscatinfo(k{j}))
                
                % store the projected catalog. only events within the strip and shape are stored
                obj.xscats(k{j})=xs.project(obj.catalog);
                %disp(obj.xscats(k{j}));
                
                % store the information about the current catalog used to project
                obj.xscatinfo(k{j})=currcatsummary;
                
                % plot
                mytab=findobj(obj.fig,'Title',k{j},'-and','Type','uitab');
                myax=findobj(mytab,'Type','axes');
                obj.xscats(k{j}).Count
                xs.plot_events_along_strike(myax,obj.xscats(k{j}),false);
                myax.Title=[];
            end
        end
    %end
    
    evs=findobj(obj.fig,'Tag','all events');
    if all(m) 
        evs.Visible='off';
    else
        evs.XData(m)=nan;
        evs.XData(~m)=obj.rawcatalog.Longitude(~m);
        evs.Visible='on';
    end
    %drawnow

    obj.fig.Name=sprintf('%s [%s - %s]',obj.catalog.Name ,char(min(obj.catalog.Date)),...
        char(max(obj.catalog.Date)));
    %figure(obj.fig)
    obj.plotmainmap();
    % Each tab group will have a "SelectionChanghedFcn", "CreateFcn", "DeleteFcn", "UIContextMenu"
    
    lrTabGroup = findobj(obj.fig,'Type','uitabgroup','-and','Tag','LR plots');
    urTabGroup = findobj(obj.fig,'Type','uitabgroup','-and','Tag','UR plots');
    
    WasPlottedBefore=~isempty(lrTabGroup.SelectedTab);
    %if ~WasPlottedBefore
        % plot the two visible tabs first
        obj.plothist('Magnitude',obj.catalog.Magnitude,'UR plots');
        obj.cumplot('LR plots');
    %end
    obj.plothist('Depth',obj.catalog.Depth,'UR plots');
    obj.plothist('Date',obj.catalog.Date,'UR plots');
    obj.plothist('Hour',hours(obj.catalog.Date.Hour),'UR plots');
    obj.fmdplot('UR plots');
    obj.cummomentplot('LR plots');
    obj.time_vs_something_plot('Time-Mag',TimeMagnitudePlotter,'LR plots');
    obj.time_vs_something_plot('Time-Depth',TimeDepthPlotter, 'LR plots');
    if isempty(obj.xsgroup.Children)
        obj.xsgroup.Visible='off';
        set(findobj(obj.fig,'Tag','mainmap_ax'),'Position',obj.MapPos_L);
    end
    obj.replotting=false;
    lrTabGroup.Visible='on';
    urTabGroup.Visible='on';
    drawnow
end
