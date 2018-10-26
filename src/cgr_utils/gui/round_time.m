function dates = round_time(dates, selector)
    % ROUND_TIME rounds the time
    %
    % dates = round_time(dates, selector), where SELECTOR can be 'nearest_day','nearest_hour', or ''
    
    switch selector
        case 'nearest_day'
            dates = datetime(dates.Year, dates.Month, dates.Day + round(dates.Hour ./ 24));
        case 'nearest_hour'
            dates = datetime(dates.Year, dates.Month, dates.Day, dates.Hour + round(dates.Minute/60),0,0);
        otherwise
            dates.Format='uuuu-MM-dd HH:mm:ss';
            % do nothing
    end
end