function result = availableDefaults()
    % list json files within this package
    d=which('defaults.writeDefaults');
    d=fileparts(d); % keep directory only
    jsonfiles = dir(fullfile(d,'*.json'));
    for i = 1 :numel(jsonfiles)
        [~,name] = fileparts(jsonfiles(i).name); % drop extension
        result(i,1) = {name};
    end
end