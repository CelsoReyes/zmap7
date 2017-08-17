function [mCatalog] = import_start(sFilterDir,FilePath)
    %13.04.14: small fix allowing to pass in the filepath directly to avoid
    %GUI file handler (used for MapSeis)
    
    if nargin<2
        FilePath=[];
    end
    
    % Default return value
    mCatalog = nan;
    
    % Check if filter directory ends with the appropriate directory separator
    sLastChar = sFilterDir(length(sFilterDir));
    if ~(sLastChar == filesep)
        sFilterDir = [sFilterDir filesep];
    end
    
    % Get directory in filter directory
    vrDir = dir(sFilterDir);
    if isempty(vrDir)
        errordlg('Directory does not exist');
        return;
    elseif length(vrDir) == 2
        errordlg('Directory is empty. No Filters found.');
        return;
    end
    
    % Initialize filter list
    cFilter = {};
    % Counter for detected filters
    nFilter = 1;
    
    for nCnt = 1:length(vrDir)
        % Check for directories
        if ~((strcmp(vrDir(nCnt).name, '.')) | (strcmp(vrDir(nCnt).name, '..')))
            % Get name of file
            sName = vrDir(nCnt).name;
            nPos = strfind(sName, '.m');
            % Is it a .m-file
            if ~isempty(nPos)
                sName = sName(1:(nPos - 1));
                try
                    % Is it an import filter
                    sDescription = feval(sName, 0);
                catch
                    sDescription = [];
                end
                % Is it really an import filter
                if ischar(sDescription)
                    % Insert it into filter list
                    cFilter{nFilter, 1} = sDescription;
                    cFilter{nFilter, 2} = sName;
                    nFilter = nFilter + 1;
                end
            end
        end
    end
    
    % Charmatrix with names of filters
    mFilterNames = char(cFilter{:,1});
    mFilterFiles = char(cFilter{:,2});
    
    % Invoke the user interface
    hDialog = import_dialog(mFilterNames, mFilterFiles, sFilterDir);
    
    % Analyze Output
    if ~ishandle(hDialog)
        answer = 0;
    else
        handles = guidata(hDialog);
        answer = handles.answer;
        % OK pressed
        if answer == 1
            % Get the values from figure
            nFilter = get(handles.lstFilter, 'Value');
            % Remove figure from memory
            delete(hDialog);
            % Get the catalog file
            if isempty(FilePath)
                [newfile, newpath] = uigetfile('*.*', 'Choose catalog datafile');
            else
                [pathstr, name, ext] = fileparts(FilePath);
                newpath =[pathstr,filesep];
                newfile = [name,ext];
            end
            
            % Cancel pressed?
            if ~(isequal(newfile, 0) | isequal(newpath, 0))
                newfile = [newpath newfile];
                % Everything ok?
                if length(newfile) > 1
                    mCatalog = feval(cFilter{nFilter,2}, 1, newfile);
                end
            end
        else
            % Remove figure from memory
            delete(hDialog);
        end
    end
    
end
