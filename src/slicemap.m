% depthslice.m
% To plot multiple slices through a 3D data cube

report_this_filefun(mfilename('fullpath'));

global  tiplo2 ax3 a hs plb  tiplo1 xc1 xc2 plb2 plc1 plc2 teb1 teb2 ds
global ZG.newt2  hndl2 tgl1 Rconst %killed one hs
global ps1 ps2 plin pli xt3 bvalsum3 slfig


if ~exist('slm', 'var'); slm = 'new' ; end
if ~exist('zv2', 'var'); zv2= zvg ; end
if ~exist('fix1', 'var'); fix1 = min(min(min(zvg))); fix2 = max(max(max(zvg))); end
if isempty(fix1) == 1; fix1 = min(min(min(zvg))); fix2 = max(max(max(zvg))); end

switch(slm)

    case 'new'

        fix1 = min(min(min(zvg))); fix2 = max(max(max(zvg)));

        R = nan;

        if mean(gz) < 0 ; gz = -gz; end
        ds = min(gz);

        l = ram > R;
        zvg(l)=nan;

        %y = get(pli,'Ydata');
        gx2 = linspace(min(gx),max(gx),80);
        gy2 = linspace(min(gy),max(gy),80);
        gz2 = linspace(min(gz),max(gz),10);

        [X,Y,Z] = meshgrid(gy,gx,gz);
        [X2,Y2] = meshgrid(gx2,gy2);
        Z2 = (X2*0 + ds);


        slfig = figure_w_normalized_uicontrolunits('pos', [80 50 900 650]);
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

        hold on
        overlay_

        caxis([fix1 fix2]);
        colormap(jet);

        set(gca,'TickDir','out','Ticklength',[0.02 0.02],'Fontweight','bold','Tag','hs');
        hs = gca;
        h5 = colorbar('horz');
        hsp = get(hs,'pos');
        set(h5,'pos',[0.15 hsp(2)-0.1 0.3 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');
        ti = title(['Depth: ' num2str(ds,3) ' km'],'Fontweight','bold');

        uicontrol('Units','normal',...
            'Position',[.90 .95 .04 .04],'String','Slicer',...
             'Callback','close;ac2 = ''new''; myslicer')

        uicontrol(,'Units','normal',...
            'Position',[.96 .90 .04 .04],'String',' V1',...
             'Callback','anseiswa samp1; timeplot')
        uicontrol('Units','normal',...
            'Position',[.96 .85 .04 .04],'String',' V2',...
             'Callback','anseiswa samp2; timeplot')
        uicontrol('Units','normal',...
            'Position',[.0 .95 .15 .04],'String',' Define X-section',...
             'Callback','action = ''start''; animatorb;')

        labelList=[' hsv | hot | jet | cool | pink | gray | bone | invjet  '];
        labelPos = [0.9 0.00 0.10 0.05];
        hndl2=uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'Value',1,...
            'String',labelList,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'Callback','slm = ''newcolmap'';slicemap ');
        set(hndl2,'Value',3)

        labelList=[' b-value Map | Mc Map | Goodness of fit Map | Resolution Map |a-value Map | recurrence time map'];
        labelPos = [0. 0.0 0.30 0.05];
        hndl3=uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'Value',1,...
            'String',labelList,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'Callback','slm = ''newtype'';slicemap ');

        ed1 =  uicontrol('units','norm',...
            'BackgroundColor',[0 0 0], ...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.08 hsp(2)-0.11 0.06 0.035], ...
            'String',num2str((fix1),2) , ...
            'TooltipString','Change colorbar range - minimum value', ...
            'Style','edit', ...
             'Callback','fix1 = str2num(get(ed1,''string'')), slm = ''newclim''; slicemap') ;

        ed2 =  uicontrol('BackgroundColor',[0 0 0], ...
            'units','norm',...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.48 hsp(2)-0.11 0.06 0.035], ...
            'String',num2str((fix2),2) , ...
            'TooltipString','Change colorbar range - maximum value ', ...
            'Style','edit', ...
             'Callback','fix2 = str2num(get(ed2,''string'')), slm = ''newclim''; slicemap') ;


        sl1 = uicontrol('units','norm',...
            'BackgroundColor',[0.7 0.7 0.70], ...
            'ListboxTop',0, ...
             'Callback','ds = min(get(sl1,''Value'')); slm = ''newdep''; slicemap; ', ...
            'Max',max(abs(gz)),'Min',0, ...
            'Position',[0.15 0.92 0.35 0.03], ...
            'SliderStep',[0.05 0.15], ...
            'Style','slider', ...
            'Tag','Slider1', ...
            'TooltipString','Move the slider to select the z-value map depth');

        ax3 = axes(...
            'Units','norm', ...
            'Box','on', ...
            'Position',[0.6 0.6 0.3 0.3], ...
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
            'Position',[0.6 0.15 0.3 0.3], ...
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

        xlabel('Magnitude');
        ylabel('Cumul. Number');


        % Plot the events on map in yellow
        axes(hs)
        hold on
        xc2 = plot(mean(gx)+std(gx)/2,mean(gy)+std(gx)/2,'ch','MarkerSize',12,'LineWidth',1.0,'era','normal');
        set(xc2,'Markeredgecolor','w','Markerfacecolor','r')
        set(xc2,'ButtonDownFcn','anseiswa start2');
        set(gcbf,'WindowButtonMotionFcn','')
        set(gcbf,'WindowButtonUpFcn','')
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

        whitebg(gcf);
        matdraw
        helpdlg('You can drag the square and star to display new subvolumes. To diplay a different depth layer, use the slider')
        set(xc2,'era','back')

    case 'newdep'
        if ds < min(abs(gz)) ; ds = min(abs(gz)); end
        chil = get(hs,'Children');
        Z2 = (X2*0 + ds);
        sl = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        set(chil(length(chil)),'Cdata',sl);
        set(ti,'string',['Depth: ' num2str(ds,3) ' km']);
        anseiswa tipl2
        anseiswa tipl

    case 'newclim'
        axes(hs)
        caxis([fix1 fix2]);
        h5 = colorbar('horiz');
        %hsp = get(hs,'pos');
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
        if in3 == 1 ; zvg = bvg;  ; end
        if in3 == 2 ; zvg = mcma; ; end
        if in3 == 3 ; zvg = go     ; end
        if in3 == 4 ; zvg = ram    ; end
        if in3 == 5 ; zvg = avm ; end
        if in3 == 6 

            def = {'6'};m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
            m1 = m{:}; m = str2double(m1);
            zvg =(teb - t0b)./(10.^(avm-m*bvg));

        end

        chil = get(hs,'Children');
        Z2 = (X2*0 + ds);
        sl = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        set(chil(length(chil)),'Cdata',sl);
        fix1 = min(min(min(zvg))); fix2 = max(max(max(zvg)));
        set(ed1,  'String',[num2str(fix1,3)]);
        set(ed2,  'String',[num2str(fix2,3)]);

        slm = 'newclim'; slicemap

    case 'newslice'

        nlammap
        prev = 'ver';
        try
            x = get(pli,'Xdata');
        catch ME
            error_handler(ME,@do_nothing);
            errordlg(' Please Define a X-section first! ');
            return;
        end
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
        lat1 = y(1); lat2 = y(2);lon1 = x(1); lon2 = x(2);
        di = deg2km(distance(lat1,lon1,lat2,lon2));

        %lc_event(a(ZG.a.Depth<=dep1,2),a(ZG.a.Depth<=dep1,1),'.b',1);
        if ~exist('wi', 'var'); wi = 10; end
        [ax ay,  inde] = mysectnoplo(ZG.a.Latitude',ZG.a.Longitude',ZG.a.Depth,wi,0,lat1,lat2,lon1,lon2);
        hold on
        %figure
        plot(di-ax,-ay,'.k','Markersize',1);

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
        set(h5,'pos',[0.35 hsp(2)-0.05 0.25 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');

        whitebg(gcf,[0 0 0]);
        set(gca,'FontSize',10,'FontWeight','bold')
        set(gcf,'Color','k','InvertHardcopy','off')
        slax = gca;
        in3 =get(hndl2,'Value');
        if in3 == 1 ; colormap(hsv); end
        if in3 == 2 ; colormap(hot) ; end
        if in3 == 3 ; colormap(jet) ; end
        if in3 == 4 ; colormap(cool) ; end
        if in3 == 5 ; colormap(pink) ; end
        if in3 == 6 ; colormap(gray) ; end
        if in3 == 7 ; colormap(bone) ; end
        if in3 == 8; co = jet; co = co(64:-1:1,:); colormap(co) ; end

        matdraw
        %delete(ps2); delete(pli); delete(ps1);


        %killed one end
end



