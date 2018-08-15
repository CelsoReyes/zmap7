function bwithti(mycat) 
    % calculate b-value with time
    
    % turned into function by Celso G Reyes 2017
    
    report_this_filefun();
    myFigName='b-value with time';
    
    BV = [];
    BV3 = [];
    mag = [];
    me = [];
    av2=[];
    Nmin = 50;
    
    bv2 = [];
    bv3 = [] ;
    me = [];

    sdlg.prompt='Number of events in each window';sdlg.value=150
    sdlg(2).prompt='Overlap factor';sdlg(2).value=5;
    
    [~,~, ni, ofac] = smart_inputdlg('b with depth input parameters',sdlg) 
    
    ButtonName=questdlg('Mc determination?', ...
        ' Question', ...
        'Automatic','Fixed Mc=Mmin','Money');
    
    
    
    for i = 1:ni/ofac:mycat.Count-ni
        
        b = mycat.subset(i:i+ni);
        
        switch ButtonName
            case 'Automatic'
                [Mc, Mc90, Mc95, magco, prf]=mcperc_ca3(b.Magnitude);
                if isnan(Mc95) == 0
                    magco = Mc95;
                elseif isnan(Mc90) == 0
                    magco = Mc90;
                else
                    [bv magco stan av pr] =  bvalca3(b.Magnitude,McAutoEstimate.auto);
                end
            case 'Fixed Mc=Mmin'
                magco = min(b.Magnitude)
        end
        
        l = b.Magnitude >= magco-0.05;
        if sum(l) >= Nmin
            [bv, stan,  av] = calc_bmemag(b.Magnitude(l), 0.1);
        else
            bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
        end
        BV = [BV ; bv min(b.Date) ; bv max(b.Date) ; inf inf];
        BV3 = [BV3 ; bv mean(b.Date) stan ];
        
    end
    
    % Find out if figure already exists
    %
    bdep=findobj('Type','Figure','-and','Name',myFigName);
    
    % Set up the window
    
    if isempty(bdep)
        bdep = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','on');
    end
    figure(bdep);
    delete(find(bdep,'Type','axes'));
    set(gca,'NextPlot','add')
    axis off
    
    rect = [0.15 0.20 0.7 0.65];
    axes('position',rect)
    ple = errorbar(BV3(:,2),BV3(:,1),BV3(:,3),BV3(:,3),'k');
    set(ple(1),'color',[0.5 0.5 0.5]);
    
    set(gca,'NextPlot','add')
    pl = plot(BV(:,2),BV(:,1),'color',[0.5 0.5 0.5]);
    pl = plot(BV3(:,2),BV3(:,1),'sk');
    
    set(pl,'LineWidth',1.0,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','k','Marker','s');
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1,'Ticklength',[ 0.02 0.02])
    
    bax = gca;
    strib = [name ', ni = ' num2str(ni), ', Mmin = ' num2str(min(mycat.Magnitude)) ];
    ylabel('b-value')
    xlabel('Time [years]')
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'Color','k')
    
    xl = get(gca,'Xlim');
end
