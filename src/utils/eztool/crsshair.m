function crsshair(action)
    %         crsshair
    %
    %  A gui interface for reading (x,y) values from a plot.
    %
    %  A set of mouse driven crosshairs is placed on the current axes,
    %  and displays the current (x,y) position, interpolated between points.
    %  For multiple traces, only plots with the same length(xdata)
    %  will be tracked. Select done after using to remove the gui stuff,
    %  and to restore the mouse buttons to previous values.
    %
    %   Richard G. Cobb    3/96
    %   rcobb@afit.af.mil
    %
    global xhr_plot xhr_xdata xhr_ydata xhr_plot_data xhr_button_data
    if nargin == 0
        xhr_plot=gcf;
        xhrx_axis=gca;
        xhr_xdata=[];
        xhr_ydata=[];
        sibs=get(xhrx_axis,'Children');
        found=0;
        for i=1:size(sibs)
            if strcmp(get(sibs(i),'Type'),'line')
                if max(size(get(sibs(i),'Xdata'))) > max(size(xhr_xdata))
                    found=1;
                    xhr_xdata=[];
                    xhr_ydata=[];
                    xhr_xdata(:,found)=get(sibs(i),'Xdata').';
                    xhr_ydata(:,found)=get(sibs(i),'Ydata').';
                elseif max(size(get(sibs(i),'Xdata'))) == max(size(xhr_xdata))
                    found=found+1;
                    xhr_xdata(:,found)=get(sibs(i),'Xdata').';
                    xhr_ydata(:,found)=get(sibs(i),'Ydata').';
                end
            end
        end
        xhr_button_data=get(xhr_plot,'WindowButtonDownFcn');
        set(xhr_plot,'WindowButtonDownFcn','crsshair(''down'');');
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
        %
        xaxis_text=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.2 .96 .2 .045],...
            'String','X value',...
            'BackGroundColor',[.7 .7 .7]);
        x_num=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.4 .96 .2 .045],...
            'String',' ',...
            'BackGroundColor',[0 .7 .7]);
        y_text=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.6 .96 .2 .045],...
            'String','Y value',...
            'BackGroundColor',[.7 .7 .7]);
        y_num=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.8 .96 .2 .045],...
            'String',' ',...
            'BackGroundColor',[0 .7 .7]);
        xhairs_on=uicontrol('Style','Text','Units','Normalized',...
            'Position',[.8 .2 .2 .04],...
            'String','Crosshairs on:',...
            'Visible','off');
        z(1,:)=['Trace ' num2str(1) '|'];
        for i=2:min(size(xhr_ydata))
            s(i,:)=['Trace ' num2str(i) '|'];
            z=[z s(i,:)];
        end
        traces=z;
        trace_switcher=uicontrol('Style','Popup','Units','Normalized',...
            'Position',[.8 .15 .2 .05],...
            'String',traces,...
            'BackGroundColor','w',...
            'Visible','off',...
            'Callback',@(s,e)crsshair('up'));
        if min(size(xhr_ydata))>1
            set(trace_switcher,'Visible','On','Value',1);
            set(xhairs_on,'Visible','On');
        end
        x_ydata_line=line(x_rng,[y_rng_ydata(1) y_rng_ydata(1)]);
        y_ydata_line=line(x_rng,[y_rng_ydata(1) y_rng_ydata(1)]);
        set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
        set(x_ydata_line,'EraseMode','xor');set(y_ydata_line,...
            'EraseMode','xor');
        closer=uicontrol('Style','Push','Units','Normalized',...
            'Position',[.92 0 .08 .04],...
            'String','Done',...
            'Callback','crsshair(''close'')',...
            'Visible','on');
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
            xhrx_axis   xaxis_text x_num...
            y_text y_num  trace_switcher...
            xhairs_on closer ];
    elseif strcmp(action,'down');
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer=handles(10);
        index=get(trace_switcher,'Value');
        xhr_xdata_col=xhr_xdata(:,index);
        xhr_ydata_col=xhr_ydata(:,index);
        set(xhr_plot,'WindowButtonMotionFcn','crsshair(''move'');');
        set(xhr_plot,'WindowButtonUpFcn','crsshair(''up'');');
        pt=get(xhrx_axis,'Currentpoint');
        xdata_pt=pt(1,1);
        if xdata_pt>=max(xhr_xdata_col)
            xdata_pt=max(xhr_xdata_col);
            k=max(size(xhr_xdata_col));
        elseif xdata_pt<=min(xhr_xdata_col)
            xdata_pt=min(xhr_xdata_col);
            k=2;
        else
            k=find(xhr_xdata_col>xdata_pt);k=k(1);
        end
        ydata_pt=table1([xhr_xdata_col(k-1) xhr_ydata_col(k-1);...
            xhr_xdata_col(k) xhr_ydata_col(k)],xdata_pt);
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
        set(x_ydata_line,'Xdata',[xdata_pt xdata_pt],'Ydata',y_rng_ydata);
        set(y_ydata_line,'Xdata',x_rng,'Ydata',[ydata_pt ydata_pt]);
        set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
        set(x_num,'String',num2str(xdata_pt,6));
        set(y_num,'String',num2str(ydata_pt,6));
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
            xhrx_axis   xaxis_text x_num ...
            y_text y_num trace_switcher ...
            xhairs_on closer ];
    elseif strcmp(action,'move');
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer=handles(10);
        index=get(trace_switcher,'Value');
        xhr_xdata_col=xhr_xdata(:,index);
        xhr_ydata_col=xhr_ydata(:,index);
        pt=get(xhrx_axis,'Currentpoint');
        xdata_pt=pt(1,1);
        if xdata_pt>=max(xhr_xdata_col)
            xdata_pt=max(xhr_xdata_col);
            k=max(size(xhr_xdata_col));
        elseif xdata_pt<=min(xhr_xdata_col)
            xdata_pt=min(xhr_xdata_col);
            k=2;
        else
            k=find(xhr_xdata_col>xdata_pt);k=k(1);
        end
        ydata_pt=table1([xhr_xdata_col(k-1) xhr_ydata_col(k-1);...
            xhr_xdata_col(k) xhr_ydata_col(k)],xdata_pt);
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
        set(x_ydata_line,'Xdata',[xdata_pt xdata_pt],...
            'Ydata',y_rng_ydata);
        set(y_ydata_line,'Xdata',x_rng,'Ydata',[ydata_pt ydata_pt]);
        set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
        set(x_num,'String',num2str(xdata_pt,6));
        set(y_num,'String',num2str(ydata_pt,6));
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
            xhrx_axis   xaxis_text x_num...
            y_text y_num trace_switcher ...
            xhairs_on closer ];
    elseif strcmp(action,'up');
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer = handles(10);
        index=get(trace_switcher,'Value');
        xhr_xdata_col=xhr_xdata(:,index);
        xhr_ydata_col=xhr_ydata(:,index);
        set(xhr_plot,'WindowButtonMotionFcn',' ');
        set(xhr_plot,'WindowButtonUpFcn',' ');
        pt=get(xhrx_axis,'Currentpoint');
        xdata_pt=pt(1,1);
        if xdata_pt>=max(xhr_xdata_col)
            xdata_pt=max(xhr_xdata_col);
            k=max(size(xhr_xdata_col));
        elseif xdata_pt<=min(xhr_xdata_col)
            xdata_pt=min(xhr_xdata_col);
            k=2;
        else
            k=find(xhr_xdata_col>xdata_pt);k=k(1);
        end
        ydata_pt=table1([xhr_xdata_col(k-1) xhr_ydata_col(k-1);...
            xhr_xdata_col(k) xhr_ydata_col(k)],xdata_pt);
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
        set(x_ydata_line,'Xdata',[xdata_pt xdata_pt],'Ydata',y_rng_ydata);
        set(y_ydata_line,'Xdata',x_rng,'Ydata',[ydata_pt ydata_pt]);
        set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
        set(x_num,'String',num2str(xdata_pt,6));
        set(y_num,'String',num2str(ydata_pt,6));
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
            xhrx_axis   xaxis_text x_num...
            y_text y_num trace_switcher ...
            xhairs_on closer ];
    elseif strcmp(action,'close')
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer=handles(10);
        delete(xaxis_text);
        delete(x_ydata_line);
        delete(y_ydata_line);
        delete(x_num);
        delete(y_text);
        delete(y_num);
        delete(xhairs_on);
        delete(trace_switcher);
        delete(closer);
        set(xhr_plot,'WindowButtonUpFcn','');
        set(xhr_plot,'WindowButtonMotionFcn','');
        set(xhr_plot,'WindowButtonDownFcn',xhr_button_data);
        refresh(xhr_plot)
        clear xhr_plot xhr_xdata xhr_ydata xhr_plot_data xhr_button_data
    end

