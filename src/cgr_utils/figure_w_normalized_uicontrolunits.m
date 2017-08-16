function [h] = figure(varargin);
    %figure_w_normalized_uicontrolunits 
    %
    % creates a figure, and sets the DefaultUicontrolUnits to 'normalized'
    % which is expected by most of the controls in Zmap.
    %
    % This adapter is to solve a problem where newly generated figures may
    % default to something else, like pixels.  However, setting the main 
    % window's DefaultUicontrolUnits to 'normalized' has a side effect that
    % makes dialog boxes show incorrectly.
    %
    % - Celso G Reyes, 2017
    %
    % see also figure
    disp('creating figure with following arguments:')
    disp(varargin)
    h = figure(varargin{:});
    set(h,'DefaultUiControlunits','normalized');
end