
% Plots a map using m_map
%
report_this_filefun(mfilename('fullpath'));

% define input parameters
if selt == 'in'
    figure_w_normalized_uicontrolunits(...
        'Name','Map Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ 200 200 300 300]);
    axis off
    labelList2=[' Lambert Projection | Miller Projection  | Mollweide Projection|  Oblique Mercator '];
    labelPos = [0.05 0.8  0.8  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2=hndl2.Value; ');

    set(hndl2,'value',1);

    labelList3=[' Crude resolution | Low Resolution  | Intermediate Resolution (slow)  | High Resolution (slower)'];
    labelPos = [0.05 0.7  0.8  0.08];
    hndl3=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList3,...
        'Callback','inb2=hndl3.Value; ');

    set(hndl3,'value',1);

    labelList4=[' Ocean White | Ocean ligh blue|  '];
    labelPos = [0.05 0.6  0.8  0.08];
    hndl4=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList4,...
        'Callback','inb2=hndl4.Value; ');

    labelList5=[' Land patched  | coastlines only  '];
    labelPos = [0.05 0.5  0.8  0.08];
    hndl5=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList5,...
        'Callback','inb2=hndl5.Value; ');
    set(hndl5,'value',1);

    uicontrol('Style','Pushbutton',...
        'Position',[.30 .05 .15 .12 ],...
        'Units','normalized','Callback','close; done','String','Cancel');

    uicontrol('Style','Pushbutton',...
        'Position',[.10 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback',' inpr2=hndl2.Value;inpr3=hndl3.Value;inpr4=hndl4.Value;inpr5=hndl5.Value;selt =''ca'';close, plotmymap',...
        'String','Go');

    uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .25 .12 ],...
        'Units','normalized',...
        'Callback','web https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/',...
        'String','Get GSHHS data');


    set(gcf,'visible','on');

end


if selt == 'ca'

    % check for data existence
    if inpr3 == 1
        FILNAME='private/gshhs_c.b';
    %    ex = exist(FILNAME);

    elseif inpr3 == 2
        FILNAME='private/gshhs_l.b';
   %     m_gshhs_l('save','coast.mat');

    elseif inpr3 == 3
        FILNAME='private/gshhs_i.b';
    %    m_gshhs_i('save','coast.mat');


    elseif inpr3 == 4
        FILNAME='private/gshhs_h.b';
     %   m_gshhs_h('save','coast.mat');
    end

    ex = exist(FILNAME);

    if ex ~= 2
        st1 = [' The GSHHS data-base you requested was not found in m_map/private'...
                'Please check the path of the data or download/uncompress the GSHHS files from to ftp://ftp.ngdc.noaa.gov/MGG/shorelines/ ' ];

        errordlg(st1,'Error: File not found ');

        selt = 'in';
        return
    end




    [existFlag,h1]=figure_exists('Lambert Map',1);

    if existFlag == 0 
        ac3 = 'new'; 
        overmap;  
    end
    if existFlag == 1
        h1 = figure(to1)
        delete(gca); delete(gca);delete(gca)
    end

    watchon
    drawnow
    l  = get(h1,'XLim');
    s1 = l(2); s2 = l(1);
    l  = get(h1,'YLim');
    s3 = l(2); s4 = l(1);

    if inpr2 == 1
        m_proj('lambert','long',[s2 s1],'lat',[s4 s3]);
    elseif inpr2 == 2
        m_proj('miller','long',[s2 s1],'lat',[s4 s3]);
    elseif inpr2 == 3
        m_proj('mollweide','long',[s2 s1],'lat',[s4 s3]);
    elseif inpr2 == 4
        m_proj('Oblique Mercator','long',[s2 s1],'lat',[s4 s3]);
    end

    if inpr5 == 1
        if inpr3 == 1
            m_gshhs_c('patch',[.8 .8 .8]);
            FILNAME='private/gshhs_c.b';

        elseif inpr3 == 2
            m_gshhs_l('patch',[.8 .8 .8]);
            FILNAME='private/gshhs_l.b';
        elseif inpr3 == 3
            m_gshhs_i('patch',[.8 .8 .8]);
            FILNAME='private/gshhs_i.b';

        elseif inpr3 == 4
            m_gshhs_h('patch',[.8 .8 .8]);
            FILNAME='private/gshhs_h.b';

        end
    elseif inpr5 == 2
        if inpr3 == 1
            m_gshhs_c('line');
        elseif inpr3 == 2
            m_gshhs_l('line');
        elseif inpr3 == 3
            m_gshhs_i('line');
        elseif inpr3 == 4
            m_gshhs_h('line');
        end
    end


    if isempty(faults) ~= 1 ; lifa = m_line(faults(:,1),faults(:,2),'color','r'); end

    hold on

    if co == 'w' ; co = 'k'; end
    li = m_plot(ZG.a.Longitude,ZG.a.Latitude);
    set(li,'Linestyle','none','Marker',ty1,'MarkerSize',ZG.ms6,'color',co)

    if exist('vo', 'var')
        if isempty(vo) ==  0
            li = m_plot(vo.Longitude,vo.Latitude);
            set(li,'Linestyle','none','Marker','^','MarkerSize',6,'markeredgecolor','r','markerfacecolor','w')
        end
    end


    m_grid('box','on','tickdir','out','linestyle','none','color','k');
    set(gcf,'Color','w')
    oco =  findobj('tag','m_grid_color');

    if inpr4 == 2
        set(oco,'FaceColor',[0.85 0.85 1 ]);
    end
    mapax = gca;

    uicontrol('Style','Pushbutton',...
        'Position',[.002 .002 .45 .05 ],...
        'Units','normalized',...
        'Callback','selt = ''sa''; savecoast2',...
        'String','Import coastline to map window');

end
watchoff

if selt == 'sa'  % save to file only
    axes(mapax);
    if inpr3 == 1
        FILNAME='private/gshhs_c.b';
        m_gshhs_c('save','coastl.mat');

    elseif inpr3 == 2
        FILNAME='private/gshhs_l.b';
        m_gshhs_l('save','coastl.mat');

    elseif inpr3 == 3
        FILNAME='private/gshhs_i.b';
        m_gshhs_i('save','coastl.mat');


    elseif inpr3 == 4
        FILNAME='private/gshhs_h.b';
        m_gshhs_h('save','coastl.mat');
    end
    load coastl.mat

    coastline = ncst;
    update(mainmap())
    clear  ncst coastl

end




