function add_cumtimeplot_zmenu(obj, parent)
    ZG = ZmapGlobal.Data;
    
    analyzemenu=parent;%uimenu(parent,'Label','analyze');
    ztoolsmenu=uimenu(parent,'Label','ztools');
    
    
    % uimenu(ztoolsmenu,'Label','Date Ticks in different format',MenuSelectedFcnName(),@(~,~)newtimetick,'Enable','off');
    
    uimenu(ztoolsmenu,'Label','Overlay another curve (hold)',...
        'Checked',tf2onoff(ZG.hold_state2),...
        MenuSelectedFcnName(),@cb_hold)
    % uimenu(ztoolsmenu,'Label','Compare two rates (fit)',MenuSelectedFcnName(),@cb_comparerates_fit); %DELETE ME
    uimenu(ztoolsmenu,'Label','Compare two rates (no fit)',MenuSelectedFcnName(),@cb_comparerates_nofit);
    %uimenu(ztoolsmenu,'Label','Day/Night split ',MenuSelectedFcnName(),@cb_006)
    
    op3D  =   uimenu(ztoolsmenu,'Label','Time series ');
    uimenu(op3D,'Label','Time-depth plot ',...
        MenuSelectedFcnName(),@(~,~)TimeDepthPlotter.plot(ZG.(obj.catname)));
    uimenu(op3D,'Label','Time-magnitude plot ',...
        MenuSelectedFcnName(),@(~,~)TimeMagnitudePlotter.plot(ZG.(obj.catname)));
    
    
    
    
    op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
    
    uimenu(op4B, 'Label', 'beta values: LTA(t) function',...
        MenuSelectedFcnName(),{@cb_z_beta_ratechanges,'bet'});
    uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',...
        MenuSelectedFcnName(), {@cb_betaTriangle,'newt2'}); % wasnewcat
    uimenu(op4B,'Label','z-values: AS(t)function',...
        MenuSelectedFcnName(),{@cb_z_beta_ratechanges,'ast'});
    uimenu(op4B,'Label','z-values: Rubberband function',...
        MenuSelectedFcnName(),{@cb_z_beta_ratechanges,'rub'});
    uimenu(op4B,'Label','z-values: LTA(t) function ',...
        MenuSelectedFcnName(),{@cb_z_beta_ratechanges,'lta'});
    
    
    op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
    uimenu(op4,'Label','automatic',MenuSelectedFcnName(),@cb_auto_mc_b_estimation)
    uimenu(op4,'label','Mc with time ',MenuSelectedFcnName(),{@plotwithtime,'mc'});
    uimenu(op4,'Label','b with depth',MenuSelectedFcnName(),@(~,~)bwithde2('newt2'))
    uimenu(op4,'label','b with magnitude',MenuSelectedFcnName(),@(~,~)bwithmag);
    uimenu(op4,'label','b with time',MenuSelectedFcnName(),{@plotwithtime,'b'});
    
    op5 = uimenu(analyzemenu,'Label','p-value estimation');
    
    %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
    %displayed (the catalog mycat).
    uimenu(op5,'Label','Completeness in days after mainshock',MenuSelectedFcnName(),@(~,~)mcwtidays)
    uimenu(op5,'Label','Define mainshock',...
        'Enable','off', MenuSelectedFcnName(),@cb_016);
    uimenu(op5,'Label','Estimate p',MenuSelectedFcnName(),@cb_pestimate);
    
    %In the following instruction the program pvalcat2.m is called. This program computes a map of p in function of the chosen values for the minimum magnitude and
    %initial time.
    uimenu(op5,'Label','p as a function of time and magnitude',MenuSelectedFcnName(),@(~,~)pvalcat2())
    uimenu(op5,'Label','Cut catalog at mainshock time',...
        MenuSelectedFcnName(),@cb_cut_mainshock)
    
    op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
    uimenu(op6,'Label','Compute the fractal dimension D',MenuSelectedFcnName(),{@cb_computefractal,2});
    uimenu(op6,'Label','Compute D for random catalog',MenuSelectedFcnName(),{@cb_computefractal,5});
    uimenu(op6,'Label','Compute D with time',MenuSelectedFcnName(),{@cb_computefractal,6});
    uimenu(op6,'Label',' Help/Info on  fractal dimension',MenuSelectedFcnName(),@(~,~)showweb('fractal'))
    
    uimenu(ztoolsmenu,'Label','Cumulative Moment Release ',MenuSelectedFcnName(),@(~,~)morel(ZG.(obj.catname)))
    
    op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
    uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ',MenuSelectedFcnName(),@(~,~)doinverse_michael())
    uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ',MenuSelectedFcnName(),@(~,~)doinversgep_pc())
    uimenu(op7,'Label','Stress tensor with time',MenuSelectedFcnName(),@(~,~)stresswtime())
    uimenu(op7,'Label','Stress tensor with depth',MenuSelectedFcnName(),@(~,~)stresswdepth())
    uimenu(op7,'Label',' Help/Info on  stress tensor inversions',MenuSelectedFcnName(),@(~,~)showweb('stress'))
    
    
    
    %uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
    %    'Separator','on',...
    %    MenuSelectedFcnName(),@(~,~)errordlg('unimplemented','unimplemented');
    
    %uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
    %    MenuSelectedFcnName(),@(~,~)errordlg('unimplemented','unimplemented');
    
    function plotwithtime(mysrc,myevt,sPar)
        %sPar tells what to plot.  'mc', 'b'
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot_McBwtime(sPar);
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

    function cb_cut_mainshock(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        l = min(find( ZG.(obj.catname).Magnitude == max(ZG.(obj.catname).Magnitude) ));
        ZG.(obj.catname) = ZG.(obj.catname).subset(l:ZG.(obj.catname).Count);
        timeplot() ;
    end
    
    function cb_pestimate(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.hold_state=false;
        pvalcat();
    end
    
      function cb_computefractal(mysrc,myevt, org)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        if org==2
            E = ZG.newt2;
        end % FIXME this is probably unneccessary, but would need to be traced in startfd before deleted
        startfd(org);
    end
    
end