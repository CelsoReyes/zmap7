function txt = event_datacursor_txt(~,event_obj)
    % show events off a map, filtering for x,y,z on main catalog
    % capable of showing multiple events if they 
    % event_obj   Object containing event data structure
    % output_txt  Data cursor text
    %
    % currently selected event(s) can be found on desktop as datacursor_catalog
    
    %event_obj.Target : handle of object data cursor is referencing
    %event_obj.Position : array specifying x,y,z
    
    % redefine data cursor Updatefcn
    % set(dcm_obj, 'UpdateFcn',@myupdatefcn)
    %ZG=ZmapGlobal.Data;
    event_obj.Target
    event_obj.Position
    
    switch lower(event_obj.Target.DisplayName)
        case {'stations'}
            txt=parse_stations(event_obj);
        case {'volcanoes'}
            txt=parse_volcanoes(event_obj);
        case {'main faultline'}
            txt=parse_faults(event_obj);
        case {'plate boundaries'}
            txt=parse_plates(event_obj);
            
        otherwise
            
            txt=parse_quakes(event_obj);
    end
    
end

%% These parsing routines should probably be assigned to the features themselves.

function txt = parse_quakes(event_obj)
    disp(event_obj.Target)
    latTol = 0.001;
    lonTol = 0.001;
    depthTol = 0.1;
    OUTPUT_NAME='datacursor_catalog';
    
    assignin('base','clickedevent',event_obj)
    evpos=event_obj.Position;
    ZG=ZmapGlobal.Data;
      evNum=find(...
         abs(evpos(2) - ZG.primeCatalog.Latitude) < latTol &...
         abs(evpos(1) - ZG.primeCatalog.Longitude) < lonTol &...
         abs(evpos(3) - ZG.primeCatalog.Depth < depthTol));
    
     minicat=ZG.primeCatalog.subset(evNum);
     minicat.Name=sprintf('datacursor:%s', char(datetime(),'uuuuMMdd''T''hhmmss'));
     assignin('base',OUTPUT_NAME,minicat);
     
     txt={};
     if minicat.Count > 1
         txt={sprintf('%d events within position tolerance',minicat.Count)};
     end
     
     if minicat.Count > 3
         try
             for i =1:minicat.Count
                 if i > 5 && i<minicat.Count
                     continue
                 end
                 if i== 5 && i < minicat.Count
                     txt = [txt, {sprintf('  ... skipping %d events ...',minicat.Count-5)}];
                     continue
                 end
                 
                 lattxt=lat_text(event_obj,minicat,i);
                 lontxt=lon_text(event_obj,minicat,i);
                 
                 mt = minicat.MagnitudeType{i};
                 if isempty(mt)
                     mt='magnitude';
                 end
                 txt=[txt,{[sprintf('[# %5d] ',evNum(i)),...
                     sprintf(' %s',char(minicat.Date(i),'uuuu-MM-dd HH:mm:ss ; ')),...
                     sprintf('( %8s , %8s ) at %5.2f km ; ',lattxt,lontxt,evpos(3)),...
                     sprintf('%s %.1f',mt, minicat.Magnitude(i))]};
                     ];
             end
             
         catch ME
             warning(ME.message)
         end
             
     else
         try
             for i =1:minicat.Count
                 lattxt=lat_text(event_obj,minicat,i);
                 lontxt=lon_text(event_obj,minicat,i);
                 mt = minicat.MagnitudeType{i};
                 if isempty(mt)
                     mt='magnitude';
                 end
                 txt=[txt,{sprintf('- Event # %d -',evNum(i)),...
                     sprintf('%s',char(minicat.Date(i),'uuuu-MM-dd HH:mm:ss')),...
                     sprintf('( %s , %s )',lattxt,lontxt),...
                     sprintf(' %.2f km depth',minicat.Depth(i)),...
                     sprintf('%s : %.1f',mt, minicat.Magnitude(i))};
                     ];
                 if i < minicat.Count
                     txt=[txt,{''}];
                 end
             end
             
         catch ME
             warning(ME.message)
         end
     end
end

function txt = parse_stations(event_obj)
    % get table information
    
    latTol = 0.01;
    lonTol = 0.01;
    
    ZG=ZmapGlobal.Data;
    f=ZG.features('stations');
    evpos=event_obj.Position;
    idx=find(...
        abs(evpos(2) - f.Latitude) < latTol &...
        abs(evpos(1) - f.Longitude) < lonTol);
    txt={sprintf('%d station(s):',numel(idx))};
    for i=1:numel(idx)
        lattxt=lat_text(event_obj,f,i);
        lontxt=lon_text(event_obj,f,i);
        
        txt=[txt,f.Names(idx(i)),...
            sprintf('( %s , %s )',lattxt,lontxt),...
            sprintf(' %.2f km elev',-f.Depth(i))];
    end
end

function txt = parse_faults(event_obj)
    txt='fault'
    %f=ZG.features('faults');
end
function txt = parse_plates(event_obj)
    txt='plate boundary'
    %f=ZG.features('plates');
end

function txt = parse_volcanoes(event_obj)    % get table information
    latTol = 0.001;
    lonTol = 0.001;
    
    ZG=ZmapGlobal.Data;
    f=ZG.features('volcanoes');
    evpos=event_obj.Position;
    idx=find(...
        abs(evpos(2) - f.Latitude) < latTol &...
        abs(evpos(1) - f.Longitude) < lonTol)
    txt={sprintf('%d volcanic feature(s):',numel(idx))};
    for i=1:numel(idx)
        lattxt=lat_text(event_obj,f,i);
        lontxt=lon_text(event_obj,f,i);
        
        txt=[txt,f.Names(idx(i)),...
            sprintf('( %s , %s )',lattxt,lontxt),...
            sprintf(' %.2f km elev',-f.Depth(i))];
    end
    
end

function lattxt=lat_text(event_obj,obj,idx)
    if ~exist('idx','var')
        idx=1;
    end
    evpos=event_obj.Position;
    if evpos(1)>0
        lattxt=[num2str(obj.Latitude(idx)) ' N'];
    else
        lattxt=[num2str(obj.Latitude(idx)) ' S'];
    end
end

function lontxt=lon_text(event_obj,obj,idx)
    if ~exist('idx','var')
        idx=1;
    end
    evpos=event_obj.Position;
    if evpos(1)>0
        lontxt=[num2str(obj.Longitude(idx)) ' E'];
    else
        lontxt=[num2str(obj.Longitude(idx)) ' W'];
    end
end
