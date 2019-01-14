function [uOutput,ok] = ascii_imp(nFunction, sFilename)
    
    ok=false;
    % Filter function switchyard
    if nFunction == FilterOp.getDescription
        uOutput = 'ASCII columns (.txt, .dat, .csv)';
        return
    elseif nFunction == FilterOp.getWebpage
        uOutput = 'ascii_imp.html';
        
    else
        opts = detectImportOptions(sFilename);
        tb = readtable(sFilename, opts);
        
        
        if is_old_zmap_style(tb)
            tb = from_old_zmap_style(tb);
        end
        tb = interpretFromTable(tb);
        
        disp(tb(1:min(5,height(tb)),:));
        
        uOutput = ZmapCatalog(tb);
        ok=true;
    end
end

function tf = is_old_zmap_style(tb)
    varNames = tb.Properties.VariableNames;
    tf = 9 <= numel(varNames) && numel(varNames) <=10; % with or without seconds
    tf = tf && all(startsWith(varNames,'Var')); % no variable specified in file
    tf = tf && all(-180 <= tb.Var1 -180 & tb.Var1 <= 180);
    tf = tf && all(-90 <= tb.Var2 -90 & tb.Var2 < 90);
    tf = tf && all(0 <= tb.Var9 & tb.Var9 <= 60); % minutes
    tf = tf && all(0 <= tb.Var8 & tb.Var8 <= 24); % hours
    tf = tf && all(0 <= tb.Var5 & tb.Var5 <= 31); % days
    tf = tf && all(0 <= tb.Var4 & tb.Var4 <= 12); % months
    tf = tf && all(tb.Var6 <= 10);  % magnitudes
    if numel(varNames) == 10
        tf = tf && all(0 <= tb.Var10 & tb.Var10 <= 60); % seconds
    end
end
    
function tb = from_old_zmap_style(tb)
    if numel(tb.Properties.VariableNames) == 9
        tb.Properties.VariableNames = {...
            'Longitude', 'Latitude', 'Year','Month','Day','Magnitude','Depth','Hours','Minutes'};
    elseif numel(tb.Properties.VariableNames) == 10
        tb.Properties.VariableNames = {...
            'Longitude', 'Latitude', 'Year','Month','Day','Magnitude','Depth','Hours','Minutes','Seconds'};
    end
    
end

function tb = interpretFromTable(tb)  
    Candidates.Latitude  = "^lat.*";
    Candidates.Longitude = "^lon.*";
    Candidates.Depth     = "^dep.*";
    Candidates.Magnitude = ["^mag$","^mags$","^magnitude$","^magnitudes$"];
    Candidates.Date      = "^date.";
    
    Candidates.DecYear   = "^decyear";
    Candidates.JulianDay = ["^julian.*","^jday"];
    Candidates.Time      = "^time.";
    Candidates.Year      = ["^yr\w?", "^year\w?"];
    Candidates.Month     = ["^month", "^mo"];
    Candidates.Day       = "^day";
    Candidates.Hour      = ["^hr\w?","^hour"];
    Candidates.Minute    = ["^mi","^min","^minute."];
    Candidates.Second    = ["^sec","^second\w?"];
    
    Candidates.MagnitudeType = ["^magnitudetype$","^magtype$"];
    Candidates.Dip           = "^dip";
    Candidates.DipDirection  = "^dipd.*";
    Candidates.Rake          = "^rake";
    Candidates.MomentTensor  = "^momenttensor";
    
    fn = fieldnames(Candidates);
    tbNames = lower( tb.Properties.VariableNames );
    for i=1:numel(fn)
        thisfield = fn{i};
        for j=1:numel(Candidates.(thisfield))
            thisExp = Candidates.(thisfield)(j);
            mask = ~ cellfun(@isempty, regexp(tbNames, Candidates.(thisfield)(j), 'once') );
            if any(mask)
                if thisfield == "Depth"
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
                tb.Properties.VariableNames(mask)={thisfield};
                break
            end
        end
    end
    tb(isnan(tb.Longitude),:)=[]; % dump comments
    tb.Date = munge_dates(tb) + munge_times(tb);
    keepFields = {'Date','Latitude','Longitude','Magnitude','Depth',...
        'MagnitudeType','Rake','Dip','DipDirection','MomentTensor'};
    theoreticalOnlyFields = fn(~ismember(fn, keepFields));
    vn = tb.Properties.VariableNames;
    toRemove = vn(~ismember(vn,keepFields'));
    tb(:,toRemove)=[];
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
    if any(vn == "DecYear")
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
    if iscell(val); val=val{1};end
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