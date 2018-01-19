function add_cumtimeplot_zmenu(obj, parent)
    ZG = ZmapGlobal.Data;
    
    analyzemenu=uimenu(parent,'Label','analyze');
    ztoolsmenu=uimenu(parent,'Label','ztools');
    
    
    % uimenu(ztoolsmenu,'Label','Date Ticks in different format','callback',@(~,~)newtimetick,'Enable','off');
    
    uimenu(ztoolsmenu,'Label','Overlay another curve (hold)',...
        'Checked',logical2onoff(ZG.hold_state2),...
        'callback',@cb_hold)
    % uimenu(ztoolsmenu,'Label','Compare two rates (fit)', 'callback',@cb_comparerates_fit); %DELETE ME
    uimenu(ztoolsmenu,'Label','Compare two rates (no fit)', 'callback',@cb_comparerates_nofit);
    %uimenu(ztoolsmenu,'Label','Day/Night split ', 'callback',@cb_006)
    
    op3D  =   uimenu(ztoolsmenu,'Label','Time series ');
    uimenu(op3D,'Label','Time-depth plot ',...
        'Callback',@(~,~)TimeDepthPlotter.plot(ZG.(obj.catname)));
    uimenu(op3D,'Label','Time-magnitude plot ',...
        'Callback',@(~,~)TimeMagnitudePlotter.plot(ZG.(obj.catname)));
    
    
    
    
    op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
    
    uimenu(op4B, 'Label', 'beta values: LTA(t) function',...
        'Callback',{@cb_z_beta_ratechanges,'bet'});
    uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',...
        'Callback', {@cb_betaTriangle,'newt2'}); % wasnewcat
    uimenu(op4B,'Label','z-values: AS(t)function',...
        'callback',{@cb_z_beta_ratechanges,'ast'});
    uimenu(op4B,'Label','z-values: Rubberband function',...
        'callback',{@cb_z_beta_ratechanges,'rub'});
    uimenu(op4B,'Label','z-values: LTA(t) function ',...
        'callback',{@cb_z_beta_ratechanges,'lta'});
    
    
    op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
    uimenu(op4,'Label','automatic', 'callback',@cb_auto_mc_b_estimation)
    uimenu(op4,'label','Mc with time ', 'callback',{@plotwithtime,'mc'});
    uimenu(op4,'Label','b with depth', 'callback',@(~,~)bwithde2('newt2'))
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
    
    uimenu(ztoolsmenu,'Label','Cumulative Moment Release ', 'callback',@(~,~)morel(ZG.(obj.catname)))
    
    op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
    uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ', 'callback',@(~,~)doinverse_michael())
    uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ', 'callback',@(~,~)doinversgep_pc())
    uimenu(op7,'Label','Stress tensor with time', 'callback',@(~,~)stresswtime())
    uimenu(op7,'Label','Stress tensor with depth', 'callback',@(~,~)stresswdepth())
    uimenu(op7,'Label',' Help/Info on  stress tensor inversions', 'callback',@(~,~)showweb('stress'))
    
    
    
    %uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
    %    'Separator','on',...
    %    'Callback',@(~,~)errordlg('unimplemented','unimplemented');
    
    %uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
    %    'Callback',@(~,~)errordlg('unimplemented','unimplemented');
    
    function plotwithtime(mysrc,myevt,sPar)
        %sPar tells what to plot.  'mc', 'b'
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot_McBwtime(sPar);
    end
    
    function cb_hold(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        obj.hold_state = ~obj.hold_state;
        mysrc.Checked=(logical2onoff(obj.hold_state));
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
        betatriangle(ZG.(catname));
    end
    
    function cb_auto_mc_b_estimation(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        obj.hold_state=false;
        bdiff2();
    end
    
end