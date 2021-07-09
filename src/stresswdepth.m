function stresswdepth() 
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    fs = filesep;
    ZG=ZmapGlobal.Data;
    bv2 = [];
    bv3 = [] ;
    me = [];
    def = {'150'};
    ni2 = inputdlg('Number of events in each window?','Input',1,def);
    l = ni2{:};
    ni = str2double(l);
    [s,is] = sort(ZG.newt2.Depth);
    newt1 = ZG.newt2(is(:,1),:) ;
    
    hodis = fullfile( ZG.hodi, 'external');
    
    cd(hodis);
    
    slfast_cmd = fullfile(ZG.hodis, append_system_specific_postfix('slfast'))
    
    str = 'Inversion data';
    for i = 1:ni/2:length(newt1)-ni
        tmpi = [newt1(i:i+ni,10:12)];
        fid = fopen('data2','w');        
        fprintf(fid,'%s  \n',str);
        fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');        
        fclose(fid);
        
        delete data2.slboot
        
        system([slfast_cmd, ' data2'])
        
        load data2.slboot
        d0 = data2;
        disp([' Now computing depth ' ...
            num2str(mean(newt1(i:i+ni,7))) ' km ']);
        bv2 = [bv2 ; mean(newt1(i:i+ni,7)) d0(2,2:7) d0(1,1) ];
        
    end
    
    
    
    % Find out if figure already exists
    %
    bdep=findobj('Type','Figure','-and','Name','stress-tensor with depth');
    
    
    % Set up the window
    
    if isempty(bdep)
        bdep = figure_w_normalized_uicontrolunits( ...
            'Name','stress-tensor with depth',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','on');
        
        
    end
    
    figure(bdep);
    delete(findobj(bdep,'Type','axes'));
    set(gca,'NextPlot','add')
    axis off
    
    l = bv2(:,2)<0;
    bv2(l,2) = bv2(l,2)+180;
    l = bv2(:,4)<0;
    bv2(l,4) = bv2(l,4)+180;
    l = bv2(:,6)<0;
    bv2(l,6) = bv2(l,6)+180;
    
    rect = [0.15 0.70 0.7 0.25];
    axes('position',rect)
    %pl = plot(bv2(:,1),bv2(:,2),'k');
    
    
    pl1 = plot(bv2(:,1),bv2(:,2),'o');
    set(pl1,'LineWidth',1,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')
    set(gca,'NextPlot','add')
    
    pl2 = plot(bv2(:,1),bv2(:,4),'rs');
    set(pl2,'LineWidth',1,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','r')
    
    pl3 = plot(bv2(:,1),bv2(:,6),'g^');
    set(pl3,'LineWidth',1,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','b')
    
    
    
    set(gca,'Xlim',[floor(min(ZG.newt2.Depth)) max(ZG.newt2.Depth)],'XTicklabel',[]);
    set(gca,'Ylim',[0 180]);
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    
    legend([pl1,pl2,pl3],'S1','S2','S3')
    
    ylabel('Azimuth ')
    
    
    % 2nd axis
    rect = [0.15 0.4 0.7 0.25];
    axes('position',rect)
    
    pl1 = plot(bv2(:,1),bv2(:,3),'o');
    set(pl1,'LineWidth',1,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')
    set(gca,'NextPlot','add')
    
    pl2 = plot(bv2(:,1),bv2(:,5),'rs');
    set(pl2,'LineWidth',1,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','r')
    
    pl3 = plot(bv2(:,1),bv2(:,7),'g^');
    set(pl3,'LineWidth',1,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','b')
    
    set(gca,'Xlim',[floor(min(ZG.newt2.Depth)) max(ZG.newt2.Depth)],'XTicklabel',[]);
    set(gca,'Ylim',[0 90]);
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    ylabel(' Plunge ')
    
    
    
    rect = [0.15 0.10 0.7 0.25];
    axes('position',rect)
    plot(bv2(:,1),bv2(:,8),'k')
    set(gca,'NextPlot','add')
    pl = plot(bv2(:,1),bv2(:,8),'^');
    set(pl,'LineWidth',1,'MarkerSize',7,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')
    
    set(gca,'Xlim',[floor(min(ZG.newt2.Depth)) max(ZG.newt2.Depth) ]);
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    %
    xlabel('Depth  ')
    ylabel('Variance  ')
end
