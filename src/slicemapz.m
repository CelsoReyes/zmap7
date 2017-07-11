% depthslice.m
% To plot multiple slices through a 3D data cube

report_this_filefun(mfilename('fullpath'));

global  tiplo2 ax3 a hs plb  tiplo1 xc1 xc2 plb2 plc1 plc2 teb1 teb2 ds
global ZG.newt2  hndl2 tgl1 Rconst
global ps1 ps2 plin pli xt3 bvalsum3 ni zvg gz

warning off

sta = 'lta';

if ~exist('slm', 'var'); slm = 'new' ; end
if ~exist('zv2', 'var'); zv2= zvg ; end
if isempty('Rconst')  ==1 ; Rconst = 1000; end
if ~exist('Rconst') ; Rconst = 1000; end
tgl1 = 2;
switch(slm)

    case 'new'


        %zvg = bvg;
        R = 10;

        if mean(gz) < 0 ; gz = -gz; end
        ds = min(gz);



        tdiff = teb-t0b;

        lta_win = round(100/tdiff * lta_winy);
        lta_out = 100 - lta_win;


        zvg = squeeze(zv4(:,:,:,1));

        for j = 1:length(gz)
            zv3 = zv4(:,:,j,:);
            zv3 = squeeze(zv3);
            [l, l2] = find(isnan(zv3(:,:,1)) == 0);


            for i = 1:length(l)
                s0 = squeeze(zv3(l(i),l2(i),1:ni));
                cumu = histogram(a(s0,3),(t0b:(teb-t0b)/99:teb));
                s1 = cumu(tiz:tiz+lta_win);
                s2 = cumu; s2(tiz:tiz+lta_win) = [];
                var1= cov(s1);
                var2= cov(s2);
                me1= mean(s1);
                me2= mean(s2);
                zvg(l(i),l2(i),j) = -(me1 - me2)/(sqrt(var1/(length(s1))+var2/length(s2)));
            end % for i
        end % for j

        fix1 = min(min(min(min(zvg)))); fix2 = max(max(max(max(zvg))));

        %y = get(pli,'Ydata');
        gx2 = linspace(min(gx),max(gx),100);
        gy2 = linspace(min(gy),max(gy),100);
        gz2 = linspace(min(gz),max(gz),20);

        [X,Y,Z] = meshgrid(gy,gx,gz);
        [X2,Y2] = meshgrid(gx2,gy2);
        Z2 = (X2*0 + ds);


        figure_w_normalized_uicontrolunits('pos', [80 200 1000 750]);
        axes('pos',[0.1 0.15 0.4 0.7]);
        hold on
        %sl = slice(X,Y,Z,zvg,Y2,X2,Z2)

        sl = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        pcolor(X2,Y2,sl);
        shading flat

        %axis image

        box on
        shading flat; hold on
        axis([min(gx) max(gx) min(gy) max(gy) ]);
        overlay_

        caxis([fix1 fix2]);
        colormap(jet);

        set(gca,'TickDir','out','Ticklength',[0.02 0.02],'Fontweight','bold','Tag','hs');
        hs = gca;
        h5 = colorbar('horz');
        hsp = get(hs,'pos');
        set(h5,'pos',[0.15 hsp(2)-0.1 0.3 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');
        ti = title(['Depth: ' num2str(ds,3) ' km Time: ' num2str(t0b+tiz*tdiff/100,6)],'Fontweight','bold');

        uicontrol(,'Units','normal',...
            'Position',[.96 .93 .04 .04],'String',' V1',...
             'Callback','anseiswa samp1; timeplot')
        uicontrol('Units','normal',...
            'Position',[.96 .85 .04 .04],'String',' V2',...
             'Callback','anseiswa samp2; timeplot')
        uicontrol('Units','normal',...
            'Position',[.0 .10 .12 .04],'String',' Define X-section',...
             'Callback','action = ''start''; animatorz;')



        labelList=[' hsv | hot | jet | cool | pink | gray | bone | invjet  '];
        labelPos = [0.9 0.00 0.10 0.05];
        hndl2=uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'Value',1,...
            'String',labelList,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'Callback','slm = ''newcolmap'';slicemapz ');

        labelList=[' z-value Map | Probability Map (Quiescence) | Probability Map (increase) |  Resolution Map '];
        labelPos = [0. 0.0 0.20 0.05];
        hndl3=uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'Value',1,...
            'String',labelList,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'Callback','slm = ''newtype'';slicemapz ');


        ed1 =  uicontrol('units','norm',...
            'BackgroundColor',[0 0 0], ...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.1 hsp(2)-0.1 0.04 0.04], ...
            'String',[num2str(fix1),3] , ...
            'TooltipString','Change colorbar range - minimum value  ', ...
            'Style','edit', ...
             'Callback','fix1 = str2num(get(ed1,''string'')), slm = ''newclim''; slicemapz') ;

        ed2 =  uicontrol('BackgroundColor',[0 0 0], ...
            'units','norm',...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.48 hsp(2)-0.1 0.04 0.04], ...
            'String',[num2str(fix2),3] , ...
            'TooltipString','Change colorbar range - maximum value ', ...
            'Style','edit', ...
             'Callback','fix2 = str2num(get(ed2,''string'')), slm = ''newclim''; slicemapz') ;

        ed3 =  uicontrol('units','norm',...
            'BackgroundColor',[0 0 0], ...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.36 0.0 0.07 0.04], ...
            'String',[num2str(lta_winy),3] , ...
            'TooltipString','Change the LTA window length (in years) ', ...
            'Style','edit', ...
             'Callback','lta_winy = str2num(get(ed3,''string''));  slm = ''newtime''; slicemapz') ;

        ed4 =  uicontrol('units','norm',...
            'BackgroundColor',[0 0 0], ...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.42 0.94 0.10 0.03], ...
            'String',[num2str(t0b+tiz*tdiff/100,6)] , ...
            'TooltipString','Change the analysis time ', ...
            'Style','edit', ...
             'Callback','ti2 = str2num(get(ed4,''string'')); tiz = floor((ti2-t0b)*100/tdiff); set(slh2,''value'',[tiz]); slm = ''newtime''; slicemapz') ;

        ed5 =  uicontrol('units','norm',...
            'BackgroundColor',[0 0 0], ...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.36 0.05 0.07 0.04], ...
            'String',[num2str(ni)] , ...
            'TooltipString','Change the sample size (between 10 and 300) ', ...
            'Style','edit', ...
             'Callback','ni = str2num(get(ed5,''string''));  anseiswa tipl2; anseiswa tipl; slm = ''newtime''; slicemapz') ;



        slh1 = uicontrol('units','norm',...
            'BackgroundColor',[0.7 0.7 0.70], ...
            'ListboxTop',0, ...
             'Callback','ds = min(get(slh1,''Value'')); slm = ''newdep''; slicemapz; ', ...
            'Max',max(abs(gz)),'Min',0, ...
            'Position',[0.1 0.90 0.3 0.02], ...
            'SliderStep',[0.05 0.15], ...
            'Style','slider', ...
            'Tag','Slider1', ...
            'TooltipString','Move the slider to select the z-value map depth');

        slh2 = uicontrol('units','norm',...
            'BackgroundColor',[0.7 0.7 0.70], ...
            'ListboxTop',0, ...
             'Callback','tiz = min(get(slh2,''Value''))+1; slm = ''newtime''; slicemapz; ', ...
            'Max',99-lta_win,'Min',0, ...
            'Position',[0.1 0.95 0.3 0.02], ...
            'SliderStep',[0.05 0.15], ...
            'Style','slider', ...
            'Tag','Slider2', ...
            'TooltipString','Move the slider to select the z-value map time');



        uicontrol('units','norm',...
            'BackgroundColor',[0.32 0.32 0.32], ...
            'ForegroundColor','w', ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.0 0.92 0.1 0.05], ...
            'String','Time: ' , ...
            'Style','text');


        uicontrol('units','norm',...
            'BackgroundColor',[0.32 0.32 0.32], ...
            'ForegroundColor','w', ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.0 0.87 0.1 0.05], ...
            'String','Depth: ' , ...
            'Style','text');


        uicontrol('units','norm',...
            'BackgroundColor',[0.32 0.32 0.32], ...
            'ForegroundColor','w', ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.2 0. 0.15 0.03], ...
            'String','LTA length (yrs:) ' , ...
            'Style','text');

        uicontrol('units','norm',...
            'BackgroundColor',[0.32 0.32 0.32], ...
            'ForegroundColor','w', ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.2 0.05 0.15 0.03], ...
            'String','Sample Size: ' , ...
            'Style','text');


        ax3 = axes(...
            'Units','norm', ...
            'Box','on', ...
            'Position',[0.6 0.5 0.3 0.45], ...
            'Tag','Axes1', ...
            'TickDir','out', ...
            'TickDirMode','manual');

        hold on
        x = mean(gx); y = mean(gy) ; z = ds;
        l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2 + (ZG.a.Depth-z).^2) ;
        [s,is] = sort(l);
        ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
        ZG.newt2 = ZG.newt2(1:ni,:);
        [st,ist] = sort(ZG.newt2);   % re-sort wrt time for cumulative count
        ZG.newt2 = ZG.newt2(ist(:,3),:);
        di = sort(l); Rjma = di(ni);

        tiplo2 = plot(ZG.newt2.Date,(1:ZG.newt2.Count),'m-','era','xor');
        set(tiplo2,'LineWidth',2.0)
        set(gca,'YLim',[0 ni+15],'Xlim',[ floor(min(ZG.a.Date)) ceil(max(ZG.a.Date))]);
        set(gca,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);

        xlabel('Time [yrs]');
        ylabel('Cumul. Number');
        tline = [t0b+tiz*tdiff/100  0  ; t0b+tiz*tdiff/100 ni];
        hold on
        pltline1 = plot(tline(:,1),tline(:,2),'k:');
        tline = [t0b+tiz*tdiff/100+lta_winy  0  ; t0b+tiz*tdiff/100+lta_winy ni];
        pltline2 = plot(tline(:,1),tline(:,2),'k:');



        % Plot the events on map in yellow
        axes(hs)
        hold on
        %plev =   plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'.k','MarkerSize',4)
        xc1 = plot(mean(gx),mean(gy),'m^','MarkerSize',10,'LineWidth',1.5,'era','normal');
        set(xc1,'Markeredgecolor','w','Markerfacecolor','g')
        set(xc1,'ButtonDownFcn','anseiswa start1');
        % plot circle containing events as circle
        xx = -pi-0.1:0.1:pi;
        plc1 = plot(x+sin(xx)*Rjma/(cosd(y)*111), y+cos(xx)*Rjma/(cosd(y)*111),'k','era','normal')



        ax4 = axes(...
            'Units','norm', ...
            'Box','on', ...
            'Position',[0.6 0.1 0.3 0.3], ...
            'Tag','Axes1', ...
            'TickDir','out', ...
            'TickDirMode','manual');

        bv = bvalca3(ZG.newt2,1,1);

        plb =semilogy(xt3,bvalsum3,'sb');
        set(plb,'LineWidth',1.0,'MarkerSize',4,...
            'MarkerFaceColor','g','MarkerEdgeColor','g');
        teb2 = text(0.6,0.8,[ 'b-value: ' num2str(bv,3)],'units','norm','color','m');


        axes(ax3)
        hold on
        x = mean(gx)+std(gx)/2; y = mean(gy)+std(gy)/2 ; z = ds;
        l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2 + (ZG.a.Depth-z).^2) ;
        [s,is] = sort(l);
        ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
        ZG.newt2 = ZG.newt2(1:ni,:);
        [st,ist] = sort(ZG.newt2);   % re-sort wrt time for cumulative count
        ZG.newt2 = ZG.newt2(ist(:,3),:);
        di = sort(l); Rjma = di(ni);

        tiplo1 = plot(ZG.newt2.Date,(1:ZG.newt2.Count),'c-','era','xor');
        set(tiplo1,'LineWidth',2.0)
        set(gca,'YLim',[0 ni+15],'Xlim',[ floor(min(ZG.a.Date)) ceil(max(ZG.a.Date))]);
        set(gca,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);


        % Plot the events on map in yellow
        axes(hs)
        hold on
        xc2 = plot(mean(gx)+std(gx)/2,mean(gy)+std(gx)/2,'ch','MarkerSize',12,'LineWidth',1.0,'era','normal');
        set(xc2,'Markeredgecolor','w','Markerfacecolor','r')
        set(xc2,'ButtonDownFcn','anseiswa start2');
        % plot circle containing events as circle
        xx = -pi-0.1:0.1:pi;
        plc2 = plot(x+sin(xx)*Rjma/(cosd(y)*111), y+cos(xx)*Rjma/(cosd(y)*111),'k','era','normal')
        %plot(xa0+sin(x)*l(ni)/111, ya0+cos(x)*l(ni)/111,'k','era','normal')


        axes(ax4);
        hold on

        bv = bvalca3(ZG.newt2,1,1);

        plb2 =semilogy(xt3,bvalsum3,'^b');
        set(plb2,'LineWidth',1.0,'MarkerSize',4,...
            'MarkerFaceColor','r','MarkerEdgeColor','r');
        teb1 = text(0.6,0.9,[ 'b-value: ' num2str(bv,3)],'units','norm','color','c');


        xlabel('Magnitude');
        ylabel('Cumul. Number');
        set(gcf,'renderer','painters')
        set(gcf,'renderer','zbuffer')


        whitebg(gcf);
        matdraw
        helpdlg('You can drag the square and star to display new subvolumes. To diplay a different depth layer, use the slider')


    case 'newdep'
        watchon
        if ds < min(abs(gz)) ; ds = min(abs(gz)); end
        chil = get(hs,'Children');
        Z2 = (X2*0 + ds);
        sl = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        set(chil(length(chil)),'Cdata',sl);
        set(ti,'string',['Depth: ' num2str(ds,3) ' km; Time: ' num2str(t0b+tiz*tdiff/100,6) ]);
        anseiswa tipl2
        anseiswa tipl
        if get(hndl3,'Value') > 1 ; slm = 'newtype'; slicemapz; end

        watchoff
    case 'newtime'

        watchon ;
        if sta == 'lta'
            tdiff = teb-t0b;

            lta_win = round(100/tdiff * lta_winy);
            lta_out = 100 - lta_win;


            zvg = squeeze(zv4(:,:,:,1));

            for j = 1:length(gz)
                zv3 = zv4(:,:,j,:);
                zv3 = squeeze(zv3);
                [l, l2] = find(isnan(zv3(:,:,1)) == 0);


                for i = 1:length(l)
                    s0 = squeeze(zv3(l(i),l2(i),1:ni));
                    cumu = histogram(a(s0,3),(t0b:(teb-t0b)/99:teb));
                    s1 = cumu(tiz:tiz+lta_win);
                    s2 = cumu; s2(tiz:tiz+lta_win) = [];
                    var1= cov(s1);
                    var2= cov(s2);
                    me1= mean(s1);
                    me2= mean(s2);
                    zvg(l(i),l2(i),j) = -(me1 - me2)/(sqrt(var1/(length(s1))+var2/length(s2)));
                end % for i
            end % for j

            chil = get(hs,'Children');
            Z2 = (X2*0 + ds);
            sl = interp3(X,Y,Z,zvg,Y2,X2,Z2);
            set(chil(length(chil)),'Cdata',sl);
            set(ti,'string',['Depth: ' num2str(ds,3) ' km; Time: ' num2str(t0b+tiz*tdiff/100,6) ]);
            set(pltline1,'Xdata',[ t0b+tiz*tdiff/100   t0b+tiz*tdiff/100 ]);
            set(pltline2,'Xdata',[ t0b+tiz*tdiff/100+lta_winy   t0b+tiz*tdiff/100+lta_winy ]);
            set(slh2,'Max',99-lta_win);

            if get(hndl3,'Value') > 1 ; slm = 'newtype'; slicemapz; end
            watchoff


        end % if sta == lta


    case 'newclim'
        axes(hs)
        caxis([fix1 fix2]);
        colorbar;
        hsp = get(hs,'pos');

        set(h5,'pos',[0.15 hsp(2)-0.1 0.3 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');

    case 'newcolmap'
        in3 =get(hndl2,'Value');
        if in3 == 1 ; colormap(hsv); end
        if in3 == 2 ; colormap(hot) ; end
        if in3 == 3 ; colormap(jet) ; end
        if in3 == 4 ; colormap(cool) ; end
        if in3 == 5 ; colormap(pink) ; end
        if in3 == 6 ; colormap(gray) ; end
        if in3 == 7 ; colormap(bone) ; end
        if in3 == 8; co = jet; co = co(64:-1:1,:); colormap(co) ; end

    case 'newtype'
        in3 =get(hndl3,'Value');
        if in3 == 1 ; zvg = zv4; slm = 'newtime';colormap(jet(64)); fix1 = -5; fix2 = 5;  slicemapz ; slm = 'newclim'; slicemapz ; return ; end
        if in3 == 2 ; slm = 'statsq' ;slicemapz  ; return ; end
        if in3 == 3 ; slm = 'statsi' ;slicemapz  ; return ; end

        if in3 == 4 ; zvg = ram     ; end
        if in3 == 5 ; zvg = ram    ; end
        if in3 == 5 ; zvg = avm ; end
        if in3 == 6 

            def = {'6'};m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
            m1 = m{:}; m = str2double(m1);
            zvg =(teb - t0b)./(10.^(avm-m*bvg));

        end
        if in3 == 7 ; colormap(bone) ; end
        if in3 == 8; co = jet; co = co(64:-1:1,:); colormap(co) ; end


        chil = get(hs,'Children');
        Z2 = (X2*0 + ds);
        sl = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        set(chil(length(chil)),'Cdata',sl);
        fix1 = min(min(min(zvg))); fix2 = max(max(max(zvg)));
        set(ed1,  'String',[num2str(fix1,3)]);
        set(ed2,  'String',[num2str(fix2,3)]);

        slm = 'newclim'; slicemapz

    case 'newslice'


        prev = 'ver';
        do = ['x = get(pli,''Xdata'');'];
        err = [' errordlg(['' Please Define a X-section first! '' ]);return '];
        eval(do,err);
        y = get(pli,'Ydata');
        gx2c = linspace(x(1),x(2),50);
        gy2c = linspace(y(1),y(2),50);
        gz2c = linspace(min(gz),max(gz),50);

        dic = distance(gy2c(1),gx2c(1),gy2c(50),gx2c(50))*111;
        dic = 0:dic/49:dic;

        [Y2c,Z2c] = meshgrid(gy2c,gz2c);
        X2c = repmat(gx2c,50,1);

        [Xc,Yc,Zc] = meshgrid(gy,gx,gz);

        figure_w_normalized_uicontrolunits('visible','off');
        hold on;
        sl2 = slice(Xc,Yc,Zc,zvg,Y2c,X2c,Z2c);
        re3 = get(sl2,'Cdata');
        close(gcf)
        figure
        axes('pos',[0.15 0.15 0.6 0.6]);
        pcolor(dic,-gz2c,re3);
        shading flat
        if prev == 'hor'; set(sl,'tag','slice'); end
        box on
        shading flat
        caxis([fix1 fix2]);
        axis image
        hsc = gca;
        set(gca,'Xaxislocation','top');
        set(gca,'TickDir','out','Ticklength',[0.02 0.02],'Fontweight','bold');
        xlabel('Distance [km]');
        ylabel('Depth [km]');


        h5 = colorbar('horz');
        hsp = get(hsc,'pos');
        set(h5,'pos',[0.20 hsp(2)-0.05 0.5 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');

        whitebg(gcf,[0 0 0]);
        set(gca,'FontSize',10,'FontWeight','bold')
        set(gcf,'Color','k','InvertHardcopy','off')
        slax = gca;
        in3 =get(hndl2,'Value');
        if in3 == 1 ; colormap(hsv(64)); end
        if in3 == 2 ; colormap(hot(64)) ; end
        if in3 == 3 ; colormap(jet(64)) ; end
        if in3 == 4 ; colormap(cool(64)) ; end
        if in3 == 5 ; colormap(pink(64)) ; end
        if in3 == 6 ; colormap(gray(64)) ; end
        if in3 == 7 ; colormap(bone(64)) ; end
        if in3 == 8; co = jet; co = co(64:-1:1,:); colormap(co) ; end


        if get(hndl3,'Value') == 2 ;

            chil = get(hsc,'Children');
            zvals = get(chil(length(chil)),'Cdata');
            l = isnan(zvals) == 0;
            zvals(l)  = log10(1- normcdf(zvals(l),mu,varz));

            set(chil(length(chil)),'Cdata',zvals);
            fix1 = -4; fix2 = -1.3;
            axes(hsc)
            j = jet(64);
            j = [  j(64:-1:1,:);  zeros(1,3)+0.4; ];
            colormap(j); colorbar

        end

        if get(hndl3,'Value') == 3 ;

            chil = get(hsc,'Children');
            zvals = get(chil(length(chil)),'Cdata');
            l = isnan(zvals) == 0;
            zvals(l)  = log10(normcdf(zvals(l),mu,varz));

            set(chil(length(chil)),'Cdata',zvals);
            fix1 = -4; fix2 = -1.3;
            axes(hsc)
            j = jet(64);
            j = [  j;  zeros(1,3)+0.4; ];
            colormap(j); colorbar

        end

        matdraw
        delete(ps2); delete(pli); delete(ps1);

    case 'statsq'
        watchon
        as = zeros(1,500);

        for i = 1:500
            s0 = ceil(rand(ni,1)*(length(a)-1));
            tizr = ceil(  rand(1,1)*(100 -lta_win));
            cumu = histogram(a(s0,3),(t0b:(teb-t0b)/99:teb));
            s1 = cumu(tizr:tizr+lta_win);
            s2 = cumu; s2(tizr:tizr+lta_win) = [];
            var1= cov(s1);
            var2= cov(s2);
            me1= mean(s1);
            me2= mean(s2);
            as(i) = (me1 - me2)/(sqrt(var1/(length(s1))+var2/length(s2)));
        end % for i

        mu = mean(as); varz = std(as);

        chil = get(hs,'Children');
        zvals = get(chil(length(chil)),'Cdata');
        l = isnan(zvals) == 0;
        zvals(l)  = log10(1- normcdf(zvals(l),mu,varz));

        set(chil(length(chil)),'Cdata',zvals);
        watchoff
        fix1 = -4; fix2 = -1.3;
        slm = 'newclim';
        axes(hs)
        j = jet(64);
        j = [  j(64:-1:1,:);  zeros(1,3)+0.4; ];
        colormap(j); colorbar

        slicemapz

    case 'statsi'
        watchon
        as = zeros(1,500);

        for i = 1:500
            s0 = ceil(rand(ni,1)*(length(a)-1));
            tizr = ceil(  rand(1,1)*(100 -lta_win));
            cumu = histogram(a(s0,3),(t0b:(teb-t0b)/99:teb));
            s1 = cumu(tizr:tizr+lta_win);
            s2 = cumu; s2(tizr:tizr+lta_win) = [];
            var1= cov(s1);
            var2= cov(s2);
            me1= mean(s1);
            me2= mean(s2);
            as(i) = (me1 - me2)/(sqrt(var1/(length(s1))+var2/length(s2)));
        end % for i

        mu = mean(as); varz = std(as);

        chil = get(hs,'Children');
        zvals = get(chil(length(chil)),'Cdata');
        l = isnan(zvals) == 0;
        zvals(l)  = log10(normcdf(zvals(l),mu,varz));

        set(chil(length(chil)),'Cdata',zvals);
        watchoff
        fix1 = -4; fix2 = -1.3;
        slm = 'newclim';
        axes(hs)
        j = jet(64);
        j = [  j ;  zeros(1,3)+0.4; ];
        colormap(j); colorbar

        slicemapz


end



