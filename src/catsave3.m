function catsave3(version)
    % save catalog and associated items, collated from various methods

    %TODO detangle this
    warning('not saving');
    ZmapMessageCenter.set_info('Save Grid','  ');
    switch version
        
        case 'bcross'
            [file1,path1] = uiputfile([ '*.mat'], 'Grid Datafile Name?') ;

            vlist=split('ll a newgri lat1 lon1 lat2 lon2 xsec_defaults.WidthKm  bvg xvect yvect gx gy dx dd bin_dur newa maex maey maix maiy'); 
           
        case 'bcrossV2'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?') ; 
            vlist=split('ll a tmpgri newgri lat1 lon1 lat2 lon2 xsec_defaults.WidthKm  bvg xvect yvect gx gy dx dd bin_dur newa maex maey maix maiy'); 
          
        case 'bcrossVt2'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?') ; 
            vlist=split('ll tmpgri bvg xvect yvect gx gy ni dx dd bin_dur ni newa maex maey maix maiy'); 

            
        case 'bdepth_ratio'
            vlist=split('bvg gx gy dx dy bin_dur tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll depth_ratio top_zonet top_zoneb bot_zoneb bot_zonet ni_plot'); 
            
        case 'bgrid3dB'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?') ; 
            vlist=split('zvg teb ram go avm mcma gx gy gz dx dy dz bin_dur bvg tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri well ll ni'); 
            
            
        case 'bvalgrid'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?') ;
                vlist={'bvg','gx', 'gy', 'dx', 'dy', 'bin_dur', 'tdiff', 't0b', 'teb', 'a', 'main', 'faults', 'mainfault', 'coastline', 'yvect', 'xvect', 'newgri', 'll'};

        case 'bvalmaptd'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?') ; 
            vlist=split('bvg gx gy dx dy bin_dur tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll'); 
          
            
        case 'calc_across'
            [file1,path1] = uiputfile([ '*.mat'], 'Grid Datafile Name?') ;
            vlist=split('ll a tmpgri newgri lat1 lon1 lat2 lon2 xsec_defaults.WidthKm  avg xvect yvect gx gy dx dd bin_dur newa maex maey maix maiy'); 
          
            
        case 'calc_Omoricross'
            [file1,path1] = uiputfile(fullfile(hodi, 'eq_data', '*.mat'), 'Grid Datafile Name?') ; 
            vlist=split('mCross gx gy dx dy bin_dur tdiff t0b teb newa a main faults mainfault coastline yvect xvect tmpgri ll overall_b_value newgri ra time timef bootloops maepi xsecx xsecy xsec_defaults.WidthKm lon1 lat1 lon2 lat2'); 
           
            
        case 'Dcross'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?') ;
            vlist=split('ll a tmpgri newgri lat1 lon1 lat2 lon2 xsec_defaults.WidthKm  bvg xvect yvect gx gy dx dd bin_dur newa maex maey maix maiy'); 
          
            
        case 'magrcros'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile Name?'); 
            vlist=split('cumuall pos gx gy ni dx dy bin_dur newa maex maix maey maiy tmpgri ll newgri xvect yvect');
           
        case 'makegrid'
            [file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.Directories.data, '*.mat'), 'Grid Datafile',400,400); 
            vlist=split('x y tmpgri newgri xvect yvect ll cumuall bin_dur ni dx dy gx gy tdiff t0b teb loc a main faults mainfault coastline'); 
           
            
        otherwise
            file1='';
            vlist={};
    end
    
    if length(file1) > 1
        wholePath=[path1 file1];  
        save(wholePath, vlist{:});
    end

end