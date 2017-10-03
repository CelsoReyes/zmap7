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
    
    latTol = .001;
    lonTol = .001;
    depthTol = 1;
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
                 if evpos(2)>0
                     lattxt=[num2str(minicat.Latitude(i)) ' N'];
                 else
                     lattxt=[num2str(-minicat.Latitude(i)) ' S'];
                 end
                 
                 if evpos(1)>0
                     lontxt=[num2str(minicat.Longitude(i)) ' E'];
                 else
                     lontxt=[num2str(-minicat.Longitude(i)) ' W'];
                 end
                 mt = minicat.MagnitudeType{i};
                 if isempty(mt)
                     mt='magnitude';
                 end
                 txt=[txt,{[sprintf('[# %5d] ',evNum(i)),...
                     sprintf(' %s',char(minicat.Date(i),'uuuu-MM-dd hh:mm:ss ; ')),...
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
                 if evpos(2)>0
                     lattxt=[num2str(minicat.Latitude(i)) ' N'];
                 else
                     lattxt=[num2str(minicat.Latitude(i)) ' S'];
                 end
                 
                 if evpos(1)>0
                     lontxt=[num2str(minicat.Longitude(i)) ' E'];
                 else
                     lontxt=[num2str(minicat.Longitude(i)) ' W'];
                 end
                 mt = minicat.MagnitudeType{i};
                 if isempty(mt)
                     mt='magnitude';
                 end
                 txt=[txt,{sprintf('- Event # %d -',evNum(i)),...
                     sprintf('%s',char(minicat.Date(i),'uuuu-MM-dd hh:mm:ss')),...
                     sprintf('( %s , %s )',lattxt,lontxt),...
                     sprintf(' %.2f km depth',evpos(3)),...
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