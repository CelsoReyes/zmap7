function [uOutput,ok] = ascii_imp(nFunction, sFilename)
    % impor ascii delimited files data
    
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
        uOutput = ZmapCatalog.from(tb);
        ok = true;
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
    % relabel the zmap table columns [VariableNames] so that it can be automatically recognized
    if numel(tb.Properties.VariableNames) == 9
        tb.Properties.VariableNames = {...
            'Longitude', 'Latitude', 'Year','Month','Day','Magnitude','Depth','Hours','Minutes'};
    elseif numel(tb.Properties.VariableNames) == 10
        tb.Properties.VariableNames = {...
            'Longitude', 'Latitude', 'Year','Month','Day','Magnitude','Depth','Hours','Minutes','Seconds'};
    end
    
end