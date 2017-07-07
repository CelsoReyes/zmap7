report_this_filefun(mfilename('fullpath'));


ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);

figure_w_normalized_uicontrolunits(map)

plos2 = plot(x,y,'k-','Linewidth',2);        % plot outline
sum3 = 0.;
pause(0.3)

do = [' s' num2str(k) ' = [ x(1) y(1) ; x(2) y(2) ; x(4) y(4) ; x(3) y(3) ]; '];
eval(do)

if k == 1
    do = [' save kantonzones.mat  s' num2str(k) ' k  '];
    eval(do)
else
    do = [' save kantonzones.mat  s' num2str(k) ' k  -append  '];
    eval(do)
end



ans_ = questdlg('  ',...
    'Define More source zones',...
    'Yes please','No thank you','No' );

switch ans_
    case 'Yes please'
        k = k+1;
        defzonesswiss
    case 'No thank you'
        return
end

