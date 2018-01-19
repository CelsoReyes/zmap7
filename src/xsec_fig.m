function fignum = xsec_fig()
    % XSEC_FIG returns the handle to the cross-section figure
    fignum=findobj('Type','Figure','-and','Name','Cross -Section');
    if isempty(fignum)
        fignum=figure('Name','Cross -Section');
    end
        