function sliderca(command)
    % This function is a sub callback for axiscall.
    % It should not be called from the command line.
    %
    % R. Cobb 11/94
    global YControl

    data=get(YControl,'UserData');
    v_1=data(1:6);
    vnew_1=v_1;

    y_1=data(7);
    x_1=data(8);
    if command == 2

        y_1= get(gco,'Value');
        vnew_1(4)=v_1(4)*2*y_1;
        vnew_1(2)=v_1(2)*2*x_1;
        if abs(v_1(1))==v_1(2)
            vnew_1(1)=-vnew_1(2);
        end
        if abs(v_1(3))==v_1(4)
            vnew_1(3)=-vnew_1(4);
        end
        temp=axis;
        if length(temp)==6
            axis([vnew_1(1:4),temp(5:6)]);
        else
            axis(vnew_1(1:4));
        end

    elseif command == 1
        x_1= get(gco,'Value');
        vnew_1(2)=v_1(2)*2*x_1;
        vnew_1(4)=v_1(4)*2*y_1;
        if abs(v_1(1))==v_1(2)
            vnew_1(1)=-vnew_1(2);
        end
        if abs(v_1(3))==v_1(4)
            vnew_1(3)=-vnew_1(4);
        end
        temp=axis;
        if length(temp)==6
            axis([vnew_1(1:4),temp(5:6)]);
        else
            axis(vnew_1(1:4));
        end
    end
    data(7)=y_1;
    data(8)=x_1;

    set(YControl,'UserData',data);


