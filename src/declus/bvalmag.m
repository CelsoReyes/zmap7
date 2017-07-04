function bvalmag(newcat,var1)
    %This routine calculates the b-value of a specified sequence
    %for different magnitude ranges. The B-value is calculated based
    %on the weighted LS-method and on the maximum-liklihood-method and
    %is displayed as a function of magnitude including errorbars

    %Alexander Allmann 11/95
    %

    global cluscat mess bmfig backcat
    global  ttcat les n teb t0b cua
    global wex wey freq_field1 freq_field2 freq_field3
    global freq_field4 dx dy ni nh go_button bm2fig binfo_b
    global bcat bmplot1 bmplot2 bmplot3 zoom1 zoom2 zoom3




    bcat=newcat;
    if var1==1
        report_this_filefun(mfilename('fullpath'));


        dx = min(newcat.Magnitude);           % smallest minimum magnitude
        dy = max(newcat.Magnitude)-1.5 ;        % biggest minimum magnitude
        ni = .1;                         % magnitude step size
        nh = dy+1.5;
        % make the interface
        %
        bmfig= figure_w_normalized_uicontrolunits(...
            'Name','B-Value Input Parameters',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','new', ...
            'units','points',...
            'Visible','off', ...
            'Position',[ wex+200 wey-200 450 250]);
        axis off

        % creates a dialog box to input grid parameters
        %
        freq_field1=uicontrol('Style','edit',...
            'Position',[.60 .50 .22 .10],...
            'Units','normalized','String',num2str(ni),...
            'Callback','ni=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(ni));');

        freq_field2=uicontrol('Style','edit',...
            'Position',[.60 .60 .22 .10],...
            'Units','normalized','String',num2str(dx),...
            'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

        freq_field3=uicontrol('Style','edit',...
            'Position',[.60 .40 .22 .10],...
            'Units','normalized','String',num2str(dy),...
            'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

        freq_field4=uicontrol('Style','edit',...
            'Position',[.60 .25 .22 .10],...
            'Units','normalized','String',num2str(nh),...
            'Callback','nh=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(nh));');


        txt3 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.25 0.84 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String','Magnitude Range Input');
        txt5 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.62 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','smallest minimum magnitude: ');

        txt6 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.42 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','biggest minimum magnitude: ');

        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.52 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            'FontWeight','bold',...
            'String','step size: ');
        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.25 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            'FontWeight','bold',...
            'String','upper magnitude threshold: ');

        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.70 .05 .15 .12 ],...
            'Units','normalized','Callback','close;done','String','Cancel');

        go_button=uicontrol('Style','Pushbutton',...
            'Position',[.15 .05 .15 .12 ],...
            'Units','normalized',...
            'Callback','clf;close; bvalmag(bcat,2);',...
            'String','Go');

        binfo_b=uicontrol('Style','Pushbutton',...
            'Position',[.40 .05 .15 .12 ],...
            'Units','normalized',...
            'Callback','clinfo(17)',...
            'String','Info');


        set(gcf,'visible','on');

    elseif var1==2
        tt=find(newcat.Magnitude<=nh);
        newcat=newcat.subset(tt);
        nh=max(newcat.Magnitude);
        j=0;
        i2=1;

        magn= [dx:ni:dy];
        wai=waitbar(0,'Please Wait ...');
        set(wai,'NumberTitle','off','Name','b-value estimatation');
        drawnow

        for ii= magn
            j=j+1;
            waitbar(j/length(magn))
            ttt=find(newcat.Magnitude>=ii);
            newcat=newcat.subset(ttt);

            maxmag = max(newcat.Magnitude);
            mima = min(newcat.Magnitude);
            if mima > 0 ; mima = 0 ; end

            % number of mag units
            nmagu = (maxmag*10)+1;

            bval = zeros(1,nmagu);
            bvalsum = zeros(1,nmagu);
            bvalsum3 = zeros(1,nmagu);

            [bval,xt2] = hist(newcat.Magnitude,(mima:0.1:maxmag));
            bvalsum = cumsum(bval);                        % N for M <=
            bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
            xt3 = (maxmag:-0.1:mima);


            backg_be = log10(bvalsum);
            backg_ab = log10(bvalsum3);


            difb = [0 diff(bvalsum3) ];

            i = find(difb == max(difb)); %works with automatic pick
            i = max(i);

            M1b = [];
            M1b = [xt3(i) bvalsum3(i)];


            M2b = [];
            M2b =  [xt3(i2) bvalsum3(i2)];

            %ll = xt3 >= M1b(1) & xt3 <= M2b(1);  %if automatic pick
            ll   = xt3>ii & xt3 < nh;
            x = xt3(ll);
            [ av, bv, si] = bmemag(newcat)  ;
            y = backg_ab(ll);
            [aw bw,  ew] = wls(x',y');
            p = [bw aw];
            f = polyval(p,x);
            (teb-t0b)/(10.^ polyval(p,6.0));
            f = 10.^f;
            r = corrcoef(x,y);
            r = r(1,2);
            std_backg = ew;      % standard deviation of fit

            p=-p(1,1);
            p=fix(100*p)/100;
            std_backg=fix(100*std_backg)/100;

            tt1(j)=p;
            tt2(j)=std_backg;
            tt4(j)=bv;
            tt5(j)=si;

        end
        delete(wai);
        [existFlag,figNumber]=figure_exists('B-Value Estimate ',1);
        if existFlag
            figure_w_normalized_uicontrolunits(bm2fig)
            clf;
        else
            bm2fig=figure_w_normalized_uicontrolunits('units','normalized',...
                'NumberTitle','off',...
                'name','B-Value Estimate ',...
                'position',[.2 .2 .4 .75],...
                'visible','off');
        end
        matdraw;
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
             'Callback','myprint')

        axis('off')

        uicontrol('Units','normal',...
            'Position',[.0 .75 .08 .06],'String','Close ',...
             'Callback','f1=gcf; f2=gpf; set(f1,''Visible'',''off''),close(f1);if f1~=f2, zmap_message_center.set_info('' '','' '');done; end')

        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
             'Callback','clinfo(17)')


        axis('off')
        rect1=[0 0 1 1];
        h2=axes('visible','off',...
            'Position',rect1);

        axis('off')
        rect=[.2 .4 .65 .25];
        bmplot1=axes('position',rect,'box','on');
        hold on
        plot(magn,tt1,'ob')
        errorbar(magn,tt1,tt2);
        xlabel('Minimum Magnitude');
        ylabel('b-value w LS');
        grid

        rect=[.2 .72 .65 .25];
        bmplot2=axes('position',rect,'box','on');
        hold on
        plot(magn,tt4,'ob')
        errorbar(magn,tt4,tt5);
        xlabel('Minimum Magnitude');
        ylabel('b-value  Max L');
        grid


        tt6=tt4-tt1;
        tt7=sqrt(tt2.^2+tt5.^2);
        rect=[.2 .13 .65 .2];
        bmplot3=axes('position',rect,'box','on');
        hold on
        plot(magn,tt6,'ob');
        errorbar(magn,tt6,tt7);
        xlabel('Minimum Magnitude')
        ylabel('LS - Max L')
        grid

        hold off
        axes(h2);
        tt8=num2str(nh);
        tt9=['Upper Magnitude Threshold:  ',tt8];
        text1= text( 'EraseMode','normal',...
            'Position',[0.15 0.03 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            'FontWeight','bold',...
            'String',tt9);
        clear bcat;
    end


