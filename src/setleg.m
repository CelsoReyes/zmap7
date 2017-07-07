
% make dialog interface for the fixing of the legend
%

global tim1 tim2 tim3 tim4 t0b teb
% TODO fix the way times are handled
report_this_filefun(mfilename('fullpath'));



% TOFIX these global variables are out of sync with the newer method of tracking divisions
switch ZmapGlobal.Data.mainmap_plotby
case 'tim'
    
    % creates a dialog box to input some parameters
    %
    tim1 = t0b;
    tim2 = t0b +  (teb-t0b)/3;
    tim3 = t0b +  (teb-t0b)*0.663;
    tim4 = teb;
    
    
    dlg_title='Legend Time Breaks';
    prompt={'Time 1 (earliest):','Time2:','Time 3:','Time 4 (latest):'};
    defaultans = {char(tim1,'uuuu-MM-dd HH:mm:ss'), char(tim2,'uuuu-MM-dd HH:mm:ss'),...
        char(tim3,'uuuu-MM-dd HH:mm:ss'), char(tim4,'uuuu-MM-dd HH:mm:ss')};
    answer = inputdlg(prompt, dlg_title, 1, defaultans);
    if ~isempty(answer)
        for i=1:4
            if contains(answer{i},{' ','/','-',':'})
                % convert from string
                answer{i} = datetime(answer{i});
            else
                tmp=str2double(answer{i});
                if isnan(tmp)
                    answer{i} = datetime(datevec(decyear(answer{i})));
                else
                    answer{i}=datetime(datevec(decyear2mat(tmp)));
                end
                    
            end
        end
        ZG=ZmapGlobal.Data;ZG.mainmap_plotby='tim'; %redundant?
        tim1=answer{1};
        tim2=answer{2};
        tim3=answer{3};
        tim4=answer{4};
    else
        welcome;
    end
end
clear answer temp defaultans prompt dlg_title
update(mainmap())
    
