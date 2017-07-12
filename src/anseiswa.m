function anseiswa(action)
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

    report_this_filefun(mfilename('fullpath'));

    global  xc1  xc2 currPt ni tiplo2 ds teb
    global  tgl1 Rconst
    global   plb bvalsum3 xt3 tiplo1 plb2 plc1 plc2 teb1 teb2 
    
    ZG=ZmapGlobal.Data;

    switch(action)
        case 'start1'
            axes(findobj(groot,'Tag','hs'))
            axis manual; hold on
            point1 = get(gca,'CurrentPoint'); % button down detected
            set(xc1,'Xdata',point1(1,1),'Ydata',point1(1,2))

            set(gcf,'WindowButtonMotionFcn',@(~,~)anseiswa('move1'))
            set(gcf,'WindowButtonUpFcn',@(~,~)anseiswa('stop1'))

        case 'move1'
            currPt=get(gca,'CurrentPoint');
            set(xc1,'Xdata',currPt(1,1),'Ydata',currPt(1,2))

        case 'stop1'
            set(gcf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','')
            set(gcbf,'WindowButtonUpFcn','')
            %set(xc2,'Xdata',currPt(1,1))
            %set(xc3,'Xdata',currPt(1,2))
            anseiswa('tipl')


        case 'tipl' %change sample size (?)
            x = get(xc1,'Xdata'); y = get(xc1,'Ydata'); z = ds;
            l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2 + (ZG.a.Depth-z).^2) ;
            [s,is] = sort(l);

            ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

            if tgl1 == 0   % take point within r
                l3 = l <= Rconst;
                ZG.newt2 = ZG.newt2(l3,:);      % new data per grid point (b) is sorted in distance
                Rjma = Rconst;
            else
                % take first ni points
                ZG.newt2 = ZG.newt2(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); Rjma = l2(ni);
            end

            ZG.newt2.sort('Date');   % re-sort wrt time for cumulative count
            set(tiplo2,'Xdata',[ZG.newt2.Date ; teb],'Ydata',[(1:ZG.newt2.Count) ZG.newt2.Count  ] );
            set(xc1,'era','normal')
            set(ax3,'YLim',[0 ZG.newt2.Count+15],'Xlim',[ (min(ZG.a.Date)) (max(ZG.a.Date))]);
            set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);

            bv = bvalca3(ZG.newt2,1,1);
            set(plb,'Xdata',xt3,'Ydata',bvalsum3);

            % set circle containing events as circle
            xx = -pi-0.1:0.1:pi;
            xcir = x+sin(xx)*Rjma/(cosd(y)*111);
            ycir = y+cos(xx)*Rjma/(cosd(y)*111);
            set(plc1,'Xdata',xcir,'Ydata',ycir);
            set(teb2,'string',['b-value: ' num2str(bv,3)]);


        case 'start2'
            axes(findobj(groot,'Tag','hs'))
            axis manual; hold on
            point1 = get(gca,'CurrentPoint'); % button down detected
            set(xc2,'era','back','Xdata',point1(1,1),'Ydata',point1(1,2))

            set(gcf,'WindowButtonMotionFcn',@(~,~) anseiswa('move2'))
            set(gcf,'WindowButtonUpFcn',@(~,~) anseiswa('stop2'))

        case 'move2'
            currPt=get(gca,'CurrentPoint');
            set(xc2,'Xdata',currPt(1,1),'Ydata',currPt(1,2))

        case 'stop2'
            set(gcf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','')
            set(gcbf,'WindowButtonUpFcn','')
            anseiswa('tipl2')


        case 'tipl2' %change sample size (?)
            x = get(xc2,'Xdata'); y = get(xc2,'Ydata'); z = ds;
            l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2 + (ZG.a.Depth-z).^2) ;
            [s,is] = sort(l);
            ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            if tgl1 == 0   % take point within r
                l3 = l <= Rconst;
                ZG.newt2 = ZG.newt2(l3,:);      % new data per grid point (b) is sorted in distance
                Rjma = Rconst;
            else
                % take first ni points
                ZG.newt2 = ZG.newt2(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); Rjma = l2(ni);
            end
            [st,ist] = sort(ZG.newt2);   % re-sort wrt time for cumulative count
            ZG.newt2 = ZG.newt2(ist(:,3),:);
            set(tiplo1,'Xdata',[ZG.newt2.Date ; teb],'Ydata',[(1:ZG.newt2.Count) ZG.newt2.Count  ] );
            set(xc1,'era','normal')
            set(ax3,'YLim',[0 ZG.newt2.Count+15],'Xlim',[ (min(ZG.a.Date)) (max(ZG.a.Date))]);
            set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);

            bv = bvalca3(ZG.newt2,1,1);
            set(plb2,'Xdata',xt3,'Ydata',bvalsum3);

            % set circle containing events as circle
            xx = -pi-0.1:0.1:pi;
            xcir = x+sin(xx)*Rjma/(cosd(y)*111);
            ycir = y+cos(xx)*Rjma/(cosd(y)*111);
            set(plc2,'Xdata',xcir,'Ydata',ycir);
            set(teb1,'string',['b-value: ' num2str(bv,3)]);
        case 'samp1' %V1

            x = get(xc1,'Xdata'); y = get(xc1,'Ydata'); z = ds;
            l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2 + (ZG.a.Depth-z).^2) ;
            [~,is] = sort(l);
            ZG.newt2 = ZG.a.subset(is) ;       % re-orders matrix to agree row-wise
            ZG.newt2 = ZG.newt2.subset(1:ni);

        case 'samp2'

            x = get(xc2,'Xdata'); y = get(xc2,'Ydata'); z = ds;
            l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2 + (ZG.a.Depth-z).^2) ;
            [~,is] = sort(l);
            ZG.newt2 = ZG.a.subset(is) ;       % re-orders matrix to agree row-wise
            ZG.newt2 = ZG.newt2.subset(1:ni);

    end  % switch


