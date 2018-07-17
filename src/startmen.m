function startmen(parent_fig)
    % startmen adds menus for the basic zmap functions (Data, help)
    
    report_this_filefun();
    %
    %  This file display the original menu
    %
    %  Stefan Wiemer 12/94
    
    %  Create new figure
    % Find out if figure already exists
    %
    
    % Set up the Seismicity Map window Enviroment
    %
    if nargin==1
        disp(parent_fig)
        genmen = uimenu(parent_fig,'Label','Data');
        
        uimenu(genmen, ...
            'Label','Load Catalog (*.mat file)',...
            MenuSelectedField(), @(~,~)cb_load_file);%ZmapImportManager(@load_zmapfile));
        uimenu(genmen, ...
            'Label','Import Catalog from other formatted file',... %was Data ImportFilters
            MenuSelectedField(), @(~,~)ZmapImportManager(@zdataimport));
        uimenu(genmen, ...
            'Label','FDSN web fetch',... %TODO
            MenuSelectedField(), @(~,~)cb_load_web);%ZmapImportManager(@get_fdsn_data_from_web_callback));
        uimenu(genmen, ...
            'Label', 'Create or Modify *.mat datafile',...
            MenuSelectedField(), {@think_and_do, 'setup'});
        uimenu(genmen, ...
            'Label', 'Current Dataset Info',...
            'Enable','off',... % may no longer be relevent
            MenuSelectedField(), @(~,~)datinf());
        
        uimenu(genmen, ...
            'Label','Set working directory ',...
            'Enable','off',... % doesn't seem to be used anywhere
            MenuSelectedField(),@(~,~)working_dir_in);
        
        genmen = uimenu(parent_fig,'Label','Help');
        
        
        uimenu(genmen, ...
            'Label','Introduction and Help',...
            MenuSelectedField(), @(s,e) showweb('new'));
        
        uimenu(genmen, ...
            'Label','Sample Slide Show',...
            MenuSelectedField(),@(s,e) slshow());
        
    end
    function cb_load_file
        ok=ZmapImportManager(@load_zmapfile);
        if ok
            ZG= ZmapGlobal.Data;
            ZmapMainWindow([],ZG.primeCatalog);
        end
    end
    function cb_load_web
        ok=ZmapImportManager(@get_fdsn_data_from_web_callback);
        if ok
            ZG= ZmapGlobal.Data;
            ZmapMainWindow([],ZG.primeCatalog);
        end
    end
end

function think_and_do(~, ~, f_handle, varargin)
    
    if ischar(f_handle) && nargin==3
        evalin('base',f_handle); %use evalin??
    else
        f_handle(varargin{:});
    end
    ZmapMessageCenter.update_catalog();
end

