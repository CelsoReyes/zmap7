function varargout = topo(varargin)
    % topo(frame,a,ZG.maepi,faults,res,gx,gy,s)
    % frame=[s4 s3 s1 s2]
    % s -> startup parameter
    % 8.2.2002
    %
    % TOPO Application M-file for topo.fig
    %    FIG = TOPO launch topo GUI.
    %    TOPO('callback_name', ...) invoke the named callback.
    
    if nargin == 8  % LAUNCH GUI
        cfig = openfig(mfilename,'reuse');
        set(cfig,'Name','Topo')
        % Use system color scheme for figure:
        % set(cfig,'Color',get(groot,'defaultUicontrolBackgroundColor'));
        % whitebg('white')
        % set(gcf,'color','w')
        % Generate a structure of handles to pass to callbacks, and store it.
        handles = guihandles(cfig);
        handles.bor     = varargin{1};
        handles.equ     = varargin{2};
        handles.faults  = varargin{3}; %Faults
        handles.coast   = varargin{4}; %Coastlines
        handles.resu    = varargin{5}; %Resultate
        handles.gx      = varargin{6};
        handles.gy      = varargin{7};
        s=varargin{8};
        
        handles.spec    = 1; %Special Objects
        handles.lines   = 1; %Lines
        
        handles.ploe=1;  %isnan
        handles.plof=1;  %isnan
        handles.plos=1;  %isnan
        handles.ploli=1; %isnan
        handles.ploc=1;  %isnan
        handles.depq=1;  %isnan
        handles.depf=1;  %isnan
        handles.desp=1;  %isnan
        handles.depl=1;  %isnan
        handles.resmap=1; %isnan
        handles.resu;
        
        if s==1
            conres=struct2cell(handles.resu);
            inp=conres(2,1,1);
            for i=2:size(handles.resu,2)
                inp=[inp;conres(2,1,i)];
            end
        end
        set(handles.listres,'String',inp);
        guidata(cfig, handles);
        
        guidata(cfig, handles);
        %uiwait(fig);
        
        if nargout > 0
            varargout{1} = cfig;
        end
        set(handles.draw,'Visible','off')
    elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
        
        try
            if (nargout)
                [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
            else
                feval(varargin{:}); % FEVAL switchyard
            end
        catch
            disp(lasterr);
        end
    end
    
    
    % --------------------------------------------------------------------%
function varargout = gemapwi_Callback(h, eventdata, handles, varargin)
    disp('this is topo|gemapwi')
    global psloc;
    global pgt30;
    global pgdem;
    
    inp =get(handles.listdem,'Value');
    bor=handles.bor;
    handles.plma=figure_w_normalized_uicontrolunits( ...
        'Name','Topographic Map',...
        'NumberTitle','off', ...
        'Color',[1 1 1],...
        'Visible','off');
    
    handles.axm=axesm('MapProjection','eqdcylin');
    figure_w_normalized_uicontrolunits(handles.plma);
    set(handles.plma,'Visible','on');
    
    lo1 = bor(1); lo2=bor(2);
    la1=bor(3); la2=bor(4);
    fac = 1;
    if abs(la2-la1) > 10 | abs(lo2-lo1) > 10
        def = {'3'};
        ni2 = inputdlg('Decimation factor for DEM data?','Input',1,def);
        l = ni2{:};
        fac = str2double(l);
    end
    switch(inp)
        case 1
            gtopo30s([la1 la2],[lo1 lo2]);
            [tmap, tmapleg] = gtopo302(pgt30,fac,[la1 la2],[lo1 lo2]);
            cd (psloc); %Stao des Skriptes
            tmap(isnan(tmap)) = -1; %Replace the NaNs in the ocean with -1 to color them blue
            [latlim,lonlim] = limitm(tmap,tmapleg);
            
        case 2
            fname = globedems([la1 la2],[lo1 lo2]);
            try
                [tmap, tmapleg] = globedem(fname{1},fac,[la1 la2],[lo1 lo2]);
            catch ME
                errordlg(ME.message,'ERROR:topo');
                return
            end
            cd (psloc); %Stao des Skriptes
            tmap(isnan(tmap)) = nan; %Replace the NaNs in the ocean with -1 to color them blue
            [latlim,lonlim] = limitm(tmap,tmapleg);
            
        case 3
            
            [lat,lon, gtmap] =satbath(fac,[la1 la2],[lo1 lo2]); % general matrix map
            gtmap(isnan(gtmap)) = -1;
            latlim = [la1 la2];
            lonlim = [lo1 lo2];
            pack
            [map,maplegend] = nanm(latlim,lonlim,30);
            % original was about 1 cell per degree
            tmap = imbedm(lat,lon,gtmap,map,maplegend);
            tmapleg=maplegend;
            
        case 4
            region = [la1 la2 lo1 lo2];
            [tmap,tmapleg] = tbase(fac,[la1 la2 ],[lo1 lo2] );
            [latlim,lonlim] = limitm(tmap,tmapleg);
            tmap(isnan(tmap)) = -1; %Replace the NaNs in the ocean with -1 to color them blue
    end
    
    lai=abs((la2-la1)/4);
    tilat=transpose([la1+0.5*lai la1+1.5*lai la1+2.5*lai la1+3.5*lai]);
    loi=abs((lo2-lo1)/4);
    tilon=transpose([lo1+0.5*loi lo1+1.5*loi lo1+2.5*loi lo1+3.5*loi]);
    
    meshm(tmap,tmapleg,size(tmap),tmap);demcmap(tmap);
    setm(handles.axm,'maplatlimit',latlim,'maplonlimit',lonlim);
    
    if min(tmap(:)) > 0
        demcmap(tmap,100,[0 0.3 1],[]);
        daspectm('m',05);
    else
        demcmap(tmap)
        daspectm('m',05);
    end
    
    showaxes('hide');
    setm(handles.axm,'meridianlabel','on','parallellabel','on',...
        'LabelUnits','dm',...
        'mlabelround',-2,...
        'plabelround',-2,...
        'grid','off',...
        'LabelFormat','compass',...
        'plabellocation',tilat,'mlabellocation',tilon,...
        'plinelocation',tilat,'mlinelocation',tilon,...
        'frame','off');
    shading flat
    
    zdatam(handlem('mlabel'),0);
    zdatam(handlem('plabel'),0);
    %   zdatam(handlem('frame'),0)
    camlight(-80,0); lighting phong; material([.8 1 0]);
    
    handles.colbar=colorbar;
    set(handles.colbar,'Position', [0.9 0.3 0.015 .3]) ;
    set(handles.colbar,'visible','on','FontSize',10,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1,...
        'Box','on','TickDir','out');
    
    set(handles.gemapwi,'String','NEW DEM')
    handles.tmapleg=tmapleg;
    handles.tmap=tmap;
    handles.maptype=1;
    guidata(gcbo,handles);
    maptool;
    set(handles.draw,'Visible','on');
    % --------------------------------------------------------------------
function varargout = popeq_Callback(h, eventdata, handles, varargin)
    disp('this is topo|popeq')
    A=handles.equ;
    depq=handles.depq;
    if handles.maptype==1
        tmap=handles.tmap;
        tmapleg=handles.tmapleg;
    end
    ploe=handles.ploe;
    figure_w_normalized_uicontrolunits(handles.plma);
    inp = get(handles.pop1,'Value');
    if depq==1  &&  (inp==3 || inp==4)  &&  handles.maptype==1
        [lat,lon] = meshgrat(tmap,tmapleg);
        depq = interp2(lon,lat,tmap,A(:,1),A(:,2));
        close(hw);
    end
    
    if inp == 1
        ploe=plotm(A.Latitude,A.Longitude,'ro');
        set(ploe,'LineWidth',0.1,'MarkerSize',2,...
            'MarkerFaceColor','w','MarkerEdgeColor','r');
        if handles.maptype==1;zdatam(handlem('allline'),max(tmap(:)));end
    end
    
    if inp == 2
        ploe=plotm(A.Latitude,A.Longitude,'ro');
        set(ploe,'LineWidth',0.1,'MarkerSize',3,...
            'MarkerFaceColor','w','MarkerEdgeColor','k');
        if handles.maptype==1;zdatam(handlem('allline'),max(tmap(:)));end
    end
    
    if inp == 3  &&  handles.maptype==1
        ploe=plot3m(A.Latitude,A.Longitude,depq+25,'ro');
        set(ploe,'LineWidth',0.1,'MarkerSize',2,...
            'MarkerFaceColor','w','MarkerEdgeColor','r');
    end
    
    if inp == 4  &&  handles.maptype==1
        ploe=plot3m(A.Latitude,A.Longitude,depq+25,'ro');
        set(ploe,'LineWidth',0.1,'MarkerSize',3,...
            'MarkerFaceColor','w','MarkerEdgeColor','k');
    end
    
    if inp == 5 ; delete(ploe);  end
    handles.ploe=ploe;
    handles.depq=depq;
    
    guidata(gcbo,handles);
    
    % --------------------------------------------------------------------
function varargout = popfau_Callback(h, eventdata, handles, varargin)
    disp('this is topo|popfau')
    depf=handles.depf;
    faults=handles.faults;
    coast=handles.coast;
    if handles.maptype==1
        tmap=handles.tmap;
        tmapleg=handles.tmapleg;
    end
    plof=handles.plof;
    figure_w_normalized_uicontrolunits(handles.plma);
    inp =get(handles.pop2,'Value');
    if depf==1  &&  inp==2  &&  handles.maptype==1
        clear('depf');
        [lat,lon] = meshgrat(tmap,tmapleg);
        depf= interp2(lon,lat,tmap,faults(:,1),faults(:,2));
    end
    
    if inp == 1
        plof = plotm(faults(:,2),faults(:,1),'m','Linewidth',2);
        if handles.maptype==1;zdatam(handlem('allline'),max(tmap(:)));end
    end
    if inp == 2 ; plof = plot3m(faults(:,2),faults(:,1),depf+25,'m','Linewidth',2);end
    if inp == 3 ; delete(plof) ; end
    if inp == 4 ; ploc=plot3m(coast(:,2),coast(:,1),1,'k','Linewidth',2) ; end
    if inp == 5 ; delete (ploc); end
    handles.ploc=ploc;
    handles.plof=plof;
    handles.depf=depf;
    guidata(gcbo,handles)
    
    % --------------------------------------------------------------------
function varargout = popspec_Callback(h, eventdata, handles, varargin)
    disp('this is topo|popspec')
    s=handles.spec;
    inp = get(handles.pop3,'Value');
    if not(inp==5)
        [file1,path1] = uigetfile([ '*.txt'],'File containing  my, mx ');
        s=load(file1);
    end
    desp=handles.desp;
    if handles.maptype==1
        tmap=handles.tmap;
        tmapleg=handles.tmapleg;
    end
    plos=handles.plos;
    figure_w_normalized_uicontrolunits(handles.plma);
    
    if desp==1  &&  (inp==3 | inp==4)  &&  handles.maptype==1
        [lat,lon] = meshgrat(tmap,tmapleg); 
        desp = interp2(lat,lon,tmap,s(:,1),s(:,2));
    end
    
    if inp == 1
        plos=plotm(s(:,1),s(:,2),'*');
        set(plos,'LineWidth',0.1,'MarkerSize',3,...
            'MarkerFaceColor','w','Marker','*','MarkerEdgeColor','r');
        if handles.maptype==1;zdatam(handlem('allline'),max(tmap(:))); end
        
    elseif inp == 2
        plos=plotm(s(:,1),s(:,2),'v');
        set(plos,'LineWidth',0.1,'MarkerSize',3,...
            'MarkerFaceColor','w','Marker','v','MarkerEdgeColor','r');
        if handles.maptype==1;zdatam(handlem('allline'),max(tmap(:)));end
        
    elseif inp == 3   &&  handles.maptype==1
        plos=plot3m(s(:,1),s(:,2),desp+25,'*');
        set(plos,'LineWidth',0.1,'MarkerSize',3,...
            'MarkerFaceColor','w','Marker','*','MarkerEdgeColor','r');
        
    elseif inp == 4  &&  handles.maptype==1
        plos=plot3m(s(:,1),s(:,2),desp+25,'v');
        set(plos,'LineWidth',0.1,'MarkerSize',3,...
            'MarkerFaceColor','w','Marker','v','MarkerEdgeColor','r');
    end
    
    if inp == 5 ; delete(plos);  end
    handles.plos=plos;
    handles.depsp=desp;
    guidata(gcbo,handles)
    
    % -------------------------------------------------------------------
function varargout = ploli_Callback(h, eventdata, handles, varargin)
    disp('this is topo|ploli')
    inp =get(handles.pop4,'Value');
    if not(inp==3)
        [file1,path1] = uigetfile([ '*.txt'],'File containing  my, mx ');
        s=load(file1);
    end
    depl=handles.depl;
    lines=handles.lines;
    if handles.maptype==1
        tmap=handles.tmap;
        tmapleg=handles.tmapleg;
    end
    ploli=handles.ploli;
    figure_w_normalized_uicontrolunits(handles.plma);
    if depl==1  &&  inp==2  &&  handles.maptype==1
        [lat,lon] = meshgrat(tmap,tmapleg);
        depl = interp2(lon,lat,tmap,s(:,1),s(:,2));
    end
    if inp == 1
        ploli = plotm(s(:,2),s(:,1),'m','Linewidth',2)
        if handles.maptype==1;zdatam(handlem('allline'),max(tmap(:)));end
    end
    if inp == 2 & handles.maptype==1; ploli = plot3m(s(:,2),s(:,1),depl+25,'m','Linewidth',2);end
    if inp == 3 ; delete(ploli) ; end
    
    handles.ploli=ploli;
    handles.depl=depl;
    guidata(gcbo,handles);
    
    % --------------------------------------------------------------------
function varargout = colorsty_Callback(h, eventdata, handles, varargin)
    disp('this is topo|colorsty')
    tmap=handles.tmap;
    figure_w_normalized_uicontrolunits(handles.plma);
    inp =get(handles.pop5,'Value');
    if inp == 3
        if min(tmap(:)) > 0
            demcmap(tmap,100,[0 0.3 1],[]);
            daspectm('m',05);
        else
            demcmap(tmap);
            daspectm('m',05);
        end
    elseif inp == 1
        demcmap(tmap,265,[1 1 1],[.3 .3 .3; .8 .8 .8]);
        daspectm('m',05);
    elseif inp==2
        demcmap(tmap,265,[1 1 1],[.5 .5 .5; .8 .8 .8]);
        daspectm('m',05);
    end
    handles.tmap=tmap;
    % --------------------------------------------------------------------
function varargout = callaxesmui_Callback(h, eventdata, handles, varargin)
    axesmui (handles.axm);
    
    % --------------------------------------------------------------------
function varargout = wtob_Callback(h, eventdata, handles, varargin)
    figure_w_normalized_uicontrolunits(handles.plma);
    whitebg('black');
    set(gcf,'color','k');
    
    % --------------------------------------------------------------------
function varargout = btow_Callback(h, eventdata, handles, varargin)
    figure_w_normalized_uicontrolunits(handles.plma);
    whitebg('white');
    set(gcf,'color','w');
    
    % --------------------------------------------------------------------
function varargout = calldarken_Callback(h, eventdata, handles, varargin)
    figure_w_normalized_uicontrolunits(handles.plma);
    brighten(handles.plma,-.1);
    
    % --------------------------------------------------------------------
function varargout = callbrighten_Callback(h, eventdata, handles, varargin)
    figure_w_normalized_uicontrolunits(handles.plma);
    brighten(handles.plma,+.1);
    
    % --------------------------------------------------------------------
function varargout = draw_Callback(h, eventdata, handles, varargin)
    disp('this is topo|draw')
    
    if handles.maptype==1
        tmap=handles.tmap;
        tmapleg=handles.tmapleg;
    end
    
    resu=handles.resu;
    figure_w_normalized_uicontrolunits(handles.plma);
    resmap=handles.resmap;
    
    if resmap >1
        delete(resmap);
    end
    
    gx=handles.gx;
    gy=handles.gy;
    
    if handles.maptype==1 %matrix map
        colorbar= handles.colbar;
    end
    
    if handles.maptype==2 % vector map
        handles.colbar=colorbar;
        set(handles.colbar,'Position', [0.9 0.3 0.015 .3]) ;
        set(handles.colbar,'visible','on','FontSize',10,'FontWeight','normal',...
            'FontWeight','normal','LineWidth',1,...
            'Box','on','TickDir','out');
    end
    
    inp=get(handles.listres,'Value');
    ren=resu(inp).data;
    figure_w_normalized_uicontrolunits(handles.plma);
    
    if handles.maptype==1 %matrix map
        [lat,lon] = meshgrat(tmap,tmapleg);
        [X , Y]  = meshgrid(gx,gy);
        ren = interp2(X,Y,ren,lon,lat);
        cmin=min(ren(:));
        cmax=max(ren(:));
        cmin=min(min(resu(inp).data));
        cmax=max(max(resu(inp).data));
        mi = min(ren(:));
        l =  isnan(ren);
        ren(l) = mi-20;
        ll = tmap < 0 & ren < 0;
        ren(ll) = ren(ll)*0 + 20;
        resmap=meshm(ren,tmapleg,size(tmap),tmap);
        daspectm('m',05);
        tightmap;
        view([0 90]);
        camlight; lighting phong;
        set(gca,'projection','perspective');
        j = jet;
        %j = j(64:-1:1,:);
        j = [ [ 0.85 0.9 0.9 ] ; j;[ 0.85 0.9 0.9 ] ];
        caxis([ cmin cmax ]);
        colormap(j);
        handles.colbar=colorbar ;
        handles.resmap=resmap;
        delete(colorbar);
        shading flat;
    end
    
    if handles.maptype==2 %vector map
        resmap=pcolorm(ren);
        j = jet;
        colormap(j);
        handles.colbar=colorbar ;
        handles.resmap=resmap;
        zdatam(handlem('allline'))
        delete(colorbar);
        shading interp;
    end
    set(handles.draw,'Visible','off');
    guidata(gcbo,handles);
    % --------------------------------------------------------------------
    
function varargout = drawcob_Callback(h, eventdata, handles, varargin)
    disp('this is topo|drawcob')
    figure_w_normalized_uicontrolunits(handles.plma);
    
    resu=handles.resu;
    inp =get(handles.listres,'Value');
    ret=resu(inp).lab;
    
    handles.colbar=colorbar;
    set(handles.colbar,'Position', [0.9 0.3 0.015 .3])
    set(handles.colbar,'visible','on','FontSize',10,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1,...
        'Box','on','TickDir','out');
    colorbar;
    
    txt1 = text(...
        'Units','normalized',...
        'Position',[ 1.2 0.7 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',10,....
        'FontWeight','normal',...
        'String',ret);
    
    % --------------------------------------------------------------------
function varargout = listdem_Callback(h, eventdata, handles, varargin)
    
    % --------------------------------------------------------------------
function varargout = listres_Callback(h, eventdata, handles, varargin)
    
    % --------------------------------------------------------------------
function varargout = listvec_Callback(h, eventdata, handles, varargin)
    
    % --------------------------------------------------------------------
function varargout = dvmap_Callback(h, eventdata, handles, varargin)
    disp('this is topo|dvmap')
    inp =get(handles.listvec,'Value');
    bor=handles.bor;
    handles.plma=figure_w_normalized_uicontrolunits( ...
        'Name','Topographic Map',...
        'NumberTitle','off', ...
        'Color',[1 1 1],...
        'Visible','off');
    
    handles.axm=axesm('MapProjection','eqdcylin');
    figure_w_normalized_uicontrolunits(handles.plma);
    set(handles.plma,'Visible','on');
    
    lo1 = bor(1); lo2=bor(2);
    la1=bor(3); la2=bor(4);
    latlim=[la1 la2];
    lonlim=[lo1 lo2];
    
    if inp ==1
        load worldlo;
        displaym(POline);
        delete(handlem('International Boundary'));
    end
    
    if inp==2
        GSHHS('gshhs_c.b','createindex');
        vdata = gshhs('gshhs_c.b',latlim,lonlim);
        coli=displaym(vdata);
        set(coli,'FaceColor',[1 1 1]);
    end
    
    if inp==3
        GSHHS('gshhs_i.b','createindex');
        vdata = gshhs('gshhs_i.b',latlim,lonlim);
        coli=displaym(vdata);
        set(coli,'FaceColor',[1 1 1]) ;
    end
    
    if inp==4
        GSHHS('gshhs_h.b','createindex');
        vdata = gshhs('gshhs_h.b',latlim,lonlim);
        coli=displaym(vdata);
        set(coli,'FaceColor',[1 1 1]);
    end
    
    tilat=(abs(abs(latlim(1))-abs(latlim(2)))/4);
    tilon=(abs(abs(lonlim(1))-abs(lonlim(2)))/4);
    setm(handles.axm,'maplatlimit',latlim,'maplonlimit',lonlim);
    setm(handles.axm,'meridianlabel','on','parallellabel','on',...
        'plinelocation',tilat,'mlinelocation',tilon,...
        'glinestyle','-.',...
        'grid','off',...
        'plabellocation',tilat,'mlabellocation',tilon,...
        'LabelFormat','compass',...
        'flinewidth',3);
    showaxes('hide');
    handles.maptype=2;
    handles.coli=coli;
    set(handles.pushbutton14,'String','NEW Vector Map');
    set(handles.draw,'Visible','on');
    guidata(gcbo,handles);
    maptool;
    
    % --------------------------------------------------------------------
function varargout = listbox4_Callback(h, eventdata, handles, varargin)
    
    % --------------------------------------------------------------------
function varargout = maflat_Callback(h, eventdata, handles, varargin)
    figure_w_normalized_uicontrolunits(handles.plma);
    shading flat;
    
    % --------------------------------------------------------------------
function varargout = mainterp_Callback(h, eventdata, handles, varargin)
    figure_w_normalized_uicontrolunits(handles.plma);
    shading interp;
    
    % --------------------------------------------------------------------
function varargout = vexag_Callback(h, eventdata, handles, varargin)
    disp('this is topo|vexag')
    figure_w_normalized_uicontrolunits(handles.plma);
    exavg=get(handles.edit1,'string');
    fexavg=str2double(exavg);
    daspectm('m',fexavg);
    tightmap
    
    
