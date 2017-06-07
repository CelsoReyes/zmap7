function anseiswa(action)

    global pipo gx gy gz xc1  xc2 currPt xc3 a ni newt2 tiplo2 ds ax1 ax2 ax3
    global ax4 pl2 zvg X Y Z gd gx2 gy2 nie tiplo3 ax5 newt3 plas ax3b iwl2 t0b teb par1
    global  ps1 ps2 pli plin
    global  zv2 zall  plev
    global plx plx2 lat1 lat2 lon1 lon2 hs fix1 fix2 hndl2



    switch(action)
        case 'start1'
            axes(ax2)
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

        case 'startc'
            axes(ax4)
            axis manual; hold on
            point1 = get(gca,'CurrentPoint'); % button down detected
            set(xc2,'era','back','Xdata',point1(1,1),'Ydata',point1(1,2))

            set(gcf,'WindowButtonMotionFcn',' anseiswa movec')
            set(gcf,'WindowButtonUpFcn','anseiswa stopc')

        case 'movec'
            currPt=get(gca,'CurrentPoint');
            set(xc2,'Xdata',currPt(1,1),'Ydata',currPt(1,2))

        case 'stopc'
            set(gcf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','')
            set(gcbf,'WindowButtonUpFcn','')
            anseiswa tiplc

        case 'tipl'
            x = get(xc1,'Xdata'); y = get(xc1,'Ydata'); z = ds;
            l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + (a(:,7)-z).^2) ;
            [s,is] = sort(l);
            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            newt2 = newt2(1:ni,:);
            di = sort(l); Rjma = di(ni);
            [st,ist] = sort(newt2);   % re-sort wrt time for cumulative count
            newt2 = newt2(ist(:,3),:);
            set(tiplo2,'Xdata',[newt2(:,3) ; teb],'Ydata',[(1:length(newt2(:,3))) length(newt2(:,3))  ] );
            set(xc1,'era','normal')
            set(ax3,'YLim',[0 length(newt2(:,1))+15],'Xlim',[ floor(min(a(:,3))) ceil(max(a(:,3)))]);
            set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);

            iwl = floor(iwl2*365/par1);
            [cumu, xt] = hist(newt2(:,3),(t0b:par1/365:teb));
            ncu = length(xt);
            as = NaN(1,ncu);

            for i2 = 1:length(cumu)-iwl
                cu = [cumu(1:i2-1) cumu(i2+iwl+1:ncu)];
                mean1 = mean(cu);
                mean2 = mean(cumu(i2:i2+iwl));
                var1 = cov(cu);
                var2 = cov(cumu(i2:i2+iwl));
                as(i2) = (mean1 - mean2)/(sqrt(var1/(ncu-iwl)+var2/iwl));
            end     % for i2

            set(plas,'Ydata',as,'Xdata',xt);
            set(plev,'Xdata',newt2(:,1),'Ydata',newt2(:,2));
            set(plx2,'Xdata',[]','Ydata',[]);




            l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + (a(:,7)-z).^2) ;
            [s,is] = sort(l);
            newt3 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            l2 = l < Rjma;
            newt3 = newt3(l2,:);
            [st,ist] = sort(newt3);   % re-sort wrt time for cumulative count
            newt3 = newt3(ist(:,3),:);
            set(tiplo3,'Xdata',[newt3(:,3) ; teb],'Ydata',[(1:length(newt3(:,3))) length(newt3(:,3))  ] );
            set(ax5,'YLim',[0 length(newt3(:,1))+15],'Xlim',[ floor(min(nie(:,3))) ceil(max(nie(:,3)))]);



        case 'tiplc'
            x = get(xc2,'Xdata'); z = -get(xc2,'Ydata');
            i = find(abs(x-gd) == min(abs(x-gd)) );
            x = gx2(i); y = gy2(i) ;

            l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + (a(:,7)-z).^2) ;
            [s,is] = sort(l);
            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            newt2 = newt2(1:ni,:);
            di = sort(l); Rjma = di(ni);
            [st,ist] = sort(newt2);   % re-sort wrt time for cumulative count
            newt2 = newt2(ist(:,3),:);
            set(tiplo2,'Xdata',[newt2(:,3) ; teb],'Ydata',[(1:length(newt2(:,3))) length(newt2(:,3))  ] );
            set(ax3,'YLim',[0 length(newt2(:,1))+15],'Xlim',[ floor(min(a(:,3))) ceil(max(a(:,3)))]);
            set(ax3,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);

            iwl = floor(iwl2*365/par1);
            [cumu, xt] = hist(newt2(:,3),(t0b:par1/365:teb));
            ncu = length(xt);
            as = NaN(1,ncu);

            for i2 = 1:length(cumu)-iwl
                cu = [cumu(1:i2-1) cumu(i2+iwl+1:ncu)];
                mean1 = mean(cu);
                mean2 = mean(cumu(i2:i2+iwl));
                var1 = cov(cu);
                var2 = cov(cumu(i2:i2+iwl));
                as(i2) = (mean1 - mean2)/(sqrt(var1/(ncu-iwl)+var2/iwl));
            end     % for i2

            set(plas,'Ydata',as,'Xdata',xt);

            % update the X-sec
            [xsecx2 xsecy2,  inde2] =mysectnoplo(newt2(:,2)',newt2(:,1)',newt2(:,7),900,0,lat1, lon1, lat2,lon2);
            newa2  = newt2(inde2,:);
            newa2 = [newa2 xsecx2'];
            set(plx2,'Xdata',xsecx2','Ydata',-newa2(:,7));

            if lon2 < lon1 ; xsecx2 = abs(xsecx2 - max(gd)) ;  end
            set(plx2,'Xdata',xsecx2','Ydata',-newa2(:,7));
            set(plev,'Xdata',newt2(:,1),'Ydata',newt2(:,2));



            l = sqrt(((nie(:,1)-x)*cos(pi/180*y)*111).^2 + ((nie(:,2)-y)*111).^2 + (nie(:,7)-z).^2) ;
            [s,is] = sort(l);
            newt3 = nie(is(:,1),:) ;       % re-orders matrix to agree row-wise
            l2 = l < Rjma;
            newt3 = newt3(l2,:);
            [st,ist] = sort(newt3);   % re-sort wrt time for cumulative count
            newt3 = newt3(ist(:,3),:); size(newt3)
            set(tiplo3,'Xdata',[newt3(:,3) ; teb],'Ydata',[(1:length(newt3(:,3))) length(newt3(:,3))  ] );
            set(ax5,'YLim',[0 length(newt3(:,1))+15],'Xlim',[ floor(min(nie(:,3))) ceil(max(nie(:,3)))]);
            set(ax5,'YLimMode','auto')




            set(xc1,'Xdata',x,'Ydata',y)
            set(xc2,'era','normal')


        case 'samp1'

            x = get(xc1,'Xdata'); y = get(xc1,'Ydata'); z = ds;
            l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + (a(:,7)-z).^2) ;
            [s,is] = sort(l);
            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            newt2 = newt2(1:ni,:);

        case 'samp2'

            x = get(xc2,'Xdata'); y = get(xc2,'Ydata'); z = ds;
            l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2 + (a(:,7)-z).^2) ;
            [s,is] = sort(l);
            newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            newt2 = newt2(1:ni,:);

        case 'newclim'

            axes(hs)
            caxis([fix1 fix2]);
            h5 = colorbar;
            hsp = get(hs,'pos');

            set(h5,'pos',[0.15 hsp(2)-0.1 0.3 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');

        case 'newcolmap'
            in3 =get(hndl2,'Value');
            if in3 == 1 ; colormap(hsv) ; end
            if in3 == 2 ; colormap(hot) ; end
            if in3 == 3 ; colormap(jet) ; end
            if in3 == 4 ; colormap(cool) ; end
            if in3 == 5 ; colormap(pink) ; end
            if in3 == 6 ; colormap(gray) ; end
            if in3 == 7 ; colormap(bone) ; end
            if in3 == 8; co = jet; col = col(64:-1:1,:); colormap(col) ; end


    end  % switch


