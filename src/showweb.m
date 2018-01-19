function showweb(action)
    %  M file that starts a Browser displaying
    %  the HTML version of the ZMAP Users Guide
    %
    %  Stefan Wiemer   6/96
    
    report_this_filefun(mfilename('fullpath'));
    disp('Attempting to open browser - please be patient...');
    
    switch(action)
        
        case 'new'
            file_to_manually_open = 'help/IntrotoZMAP6.htm';
            page_location = which('IntrotoZMAP6.htm');
            
        case 'stress'
            file_to_manually_open = 'help/stressinversions.pdf';
            page_location = which('stressinversions.htm');
            
            
        case 'data'
            %FIXME data no longer exists here.
            file_to_manually_open = 'help/onlinedata.htm';
            page_location = ' http://seismo.ethz.ch/staff/stefan/zmap6/help/onlinedata.htm ';
            
            
        case 'fractal'
            file_to_manually_open='help/FDH0.htm';
            page_location = which('FDH0.htm');
            
            
        case 'explproba'
            file_to_manually_open='help/explproba.htm';
            page_location = which('explproba.htm');
            
            
        case '3dgrids'
            file_to_manually_open='help/3dgrid.htm'; %was 3dgrids, but that doesn't existt
            page_location = which('3dgrid.htm');
            
            
        case 'topo'
            file_to_manually_open='help/plottopo.htm';
            page_location = which('plottopo.htm');
        otherwise
            file_to_manually_open=[];
            page_location = [];
    end
    
    if isempty(page_location)
        return
    end
    
    try
        % on mac, at least, page_location need not be preceded by 'file:'
        [status] = web(page_location,'-browser'); % open externally
        if ~(status==0)
            web(page_location); % open in MatLab's browser
        end
    catch
        disp(['Error opening browser  ... please open the file ' file_to_manually_open ' manually']);
    end
end
