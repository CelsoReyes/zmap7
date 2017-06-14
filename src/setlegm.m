
% make dialog interface for the fixing of the legend
%


%
global dep1 dep2 dep3 a

report_this_filefun(mfilename('fullpath'));


if typele =='mag'

    % creates a dialog box to input some parameters
    %
    dep3 = max(a(:,6));
    dep1 = min(a(:,6));
    dep2 = (dep1+dep3)*2/3;
    dep1 = (dep1+dep3)*1/3;

    dlg_title='Legend Magnitude Breaks';
    prompt={'First magnitude division (smallest):','Second magnitude division:','Third magnitude division (largest):'};
    defaultans = {num2str(dep1), num2str(dep2), num2str(dep3)};
    answer = inputdlg(prompt, dlg_title, 1, defaultans);
    if ~isempty(answer)
        for i=1:3
            % convert from string
            answer{i} = str2double(answer{i});
        end
        typele='mag'; %redundant?
        dep1=answer{1};
        dep2=answer{2};
        dep3=answer{3};
    else
        welcome;
    end
end


if typele == 'dep'
    % creates a dialog box to input some parameters
    %
    dep_idx = 7;
    % divide depths into 3 categories
    dep1 = 0.3*max(a(:,dep_idx));
    dep2 = 0.6*max(a(:,dep_idx));
    dep3 = max(a(:,dep_idx));

    dlg_title='Legend Depth Breaks';
    prompt={'First depth division (shallowest, km):','Second depth division (km):','Third magnitude division (deepest, km):'};
    defaultans = {num2str(dep1), num2str(dep2), num2str(dep3)};
    answer = inputdlg(prompt, dlg_title, 1, defaultans);
    if ~isempty(answer)
        for i=1:3
            % convert from string
            answer{i} = str2double(answer{i});
        end
        typele='dep'; %redundant?
        dep1=answer{1};
        dep2=answer{2};
        dep3=answer{3};
    else
        welcome;
    end
end
clear answer temp defaultans prompt dlg_title
mainmap_overview()



