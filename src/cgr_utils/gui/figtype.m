function style = figtype(f)
    % get the type of a figure, distinguishing between the modern 'uifigure' and the old 'figure'
    
    
    % depends upon fact that modern figures aren't children of groot
    if isa(f,"matlab.ui.Figure")
        if ismember(f,get(groot,'Children'))
            style = 'figure';
        else
            style = 'uifigure';
        end
    else
        error('not a figure');
    end
  end