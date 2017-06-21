function [X, Y, B] = ginput_datetime(ax, varargin)
    % standard ginput, but can handle date_time. Axes must be specified
    % [x, y, button] = ginput_datetime(ax, ...)
    %
    % because, for large date ranges, there is an artificial level of precision,
    % the addition of a 'nearest_...' parameter (as the last parameter) will do rounding
    %
    % [x, y, button] = ginput_datetime(ax, ... , 'nearest_day')
    % [x, y, button] = ginput_datetime(ax, ... , 'nearest_hour')
    %
    %
    % see also ginput
    %
    % Celso G Reyes, 2017
    
    selector = '';
    if ~isempty('varargin') && ischar(varargin{end}) && startsWith(varargin{end},'nearest_')
        selector = varargin{end};
        varargin(end) = [];
    end
        
    axes(ax);
    xlims = ax.XLim;
    ylims = ax.YLim;
    [X, Y, B] = ginput(varargin{:});
    
    if isa(xlims,'datetime')
        X = min(xlims) + days(X);
        X = round_time(X,selector);
    end
    if isa(ylims,'datetime')
        Y = min(ylims) + days(Y);
        Y = round_time(Y,selector);
    end
        
end

function dates = round_time(dates, selector)
    switch selector
        case 'nearest_day'
            dates = datetime(dates.Year, dates.Month, dates.Day + round(dates.Hour ./ 24));
        case 'nearest_hour'
            dates = datetime(dates.Year, dates.Month, dates.Day, dates.Hour + round(dates.Minute/60),0,0);
        otherwise
            % do nothing
    end
end