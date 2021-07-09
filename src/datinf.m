function datinf() 
    % display available information about a dataset
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    myFigName='Dataset Info';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    %
    
    %
    %  Stefan Wiemer 12/94
    
    % This is the info window text
    %
    ttlStr='Information about the current dataset         ';
    hlpStr1dainf = ...
        ['                                                '
        ' This window contains information about the     '
        ' current dataset. You can enter any additional  '
        ' information in this window.                    '
        '                                                '
        ' You should try to document as much information '
        ' as possible about your data!                   '
        '                                                '
        ' In order to save this information you have to  '
        ' select SAVE and save the current dataset       '
        ' information along with the current catalog and '
        ' overlay information in a file.                 '
        '                                                '];
    
    %  Create new figure
    % Find out if figure already exists
    %
    dainf = myFigFinder();
    
    % Set up the datinf window Environment
    %
    if isempty(dainf)
        dainf = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Color',[0.7 0.7 0.7],...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1)-100, ZG.map_len(2)-100));
        
        orient tall
        axis off
        
        fr = uicontrol(dainf,...
            'Units','normalized',...
            'Style','frame',...
            'BackgroundColor' ,[1.0 1.0 0.7]',...
            'Position',[0.1 0.1 0.8 0.7]);
        
        if ~exist('infstri','var') || isempty(infstri)
            infstri = ' Please enter information about the dataset';
        end
        
        uic = uicontrol(dainf,...
            'Style','edit',...
            'Units','normalized',...
            'String',infstri,...
            'BackgroundColor' ,[1.0 1.0 1.0]',...
            'Max',2,...
            'Tag', 'uic',...
            'Position',[0.12 0.12 0.75 0.65]);
        
        % show buttons  for various analyses programs:
        
        uicontrol('Units','normal',...
            'Position',[.0 .90 .10 .09],'String','Print ',...
            'callback',@callbackfun_001)
        
        uicontrol('Units','normal',...
            'Position',[.2 .90 .10 .09],'String','Close ',...
            'callback',@callbackfun_002)
        
        uicontrol('Units','normal',...
            'Position',[.4 .90 .10 .09 ],'String','Info ',...
            'callback',@callbackfun_003)
        
        uicontrol('Units','normal',...
            'Position',[.6 .90 .10 .09 ],'String','Save',...
            'callback',@save_cb);
        
        
        
        
    end   % if fig exist
    
    figure(dainf)
    set(findobj(dainf,'Tag', 'uic'),'String',infstri);
    set(dainf,'Visible','on')
    
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        printdlg;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        infstri = get(uic,'String');
        f1=gcf;
        f2=gpf;
        set(f1,'Visible','off');
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1dainf);
    end
    
    function save_cb(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        infstri = get(uic,'String');msg.infodisp('  ','Save Data');
        [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Earthquake Datafile');
        if length(file1) > 1
            try
                save([path1, file1], 'a','faults','main','mainfault','coastline','infstri')
            catch ME
                errordlg(ME.message,'Error saving data');
            end
        end
    end
    
end
