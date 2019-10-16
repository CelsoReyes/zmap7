function [uOutput] = yourfilterimp(nFunction, sFilename)
% Import filter template -- copy and modify to import your own delimted ascii files
%
% To use this:
%   - Copy it into an appropriate new name (still in the importfilters directory)
%   - Change it

% Assume this function is to convert a comma-separated file formatted thusly:
%
%  ID, La, Lo, Dp, Yr, Mo, Dy, Tm, Ma, MagT, cm
%  01, 46.0, 10.3, 4.0, 2015, 12, 3, 3.1, 12:00:03, Mb, comment
%  02, 45.2, 6.4, 6.0, 2015, 12, 4, 3.2, 03:00:03, Mb, comment
%  03, 45.8, 9.1, 8.0, 2015, 12, 3, 2.0, 12:00:03, Mb, comment
%   ... etc ...
%
%  The goal is to turn this into a ZmapCatalog.
%

% if the file did not have a header, you would specify the column names here:
%
% ColumnNamesInFile = {'ID','Latitude','Longitude','Depth','Year','Month','Day','Time','Magnitude','MagnitudeType', 'Comment'}

% if the names need to be remapped, create the mapping here:
%   - note, if a column is not mentioned, it will be unchanged
%   - note, if a column is mapped to [], it will be removed
fileCols2catalogCols = {'La', 'Latitude';...
                        'Lo', 'Longitude';...
                        'Dp', 'Depth';...
                        'Ma', 'Magnitude';...
                        'MagT', 'MagnitudeType';...
                        'cm', []...
                        };
                    

% Filter function switchyard
switch nFunction
    case FilterOp.getDescription
        % return a short description which will appear in the drop-down list
        uOutput = 'Your data format - adjust the file yourfilterimp.m';
    case FilterOp.getWebpage
        % return a web-page detailing your format
        uOutput = 'yourfilterimp.html';
    case FilterOp.importCatalog
        
        opts = detectImportOptions(sFilename);
        tb = readtable(sFilename, opts);
        
        % now add or change column names, thesemay not map directly to ZmapCatalog yet
        if exist('ColumnNamesInFile','var')
            tb.Properties.VariableNames = ColumnNamesInFile;
        end
        
        % now calculate any columns as necessary.
        tb.Date = datetime(tb.Yr, tb.Mo, tb.Dy) + tb.Tm;  % in this case, tm was automatically converted to a duration
        
        % now rename and delete columns as desired
        if exist('fileCols2catalogCols','var')
            remapper = containers.Map(fileCols2catalogCols(:,1),fileCols2catalogCols(:,2));
            for idx = numel(tb.Properties.VariableNames) : -1 : 1 % going backwards avoids trouble deleting
                fcolname = tb.Properties.VariableNames{idx};
                if ismember(fcolname, remapper.keys())
                    if isempty(remapper(fcolname))
                        tb.(fcolname) = [];
                    else
                        tb.Properties.VariableNames{idx} = remapper(fcolname);
                    end
                end
            end
        end
        uOutput = ZmapCatalog.from(tb);
        return
    
end

