function inpudenew(catalog)
    %  This scriptfile ask for several input parameters that can be setup
    %  at the beginning of each session. The default values are the values used by Raesenberg
    %
    %  Alexander Allmann
    
    % modified Celso Reyes 2017
    report_this_filefun();
    
    
    global taumin taumax xmeff xk rfact P err derr
    ZG=ZmapGlobal.Data;
    %routine works on ZG.newcat
    %
    if isempty(ZG.newcat)
        ZG.newcat=ZG.primeCatalog;
    end
    
    
    %  default values
    
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
    %{
    figure_w_normalized_uicontrolunits(...
        'Units','pixel','pos',[ZG.welcome_pos 250 380 ],...
        'Name','Declustering Input Parameters',...
        'visible','off',...
        'NumberTitle','off',...
        'NextPlot','new');
    axis off
    %}
    %% create the edit boxes with accompanying text labels.
    % 
    IDX_TAG=1; % tag used to access control box
    IDX_LABEL=2;
    IDX_VAL=3;
    IDX_HELP=4;
    ctrl_params = {
        ... tag, label, ypos,  val, help,
        'taumin', 'Taumin:' ,taumin, 'look ahead time for not clustered events';
        'taumax', 'Taumax:', taumax,  'maximum look ahead time for clustered events';
        'P', 'P1:',  P, 'Confidence level : observing the next event in the sequence';
        'xk', 'XK:',xk, 'factor used in xmeff';
        'xmeff', 'XMEFF:', xmeff, '"effective" lower magnitude cutoff for catalog, during clusters, it is xmeff^{xk*cmag1}';
        'rfact', 'RFACT:', rfact, 'factor for interaction radius for dependent events';
        'err', 'Epicenter-Error:',  err,  'Epicenter error';
        'derr', 'Depth-Error:', derr, 'Depth error'
        };
    
    zdlg = ZmapDialog([],@do_nothing);
    zdlg.AddHeader('Declustering parameters');
    for i=1:size(ctrl_params,1)
        params=ctrl_params(i,:);
        zdlg.AddEdit(params{IDX_TAG},params{IDX_LABEL}, params{IDX_VAL}, params{IDX_HELP});
    end
    [vals, okpressed]=zdlg.Create('Declustering Parameters');
    if okpressed
        [outputcatalog,details]=declus(catalog,vals);
        error('hey developer. do something with outputcatalog')
        % TODO do something with the declustered catalog
    end

    
%% callbacks
    
end