function fdallfig()
    % Plot the correlation integral versus the distance calculated at each grid point.
    % Francesco Pacchiani 1/2000
    %
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    HCIfig=findobj('Type','Figure','-and','Name','Correlation Integral');
    
    if ~isempty(HCIfig)
        fig = 'addfig';
    else
        fig = 'orifig';
    end
    
    
    D = coef(1,1);
    col = 0.6:0.45:3.3;
    colin = jet(64);
    Db = D-0.6;
    Dc = round((Db*64)/2.7);
    
    
    switch(fig);
        
        case 'orifig'
            
            HCIfig = figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Correlation Integral', 'Visible','on');
            Haxes = gca;
            
            if D < 0.6 | 3.3 < D
                
                str5 = 'The fractal dimension calculated is not comprised in the interval 0.6-3.3. The scaling range might be the problem. ';
                msg3 = msgbox(str5, 'Input Error');
                waitforbuttonpress;
                close(msg3);
                close(HCIfig);
            end
            
            Hline = loglog(r, corint,'color', [colin(Dc,1) colin(Dc,2) colin(Dc,3)]);
            set(Hline,'Linewidth',1);
            xlabel('Interevent Distance R [km]', 'fontsize',12);
            ylabel('Correlation Integral C(R)', 'fontsize',12);
            title('Correlation Integral of All Subsets', 'fontsize',14);
            set(Haxes, 'fontsize', 11);
            set(gca,'NextPlot','add');
            
            
        case 'addfig'
            
            figure(HCIfig);
            set(gcf,'visible','on');
            axes(Haxes);
            set(gca,'NextPlot','add');
            if Dc < 1; Dc = 1; end
            if Dc > 63; Dc = 63; end
            Hline = loglog(r, corint,'color', [colin(Dc,1) colin(Dc,2) colin(Dc,3)]);
            axis([0.001 100 0.000001 5]);
            set(Haxes, 'fontsize', 11);
            
    end %switch
    
    
end
