function subclus(var1)
    %subclus.m                            A.Allmann
    %routine for subplots(swarms,dublettes,etc)
    %
    %Last modification 6/95
    global original clus cluslength bgevent  %for bsubclus.m
    global swarmtmp clust backcat equi bg maintmp dubletttmp
    global fontsz par1 file1 clu h5
    global cluscat backequi backbgevent newclcat
    global plot1_h plot2_h

    if ~isempty(backcat)    %reset of parameters
        cluscat=backcat;
        equi=backequi;
        bgevent=backbgevent;
    else                 %first call of this subroutine
        if ~isempty(newclcat)      %specials only for selected area
            backcat=cluscat;
            bgevent=backbgevent;
        else
            backbgevent=bgevent;       %backcopy of original bgevent
            backequi=equi;              %backcopy of original equi
            backcat=cluscat;
        end
        [maintmp swarmtmp,  dubletttmp] =bsubclus;
        equi=backequi;
    end
    if var1==1         %mainshock complete
        if ~isempty(maintmp)
            tmpclust=clust(:,maintmp);
            cluscat=original(tmpclust(find(clust(:,maintmp))),:);

            %reset of parameters for new plots
            equi=equi(maintmp,:);
            bgevent=bgevent(maintmp,:);
            plot1_h=[];plot2_h=[];

            cluoverl(7);
            strib=[' Mainclusters of ' file1];
            title(strib,'FontWeight','bold',...
                'FontSize',fontsz.l,'Color','r')

        else
            var1==6
        end
    elseif var1==2       %foreshocks
        if ~isempty(maintmp)
            tmpclust=clust(:,maintmp);
            for i=1:length(tmpclust(1,:))
                tm1=find(tmpclust(:,i)>=bg(maintmp(i)));
                tmpclust(tm1,i)=zeros(size(tm1));
            end
            tm2=find(tmpclust(find(clust(:,maintmp))));
            if isempty(tm2)
                disp('There are no foreshocks related to this earthquake sequences.Program goes back to general Cluster Menu')

            else
                cluscat=original(tm2,:);

                %reset of parameters for new plots
                equi=equi(maintmp,:);
                bgevent=bgevent(maintmp,:);
                plot1_h=[];plot2_h=[];

                cluoverl(7);
                strib=[' Foreshocks of ' file1];
                title(strib,'FontWeight','bold',...
                    'FontSize',fontsz.l,'Color','r')
            end
        else
            var1==6;
        end

    elseif var1==3         %aftershocks
        if ~isempty(maintmp)
            tmpclust=clust(:,maintmp);
            for i=1:length(tmpclust(1,:))
                tm1=find(tmpclust(:,i)<=bg(maintmp(i)));
                tmpclust(tm1,i)=zeros(size(tm1));
            end
            tm2=find(tmpclust(find(clust(:,maintmp))));

            if isempty(tm2)
                disp('There are no aftershocks related to this earthquake sequences.Program goes back to general Cluster Menu')

            else
                cluscat=original(tm2,:);

                %reset of parameters for new plots
                equi=equi(maintmp,:);
                bgevent=bgevent(maintmp,:);
                plot1_h=[];plot2_h=[];

                cluoverl(7);
                strib=[' Aftershocks  of ' file1];
                title(strib,'FontWeight','bold',...
                    'FontSize',fontsz.l,'Color','r')
            end
        else
            var1==6;
        end

    elseif var1==4           %swarms
        if ~isempty(swarmtmp)
            tmpclust=clust(:,swarmtmp);
            cluscat=original(tmpclust(find(clust(:,swarmtmp))),:);

            %reset of parameters for new plots
            equi=equi(swarmtmp,:);
            bgevent=bgevent(swarmtmp,:);
            plot1_h=[];plot2_h=[];

            cluoverl(7);
            strib=[' Swarms of ' file1];
            title(strib,'FontWeight','bold',...
                'FontSize',fontsz.l,'Color','r')
            hold on
        else
            var1==6;
        end
    elseif var1==5
        if ~isempty(dubletttmp)
            tmpclust=clust(:,dubletttmp);
            cluscat=original(tmpclust(find(clust(:,dubletttmp))),:);

            %reset of parameters for new plots
            equi=equi(dubletttmp,:);
            bgevent=bgevent(dubletttmp,:);
            plot1_h=[];plot2_h=[];

            cluoverl(7);
            strib=[' Dubletts of  ' file1];
            hold on
            title(strib,'FontWeight','bold',...
                'FontSize',fontsz.l,'Color','r')
        else
            var1==6;
        end
    end
    if var1==6
        disp('There is no cluster fitting the selected special type(main,swarm,etc.)');
    end
