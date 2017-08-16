function inpudenew()
    %  This scriptfile ask for several input parameters that can be setup
    %  at the beginning of each session. The default values are the
    %  values Raesenberg used in this program
    %  Alexander Allmann
    
    % modified Celso Reyes 2017
    report_this_filefun(mfilename('fullpath'));
    
    
    global taumin taumax xmeff xk rfact P err derr
    ZG=ZmapGlobal.Data;
    %routine works on ZG.newcat
    %
    if isempty(ZG.newcat)
        ZG.newcat=ZG.a;
    end
    
    
    %  default values
    think
    taumin = 1;
    taumax = 10;
    P = 0.95;
    xk = 0.5;
    xmeff = 1.5;
    rfact = 10;
    err=1.5;
    derr=2;
    
    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Units','pixel','pos',[ZG.welcome_pos 250 380 ],...
        'Name','Declustering Input Parameters',...
        'visible','off',...
        'NumberTitle','off',...
        ...
        'NextPlot','new');
    axis off
    
    %% create the edit boxes with accompanying text labels.
    % 
    IDX_TAG=1; % tag used to access control box
    IDX_LABEL=2;
    IDX_YPOS=3;
    IDX_VAL=4;
    IDX_HELP=5;
    ctrl_params = {
        ... tag, label, ypos,  val, help,
        'taumin', 'Taumin:' , 0.69, taumin, 'look ahead time for not clustered events';
        'taumax', 'Taumax:', 0.61, taumax,  'maximum look ahead time for clustered events';
        'P', 'P1:', 0.53, P, 'Confidence level : observing the next event in the sequence';
        'xk', 'XK:', 0.45, xk, 'factor used in xmeff';
        'xmeff', 'XMEFF:', 0.37, xmeff, '"effective" lower magnitude cutoff for catalog, during clusters, it is xmeff^{xk*cmag1}';
        'rfact', 'RFACT:', 0.29, rfact, 'factor for interaction radius for dependent events';
        'err', 'Epicenter-Error:', 0.21, err,  'Epicenter error';
        'derr', 'Depth-Error:', 0.13, derr, 'Depth error'
        };
    
    
    for i=1:numel(ctrl_params)
        params=ctrl_params(i,:);
        % create the edit box
        h.(params{IDX_TAG}) =  uicontrol('Style','edit',...
            'Position',[.65 params{IDX_YPOS} .30 .06],...
            'Units', 'normalized',...
            'String', num2str(params{IDX_VAL}),...
            'Value', params{IDX_VAL},...
            'TooltipString', params{IDX_HELP},...
            'Callback', @set_numeric,...
            'Tag',['edit_', params{IDX_TAG}]);
        
        % label the edit box
        uicontrol('Style','text',...
            'Position',[0.1 params{IDX_YPOS} .6 .06 ],...
            'FontWeight','bold' ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'HorizontalAlignment','left',...
            'String',params{IDX_LABEL},...
            'Tag',['text_', params{IDX_TAG}]);
        
    end
    
    
%% create action buttons
    
    uicontrol('Style','Pushbutton',...
        'Position',[.78 .02 .21 .09 ],...
        'Units','normalized','Callback',@close_callback,'String','cancel');
    
    uicontrol('Style','Pushbutton',...
        'Position',[.505 .02 .28 .09 ],...
        'Units','normalized',...
        'Callback',@(s,e)matlab_decluster,...
        'String','Go MatLab');
    
    uicontrol('Style','Pushbutton',...
        'Position',[.01 .02 .20 .09 ],...
        'Units','normalized',...
        'Callback',@info_callback,...
        'String','Info');
    
%% create figure title text
    uicontrol('Style','text',...
        'ForegroundColor',[0 0 .3 ],...
        'Position',[0.1 .9 .8 .1 ],...
        'FontWeight','bold' ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'HorizontalAlignment','Center',...
        'String','Declustering Parameters:');
    
    text(...
        'Position',[0.5 0.95 0 ],...
        'FontWeight','bold' ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'HorizontalAlignment','Center',...
        'String','(mouseover field for tool-tip help)');
 
    set(gcf,'visible','on')
    watchoff
    done
    
%% callbacks
    function set_numeric(src,~)
        src.Value = str2double(src.String);
    end
    
    function matlab_decluster()
        taumin = h.taumin.Value;
        taumax = h.taumax.Value;
        P = h.P.Value;
        xk = h.xk.Value;
        xmeff = h.xmeff.Value;
        rfact = h.rfact.Value;
        err = h.err.Value;
        derr = h.derr.Value;
        close;
        think;
        declus()
        %declus(taumin,taumax,xk,xmeff,P,rfact,err,derr);
    end
    
    function close_callback(~,~)
        close;
        done;
    end
    
    function info_callback(~,~)
        clinfo(9); 
        web(['file:' hodi '/zmapwww/chap7.htm#996752']);
    end
end



