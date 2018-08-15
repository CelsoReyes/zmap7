function nlammap()
    %  NLAMMAP displays a map view of the seismicity in Lambert projection and ask for two input
    % points select with the cursor. These input points are
    % the endpoints of the crossection.
    %
    % Stefan Wiemer 2/95
    % updated: 12.10.2004, jochen.woessner@sed.ethz.ch
    % turned into function by Celso G Reyes 2017
    
    %global a
    %global main mainfault faults coastline vo s1 s2 s3 s4
    %global mapl fipo
    %global h2 newa lat1 leng lon1 lon2 lat2
    
    %{
%% This is how you do it with the mapping toolbox -CGR
fig = figure;
axm=axesm('lambert','MapLatLimit',[min(ZG.primeCatalog.Latitude) max(ZG.primeCatalog.Latitude)],'MapLonLimit',[min(ZG.primeCatalog.Longitude) max(ZG.primeCatalog.Longitude)]);
plm=plotm(coastlat,coastlon,'k');
plm=plotm(ZG.primeCatalog.Latitude,ZG.primeCatalog.Longitude,'.');
disp('Select one end of cross-section')
p1=ginput(1); %TODO offer chance to redo/abort

disp('Select other end of cross-section')
p2=ginput(1);

    
    %}
    
    
    [c2, gcDist, zans] = plot_cross_section_from_mainmap; %was select_xsection();
    disp(c2)
    return
    
    ZG=ZmapGlobal.Data;
    report_this_filefun();
    %
    % Find out if figure already exists
    %
    mapl=findobj('Type','Figure','-and','Name','Seismicity Map (Lambert)');
    
    
    ZG.xsec_rotation_deg = 0;
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(mapl)
        mapl = figure_w_normalized_uicontrolunits( ...
            'Name','Seismicity Map (Lambert)',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        drawnow
        info2=@(s,ev)web(['file:' ZG.hodi '/zmapwww/chap4.htm#997433']);
        info1=@(s,ev)web(['file:' ZG.hodi '/zmapwww/chp11.htm#996756']) ;
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Info ',...
            'callback',@info1_callback);
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Info ',...
            'callback',@info2_callback);
        
        
    end % if figure exist
    %figure(mapl);
    %delete(findobj(mapl,'Type','axes'));
    plotmap(mapl);
    %{
    if isempty(coastline)
        coastline = [ZG.primeCatalog.Longitude(1) ZG.primeCatalog.Latitude(1)];
    end
    %}
    set(gca,'NextPlot','add')
    % Added try-catch to prevent failure if no coastline is inside
    % cross-section box, JW
    %try
    %{
    if length(coastline) > 1 %TODO what is coastline?
        lc_map(coastline(:,2),coastline(:,1),s3,s4,s1,s2)
        g = get(gca,'Children');
        set(g,'Color','k')
        
        %catch
    end
    set(gca,'NextPlot','add')
    try
        if length(faults) > 10
            lc_map(faults(:,2),faults(:,1),s3,s4,s1,s2)
        end
    catch
    end
    set(gca,'NextPlot','add')
    if ~isempty(mainfault)
        lc_map(mainfault(:,2),mainfault(:,1),s3,s4,s1,s2)
    end
    at_dep1 = ZG.primeCatalog.Depth<=dep1;
    at_dep2 = ZG.primeCatalog.Depth<=dep2 & ZG.primeCatalog.Depth>dep1;
    at_dep3 = ZG.primeCatalog.Depth<=dep3 & ZG.primeCatalog.Depth>dep2;
    if ZG.primeCatalog.Count > 5000
        %lc_event(ZG.primeCatalog.Latitude,ZG.primeCatalog.Longitude,'.k')
        lc_event(ZG.primeCatalog.Latitude(at_dep1),ZG.primeCatalog.Longitude(at_dep1),'.b',1);
        lc_event(ZG.primeCatalog.Latitude(at_dep2),ZG.primeCatalog.Longitude(at_dep2),'.g',1);
        lc_event(ZG.primeCatalog.Latitude(at_dep3),ZG.primeCatalog.Longitude(at_dep3),'.r',1);
    else
        lc_event(ZG.primeCatalog.Latitude(at_dep1),ZG.primeCatalog.Longitude(at_dep1),'+b');
        lc_event(ZG.primeCatalog.Latitude(at_dep2),ZG.primeCatalog.Longitude(at_dep2),'og');
        lc_event(ZG.primeCatalog.Latitude(at_dep3),ZG.primeCatalog.Longitude(at_dep3),'xr');
        
    end
    
    if ~isempty(ZG.maepi)
        lc_event(ZG.maepi.Latitude,ZG.maepi.Longitude,'hy',10,2.0)
    end
    if ~isempty(main)
        lc_event(main(:,2),main(:,1),'hk',10,2.0)
    end
    if ~isempty(vo)
        lc_event(vo.Latitude,vo.Longitude,'^r')
    end
    if ~isempty(well)
        lc_event(well(:,2),well(:,1),'dk')
    end
    %}
    labelList={'Select Endpoints by Mouse',...
        'Coordinate Input',...
        'Multiple segments',...
        'Rotate X-Section'};
    funList = { @do_nlammap2,... select endpoints by mouse
                @posinpu,...    coordinate input
                @musec,...      multiple segments
                @rotateit};     % rotate cross-section
            
    labelPos = [.05 .00 .40 .06];
    
    tmp1=ZG.primeCatalog.Latitude';
    tmp2=ZG.primeCatalog.Longitude';
    
    
    % dialog box for parameters
    zdlg=ZmapDialog([]);
    %zdlg.AddEdit(tag,label,value,tooltip);
    zdlg.AddEdit('xsec_width_km','Cross section width [km]',ZG.xsec_defaults.WidthKm,'cross section width, km');
    zdlg.AddPopup('uic',         'Selection Method:',labelList,1,...
        'Select an option for choosing cross section', funlist);
    zdlg.AddCheckbox('do_rotation','Rotate Cross Section', false, 'xsec_rotation_deg','Rotate Cross section');
    zdlg.AddEdit('xsec_rotation_deg','Rotation [deg]:',ZG.xsec_rotation_deg,'Rotate cross-section');
    [result,okPressed]=zdlg.Create('Cross section parameters');
    if ~okPressed
        return
    end
    ZG.xsec_defaults.WidthKm = result.xsec_width_km;
    ZG.xsec_rotation_deg = result.xsec_rotation_deg;
    
    result.uic(); 
    
    function do_nlammap2()
        [xsecx xsecy,  inde] = mysect(tmp1,tmp2,ZG.primeCatalog.Depth,ZG.xsec_defaults.WidthKm);
        nlammap2;
    end
    
end

function rotateit() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    if ~exist('lat1')
        errordlg('Create a cross-section first!');
    else
        [lat1, lat2, lon1, lon2] = rotate_xsection(lat1, lat2, lon1, lon2, ZG.xsec_rotation_deg);
        
        [xsecx xsecy,  inde] = mysect(tmp1,tmp2,ZG.primeCatalog.Depth,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
        nlammap2;
    end
    
end
