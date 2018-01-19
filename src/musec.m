function musec()
    % function to create a cross-section consisting of multiple segments
    % works from a MAP
    %
    % stefan wiemer 1/97
    
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    global sw
    
    messtext=...
        ['To select the multiple segments:      '
        'Please use the LEFT mouse button      '
        'To select each corner. Use the RIGHT- '
        'the RIGTH mouse button for            '
        'the final point.                      '
        'Mac Users: Use the keyboard "p" more  '
        'point to select, "l" last point.      '
        '                                      '];
    
    ZmapMessageCenter.set_message('Select Mutiple segments for x-section',messtext');
    
    % first lets input the endpoints
    but = 1;x=[];y=[];
    while but == 1 || but == 112
        [xi,yi,but] = ginput(1);
        [lat1, lon1] = lc_froca(xi,yi);
        lc_event(lat1,lon1,'rx',6,2)
        x = [x; lon1];
        y = [y; lat1];
    end
    
    % now feed the endpoints one by one to mysect
    newa=[]; %TOFIX this is now suposed to be a ZmapCatalog
    po = length(a(1,:))+1;
    for i=1:length(x)-1
        lat1 = y(i);lat2 = y(i+1);lon1 = x(i);lon2=x(i+1);
        [xsecx xsecy,  inde] =mysect(tmp1,tmp2,ZG.primeCatalog.Depth,ZG.xsec_width_km,0,lat1,lon1,lat2,lon2);
        if strcmp(sw,'on')
            xsecx = -xsecx +max(xsecx);
        end
        if i==1
            ma = 0; 
        else
            ma = max(newa(:,po));
        end
        newa  = [newa ; a(inde,:) xsecx'+ma];
    end
    
    l = newa(:,6) >= ZG.big_eq_minmag;
    maex = newa(l,po);
    maey = newa(l,7);
    if isempty(maex)
     maex = 0;
      maey = 0;
      end
    if length(maex)>1 ; maex = maex(1); maey = maey(1);end
    newa(:,po) = newa(:,po) - maex;
    maex = 0*maex;
    
    [st,ist] = sort(newa);   % re-sort wrt time for cumulative count
    newa = newa(ist(:,3),:);
    xsecx = newa(:,po)';
    xsecy = newa(:,7);
    
    % now lets plot the combined x-section
    % with origin at the larget event
    
    xsec_fig_h=findobj('Type','Figure','-and','Name','Cross -Section');
    
    
    
    if isempty(xsec_fig_h)
        xsec_fig_h = figure_w_normalized_uicontrolunits( ...
            'Name','Cross -Section',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'Visible','on');
    end
    
    figure(xsec_fig_h);
    delete(findobj(xsec_fig_h,'Type','axes'));
    set(xsec_fig_h,'PaperPosition',[1 .5 9 6.9545])
    
    pl =plot(newa(:,po),-newa(:,7),'rx');
    set(pl,'Linewidth',1.5,'MarkerSize',6)
    
    if exist('maex', 'var')
        hold on
        pl = plot(maex,-maey,'xm')
        set(pl,'MarkerSize',10,'LineWidth',2)
    end
    
    axis('equal')
    axis([min(newa(:,po))*1.1 max(newa(:,po))*1.1 min(-newa(:,7))*1.1 max(-newa(:,7))*1.1]);
    
    
    set(gca,'Color',color_bg)
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',12,'Linewidth',1.2)
    
    xlabel('Distance in [km]')
    ylabel('Depth in [km]')
    
    
    
    xpos = get(gca,'pos');
    set(gca,'pos',[0.15 0.15 xpos(3) xpos(4)]);
    
    uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
        'Position',[.40 .95 .20 .05],'String','differential b ',...
        'callback',@(~,~)bcrossVt2());
    
    uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
        'Position',[.60 .95 .20 .05],'String','Fractal Dimension',...
        'callback',@(~,~)Dcross());
    
    
    %uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
    %   'Position',[.6 .9 .20 .05],'String','Refresh ',...
    %    'callback',@callbackfun_003);
    
    uic3 = uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
        'Position',[.20 .95 .20 .05],'String','z-value grid',...
        'callback',@(~,~)magrcros());
    
    uic4 = uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
        'Position',[.0 .95 .20 .05],'String','b and Mc grid ',...
        'callback',@(~,~)bcross());
    
    % uicontrol('Units','normal',...
    %   'Position',[.80 .58 .20 .10],'String','b-grid (const R) ',...
    %    'callback',@callbackfun_006);
    
    uic5 = uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
        'position',[0.0 .9 .2 .05],'String','Select Eqs',...
        'callback',@callbackfun_007);
    
    uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
        'position',[.2 .9 .2 .05],'String','Time Plot ',...
        'callback',@(~,~)timcplo());
    
    figure(mapl);
    uic2 = uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
        'Position',[.80 .92 .20 .06],'String','Refresh ',...
        'callback',@callbackfun_009);
    
    
    % create the selected catalog
    %
    sel = 'in';
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        [xsecx xsecy,  inde] =mysect(tmp1,tmp2,ZG.primeCatalog.Depth,ZG.xsec_width_km,0,lat1,lon1,lat2,lon2);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        crosssel;
        ZG.newt2=newa2;
        ZG.newcat=newa2;
        timeplot();
    end
    
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        delete(uic2);

        delete(findobj(xsec_fig_h,'Type','axes'));
        nlammap;
    end
    
end
