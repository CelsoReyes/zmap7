function info2(var1)
    %clinfo.m                        A.Allmann 6/95
    %function to make an info window for various routines
    %
    global cinfo p1


    if var1==1               %first call in P-Value window

        % This is the info window text
        %
        ttlStr='The p-value Window                                 ';

        hlpStr1=...
            ['The minimum magnitude is the smallest magnitude              '
            'in the catalog. It is suggested to choose the magnitude      '
            'of completness as the minimum. The time shown in the         '
            'green fields is yourchoice by mouse. You can change all      '
            ' parameters or hit Go  to  continue                          '
            'You have the choice of a new Info window after the next step '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==2          %second call in P-Value window
        ttlStr='The p-value Window                                 ';

        hlpStr1=...
            ['The P-Value and the two constants c and k, are from       '
            ' the modified Omori Law n(t)=k/(t+c)^-p.                  '
            ' N(t) is the integration of this equation. A and B are    '
            ' the values out of the Gutenberg/Richter relationship,    '
            'based on the constant k. The chosen parameters for time   '
            ' and magnitude are shown inside the cumulative number plot'];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==3          %call in cluster window
        ttlStr='The cluster Window                                 ';


        hlpStr1=...
            ['Aftershocks are displayed in red color,foreshocks in blue.    '
            ' The pink cross is  the location of the biggest eq in the     '
            'selected sequence. The After and Fore Buttons allow the       '
            'choice of working  only on the respective eq-type.This choice '
            ' must be done before area selections and cuts.Otherwise       '
            'follows no reaction of the program.Area selections or cuts    '
            'can be made at any time. The selected eqs are displayed       '
            'in the respective area. All functions work on the actual      '
            'catalog. Hit Back to get your original Cluster window.        '
            'To go back to Cluster Menu, hit Quit.                         '];

        zmaphelp(ttlStr,hlpStr1)


    elseif var1==4             %call in cumulative number window
        ttlStr='The cumulative Number  Window                         ';



        hlpStr1=...
            ['This window shows the cumulative number of eqs versus time    '
            'It works allways on the actual catalog of the window where you'
            ' called the function. You have the choice of some statistical '
            'measurements. The AS-function calculates the z-value based on '
            ' as(t). The LTA-function calculates the z-value based on the  '
            'comparison of a sliding window with fixed length  to the rest '
            'of the graph. Back shows the original cumulative window       '
            'without the function of the z-value Close removes the window. '];
        zmaphelp(ttlStr,hlpStr1)


    elseif var1==5            %Call out of LTA from Cumulative number
        ttlStr='                          ';



        hlpStr1=...
            ['This window displays the cumulative number of eqs versus  '
            'time and the LTA-function to recognize rate changes. The   '
            'green field shows the time length of the sliding window in '
            'years.You can change this value through input in this      '
            'window or by using the arrows above. The program sets the  '
            'value back after your choice, if it exeeds a lower or upper'
            'threshold. Back returns to the original cumulative number  '
            'plot. Close removes the window.                            '];

    elseif var1==6            %call from main Cluster Menu

        str=['Map window of clusters.Select offers you the choice of area  selections.Cuts defines catalogs related to eqs which fullfill  special requirements. All selections are based on the equivalent events.If this event is chosen, than the whole cluster related with it is chosen. SPECIAL selects different cluster-typs(Swarms,etc).Main stands for normal fore +aftershock sequences.With Single do you select a single cluster whose equivalent event is next to your position input or has the chosen clusternumber.This also leads you to a toolbox for the examination of this sequence. Hist, Tools and Display are self explaining. The buttons Clus,Equi and Big are for the Display of all eqs(blue dot),equivalent events (green crosses) and biggest events of a  cluster(pink crosses) respective.'];

    elseif var1==7              %call from histogram

        str=[' Histogram of parameter you chose before. If the call comes from CLUSTER MENU,the histogram is displayed for only  one event per cluster(equivalent),or a cluster value(foreshock percentage).Call from single cluster works with actual catalog for this cluster. Display gives you the option of several output formats. Default is display with 10 bins,that is the output you get automatically. Bin Number makes an input window for the number of bins you want (Integer Number). Bin Vector creates a input window for a vector.This vector should look like  0:1:10  .Like the example in Matlab Reference Guide. After data input hit GO.'];

    elseif var1==8              %call from b-value plot

        str=['Evaluation of the b-value. Choose magnitude 1 as the smaller magnitude at the beginning of the slope and magnitude 2 at the end of the constant part of the downslope.The respective magnitude will be displayed in the plot.The blue line that appears is the best fit to the curve, and the negative slope of it is the b-value that will be shown below  the graph with its standard deviation.'];

    elseif var1==9

        str=['The declustering is based on an algorithm by Raesenberg(1985) The dependent and independent seismicity is seperated. The parameters which you can adjust'
            ' are described in Raesenbergs paper. Taumin,Taumax are the look-ahead times and '
            'Rfact is the factor for the fracture zone to calculate the interaction zone. Rfact is the same as Q in Raesenbergs paper.XMEFF is the effective lower magnitude cutoff for catalog,it is raised by a factor Xk*(Magnitude of biggest event) during clusters. This default values are for empirical values for California. You have to be careful if you use this program in a different environment like subduction zones.There are some parameters inside the code like a threshold for the interaction zone to the crustal thickness which migth be different in other areas.So be aware that it is not the universal solution for every area and you may have to play around with the parameters until your satisfied with the output.I recommend to look at cumulative number plots after the declustering,to get a first impression how the declustering worked'];
    end
    te=text(0.05, 0.9 , str);
    set(te,'FontSize',14);
    set(cinfo,'visible','on');
