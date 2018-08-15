function setlegm() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    % make dialog interface for the fixing of the legend
    %
    
    
    %
    ZG=ZmapGlobal.Data;
    
    report_this_filefun();
    
    % FIXME these global variables are out of sync with the newer method of tracking divisions
    switch ZmapGlobal.Data.mainmap_plotby
        case 'mag'
            % creates a dialog box to input some parameters
            %
            dep3 = max(ZG.primeCatalog.Magnitude);
            dep1 = min(ZG.primeCatalog.Magnitude);
            dep2 = (dep1+dep3)*2/3;
            dep1 = (dep1+dep3)*1/3;
            
            dlg_title='Legend Magnitude Breaks';
            sdlg.prompt='First magnitude division (smallest):';sdlg.value=dep1;
            sdlg(2).prompt='Second magnitude division:';sdlg(2).value=dep2;
            sdlg(3).prompt='Third magnitude division (largest):';sdlg.value=dep3;
            [sdlg,cancelled]=smart_inputdlg(dlg_title,sdlg);
            if cancelled
                zmap_message_center()
                return
            end
            ZG.mainmap_plotby='mag'; %redundant?
            dep1=sdlg(1).value;
            dep2=sdlg(2).value;
            dep3=sdlg(3).value;
            
        case 'depth'
            % creates a dialog box to input some parameters
            %
            % divide depths into 3 categories
            dep1 = 0.3*max(ZG.primeCatalog.Depth);
            dep2 = 0.6*max(ZG.primeCatalog.Depth);
            dep3 = max(ZG.primeCatalog.Depth);
            
            dlg_title='Legend Depth Breaks';
            prompt={'First depth division (shallowest, km):',...
                'Second depth division (km):',...
                'Third magnitude division (deepest, km):'};
            defaultans = {num2str(dep1), num2str(dep2), num2str(dep3)};
            answer = inputdlg(prompt, dlg_title, 1, defaultans);
            if ~isempty(answer)
                for i=1:3
                    % convert from string
                    answer{i} = str2double(answer{i});
                end
                ZG=ZmapGlobal.Data;ZG.mainmap_plotby='depth'; %redundant?
                dep1=answer{1};
                dep2=answer{2};
                dep3=answer{3};
            else
                ZmapMessageCenter();
            end
    end
    clear answer temp defaultans prompt dlg_title
    zmap_update_displays();
end
