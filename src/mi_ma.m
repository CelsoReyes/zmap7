%  misfit_magnitude
% August 95 by Zhong Lu

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('Misfit as a Function of Magnitude',1);

newWindowFlag=~existFlag;

if newWindowFlag
    mif88 = figure_w_normalized_uicontrolunits( ...
        'Name','Misfit as a Function of Magnitude',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ fipo(3)-300 fipo(4)-500 winx winy]);

    
    matdraw
    hold on

end
figure_w_normalized_uicontrolunits(mif88)
hold on


plot(a.Magnitude,mi(:,2),'go');

grid
%set(gca,'box','on',...
%        'SortMethod','childorder','TickDir','out','FontWeight',...
%        'bold','FontSize',fontsz.m,'Linewidth',1.2);

xlabel('Magnitude of Earthquake','FontWeight','bold','FontSize',fontsz.m);
ylabel('Misfit Angle ','FontWeight','bold','FontSize',fontsz.m);
hold off;

done
