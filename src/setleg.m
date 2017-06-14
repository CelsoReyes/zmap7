
% make dialog interface for the fixing of the legend
%

global tim1 tim2 tim3 tim4 t0b teb typele
% TODO fix the way times are handled
report_this_filefun(mfilename('fullpath'));



if typele =='tim'
    
    % creates a dialog box to input some parameters
    %
    tim1 = t0b;
    tim2 = t0b +  (teb-t0b)/3;
    tim3 = t0b +  (teb-t0b)*0.663;
    tim4 = teb;
    
    
    dlg_title='Legend Time Breaks';
    prompt={'Time 1 (earliest):','Time2:','Time 3:','Time 4 (latest):'};
    defaultans = {num2str(tim1), num2str(tim2), num2str(tim3), num2str(tim4)};
    answer = inputdlg(prompt, dlg_title, 1, defaultans);
    if ~isempty(answer)
        for i=1:4
            if contains(answer{i},{' ','/','-',':'})
                % convert from string
                answer{i} = decyear(datetime(answer{i}));
            else
                tmp=str2double(answer{i});
                if isnan(tmp)
                    answer{i} = decyear(datetime(answer{i}));
                else
                    answer{i}=tmp;
                end
                    
            end
        end
        typele='tim'; %redundant?
        tim1=answer{1};
        tim2=answer{2};
        tim3=answer{3};
        tim4=answer{4};
    else
        welcome;
    end
end
clear answer temp defaultans prompt dlg_title
mainmap_overview()
    
