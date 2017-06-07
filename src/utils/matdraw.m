% MATDRAW  adds menus and draw functions to Matlab
% MATDRAW()
% Adds a suite of menus and a Draw palette to
% the Matlab environment.  This is an extension
% of the earlier package matmenus, which was
% written in November of 1993.
%
%
% Keith Rogers 3/95
set(gcf,'Pointer','watch');
figure_w_normalized_uicontrolunits(gcf);
%mdprog;
%eztools
clear size
set(gcf,'Pointer','arrow');

set(gcf,'Menubar','figure')
if exist('plotedit') == 6 
    plotedit('on');
    plotedit('off'); 
end
