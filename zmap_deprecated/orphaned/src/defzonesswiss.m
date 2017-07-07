report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(map);
ax = findobj('Tag','main_map_ax');
[x,y, mouse_points_overlay] = select_polygon(ax);
figure_w_normalized_uicontrolunits(map)

plos2 = plot(x,y,'k-','Linewidth',2);        % plot outline
sum3 = 0.;
pause(0.3)

if length(x) == 5
    do = [' s' num2str(k) ' = [ x(1) y(1) ; x(2) y(2) ; x(4) y(4) ; x(3) y(3) ]; ']; eval(do);
elseif length(x) == 7
    do = [' s' num2str(k) ' = [ x(1) y(1) ; x(2) y(2) ; x(6) y(6) ; x(3) y(3); x(5) y(5) ; x(4) y(4) ]; ']; eval(do);
elseif length(x) == 9
    do = [' s' num2str(k) ' = [ x(1) y(1) ; x(2) y(2) ; x(8) y(8) ; x(3) y(3); x(7) y(7) ; x(4) y(4); x(6) y(6) ; x(5) y(5)  ]; ']; eval(do);
end


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
        swisshaz
end

