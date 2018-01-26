function startmen(parent_fig)
    % startmen adds menus for the basic zmap functions (Data, help)
    
    report_this_filefun(mfilename('fullpath'));
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
            'Callback', @(~,~)ZmapImportManager(@load_zmapfile));
        uimenu(genmen, ...
            'Label','Import Catalog from other formatted file',... %was Data ImportFilters
            'Callback', @(~,~)ZmapImportManager(@zdataimport));
        uimenu(genmen, ...
            'Label','FDSN web fetch',... %TODO
            'Callback', @(~,~)ZmapImportManager(@get_fdsn_data_from_web_callback));
        uimenu(genmen, ...
            'Label', 'Create or Modify *.mat datafile',...
            'Callback', {@think_and_do, 'setup'});
        uimenu(genmen, ...
            'Label', 'Current Dataset Info',...
            'Enable','off',... % may no longer be relevent
            'Callback', @(~,~)datinf());
        
        uimenu(genmen, ...
            'Label','Set working directory ',...
            'Enable','off',... % doesn't seem to be used anywhere
            'Callback',@(~,~)working_dir_in);
        
        genmen = uimenu(parent_fig,'Label','Help');
        
        
        uimenu(genmen, ...
            'Label','Introduction and Help',...
            'Callback', @(s,e) showweb('new'));
        
        uimenu(genmen, ...
            'Label','Sample Slide Show',...
            'Callback',@(s,e) slshow());
        
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

