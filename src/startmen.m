function startmen(parent_fig)
    % startmen adds menus for the basic zmap functions (Data, help)
    
    report_this_filefun(mfilename('fullpath'));
    %
    %  This file display the original menu
    %
    %  Stefan Wiemer 12/94
    
    %  Create new figure
    % Find out of figure already exists
    %
    
    global my_dir
    
    % [existFlag, mainmenu]=figure_exists('ZMAP 6.0 - Menu');
    my_dir = ' ';
    
    % Set up the Seismicity Map window Enviroment
    %
    if nargin==1
        disp(parent_fig)
        genmen = uimenu(parent_fig,'Label','Data');
        
        uimenu(genmen, ...
            'Label','Load *.mat datafile',...
            'Callback', {@(s,e) startzma() });
        uimenu(genmen, ...
            'Label','Import data from other formatted file',... %was Data ImportFilters
            'Callback', {@think_and_do,'zdataimport'});
        uimenu(genmen, ...
            'Label','FDSN web fetch',... %TODO
            'Callback', @get_fdsn_data_from_web);
        uimenu(genmen, ...
            'Label', 'Create or Modify *.mat datafile',...
            'Callback', {@think_and_do, 'setup'});
        uimenu(genmen, ...
            'Label', 'Current Dataset Info',...
            'Callback',{@think_and_do,'datinf'});
        
        uimenu(genmen, ...
            'Label','Set working directory ',...
            'Callback',{@think_and_do,'working_dir_in'});
        
        genmen = uimenu(parent_fig,'Label','Help');
        
        
        uimenu(genmen, ...
            'Label','Introduction and Help',...
            'Callback', @(s,e) showweb('new'));
        
        uimenu(genmen, ...
            'Label','Sample Slide Show',...
            'Callback',@(s,e) slshow());
        
    end
    
end

function think_and_do(s, e, f_handle, varargin)
    think;
    if ischar(f_handle) && nargin==3
        evalin('base',f_handle); %use evalin??
    else
        f_handle(varargin{:});
    end
    zmap_message_center.update_catalog();
end

function get_fdsn_data_from_web(s, e)
    think;
    h = findall(0,'Tag','fdsn_import_dialog');
    if isempty(h)
        fdsn_param_dialog(); % create
    else
        h.Visible = 'on'; % show existing
    end
end



