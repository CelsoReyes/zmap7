function tb = table2zmapcatalogtable(tb)
    % Interpret a table in terms of ZmapCatalog, modifying as necessary to load into a ZmapCatalog
    % see ZmapCatalog
    persistent Candidates
    
    if isempty(Candidates)
        Candidates = create_colname2property_map();
    end
    
    
    fn = fieldnames(Candidates);
    
    tbNames = lower( tb.Properties.VariableNames );
    
    for i=1:numel(fn)
        make_conformant(fn{i}, Candidates.(fn{i}))
    end
    
    % remove empty lines.  [these may have been comments]
    missing_rows = ismissing(tb.Longitude);
    tb(missing_rows,:) = []; % remove empty lines
    
    % interpet the dates
    tb.Date = munge_dates(tb) + munge_times(tb);
    
    tb = remove_unused_columns(tb);    
    return
    
    
    function make_conformant(thisfield, regex_values)
        for searchval = regex_values
            mask = ~ cellfun(@isempty, regexp(tbNames, searchval, 'once') );
            if any(mask)
                % found this field, change it and return
                if thisfield == "Depth"
                    tb = set_depth_units(tb, mask);
                end
                tb.Properties.VariableNames(mask)={thisfield};
                return
            end
        end
    end
    
    function tb = remove_unused_columns(tb)
        fieldsToKeep = {'Date','Latitude','Longitude','Magnitude','Depth',...
            'MagnitudeType','Rake','Dip','DipDirection','MomentTensor'};
        vn       = tb.Properties.VariableNames;
        toRemove = vn(~ismember(vn,fieldsToKeep'));
        tb(:,toRemove) = [];
    end
end


function colpropexprs = create_colname2property_map()
    % this maps probable column titles to ZMAP properties
    colpropexprs.Latitude  = "^lat.*";
    colpropexprs.Longitude = "^lon.*";
    colpropexprs.Depth     = "^dep.*";
    colpropexprs.Magnitude = ["^mag$", "^mags$", "^magnitude$", "^magnitudes$"];
    colpropexprs.Date      = "^date.?";
    
    colpropexprs.DecYear   = ["^decyear", "^decimalyear"];
    colpropexprs.JulianDay = ["^julian.*","^jday"];
    colpropexprs.Time      = "^time.";
    colpropexprs.Year      = ["^yr\w?", "^year\w?"];
    colpropexprs.Month     = ["^month", "^mo"];
    colpropexprs.Day       = "^day";
    colpropexprs.Hour      = ["^hr\w?","^hour"];
    colpropexprs.Minute    = ["^mi","^min","^minute."];
    colpropexprs.Second    = ["^sec","^second\w?"];
    
    colpropexprs.MagnitudeType = ["^magnitudetype$","^magtype$"];
    colpropexprs.Dip           = "^dip";
    colpropexprs.DipDirection  = "^dipd.*";
    colpropexprs.Rake          = "^rake";
    colpropexprs.MomentTensor  = "^momenttensor";
    
    % do test to make sure this will work correctly in a loop
    assert(all(structfun(@isrow, colpropexprs)));
end

function tb = set_depth_units(tb, mask)
    s=split(tb.Properties.VariableNames(mask),["_","/"]);
    for q=2:numel(s)
        try
            unit = validateLengthUnit(s{q});
            tb.Properties.VariableUnits(mask)={unit};
        catch
            do_nothing();
        end
    end
end

function d = add_duration(d, transFcn, values)
    if isnumeric(values)
        d = d + transFcn(values);
    elseif isduration(values)
        d=d+values;
    else
        error('choked on duration..unknown type');
    end
end

function d = munge_times(tb)
    vn = tb.Properties.VariableNames;
    tidx = (vn=="Time");
    if any(tidx) && ~isduration(tb.Time)
        fmt = timestr_to_fmt(tb.Time(1));
        
        dt= datetime(tb.Time, 'InputFormat',fmt);
        % fmt includes full date, but keep only time part
        d = dt - datetime(dt.Year, dt.Month, dt.Day); % now it is a duration
        return
    elseif any(tidx) && isduration(tb.Time)
        d =tb.Time;
        return
    end
    
    d = years(zeros(height(tb),1));
    if any(vn == "Hour")
        d = add_duration(d, @hours, tb.Hour);
    end
    if any(vn == "Minute")
        d = add_duration(d, @minutes, tb.Minute);
    end
    if any(vn == "Second")
        d = add_duration(d, @seconds, tb.Second);
    end
    
end

function dt = munge_dates(tb)
    vn = tb.Properties.VariableNames;
    if any(vn == "Date")
        if isa(tb.Date,'datetime')
            dt = tb.Date;
            return
        end
        fmt = timestr_to_fmt(tb.Date(1));
        dt = datetime(tb.Date, 'InputFormat',fmt);
        return
    elseif any(vn == "DecYear")
        disp('decyear detected')
        yelapsed = years(tb.DecYear); %duration
        dt = datetime(0,0,0) + yelapsed;
        
    else
        if any(vn == "Time") && ~isduration(tb.Time(1))
            fmt = timestr_to_fmt(tb.Time(1));
            if fmt(1)=='y'
                dt = datetime(tb.Time, 'InputFormat',fmt);
                % fmt includes full date, but keep only time part
                dt = datetime(dt.Year, dt.Month, dt.Day); % now it is just the base datetime
                
                if all(dt.Month)==0 || all(dt.Day)==0
                    % continue
                else
                    return
                end
            end
        end
        if any(vn == "Year")
            yy = tb.Year;
        else
            yy = zeros(height(tb),1);
        end
        if any(vn == "Month")
            mm = tb.Month;
        else
            mm = zeros(height(tb),1);
        end
        if any(vn == "Day")
            dd = tb.Day;
        else
            dd = zeros(height(tb),1);
        end
        dt = datetime(yy, mm, dd);
    end
end


function fmt = timestr_to_fmt(val)
    % look at format for the date
    if iscell(val)
        val=val{1};
    end
    hasDatePart = all(ismember(val(1:4),'1234567890')); %assume 4 digit year.
    hasTimePart = any(ismember(val,':')); % time
    
    if ~hasDatePart
        date_format = '';
    elseif ismember('/',val)
        date_format = 'yyyy/MM/dd';
    else
        date_format = 'yyyy-MM-dd'; %FDSN date standard
    end
    
    if ~hasTimePart
        time_format = '';
    elseif ismember('.',val)
        
        % look at format for time
        
        seconds_precision = length(val) - strfind(val,'.') - double(endsWith(val,'Z'));
        
        time_format = 'HH:mm:ss.';
        time_format(1, end+1:end+seconds_precision)='S';
    else
        time_format ='HH:mm:ss';
    end
    
    if endsWith(val,'Z')
        time_format = [time_format, '''Z'''];
    end
    
    % look at separator between date & time fields
    if ~hasDatePart
        fmt = time_format;
    elseif ~hasTimePart
        fmt = date_format;
    elseif ismember('T', val) % FDSN date standard
        fmt=[date_format, '''T''', time_format];
    else
        fmt=[date_format, ' ', time_format];
    end
end