%
% Calculation of the fractal dimension which is the slope on the
% log-log graph.
%
deriv = diff(log10(corint))./diff(log10(r));			% deriv= Vector of the appr. derivatives
r2 = r(1:(end-1));											% Forward difference approximation: deriv has one element less, and r must have the # of elements so r2

switch(dof)

    case 'newf'

        %
        % Calculation of the fractal dimension, by first calculating the
        % distances of depopulation "rd" and of saturation "rs".
        %
        rad = 0.8;				% 2rmax= linear size of the hypercube encompassing a given dataset
        ras = 7;
        v = find(r2 >= rad & r2 <= ras);					% v= Vector of the all the interevent distances that fall in the interval [rn,rs]
        lr = log10(r2(v));
        lc = log10(corint(v));

        [fd, Err] = polyfit(lr,lc,1);
        [ev, delta] = polyval(fd, log10(r), Err);

        %[fdlo,Err] = polyfit(log10(r2(v)), log10(corint(v)), 1);
        %[fd,Err] = polyfit(log10(r2(v)), log10(corint(v)), 1);
        %[deriv3, delta] = polyval(fd, log10(r2(v)), Err);

        Ha_Cax = gca;
        Hf_Cfig;
        hold on;
        Hl_gr2a = loglog(r2(v), corint(v), 'k.','Markersize',7);
        Hl_gr2b = plot(r,10.^ev,'k','Linewidth',1);
        xlabel('Interevent Distance R [km]');
        ylabel('Correlation Integral C(R)');
        set(Ha_Cax,'pos',[0.21 0.1 0.75 0.75]);

        if d == 2
            title('Correlation Integral versus the 2D Interevent Distance R');
        else
            title('Correlation Integral versus the 3D Interevent Distance R');
        end

        g = [];
        uicontrol('Units','normal','Position',[.0 .92 .15 .07],...
            'String','Scaling range', 'Callback','g = ginput(2);dof = ''newc''; dofdim')


        str1 = ['Range = ' num2str(rd,3) ' - ' num2str(rs,3) ' [km]'];
        str2 = ['D =  ' num2str(fd(1,1),3)];
        axes('pos',[0 0 1 1]); axis off; hold on;
        te1 = text(0.25, 0.8, str1 ,'Fontweight','bold');
        te2 = text(0.25, 0.75, str2, 'Fontweight', 'bold');


        %str3 = [' The scaling range is calculated as proposed by Nerenberg & Essex (1990): ' num2str(rd,3) ' - ' num2str(rs,4) ' [km] . If you wish to change the scaling range please click on the "scaling range" button'];
        %msg1 = msgbox( str3,'Fractal Dimension');


    case 'newc'

        rd = min(g(:,1)); rs = max(g(:,1));
        v = find(r2 >= rd & r2 <= rs);

        lr = log10(r2(v));
        lc = log10(corint(v));

        [fd, Err] = polyfit(lr,lc,1);
        [ev, delta] = polyval(fd, log10(r), Err);

        delete(Hl_gr2a);
        delete(Hl_gr2b);
        Hl_gr2a = loglog(r2(v), corint(v), 'k.','Markersize',7);
        Hl_gr2b = plot(r,10.^ev,'k','Linewidth',1);

        delete(te1);
        delete(te2);
        str1 = ['Range = ' num2str(rd,3) ' - ' num2str(rs,3) ' [km]'];
        str2 = ['D =  ' num2str(fd(1,1),3)];
        axes('pos',[0 0 1 1]); axis off; hold on;
        te1 = text(0.25, 0.8, str1 ,'Fontweight','bold');
        te2 = text(0.25, 0.75, str2, 'Fontweight', 'bold');

end
