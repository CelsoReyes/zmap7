function stresswtime(mycat)
    % stresswtime Calculates stress tensor inversion using the approach by Michael (1987)
    % stresswtime(catalog)

    dirbase= ZmapGlobal.Data.hodi;
    report_this_filefun();
    
    mResStress = [];
    sdlg.prompt='Number of events in window'; sdlg.value=50;
    sdlg(2).prompt='Step size'; sdlg(2).value=10;
    [~,~,ni,nStep] = smart_inputdlg('Window specifications', sdlg);
    
    % Path
    sPath = pwd;
    % Path to stress tensor inversion program
    hodis = fullfile(dirbase, 'external');
    fs=filesep;
    % Select  fault plane solution
    tmpi = [mycat.Dip , mycat.DipDirection , mycat.Rake]; % was columns 10-12, perhaps.
    
    cd(hodis);
    
    
    
    for i = 1:nStep:mycat.Count-ni
        % Check for data in catalog
        nCnt = i+ni;
        if nCnt < mycat.Count-1
            tmpi = [mycat.Dip(i:i+ni) , mycat.DipDirection(i:i+ni) , mycat.Rake(i:i+ni)]; % was columns 10-12, perhaps.
            fMeanTime = mean(mycat.Date(i:i+ni));
        else
            tmpi = [mycat.Dip(i:end) , mycat.DipDirection(i:end) , mycat.Rake(i:end)]; % was columns 10-12, perhaps.
            fMeanTime = mean(mycat.Date(i:end));
        end
        % Create data file for inversion
        fid = fopen('data2','w');
        str = ['Inversion data'];str = str';
        fprintf(fid,'%s  \n',str');
        fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');
        fclose(fid);
        
        % slick calculates the best solution for the stress tensor according to
        % Michael(1987): creates data2.oput
        switch(computer)
            case 'GLNX86'
                unix(['"' dirbase fs 'external/slick_linux" data2 ']);
            case 'MAC'
                unix(['"' dirbase fs 'external/slick_macppc" data2 ']);
            case 'MACI'
                unix(['"' dirbase fs 'external/slick_maci" data2 ']);
            case 'MACI64'
                unix(['"' dirbase fs 'external/slick_maci" data2 ']);
            otherwise
                dos(['"' dirbase fs 'external\slick.exe" data2 ']);
        end
        % Get data from data2.oput
        sFilename = ['data2.oput'];
        [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename);
        
        % Remove eventually existing output
        delete data2.slboot
        % Calculate the stress tensor
        %unix([hodi fs 'external/slfast data2 ']);
        switch(computer)
            case 'GLNX86'
                unix(['"' dirbase fs 'external/slfast_linux" data2 ']);
            case 'MAC'
                unix(['"' dirbase fs 'external/slfast_macpcc" data2 ']);
            case 'MACI'
                unix(['"' dirbase fs 'external/slfast_maci" data2 ']);
            case 'MACI64'
                unix(['"' dirbase fs 'external/slfast_maci" data2 ']);
            otherwise
                dos(['"' dirbase fs 'external\slfast.exe" data2 ']);
        end
        
        load data2.slboot
        d0 = data2;
        disp([' Time step :' num2str(fMeanTime)]);
        
        mResStress = [mResStress ; fMeanTime d0(2,2:7) d0(1,1) fBeta fStdBeta fTauFit];
        
    end
    
    % Back to original directory
    cd(sPath);
    
    % Find out if figure already exists
    %
    bdep=findobj('Type','Figure','-and','Name','stress-value with time');
    
    % Set up the window
    
    % Plot time series of Variance
    figure
    hPlerr = plot(mResStress(:,1),mResStress(:,8),'^');
    set(hPlerr,'LineWidth',1.5,'Linestyle','-','MarkerSize',6,'Color',[0 0 0])
    set(gca,'box','on','SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.5)
    xlabel('Time [dec. year]');
    ylabel('Variance')
    
    
    % Plot time series of Beta
    figure
    %hPlerr = errorbar(mResStress(:,1),mResStress(:,9),mResStress(:,10));
    hPlerr = plot(mResStress(:,1),mResStress(:,9),'d');
    set(hPlerr,'LineWidth',1.5,'Linestyle','--','MarkerSize',6,'Color',[0 0 0])
    set(gca,'box','on','SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.5)
    xlabel('Time [dec. year]');
    ylabel('\beta [deg]')
    fBetamean = nanmean(mResStress(:,9))
    fBetastd = nanmean(mResStress(:,10))
end
