function dispma3() 
    % compare two rates, no fit
    % selects 4 times to define begining and end of two segments in
    % cumulative number curve and calls bvalnofit
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    t1p = min(ZG.newt2.Date);
    t4p = max(ZG.newt2.Date);
    t2p = t4p - (t4p-t1p)/2;
    t3p = t2p;
    
    show_dialog()
    
    function show_dialog()
        % Input times t1p t2p t3p and t4p by editing or use cursor if desired
        %
        
        dlg=ZmapDialog();
        dlg.AddEdit('t1p','Time 1 (T1):', t1p,'enter begin segment 1');
        dlg.AddEdit('t2p','Time 2 (T2):', t2p,'enter end segment 1');
        dlg.AddEdit('t3p','Time 3 (T3):', t3p,'enter begin segment 2');
        dlg.AddEdit('t4p','Time 4 (T4):', t4p,'enter end segment 2');
        dlg.AddCheckbox('usecursor','Use Cursor', false,[],'select with mouse');
        
        par2 = 0.1 * ZG.newt2.Count;
        
        [myans, okpressed] =dlg.Create('Name', 'Select two time segments');
        if ~okpressed
            return
        end
        if myans.usecursor
            mouse_select()
        else
            bvanofit(ZG.newt2, [myans.t1p,myans.t2p] , [myans.t3p, myans.t4p]);
        end
    end
    
    function mouse_select()
        figure(findobj('Tag','cum','-and','Type','Figure'));
        
        seti = uicontrol('Units','normal','Position',[.4 .01 .2 .05],'String','Select T1  ');
        
        pause(0.5)
        
        par2 = 0.1 * ZG.newt2.Count;
        par3 = 0.12 * ZG.newt2.Count;
        t1 = ginput(1);
        t1p = [  t1 ; t1(1) t1(2)-par2; t1(1)   t1(2)+par2 ];
        plot(t1p(:,1),t1p(:,2),'r')
        text( t1(1),t1(2)+par3,['t1: ', num2str(t1p(1))] )
        seti.String = 'select T2';
        
        pause(0.5)
        
        t2 = [];
        t2 = ginput(1);
        t2p = [  t2 ; t2(1) t2(2)-par2; t2(1)   t2(2)+par2 ];
        plot(t2p(:,1),t2p(:,2),'r')
        text( t2(1),t2(2)+par3,['t2: ', num2str(t2p(1))] )
        seti.String = 'select T3';
        
        pause(0.5)
        
        t3 = [];
        t3 = ginput(1);
        t3p = [  t3 ; t3(1) t3(2)-par2; t3(1)   t3(2)+par2 ];
        plot(t3p(:,1),t3p(:,2),'r')
        text( t3(1),t3(2)+par3,['t3: ', num2str(t3p(1))] )
        seti.String = 'select T4';
        
        pause(0.5)
        
        t4 = [];
        t4 = ginput(1);
        t4p = [  t4 ; t4(1) t4(2)-par2; t4(1)   t4(2)+par2 ];
        plot(t4p(:,1),t4p(:,2),'r')
        text( t4(1),t4(2)+par3,['t4: ', num2str(t4p(1))] )
        
        delete(seti)
        
        show_dialog()
        pause(0.1)
    end
end
