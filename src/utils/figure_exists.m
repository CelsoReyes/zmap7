function [ figure_exists, figure_number ] = figure_exists( figure_name, silent )
    %`figure_exists replacement for the deprecated figflag
    %   This adapter replaces the deprecated function "figflag"
    %   usage: [isFig, figNum] = figure_exists( name , silent )

    %   written by Celso G. Reyes, 2017

    x=findobj('type','figure','name',figure_name);
    figure_exists = ~isempty(x);
    if figure_exists
        if nargin==1 || ~silent
            figure_w_normalized_uicontrolunits(x(1).Number) %pop first matching figure to front
        end
        figure_number = [x.Number];
    else
        figure_number = -1;
    end
end

