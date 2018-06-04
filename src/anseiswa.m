function anseiswa(action, ds)
    % anseiswa slice map callbacks based on action
    %    start1
    %    move1
    %    stop1
    %    tipl
    %    start2
    %    stop2
    %    move2
    %    tipl2
    %    samp1
    %    samp2
    %
    
    report_this_filefun();
    
    global currPt ni teb
    global tgl1
    global bvalsum3 magsteps_desc
    
    ZG=ZmapGlobal.Data;
    xc1=findobj('Tag','xc1');
    xc2=findobj('Tag','xc2');
    switch(action)
        case 'start1'
            axes(findobj(groot,'Tag','hs'))
            axis manual; set(gca,'NextPlot','add')
            point1 = get(gca,'CurrentPoint'); % button down detected
            set(xc1,'Xdata',point1(1,1),'Ydata',point1(1,2))
            
            set(gcf,'WindowButtonMotionFcn',@(~,~)anseiswa('move1',ds))
            set(gcf,'WindowButtonUpFcn',@(~,~)anseiswa('stop1',ds))
            
        case 'tipl' %change sample size (?)
            tipl();
            
        case 'start2'
            axes(findobj(groot,'Tag','hs'))
            axis manual; set(gca,'NextPlot','add')
            point1 = get(gca,'CurrentPoint'); % button down detected
            set(xc2,'Xdata',point1(1,1),'Ydata',point1(1,2))
            
            set(gcf,'WindowButtonMotionFcn',@cb_move2)
            set(gcf,'WindowButtonUpFcn',@cb_stop2)
            
            
        case 'tipl2' %change sample size (?)
            tipl2();
            
        case 'samp1' %V1
            x = get(xc1,'Xdata'); y = get(xc1,'Ydata'); z = ds;
            ZG.newt2 = ZG.primeCatalog.selectClosestEvents(y,x,z,ni);
            
        case 'samp2'
            x = get(xc2,'Xdata'); y = get(xc2,'Ydata'); z = ds;
            ZG.newt2 = ZG.primeCatalog.selectClosestEvents(y,x,z,ni);
            
    end  % switch
    
    function cb_start1(~,~)
        axes(findobj(groot,'Tag','hs'))
        axis manual;
        set(gca,'NextPlot','add')
        point1 = get(gca,'CurrentPoint'); % button down detected
        set(xc1,'Xdata',point1(1,1),'Ydata',point1(1,2))
        
        set(gcf,'WindowButtonMotionFcn', @cb_move1) % @(~,~)anseiswa('move1',ds))
        set(gcf,'WindowButtonUpFcn', @cb_stop1) % @(~,~)anseiswa('stop1',ds))
    end
    
    function cb_move1(~,~)
        currPt=get(gca,'CurrentPoint');
        set(xc1,'Xdata',currPt(1,1),'Ydata',currPt(1,2))
    end
    
    function cb_stop1(~,~)
        set(gcf,'Pointer','arrow');
        set(gcbf,'WindowButtonMotionFcn','')
        set(gcbf,'WindowButtonUpFcn','')
        tipl()
    end
    
    
    function tipl()
        
        x = get(xc1,'Xdata');
        y = get(xc1,'Ydata');
        z = ds;
        l=ZG.primeCatalog.hypocentralDistanceTo(x,y,z); %km
        [s,is] = sort(l);
        
        ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
        
        if tgl1 == 0   % take point within r
            l3 = l <= ZG.Rconst;
            ZG.newt2 = ZG.newt2.subset(l3);      % new data per grid point (b) is sorted in distance
            Rjma = ZG.Rconst;
        else
            % take first ni points
            ZG.newt2 = ZG.newt2(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); Rjma = l2(ni);
        end
        
        ZG.newt2.sort('Date');   % re-sort wrt time for cumulative count
        set(findobj('Tag','tiplo2'),'Xdata',[ZG.newt2.Date ; teb],'Ydata',[(1:ZG.newt2.Count) ZG.newt2.Count  ] );
        ax3=findobj('Tag','ax3');
        set(ax3,'YLim',[0 ZG.newt2.Count+15],'Xlim',[ (min(ZG.primeCatalog.Date)) (max(ZG.primeCatalog.Date))]);
        set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);
        
        bv = bvalca3(ZG.newt2.Magnitude,1);
        set(findobj('Tag','plb'),'Xdata',magsteps_desc,'Ydata',bvalsum3);
        
        % set circle containing events as circle
        xx = -pi-0.1:0.1:pi;
        xcir = x+sin(xx)*Rjma/(cosd(y)*111);
        ycir = y+cos(xx)*Rjma/(cosd(y)*111);
        set(findobj('Tag','plc1'),'Xdata',xcir,'Ydata',ycir);
        set(findobj('Tag','teb2'),'String',['b-value: ' num2str(bv,3)]);
    end
    
    function cb_move2(~,~)
        currPt=get(gca,'CurrentPoint');
        set(xc2,'Xdata',currPt(1,1),'Ydata',currPt(1,2));
    end
    
    function cb_stop2(~,~)
            set(gcf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','')
            set(gcbf,'WindowButtonUpFcn','')
            tipl2
    end
    
    function tipl2()
            x = get(xc2,'Xdata');
            y = get(xc2,'Ydata');
            z = ds;
            l=ZG.primeCatalog.hypocentralDistanceTo(x,y,z); %km
            [s,is] = sort(l);
            ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            if tgl1 == 0   % take point within r
                l3 = l <= ZG.Rconst;
                ZG.newt2 = ZG.newt2.subset(l3);      % new data per grid point (b) is sorted in distance
                Rjma = ZG.Rconst;
            else
                % take first ni points
                ZG.newt2 = ZG.newt2(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); Rjma = l2(ni);
            end
            ZG.newt2.sort('Date');
            set(findobj('Tag','tiplo1'),'Xdata',[ZG.newt2.Date ; teb],'Ydata',[(1:ZG.newt2.Count) ZG.newt2.Count  ] );
            set(ax3,'YLim',[0 ZG.newt2.Count+15],'Xlim',[ (min(ZG.primeCatalog.Date)) (max(ZG.primeCatalog.Date))]);
            set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);
            
            bv = bvalca3(ZG.newt2.Magnitude,1);
            set(findobj('Tag','plb2'),'Xdata',magsteps_desc,'Ydata',bvalsum3);
            
            % set circle containing events as circle
            xx = -pi-0.1:0.1:pi;
            xcir = x+sin(xx)*Rjma/(cosd(y)*111);
            ycir = y+cos(xx)*Rjma/(cosd(y)*111);
            set(findobj('Tag','plc2'),'Xdata',xcir,'Ydata',ycir);
            set(findobj('Tag','teb1'),'string',['b-value: ' num2str(bv,3)]);
    end
end
