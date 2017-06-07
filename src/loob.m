report_this_filefun(mfilename('fullpath'));

av4 = [];
ni = 200
newt3 = newcat;
figure
fi = gcf;
for i = 2.0:0.1:3.1
    l = newt3(:,6) >= i;
    newt2 = newt3(l,:);
    bwithde
    drawnow
    figure_w_normalized_uicontrolunits(fi)
    hold on
    plot(av2(:,2),av2(:,1))
    drawnow

end
