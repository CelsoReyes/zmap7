function obj = load_shape(filelocation)
    % LOAD_SHAPE will load a shape from a file
    % The file may be either:
    %   1.  a .mat file, with the shape stored in the variable "zmap_shape"
    %   2.  a text file, with columns for latitude and longitude (for a polygon)
    %   2a. a text file, with single-entry columns for latitude, longitude, and radius (for a circle)
    %
    %  If the file cannot be automatically interpreted, then the user will be prompted to choose the column
    
    persistent lastdirectory
    if isempty(lastdirectory)
        lastdirectory=ZmapGlobal.Data.Directories.data;
    end
    fileTypes = {'*.*', 'ALL files';...
        '*.mat', 'MAT-files (*.mat)';...
        '*.csv;*.txt;*.dat',  'other ascii file (*.csv, *.txt, *.dat)'};
    if nargin==0
        % nothing provided, user selects the file
        [filename,pathname,filterindex]=uigetfile(fileTypes,...
            'Load Zmap Shape file',fullfile(lastdirectory, 'zmap_shape.mat'));
    elseif isfile(filelocation)
        % user provided exact file, figure out how to interpret it.
        [pathname,filename, ftype] = fileparts(filelocation);
        filterindex = 1;
        filename=[filename ftype];
    elseif isfolder(filelocation)
        % user provided foder, have them select the exact file
        [filename,pathname,filterindex]=uigetfile(fileTypes,...
            'Load Zmap Shape file',fullfile(filelocation, 'zmap_shape.mat'));
    else
        %something unrecognized was provided as a file location
        [filename,pathname,filterindex]=uigetfile(fileTypes,...
            'Load Zmap Shape file',fullfile(lastdirectory, 'zmap_shape.mat'));
    end

    if filterindex==0
        msg.dbdisp('User pressed cancel')
        return
    end
    
    if filterindex == 1
        [~,~, ftype] = fileparts(filename);
        switch ftype
            case '.mat'
                filterindex = 2;
            case {'.csv','.txt','.dat'}
                filterindex = 3;
            otherwise
                filterindex = 1;
        end
    end
    
    lastdirectory = pathname;
    obj=[];
    
    switch filterindex
        case 2
            % load from a .mat file
            tmp=load(fullfile(pathname,filename),'zmap_shape');
            obj=tmp.zmap_shape;
        case {1, 3}
            % load from a text file
            tb = readtable(fullfile(pathname, filename));
            
            vn =lower(tb.Properties.VariableNames);
            % lat
            if all(startsWith(tb.Properties.VariableNames,'Var'))
                
                % have user figure out which column is which
                quest = {'Which coordinate system is this?','  geodetic = lat & lon','  cartesian = x & y'};
                coordinate_system = questdlg(quest','Coordinate System','geodetic','cartesian','geodetic');
                switch coordinate_system
                    case 'geodetic'
                        yprompt = 'Select Latitude (N-S)';
                        xprompt = 'Select Longitude (E-W)';
                    otherwise
                        yprompt = 'Select Y values';
                        xprompt = 'Select X values';
                end
                
                
                [latIdx,ok] = listdlg('PromptString',yprompt,...
                    'SelectionMode','single',...
                    'ListString',vn_with_example(tb, tb.Properties.VariableNames));
                if ~ok; return; end
                if width(tb)~=2
                    [lonIdx,ok] = listdlg('PromptString', xprompt,...
                        'SelectionMode','single',...
                        'ListString',vn_with_example(tb, tb.Properties.VariableNames));
                    if ~ok; return; end
                else
                    lonIdx = 2-latIdx+1;
                end
            else
                
                latIdxFcns = {...
                    @(vn) vn=="latitude" |vn=="latitudes";
                    @(vn) vn=="lats" | vn=="lat" | vn=="lati";
                    @(vn) vn=='y'};
                
                lonIdxFcns = {...
                    @(vn) vn=="longitude" | vn=="longitudes";
                    @(vn) vn=="long" | vn=="lon" | vn=="lons" ;
                    @(vn) vn=='x'};
                
                
                [latIdx, ok] = getColumn('Latitude', latIdxFcns, vn, tb);
                if ~ok
                    return
                end
                
                [lonIdx, ok] = getColumn('Longitude', lonIdxFcns, vn, tb);
                if ~ok
                    return
                end
                
            end
            
            assert(~isempty(lonIdx) && ~isempty(latIdx), 'indices should have already been chosen by this point');
            
            myYs = tb.(tb.Properties.VariableNames{latIdx});
            myXs = tb.(tb.Properties.VariableNames{lonIdx});
            
            radIdx = startsWith(vn,"radius");
            myunits = extractBetween(vn{radIdx},'[',']');
            if isempty(myunits), myunits = {'km'}; end
            if height(tb)==1 && ~isempty(radIdx)
                % we selected a circle
                obj = ShapeCircle();
                obj.Points = [myXs, myYs];
                obj.Radius = tb{1,radIdx};
                
            else
                % we selected a polygon
                obj = ShapePolygon('Polygon',[myXs, myYs]);
            end
            obj.RefEllipsoid.LengthUnit = validateLengthUnit(myunits{:});
            
            
    end %switch
end

function res = vn_with_example (tb, vn)
    res = vn + " : " + string(tb{1,:})+";...";
end

function [idx, ok] = getColumn(name, compareFcns, vn, tb)
    % compare variable names, in a preferred order.
    for cf = 1 : numel(compareFcns)
        idx = compareFcns{cf}(vn);
        if any(idx)
            break
        end
    end
    
    if ~any(idx)
        % ask user which column
        [idx,ok] = listdlg('PromptString',['Select ' name ' Column'],...
            'SelectionMode','single',...
            'ListString',vn_with_example(tb,vn));
        
    elseif sum(idx) > 1
        % ask user which column
        [sel,ok] = listdlg('PromptString','Select Latitude Column',...
            'SelectionMode','single',...
            'ListString', vn_with_example(tb(1,idx),vn(idx)));
        if ok
            idx = lonIdx(sel);
        end
    else
        ok=true;
    end
end