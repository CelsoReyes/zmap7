function comp2cat() 
    % This file finds identical events in two catalogs, and
    % compares the locations and magnitudes etc.
    % turned into function by Celso G Reyes 2017
    
    % Stefan wiemer 02/99
    
    report_this_filefun();
    % ZG=ZmapGlobal.Data;
    
    butt =    questdlg('This file finds identical events in two catalogs. please load both catalogs in mat format. Press help for HTML documentation', ...
        'Compare two catalogs', ...
        'OK','Cancel','Cancel');
    
    switch butt
        case 'OK'
            nie = my_loadcatalog('First');
            if isempty(nie)
                return;
            end
            jm = my_loadcatalog('Second');
            if isempty(jm)
                return;
            end
            compare();
       
        case 'Cancel'
            return
            
    end %swith butt
    
    function compare()
        % find identical events
        dimax=50;         % km
        timax=minutes(2); % a duration
        
        %% ask user for parameters
        
        sdlg.prompt='Maximum distance of events in km';sdlg.value=dlmax;
        sdlg(2).prompt= 'Maximum Time Seperation in Minutes';sdlg(2).value=timax;
        [~,~,dimax, timax]=smart_inputdlg('Input parameters: Identical events',sdlg);
        id = [];
        
        %% do the comparison
        for i = 1:jm.Count
            dt = abs(nie.Date - jm.Date(i));
            xa0 = jm.Longitude(i);     
            ya0 = jm.Latitude(i);
            di = sqrt(((nie.Longitude-xa0)*cosd(ya0)*111).^2 + ((nie.Latitude-ya0)*111).^2);
            f = find(dt <= timax & di <= dimax);
            if rem(i,100) == 0
                disp([' Percent completed: '  num2str(i/length(jm)*100)]) ; 
            end
            if length(f) == 1
                id = [id ;  i f ] ; %#ok<AGROW>
            end
        end
        
        plot_results(id(:,1), id(:,2));
        
    end
    
    function plot_results(f1_idx, f2_idx)
        uj = jm;
        todel=f1_idx;
        idx=1:uj.Count;
        idx(todel)=[];
        uj=uj.subset(idx); % unique events in file1
        
        un = nie;
        todel=f2_idx;
        idx=1:un.Count;
        idx(todel)=[];
        un=un.subset(idx); % unique events in file2
        
        ij = jm.subset(f1_idx); %duplicate events in file1
        in = nie.subset(f2_idx); %duplicate events in file2
        
        fprintf('Number of events unique in %s: %d\n', file1, un.Count);
        fprintf('Number of events unique in %s: %d\n', file2, uj.Count);
        fprintf('Number of  identical events: %d\n', in.Count);
        
        fig=figure('pos',[100 100 900 700]);
        
        
        %% plot UL axis [Dates]
        ax=subplot(fig,2,2,1);
        tmin = floor(min([nie.Date ; jm.Date])) ;
        tmax = ceil(max([nie.Date ; jm.Date])) ;
        
        bins= tmin:days(0.02):tmax;
        [h1, ~]  = histogram(nie.Date,bins);
        [h2, ~]  = histogram(jm.Date,bins);
        [h3, ~]  = histogram(uj.Date,bins);
        [h4, t1]  = histogram(un.Date,bins);
        
        
        p1 = plot(ax,t1,h1,'b','LineWidth',2,'DisplayName',file1);  
        set(gca,'NextPlot','add')
        p2 = plot(ax,t1,h2,'r','LineWidth',2,'DisplayName',file2);
        p3 = plot(ax,t1,h3,'g-.','LineWidth',2,'DisplayName',['Unique in ' file1]);
        p4 = plot(ax,t1,h4,'k-.','LineWidth',2,'DisplayName',['Unique in ' file2]);
        
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,...
            'FontWeight','normal',...
            'FontWeight','bold',...
            'LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out','Xlim',[tmin tmax])
        
        le2 = legend(ax,[p1, p2, p3 , p4 ],file1,file2,['Unique in ' file1 ],['Unique in ' file2]);
        set(le2,'FontSize',4);
        xlabel(ax,'Time [yrs]')
        ylabel(ax,'Number of detected events');
        
        %% plot UR axis [magnitude differences]
        tmax = max(jm.Date(f1_idx));
        Times=tmin:0.1:tmax;
        blank=nan(size(Times(:)));
        dmt=struct('Time',NaT(size(Times(:))),'Mean',blank,'Var',blank,'Length',blank);
        %dmt = nan(numel(Times),4);
        for n =1:numel(Times)
            t=Times(n);
            l = t <= ij.Date & ij.Date < t+3 ;
            dm = jm.Magnitude(f1_idx(l)) - nie.Magnitude(f2_idx(l));
            dmt.Time(n)=t;
            dmt.Mean(n)=mean(dm);
            dmt.Var(n)=var(dm); %unused
            dmt.Length(n)=length(dm); %unused
        end
        
        ax=subplot(2,2,2);
        errorbar(ax,dmt.Time,dmt.Mean,dmt.Var);
        set(gca,'NextPlot','add')
        plot(ax,dmt.Time,dmt.Mean,'rs','LineWidth',2.0);
        plot(ax,dmt.Time,dmt.Mean,'k','LineWidth',2.0);
        
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel(ax,'Time [years]')
        ylabel(ax,[ 'M(' file2 ') - M(' file1 ')']);
        
        
        %% Magnitude vs Magnitude plot with trend
        
        [p,~] = polyfit(ij.Magnitude,in.Magnitude,1);
        
        Xs= 0:0.1:7; % used for polyval
        mb2 = polyval(p,Xs);
        
        r = corrcoef(in.Magnitude,ij.Magnitude);
        r = r(1,2);
        
        stri = [ 'p = ' num2str(p(1)) '*m +' num2str(p(2))  ];
        stri2 = [ 'r = ' num2str(r) ];
        
        ax=subplot(2,2,3);
        plot(ax,jm.Magnitude(f1_idx),nie.Magnitude(f2_idx),'^')
        ax.NextPlot='add';
        t = 0:0.1:6;
        plot(ax,t,t,'r','LineWidth',2);
        
        text(1,5.8,stri,'FontSize',12,'FontWeight','bold')
        text(1,5.4,stri2,'FontSize',12,'FontWeight','bold')
        
        plot(ax,Xs,mb2,'k','LineWidth',2)
        
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        axis(ax,[ 0 6 0 6.5])
        
        xlabel(ax,[file2 ' Magnitudes'])
        ylabel(ax,[file1 ' Magnitudes'])
        grid(ax,'on');
        
        %%
        ax=subplot(2,2,4);
        dm = jm.Magnitude(f1_idx) - nie.Magnitude(f2_idx);
        histogram(ax,dm,(-1.8:0.1:1.8));
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel(ax,[ 'M(' file2 ') - M(' file1 ')']);
        stri = ['Mean: ' num2str(mean(dm),2) ];
        yl = max(get(ax,'Ylim'));
        text(ax,-0.4,yl*0.95,stri,'FontSize',12,'FontWeight','bold');
        stri = ['STD: ' num2str(std(dm),2) ];
        text(-0.4,yl*0.9,stri,'FontSize',12,'FontWeight','bold');
        orient landscape
        
        %%
        % WITH NEW FIGURE
        figure('pos',[100 100 1100 600])
        xa0 = jm.Longitude(f1_idx);
        xb0 = nie.Longitude(f2_idx);
        ya0 = jm.Latitude(f1_idx);
        yb0 = nie.Latitude(f2_idx);
        %unused   za0 = jm.Depth(f1_idx);
        %unused   zb0 = nie.Depth(f2_idx);
        %unused!?!   di = sqrt(((xb0 -xa0)*cosd(36)*111).^2 + ((yb0-ya0)*111).^2);
        
        ax=axes;
        p2 = plot(ax,xa0,ya0,'or');
        set(gca,'NextPlot','add')
        p1 = plot(ax,xb0,yb0,'^b');
        p3 = plot(ax,un.Longitude,un.Latitude,'sg');
        p4 = plot(ax,uj.Longitude,uj.Latitude,'rx');
        
        zmap_update_displays();
        
        vX=inf(length(xa0)*3,1); % all inf should probably be NaN
        vY=inf(length(xa0)*3,1);
        for i = 1:length(xa0)
            vX(i*3-2 : i*3) = [xa0(i);xb0(i);inf];
            vY(i*3-2 : i*3) = [ya0(i);yb0(i);inf];
            
        end
        
        plot(ax,vX,vY,'k');
        
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel('Longitude');
        ylabel('Latitude');
        
        le2 = legend([p1, p2, p3 , p4 ],['Ident. in ' file1 ],['Ident. in ' file2],['Unique in ' file1 ],['Unique in ' file2], 'location', 'NorthEastOutside');
        set(le2,'FontSize',4);
        
        %% evaluate depth dependecy
        % WITH NEW FIGURE
        fig=figure('pos',[100 100 900 700]);
        ax=subplot(fig,2,2,1);
        
        plot(ax,jm.Depth(f1_idx),nie.Depth(f2_idx),'^')
        set(gca,'NextPlot','add')
        maxde = ceil(max([jm.Depth(f1_idx) ; nie.Depth(f2_idx)]));
        t = (0:1:maxde);
        plot(ax,t,t,'r','LineWidth',2)
        
        [p,~] = polyfit(jm.Depth(f1_idx),nie.Depth(f2_idx),1);
        
        set(gca,'NextPlot','add')
        r = corrcoef(jm.Depth(f1_idx),nie.Depth(f2_idx));
        r = r(1,2);
        stri = [ 'p = ' num2str(p(1)) '*m +' num2str(p(2))  ];
        stri2 = [ 'r = ' num2str(r) ];
        text(1,58,stri,'FontSize',12,'FontWeight','bold');
        text(1,54,stri2,'FontSize',12,'FontWeight','bold');
        mb2 = polyval(p,0:1:maxde);
        plot(ax,0:1:maxde,mb2,'k','LineWidth',2)
        
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel(ax,[ file2 ' depth in [km]' ])
        ylabel(ax,[ file1 ' depth in [km]']);
        grid
        
        %% Delta depth Depth histogram
        ax=subplot(2,2,2);
        de = jm.Depth(f1_idx) - nie.Depth(f2_idx);
        histogram(ax,de,(-50.:1:50.))
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel(ax,[file2 ' - ' file1 ' depth in [km]'])
        stri = ['Mean: ' num2str(mean(de),2) ];
        text(ax,-25,80,stri,'FontSize',12,'FontWeight','bold')
        stri = ['STD: ' num2str(std(de),2) ];
        text(ax,-25,70,stri,'FontSize',12,'FontWeight','bold')
        
        %%
        Times=tmin:years(0.5):tmax;
        dmt=struct('tplus1',nan(numel(Times),1),...
            'Mean',nan(numel(Times),1),...
            'Std',nan(numel(Times),1));
        
        for n = 1:numel(Times)
            t=Times(n);
            l = t <= ij.Date & ij.Date < t+2 ;
            warning('is this supposed to be depth? we''re mostly dealing with time...'); %FIXME maybe
            dm = jm.Depth(f1_idx(l)) - nie.Depth(f2_idx(l)); 
            dmt.tplus1(n)=t+years(1);
            dmt.Mean(n)=mean(dm);
            dmt.Std(n)=std(dm);
        end
        
        ax=subplot(2,2,3);
        errorbar(ax,dmt.tplus1,dmt.Mean,dmt.Std);
        hold(ax,'on')
        plot(ax,dmt.tplus1,dmt.Mean,'rs','LineWidth',2.0);
        plot(ax,dmt.tplus1,dmt.Mean,'k','LineWidth',2.0);
        
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel(ax,'Time [years]')
        ylabel(ax,'Delta(D)')
        
        %%
        Depths=0:1:maxde;
        dmt=struct('dplus5',nan(numel(Depths),1),...
            'Mean',nan(numel(Depths),1),...
            'Std',nan(numel(Depths),1));
      
        for n = 1:numel(Depths)
            d=Depths(n);
            l = d <= ij.Depth & ij.Depth < d+10 & ij.Date > maxde-10 ;
            dm = jm.Depth(f1_idx(l)) - nie.Depth(f2_idx(l));
            dmt.dplus5(n)=d+5;
            dmt.Mean(n)=mean(dm);
            dmt.Std(n)=std(dm);
        end
        
        ax=subplot(2,2,4);
        errorbar(ax,dmt.dplus5,dmt.Mean,dmt.Std);
        hold(ax,'on')
        plot(ax,dmt.dplus5,dmt.Mean,'rs','LineWidth',2.0);
        plot(ax,dmt.dplus5,dmt.Mean,'k','LineWidth',2.0);
        
        set(ax,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel(ax,'Depth [km]')
        ylabel(ax,[file2 ' - ' file1 ' depth in [km]'])
        
        
    end % switch
    
    
    
end


function outcat = my_loadcatalog(desc)            %% load first catalog
    outcat=ZmapCatalog();
    [file1,path1] = uigetfile( '*.mat',[desc, ' catalog in *.mat format']);
    if isempty(file1)
        warningdlg('Cancelled');
        return;
    end
    tmp=load(fullfile(path1,file1),'a'); % assume catalog in variable a
    assert(isfield('a','tmp'),'file does not contain expected variable name');
    if ~isa(tmp.primeCatalog,'ZmapCatalog')
        outcat=ZmapCatalog(tmp.primeCatalog);
    else
        outcat=tmp.primeCatalog;
    end
end