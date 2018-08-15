function brand() 
    % brand draws x random samples of size N from the current dataset and computes the b-value
    % sw, last modifies 9/2001
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    ar2 = [];
    arm2 = [];
    br2 = [];
    brm2 = [];
    

    sdlg.prompt='Minimum number of events per sample ?'; sdlg.value=50;
    sdlg(2).prompt='Step width in events ? '; sdlg(2).value=10;
    sdlg(3).prompt='Maximum number of events per sample?'; sdlg(3).value=200;
    sdlg(4).prompt='Number of samples drawn ?'; sdlg(4).value=100;

    [~,~,n1,ns,n2,nr]=smart_inputdlg('Random b-value calculation', sdlg);
    
    %n1 = str2double(prmptdlg('Minimum number of events per sample','50'));
    %ns = str2double(prmptdlg('Step width in events','10'));
    %n2 = str2double(prmptdlg('Maximum number of events per sample','200'));
    %nr = str2double(prmptdlg('Numer of samples drawn ','100'));
    tic
    niv = n1:ns:n2;
    for ni = n1:ns:n2
        ni
        ar = [];
        arm = [];
        br = [];
        brm = [];
        for i = 1:nr
            l = ceil(rand([ni 1])*ZG.primeCatalog.Count);
            %[bv magco stan,  av] =  bvalca3(newa(l,:), McAutoEstimate.manual);
            %br = [br bv];
            %ar = [ar av];
            [bv2 stan av2 ] = calc_bmemag(ZG.primeCatalog.Magnitude(l),0.1);
            brm = [brm bv2];
            arm = [arm av2];
        end
        %br2 = [br2 ; br];
        brm2 = [brm2 ; brm];
        %ar2 = [ar2 ; ar];
        arm2 = [arm2 ; arm];
    end
    
    figure
    pl1 =plot(niv,prctile2(brm2',50),'k')
    set(pl1,'LineWidth',2.0)
    set(gca,'NextPlot','add')
    pl2=plot(niv,prctile2(brm2',95),'r--');
    set(pl2,'LineWidth',1.0,'color',[0.3 0.3 0.3])
    pl3=plot(niv,prctile2(brm2',5),'r-.');
    set(pl3,'LineWidth',1.0,'color',[0.3 0.3 0.3])
    
    legend([pl1 pl2 pl3],'mean','95%','5%');
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    xlabel('Number of eqs')
    ylabel('Range of b-value')
    
    
    
    figure
    
    pl1=plot(niv,prctile2(arm2',50),'k');
    set(pl1,'LineWidth',2.0)
    set(gca,'NextPlot','add')
    pl2=plot(niv,prctile2(arm2',95),'r--');
    set(pl2,'LineWidth',1.0,'color',[0.3 0.3 0.3])
    pl3=plot(niv,prctile2(arm2',5),'r-.');
    set(pl3,'LineWidth',1.0,'color',[0.3 0.3 0.3])
    legend([pl1 pl2 pl3],'mean','95%','5%');
    
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    xlabel('Number of eqs')
    ylabel('Range of a-value')
    grid
    
    
    toc
    %
    return
    
    % experimental code ...
    
    A = [];
    for i = 1:1:99
        i
        A = [A ; niv' prctile2(brm2',i)' niv'*0+i];
    end
    % l = A(:,3)>50; A(l,3) = 100 - A(l,3);
    [ X, Y ] = meshgrid(n1:ns:n2,0.5:0.01:1.5);
    
    Z = griddata(A(:,1),A(:,2),A(:,3),X,Y);
    
    figure
    contourf(X,Y,Z,[1 5 10 50 90 95 99]);
    
    g = gray(6);
    g = g(11:-1:2,:);
    colormap(g);
end
