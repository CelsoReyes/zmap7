function [decyr] = decyear(date)
    % converts dates in year,month,day into year+fraction of yr. Takes into account leap years. Don't use if you don't have to
    %
    % [decyr] = decyear(date)
    %
    % onverts dates in year,month,day into
    % year+fraction of yr. Takes into account leap years.
    % date is a matrix with dates as yr, mn, dy , etc
    % It returns a n-vector (decyr) with results
    %
    % If you need days after first of january of each year do the following
    %        days = (decyr - date(:,cy))*365;
    %  where cy is the column in matrix date corresponding to years
    %
    %  ------------------
    % inial mods by A.Allmann, Samuel Neukomm, 3/12/04
    % completely rewritten (simplified) by Celso G Reyes, 2017
    
    if isa(date,'datetime')
        yrs=date.Year;
        decyr = (datenum(date)-datenum(yrs,1,1)) ./ (datenum(yrs+1,1,1) - datenum(yrs,1,1)) + yrs;
    else
        if length(date(1,:))==1 && all(date > datenum(1500,1,1)) && all(date < datenum(2600,1,1))
            % datevec array
            date=datevec(date);
        end
        % arrays of either year,month,day or year,month,day,hour,min, or year,month,day,hour,min,sec
        if length(date(1,:))==5
            %add seconds, otherwise it is wrong size, causing datenum to misinerpret array!
            date(:,6)=0;
        end
        % yr,mon,day!!!
        nextYear=datenum(date(:,1)+1,1,1);
        thisYear=datenum(date(:,1),1,1);
        decyr = (datenum(date) - thisYear) ./ (nextYear - thisYear) + date(:,1);
    end
end
