%  earthquake_depth.m
% August 95 by Zhong Lu

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('Depth vs Earthquake Number',1);

newWindowFlag=~existFlag;

if newWindowFlag
    mif66 = figure_w_normalized_uicontrolunits( ...
        'Name','Depth vs Earthquake Number',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ fipo(3)-300 fipo(4)-500 winx winy]);

    
    matdraw
    hold on

end
figure_w_normalized_uicontrolunits(mif66)
hold on

x = [1:length(mi)]';
[ss,ssi]=sort(a(:,7));
plot(x,ss,'go');

grid
%set(gca,'box','on',...
%        'SortMethod','childorder','TickDir','out','FontWeight',...
%        'bold','FontSize',fontsz.m,'Linewidth',1.2);

ylabel('Depth of Earthquake','FontWeight','bold','FontSize',fontsz.m);
xlabel('Earthquake Number','FontWeight','bold','FontSize',fontsz.m);
hold off;

done
