function out = load_coast_and_borders(filename, fileformat, varname)
    % loads coastaldata from a shapefile or .mat savefile
    % out = load_coast_and_borders()  loads default coastal information
    % out = load_coast_and_borders(filename, 'shp') loads coastal information from
    %        a .shp file of your choosing
    % out = load_coast_and_borders(filename, 'mat', varname) loads coastal info from
    %       a .mat file, stored in variable varname
    %
    % returns out = [lon(:) , lat(:)]
    out = [nan nan];
    if ~exist ('filename','var')
        if exist ('gadm28_adm0.shp','file')
            filename = 'gadm28_adm0.shp';
            fileformat = 'shp';
        else
            filename='coastlines.mat';
            fileformat='mat';
            tmp=load(filename);
            out = struct('Longitude',tmp.coastlon(:),'Latitude',tmp.coastlat(:));
            return
        end
    end
    
    if ~exist (filename,'file')
        errordlg(['Could not find file ',filename]);
        return
    end
    
    if ~exist('fileformat','var')
        if endswith(filename, '.mat')
            fileformat = '.mat';
        elseif endwith(filename,'.shp')
            fileformat = 'shp';
        else
            errodlg('unable to determine file format');
        end
    end
    
    switch fileformat
        case 'shp'
            S=shaperead(filename,'UseGeoCoords',true); %country administrative level
            out = struct('Longitude',[S.Lon],'Latitude',[S.Lat]');
        case 'mat'
            if ~exist('varname','var')
                whosinfo = whos('-FILE', filename);
                if numel(whosinfo) ~= 1
                    errordlg('multiple variables were found within the file. Please specify one');
                else
                    varname = whosinfo(1).name;
                end
            end
            
            
            if exist('varname','var')
                tmp = load(filename, varname);
                if isstruct(tmp.(varname)) || istable(tmp.(varname))
                    out=struct('Longitude',[],'Latitude',[]);
                    fn = fieldnames(tmp.(varname));
                    for i = 1: numel(fn)
                        switch lower(fn{i})
                            case {'lat','latitude','coastlat'}
                                out.Latitude = tmp.(varname).(fn{i});
                            case {'lon','longitude','coastlon'}
                                out.Longitude = tmp.(varname).(fn{i});
                        end
                    end
                    if size(out,2) ~=2
                        errordlg('could not properly import lat/lon fields');
                    end
                else % numeric
                    % warning: not validating
                    out = struct('Longitude',tmp.(varname)(:,1),...
                        'Latitude',tmp.(varname)(:,2));
                end
            end
    end
end