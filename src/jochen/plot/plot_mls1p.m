function plot_mls1p(vPar, vMlsprob, nType)
    % Plot maximum likelihod score (MLS) versus parameter variation
    %  plot_mls1p(vPar, vMlsprob, nType)
    % -----------------------------------------------
    % Plot maximum likelihod score (MLS) versus parameter variation
    % vPar is e.g. a shift, a stretch or a rate change
    %
    % Incoming variable
    % vPar          : Vector of parameter used in search
    % vMlsprob      : Maximum likelihood score for parameter
    % nType    : Parameter identification
    %            1 = dM (Simple shift)
    %            2 = dS (Simple stretch)
    %            3 = Rf (Rate factor)
    %
    % See also plot_mls2p, plot_mls3p
    %
    % Author: J. Woessner, woessner@seismo.ifg,.ethz.ch
    % updated: 28.10.02
    
    switch nType
        case 1
            sTitle = 'Simple magnitude shift';
            sX = 'dM';
        case 2
            sTitle = 'Simple stretch';
            sX = 'dS';
        case 3
            sTitle = 'Rate factor';
            sX = 'R_f';
        otherwise
            return;
    end
    if exist('mls2_fig','var') &  ishandle(mls2_fig)
        set(0,'Currentfigure',mls2_fig);
    else
        mls2_fig=figure_w_normalized_uicontrolunits('tag','mls2','Name','Max. Likelikehood score','Units','normalized','Nextplot','add',...
            'Numbertitle','off');
        mls2_axs=axes('tag','ax_mls2','Nextplot','add','box','off');
    end
    
    set(gcf,'tag','mls2');
    set(gca,'tag','ax_mls2','Nextplot','replace','box','off','visible','off');
    plot(vPar, log10(vMlsprob), 'r-^');
    xlabel(sX);
    ylabel('log10(Likelihood score)');
    title(sTitle);
end