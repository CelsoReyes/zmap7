function clinfo(var1)
    %clinfo.m                        A.Allmann
    %function to make an info window for various routines
    %
    %
    global cinfo p1


    if var1==1               %first call in P-Value window

        % This is the info window text
        %
        ttlStr='The p-value Window                                 ';

        hlpStr1=...
            ['The minimum magnitude is the smallest magnitude used for the '
            'p-value estimate. All eqs with a smaller magnitude will be   '
            'excluded. Normally you should use the magnitude of complet-  '
            'ness. You can edit all parameters in the green fields.       '
            'The program uses the onset times of your chosen sequence     '
            'relative to a main event. You have three options to choose   '
            'this main event.                                             '
            '1)Mainshock: The biggest event in the catalog used for the   '
            '             estimate. That are all eqs plotted in the cumu- '
            '             lative number curve.                            '
            '2)Main-Input:You will be asked to select the main event by   '
            '             clicking with the LEFT mouse button in the cumu-'
            '             lative number curve.                            '
            '3)Sequence  :The main event is the first event in your chosen'
            '             eq-sequence.                                    '];
        zmaphelp(ttlStr,hlpStr1)

    elseif var1==2          %second call in P-Value window
        ttlStr='The p-value window                                 ';

        hlpStr1=...
            ['The P-Value and the two constants c and k, are calculated '
            ' using the modified Omori Law n(t)=k/(t+c)^-p             '
            ' N(t) is the integration of this equation. A and B are    '
            ' the values out of the Gutenberg/Richter relationship,    '
            ' log(n) = A +b*M                                          '
            'based on the constant k. The selected time and magnituide '
            '  parameter are shown inside the cumulative number plot   '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==3          %call in cluster window
        ttlStr='The cluster window                                 ';


        hlpStr1=...
            ['Aftershocks are displayed in red, foreshocks in blue.         '
            'The pink cross is  the location of the biggest EQ in the      '
            'selected sequence. The After and Fore Buttons allow to        '
            'work only with after or foreshocks. This selection            '
            'must be done before area selections and cuts.                 '
            'Area selections or cuts                                       '
            'can be made at any time. All functions work on the current    '
            'catalog. Hit "Back" to go to the original Cluster window.     '
            'To go back to Cluster Menu, select "Close" from the workspace.'];

        zmaphelp(ttlStr,hlpStr1)


    elseif var1==4             %call in cumulative number window
        ttlStr='The cumulative number  window                         ';

        hlpStr1=...
            ['This window shows the cumulative number of EQs versus time    '
            'It operates on the current catalog of the window where you    '
            'called the function. You have the choice of some statistical  '
            'functions.    The AS-function calculates the z-value based on '
            'as(t). The LTA-function calculates the z-value based on the   '
            'comparison of a sliding window with fixed length  to the rest '
            'of the graph. Back shows the original cumulative window       '
            'without the function of the z-value. Close closes the window. '
            'The option "Timcut" allows you to select a smaller time       '
            'window interactivly with the mouse. After hitting "Timcut"    '
            'you only have to pick to times in the Cumulative Number Plot  '
            'with the LEFT mouse button                                    '];

        zmaphelp(ttlStr,hlpStr1)


    elseif var1==5            %Call out of LTA from Cumulative number
        ttlStr='                          ';



        hlpStr1=...
            ['This window displays the cumulative number of eqs versus   '
            'time and the LTA-function to recognize rate changes. The   '
            'green field shows the time length of the sliding window in '
            'years.You can change this value through input in this      '
            'window or by using the arrows above. The program sets the  '
            'value back after your choice, if it exeeds a lower or upper'
            'threshold. Back returns to the original cumulative number  '
            'plot. Close removes the window.                            '];
        zmaphelp(ttlStr,hlpStr1)


    elseif var1==6            %call from main Cluster Menu

        ttlStr='                          ';


        hlpStr1=...
            ['Map view of clusters. Select offers you the choice of    '
            'area  selections. Cuts allows cuts in magnitude, depth,  '
            'time and number of the cluster.       All selections are '
            'based on the equivalent events.                          '
            'SPECIAL:                                                 '
            'selects different cluster-typs (Swarms,etc). MAIN stands '
            'for normal fore  & aftershock sequences. SINGLE  selects '
            'a single cluster whose equivalent event is closest to the'
            'selected position or the selected  clusternumber.        '
            '                                                         '
            'SINGLE opens a toolbox for the examination of            '
            'this sequence. Hist, Tools and Display are self          '
            'explaining. The buttons Clus, Equi and Big select  the   '
            'display of all EQs (blue dot), equivalent events (green  '
            'crosses) and biggest events of a  cluster (pink crosses) '
            'respectively.                                            '];

        zmaphelp(ttlStr,hlpStr1)


    elseif var1==7              %call from histogram
        ttlStr='                          ';

        hlpStr1=...
            ['Histogram of  the parameter you selected. If the call '
            'comes from CLUSTER MENU, the histogram is displayed   '
            'for one event per cluster (equivalent), or a cluster  '
            'value (foreshock percentage).                         '
            'DISPLAY:                                              '
            'gives you the option of several output formats. The   '
            ' default is a display of 10 bins.                     '
            '                                                      '
            'BIN NUMBER creates an input window for the            '
            'number of bins you want (Integer only). BIN VECTOR    '
            'creates a input window for a vector. (e.g. 0:1:15)    '
            'After data input hit " GO".                           '];
        zmaphelp(ttlStr,hlpStr1)


    elseif var1==8              %call from b-value plot
        ttlStr='                          ';


        hlpStr1=...
            ['b-value evaluation. Choose magnitude one as the        '
            'smaller magnitude at the beginning of the slope and    '
            'magnitude two at the end of the constant part of the   '
            'slope.     The selected magnitude will be displayed    '
            'in the plot. The blue line is the best fit             '
            'to the curve, the slope of this line  is the           '
            'b-value that will be shown printed in the graph with   '
            'standard deviation.                                    '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==9
        ttlStr=' Declustering an earthquake catalog ';



        hlpStr1=...
            ['The declustering is based on an algorithm by Reasenberg        '
            '(1985) which separates the dependent and independent seismicity'
            'The parameters which you can adjust are described in           '
            'Reasenbergs paper. Taumin, Taumax are the look-ahead times and '
            'Rfact is the factor for the fracture zone to calculate the     '
            'interaction zone. Rfact is the same as Q in Raesenbergs paper  '
            'XMEFF is the effective lower magnitude cutoff for the catalog. '
            'It is raised by a factor Xk*(Magnitude of biggest event) during'
            'clusters. The Epicenter-Error and the Depth-Error can  be      '
            'critical for areas with a sparse network.                      '
            'The default values are for empirical values for California.    '
            'There are some hardwired                                       '
            'parameters inside the code like a threshold for the interaction'
            'zone to the crustal thickness which migth be different in other'
            'areas. We recommend to consult                                 '
            'cumulative number plots after the declustering, to evaluate the'
            'performance of the declustering.                               '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==10
        ttlStr=' Unstable P-Value Evaluation ';

        hlpStr1=...
            ['The algorithm was shut down to avoid a segmentation fault     '
            'The program could not find a stable solution for the p-value  '
            'with the specified data points.                               '
            'This might happens if you have a big increase in seismicity   '
            'rate not at the chosen starting point of the algorithm, but a '
            'a few earthquakes later. To avoid that you can use the        '
            'automatic p-value evaluation, that sets the starting point to '
            'the biggest increase in seismicity rate.                      '
            'Another reason for an unstable result migth be, that the      '
            'chosen eathquake sequence does not have enough events to      '
            'calculate a reliable p-value.                                 '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==11
        ttlStr=' Time Selection';

        hlpStr1=...
            ['Select starttime and endtime in the green fields or use the   '
            'option "Mouse".                                               '
            'If you choose "Mouse" you have to click with the LEFT button  '
            'in the cumulative number window at your time intervall of     '
            'interest.                                                     '
            'All earthquakes will be selected which are in a cluster whose '
            'equivalent event is in the chosen time window                 '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==12
        ttlStr=' Time Selection';

        hlpStr1=...
            ['Select the minimum and maximum timedifference relative to the '
            'starttime.                                                    '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==13
        ttlStr=' Seislap ';

        hlpStr1=...
            ['Seislap is based on a method by Jochen Zschau from Potsdam    '
            'It estimates the relative quiesence and plots it as a function'
            'of time                                                       '
            'If the input parameters are adjusted well the resulting curve '
            'should be constant near zero and have anomalies if an eq      '
            'occurs next to your chosen position of interest.              '
            'The input parameters:                                         '
            '   1.) DX in km, specifies the side length of a cube that     '
            '       surrounds each earthqhake. The default is 100km, and   '
            '       can be bigger for stronger eqs.(300km-400km)           '
            '   2.) Overlap time in days, specifies a time window related  '
            '       with each eq. The program calculates the overlap time  '
            '       for every eq with a potential eq as a function of time '
            '       The default is hundred days and can vary with magnitude'
            '   3.) Mmin , is the minimum magnitude of interest.           '
            '       The default is Mmin=3. Mmin can be chosen even up to 4 '
            ' 4+5.) Longitude and lattitude of the position of interest,   '
            '       Position that you are interested to examine the        '
            '       relative quiescence. Default is the position of the    '
            '       biggest event in the chosen catalog                    '
            '   6.) Binlength in days, is the stepsize in days between the '
            '       times you calculate the relative quiescence            '
            '       A short binlength causes longer computation times but  '
            '       more accurate results. The default is 1 day.           ' ];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==14
        ttlStr='Seislap Plot';

        hlpStr1=...
            ['Plot of the relative quiescence for a chosen point of interest.'
            'You can adjust three basic parameters in the green fields and  '
            'than run the program again when you hit "Repeat". The other    '
            'parameters like location and binlength stay the same as your   '
            'original choice in the main input window. If you want to adjust'
            'them also, you have to restart Seismo Lap from the "Seismicity '
            'Map " window.                                                  '
            'If there are no eqs at all in a some space-time windows, the   '
            'relative quiescence would become infinity and is substituted   '
            'by the maximum of the sequence and a warning will be shown in  '
            'your matlab command window. To avoid this case you can raise   '
            'the input parameters to expand your space-time window.         '
            'The black cross shows the location of the biggest event in the '
            'examined sequence.                                             '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==15               %parameter selection map window
        ttlStr='Select parameters';

        hlpStr1=...
            ['The default values in the yellow input fields are the limits   '
            'of the recent catalog.                                         '
            'Give in the parameters of your choice and hit "GO" to extract  '
            'a new catalog.                                                 '
            'If you want to return  to the original catalog you have to hit '
            'the option "Reset catalog" in the main map window.             '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==16               %parameter selection map window
        ttlStr='Misfit Calculation';

        hlpStr1=...
            ['Needed to be fixede yellow input fields are the limits         '
            '  .........                                                    '
            '                      ...............                          '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==17               %input window b with magnitude
        ttlStr='b-value with magnitude';

        hlpStr1=...
            ['This routine calculates the b-value of a given sequence based'
            ' on weighted LS and on the maximum liklelihood method for    '
            ' different minimum magnitude cutoffs and diplays the results '
            ' with its errorbars.                                         '
            ' The default values for the smallest minimum magnitude is set'
            ' to the smallest magnitude in the sequence. The default for  '
            ' the biggest is the largest magnitude minus 1.5 to have a    '
            ' reasonable range for the estimate. The largest magnitude is '
            ' also set as default for the upper magnitude threshold.      '
            ' The difference between upper magnitude threshold and biggest'
            ' minimum magnitude should be at least 1, but higher values   '
            ' are recommended.                                            '
            ' A bigger step size can speed up the program considerable if '
            ' the sequence contains many events and your interest lays in '
            ' a general trend                                             '];

        zmaphelp(ttlStr,hlpStr1)

    elseif var1==18                %input window p-value with magnitude
        ttStr='p-value with magnitude';

        hlpStr1=...
            ['Everything works as in the "info" of the normal p-value esti-'
            'mate. In addition you can input a range for the used minimum '
            'magnitude cutoff.                                            '
            'The range has to be written as a vector in matlab. Input     '
            'first the lowest "minimum magnitude cutoff" of interest,     '
            'followed by a colon, than the step size followed by a colon  '
            'and at the end the largest "minimum magnitude cutoff" which  '
            'should be used for the estimate.                             '
            'The output are plots for p, k and c versus minimum magnitude '
            'The plots should show the smallest p-value errorbars in the  '
            'vicinity of the magnitude of completness. The stability of   '
            'the p-value adjacent to that magnitude gives you some means  '
            ' to judge the reliability of the whole estimate              '];


        zmaphelp(ttlStr,hlpStr1)

    elseif var1==19              %input window p-value with time
        ttlStr='p-value with time';

        hlpStr1=...
            ['Everything works as in the "info" of the normal p-value esti- '
            'mate. In addition you can input a range for the used end time '
            'The range has to be written as a vector in matlab. Input first'];

    end

