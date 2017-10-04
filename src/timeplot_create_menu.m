function timeplot_create_menu()
    ZG=ZmapGlobal.Data;
    add_menu_divider();
    ztoolsmenu = uimenu('Label','ZTools');
    analyzemenu=uimenu('Label','Analyze');
    plotmenu=uimenu('Label','Plot');
    catmenu=uimenu('Label','Catalog');
    
    
    uimenu(catmenu,'Label','Rename Catalog (this subset)',...
        'callback',@cb_rename_cat);
    
    uimenu(catmenu,'Label','Set as main catalog',...
        'callback',@cb_keep); % Replaces the primary catalog, and replots this subset in the map window
    uimenu(catmenu,'Separator','on','Label','Reset',...
        'callback',@cb_resetcat); % Resets the catalog to the original selection
    
    uimenu(ztoolsmenu,'Label','Cuts in time, magnitude and depth',...
        'Callback',@cut_tmd_callback);
    uimenu(ztoolsmenu,'Label','Cut in Time (cursor) ',...
        'Callback',@cursor_timecut_callback);
    uimenu(plotmenu,'Label','Date Ticks in different format',...
        'callback',@(~,~)newtimetick,'Enable','off');
    
    uimenu (analyzemenu,'Label','Decluster the catalog',...
        'callback',@(~,~)inpudenew())
    uimenu(plotmenu,'Label','Overlay another curve (hold)',...
        'Checked',logical2onoff(ZG.hold_state2),...
        'callback',@cb_hold)
    uimenu(ztoolsmenu,'Label','Compare two rates (fit)',...
        'callback',@cb_comparerates_fit)
    uimenu(ztoolsmenu,'Label','Compare two rates (no fit)',...
        'enable','off',...
        'callback',@cb_comparerates_nofit)
    %uimenu(ztoolsmenu,'Label','Day/Night split ', 'callback',@cb_006)
    
    op3D  =   uimenu(plotmenu,'Label','Time series ');
    uimenu(op3D,'Label','Time-depth plot ',...
        'Callback',@(~,~)TimeDepthPlotter.plot(mycat));
    uimenu(op3D,'Label','Time-magnitude plot ',...
        'Callback',@(~,~)TimeMagnitudePlotter.plot(mycat));
    
    
    
    
    op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
    
    uimenu(op4B, 'Label', 'beta values: LTA(t) function',...
        'Callback',{@cb_z_beta_ratechanges,'bet'});
    uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',...
        'Callback', {@cb_betaTriangle,'newcat'})
    uimenu(op4B,'Label','z-values: AS(t)function',...
        'callback',{@cb_z_beta_ratechanges,'ast'})
    uimenu(op4B,'Label','z-values: Rubberband function',...
        'callback',{@cb_z_beta_ratechanges,'rub'})
    uimenu(op4B,'Label','z-values: LTA(t) function ',...
        'callback',{@cb_z_beta_ratechanges,'lta'});
    
    
    op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
    uimenu(op4,'Label','automatic', 'callback',@cb_010)
    uimenu(op4,'label','Mc with time ', 'callback',{@plotwithtime,'mc'});
    uimenu(op4,'Label','b with depth', 'callback',@(~,~)bwithde2())
    uimenu(op4,'label','b with magnitude', 'callback',@(~,~)bwithmag);
    uimenu(op4,'label','b with time', 'callback',{@plotwithtime,'b'});
    
    op5 = uimenu(analyzemenu,'Label','p-value estimation');
    
    %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
    %displayed (the catalog mycat).
    uimenu(op5,'Label','Completeness in days after mainshock', 'callback',@(~,~)mcwtidays)
    uimenu(op5,'Label','Define mainshock',...
        'Enable','off', 'callback',@cb_016);
    uimenu(op5,'Label','Estimate p', 'callback',@cb_pestimate);
    
    %In the following instruction the program pvalcat2.m is called. This program computes a map of p in function of the chosen values for the minimum magnitude and
    %initial time.
    uimenu(op5,'Label','p as a function of time and magnitude', 'callback',@(~,~)pvalcat2())
    uimenu(op5,'Label','Cut catalog at mainshock time',...
        'callback',@cb_cut_mainshock)
    
    op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
    uimenu(op6,'Label','Compute the fractal dimension D', 'callback',{@cb_computefractal,2});
    uimenu(op6,'Label','Compute D for random catalog', 'callback',{@cb_computefractal,5});
    uimenu(op6,'Label','Compute D with time', 'callback',{@cb_computefractal,6});
    uimenu(op6,'Label',' Help/Info on  fractal dimension', 'callback',@(~,~)showweb('fractal'))
    
    uimenu(ztoolsmenu,'Label','Cumlative Moment Release ', 'callback',@(~,~)morel())
    
    op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
    uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ', 'callback',@(~,~)doinverse_michael())
    uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ', 'callback',@(~,~)doinversgep_pc())
    uimenu(op7,'Label','Stress tensor with time', 'callback',@(~,~)stresswtime())
    uimenu(op7,'Label','Stress tensor with depth', 'callback',@(~,~)stresswdepth())
    uimenu(op7,'Label',' Help/Info on  stress tensor inversions', 'callback',@(~,~)showweb('stress'))
    op5C = uimenu(plotmenu,'Label','Histograms');
    
    uimenu(op5C,'Label','Magnitude',...
        'callback',{@cb_histogram,'Magnitude'});
    uimenu(op5C,'Label','Depth',...
        'callback',{@cb_histogram,'Depth'});
    uimenu(op5C,'Label','Time',...
        'callback',{@cb_histogram,'Date'});
    uimenu(op5C,'Label','Hr of the day',...
        'callback',{@cb_histogram,'Hour'});
    
    
    %uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
    %    'Separator','on',...
    %    'Callback',{@calSave1, cumu2}); % not saving xt
    
    %uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
    %    'Callback',{@calSave7,  cumu2, as}) % not saving xt
end

%% callback functions


function cut_tmd_callback(~,~)
    ZG.newt2 = catalog_overview(ZG.newt2);
    timeplot(ZG.newt2)
end

function cursor_timecut_callback(~,~)
    % will change ZG.newt2
    [tt1,tt2]=timesel(4);
    ZG.newt2=ZG.newt2.subset(ZG.newt2.Date>=tt1&ZG.newt2.Date<=tt2);
    timeplot(ZG.newt2);
end

function cb_hold(mysrc,myevt)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    ZG.hold_state2 = ~ZG.hold_state2;
    mysrc.Checked=(logical2onoff(ZG.hold_state2));
end


function cb_comparerates_fit(mysrc,myevt)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    dispma2(ic);
end

function cb_comparerates_nofit(mysrc,myevt)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    ic=0;
    dispma3;
end

function cb_z_beta_ratechanges(mysrc,myevt,sta)
    % beta values:
    %   'bet' : LTA(t) function
    %   'ast' : AS(t) function
    %   'rub' : Rubberband function
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    set(gcf,'Pointer','watch');
    newsta(sta);
end

function cb_betaTriangle(~, ~, catname)
    betatriangle(ZG.(catname),t0b:ZG.bin_dur:teb);
end
function cb_010(mysrc,myevt)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    ZG.hold_state=false;
    bdiff2();
end

function plotwithtime(mysrc,myevt,sPar)
    %sPar tells what to plot.  'mc', 'b'
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    plot_McBwtime(sPar);
end


function cb_016(mysrc,myevt)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    error('not implemented: define mainshock.  Original input_main.m function broken;')
end

function cb_pestimate(mysrc,myevt)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    ZG.hold_state=false;
    pvalcat();
end

function cb_cut_mainshock(mysrc,myevt)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    l = min(find( mycat.Magnitude == max(mycat.Magnitude) ));
    mycat = mycat(l+1:mycat.Count,:);
    timeplot(mycat) ;
end

function cb_computefractal(mysrc,myevt, org)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    if org==2
        E = mycat;
    end % TOFIX this is probably unneccessary, but would need to be traced in startfd before deleted
    startfd;
end

function cb_histogram(mysrc,myevt,hist_type)
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    hisgra(mycat, hist_type);
end

function cb_resetcat(mysrc,myevt)
    % Resets the catalog to the original selection
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    mycat = ZG.newcat;
    close(cum);
    timeplot(mycat);
    zmap_update_displays();
end

function cb_keep(mysrc,myevt)
    % Plots this subset in the map window
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    ZG.newcat = mycat;
    replaceMainCatalog(mycat) ;
    zmap_update_displays();
end

function cb_rename_cat(~,~)
    nm=inputdlg('Catalog Name:','Rename',1,{mycat.Name});
    if ~isempty(nm)
        mycat.Name=nm{1};
    end
    zmap_update_displays();
end