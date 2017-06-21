function anseiswa(action)

    %report_this_filefun(mfilename('fullpath'));

    global pipo gx gy gz xc1  xc2 currPt xc3 a ni newt2 tiplo2 ds ax1 ax2 ax3
    global ax4 pl2 zvg X Y Z gd gx2 gy2 nie tiplo3 ax5 newt3 ax3b iwl2 t0b teb par1
    global ps1 ps2 pli plin
    global zv2 zall  plev tgl1 Rconst hs
    global plx plx2 lat1 lat2 lon1 lon2  plb bvalsum3 xt3 tiplo1 plb2 plc1 plc2 teb1 teb2 hndl2


    switch(action)
        case 'start1'
            axes(hs)
            axis manual; hold on
            point1 = get(gca,'CurrentPoint'); % button down detected
            set(xc1,'era','back','Xdata',point1(1,1),'Ydata',point1(1,2))

            set(gcf,'WindowButtonMotionFcn',' anseiswa move1')
            set(gcf,'WindowButtonUpFcn','anseiswa stop1')

        case 'move1'
            currPt=get(gca,'CurrentPoint');
            set(xc1,'Xdata',currPt(1,1),'Ydata',currPt(1,2))

        case 'stop1'
            set(gcf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','')
            set(gcbf,'WindowButtonUpFcn','')
            %set(xc2,'Xdata',currPt(1,1))
            %set(xc3,'Xdata',currPt(1,2))
            anseiswa tipl


        case 'tipl'
            x = get(xc1,'Xdata'); y = get(xc1,'Ydata'); z = ds;
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + (a.Depth-z).^2) ;
            [s,is] = sort(l);

            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

            if tgl1 == 0   % take point within r
                l3 = l <= Rconst;
                newt2 = newt2(l3,:);      % new data per grid point (b) is sorted in distance
                Rjma = Rconst;
            else
                % take first ni points
                newt2 = newt2(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); Rjma = l2(ni);
            end

            [st,ist] = sort(newt2);   % re-sort wrt time for cumulative count
            newt2 = newt2(ist(:,3),:);
            set(tiplo2,'Xdata',[newt2.Date ; teb],'Ydata',[(1:newt2.Count) newt2.Count  ] );
            set(xc1,'era','normal')
            set(ax3,'YLim',[0 newt2.Count+15],'Xlim',[ (min(a.Date)) (max(a.Date))]);
            set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);

            bv = bvalca3(newt2,1,1);
            set(plb,'Xdata',xt3,'Ydata',bvalsum3);

            % set circle containing events as circle
            xx = -pi-0.1:0.1:pi;
            xcir = x+sin(xx)*Rjma/(cos(pi/180*y)*111);
            ycir = y+cos(xx)*Rjma/(cos(pi/180*y)*111);
            set(plc1,'Xdata',xcir,'Ydata',ycir);
            set(teb2,'string',['b-value: ' num2str(bv,3)]);


        case 'start2'
            axes(hs)
            axis manual; hold on
            point1 = get(gca,'CurrentPoint'); % button down detected
            set(xc2,'era','back','Xdata',point1(1,1),'Ydata',point1(1,2))

            set(gcf,'WindowButtonMotionFcn',' anseiswa move2')
            set(gcf,'WindowButtonUpFcn','anseiswa stop2')

        case 'move2'
            currPt=get(gca,'CurrentPoint');
            set(xc2,'Xdata',currPt(1,1),'Ydata',currPt(1,2))

        case 'stop2'
            set(gcf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','')
            set(gcbf,'WindowButtonUpFcn','')
            %set(xc2,'Xdata',currPt(1,1))
            %set(xc3,'Xdata',currPt(1,2))
            anseiswa tipl2


        case 'tipl2'
            x = get(xc2,'Xdata'); y = get(xc2,'Ydata'); z = ds;
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + (a.Depth-z).^2) ;
            [s,is] = sort(l);
            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            if tgl1 == 0   % take point within r
                l3 = l <= Rconst;
                newt2 = newt2(l3,:);      % new data per grid point (b) is sorted in distance
                Rjma = Rconst;
            else
                % take first ni points
                newt2 = newt2(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); Rjma = l2(ni);
            end
            [st,ist] = sort(newt2);   % re-sort wrt time for cumulative count
            newt2 = newt2(ist(:,3),:);
            set(tiplo1,'Xdata',[newt2.Date ; teb],'Ydata',[(1:newt2.Count) newt2.Count  ] );
            set(xc1,'era','normal')
            set(ax3,'YLim',[0 newt2.Count+15],'Xlim',[ (min(a.Date)) (max(a.Date))]);
            set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);

            bv = bvalca3(newt2,1,1);
            set(plb2,'Xdata',xt3,'Ydata',bvalsum3);

            % set circle containing events as circle
            xx = -pi-0.1:0.1:pi;
            xcir = x+sin(xx)*Rjma/(cos(pi/180*y)*111);
            ycir = y+cos(xx)*Rjma/(cos(pi/180*y)*111);
            set(plc2,'Xdata',xcir,'Ydata',ycir);
            set(teb1,'string',['b-value: ' num2str(bv,3)]);
        case 'samp1'

            x = get(xc1,'Xdata'); y = get(xc1,'Ydata'); z = ds;
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + (a.Depth-z).^2) ;
            [s,is] = sort(l);
            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            newt2 = newt2(1:ni,:);

        case 'samp2'

            x = get(xc2,'Xdata'); y = get(xc2,'Ydata'); z = ds;
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + (a.Depth-z).^2) ;
            [s,is] = sort(l);
            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            newt2 = newt2(1:ni,:);

    end  % switch


