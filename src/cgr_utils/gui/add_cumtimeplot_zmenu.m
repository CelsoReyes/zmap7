function add_cumtimeplot_zmenu(obj, parent)
    ZG = ZmapGlobal.Data;
    
    analyzemenu=parent;%uimenu(parent,'Label','analyze');
    ztoolsmenu=uimenu(parent,'Label','ztools');
    
    
    % uimenu(ztoolsmenu,'Label','Date Ticks in different format','MenuSelectedFcn',@(~,~)newtimetick,'Enable','off');
    
    uimenu(ztoolsmenu,'Label','Overlay another curve (hold)',...
        'Checked',tf2onoff(ZG.hold_state2),...
        'MenuSelectedFcn',@cb_hold)
    % uimenu(ztoolsmenu,'Label','Compare two rates (fit)','MenuSelectedFcn',@cb_comparerates_fit); %DELETE ME
    uimenu(ztoolsmenu,'Label','Compare two rates (no fit)','MenuSelectedFcn',@cb_comparerates_nofit);
    %uimenu(ztoolsmenu,'Label','Day/Night split ','MenuSelectedFcn',@cb_006)
    
    uimenu(ztoolsmenu,'Separator','on','Label','Time-depth plot ',...
        'MenuSelectedFcn',{@cb_timeSomethingPlot,TimeDepthPlotter()});
    uimenu(ztoolsmenu,'Label','Time-magnitude plot ',...
        'MenuSelectedFcn',{@cb_timeSomethingPlot, TimeMagnitudePlotter()});
    
    
    
    
    op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
    
    uimenu(op4B, 'Label', 'beta values: LTA(t) function',...
        'MenuSelectedFcn',{@cb_z_beta_ratechanges,'bet'});
    uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',...
        'MenuSelectedFcn', {@cb_betaTriangle}); % wasnewcat
    uimenu(op4B,'Label','z-values: AS(t)function',...
        'MenuSelectedFcn',{@cb_z_beta_ratechanges,'ast'});
    uimenu(op4B,'Label','z-values: Rubberband function',...
        'MenuSelectedFcn',{@cb_z_beta_ratechanges,'rub'});
    uimenu(op4B,'Label','z-values: LTA(t) function ',...
        'MenuSelectedFcn',{@cb_z_beta_ratechanges,'lta'});
    
    
    op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
    uimenu(op4,'Label','automatic','MenuSelectedFcn',@cb_auto_mc_b_estimation)
    uimenu(op4,'label','Mc with time ','MenuSelectedFcn',{@plotwithtime,'mc'});
    uimenu(op4,'Label','b with depth','MenuSelectedFcn',@(~,~)bwithde2(obj.catview.Catalog()));
    uimenu(op4,'label','b with magnitude','MenuSelectedFcn',@(~,~)bwithmag(obj.catview.Catalog()));
    uimenu(op4,'label','b with time','MenuSelectedFcn',{@plotwithtime,'b'});
    
    op5 = uimenu(analyzemenu,'Label','p-value estimation');
    
    %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
    %displayed (the catalog mycat).
    uimenu(op5,'Label','Completeness in days after mainshock','MenuSelectedFcn',@(~,~)mcwtidays(obj.catalog))
    uimenu(op5,'Label','Define mainshock',...
        'Enable','off', 'MenuSelectedFcn',@cb_016);
    uimenu(op5,'Label','Estimate p','MenuSelectedFcn',@cb_pestimate);
    
    uimenu(op5,'Label','p as a function of time and magnitude','MenuSelectedFcn',@(~,~)pvalcat2(obj.catalog))
    uimenu(op5,'Label','Cut catalog at mainshock time',...
        'MenuSelectedFcn',@cb_cut_mainshock)
    
    op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
    uimenu(op6,'Label','Compute the fractal dimension D','MenuSelectedFcn',{@cb_computefractal,2});
    uimenu(op6,'Label','Compute D for random catalog','MenuSelectedFcn',{@cb_computefractal,5});
    uimenu(op6,'Label','Compute D with time','MenuSelectedFcn',{@cb_computefractal,6});
    uimenu(op6,'Label',' Help/Info on  fractal dimension','MenuSelectedFcn',@(~,~)showweb('fractal'))
    
    uimenu(ztoolsmenu,'Label','Cumulative Moment Release ','MenuSelectedFcn',@(~,~)morel(obj.catalog))
    
    op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
    uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ','MenuSelectedFcn',@(~,~)doinverse_michael())
    uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ','MenuSelectedFcn',@(~,~)doinversgep_pc())
    uimenu(op7,'Label','Stress tensor with time','MenuSelectedFcn',@(~,~)stresswtime())
    uimenu(op7,'Label','Stress tensor with depth','MenuSelectedFcn',@(~,~)stresswdepth())
    uimenu(op7,'Label',' Help/Info on  stress tensor inversions','MenuSelectedFcn',@(~,~)showweb('stress'))
    
    
    
    %uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
    %    'Separator','on',...
    %    'MenuSelectedFcn',@(~,~)errordlg('unimplemented','unimplemented');
    
    %uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
    %    'MenuSelectedFcn',@(~,~)errordlg('unimplemented','unimplemented');
    
    function plotwithtime(mysrc,myevt,sPar)
        %sPar tells what to plot.  'mc', 'b'
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot_McBwtime(obj.catview.Catalog(), sPar);
    end
    
    function cb_hold(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        obj.hold_state = ~obj.hold_state;
        mysrc.Checked=(tf2onoff(obj.hold_state));
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
        ZG = ZmapGlobal.Data;
        newsta(sta, obj.catalog);
    end
    
    function cb_betaTriangle(~, ~)
        betatriangle(obj.catalog);
    end
    
    function cb_auto_mc_b_estimation(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        obj.hold_state=false;
        bdiff2();
    end
    
    function cb_cut_mainshock(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        l = min(find( obj.catalog.Magnitude == max(obj.catalog.Magnitude) ));
        obj.catalog = obj.catalog.subset(l:obj.catalog.Count);
        ctp=CumTimePlot(obj.catalog);
        ctp.plot();
    end
    
    function cb_pestimate(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state=false;
        pvalcat(obj.catalog);
    end
    
    function cb_computefractal(mysrc,myevt, org)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        if org==2
            E = obj.catalog;
        end % FIXME this is probably unneccessary, but would need to be traced in startfd before deleted
        startfd(org);
    end
    
    function cb_timeSomethingPlot(~,~,plotter)
        plotter.plot([], obj.catalog);
    end
    
    
end