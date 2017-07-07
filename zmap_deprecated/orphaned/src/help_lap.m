helpdlg('SEISMOLAP is no longer supported as a part of ZMAP. Please contact  Prof. J. Zschau , GFZ Potsdam, zschau@gzf-potsdam.de, for information on recent SeismoLap implementations')

report_this_filefun(mfilename('fullpath'));

return

ttlStr='  Introduction to Seismo Lap in ZMAP';
hlpStr= ...
    ['                                                                             '
    ' SeismoLap is a technique develloped by J. Zschau                            '
    ' (Geoforschungzentrum Potsdam, Germany) to measure the relative              '
    ' seismic activity in an area. The space-time overlap of cubical              '
    ' volumes is measured, normalized by the size of the cube (SeismoLap1)        '
    ' The negaite invers of this value Seismolap2 is calculated and the           '
    ' probabilty estimated using a Pearson type 3 distribution.                   '
    '                                                                             '
    ' The ZMAP implementation of SeismoLap offers the following options:          '
    '                                                                             '
    ' One point calculation: SeismoLap1 and the probability can be calculated     '
    '     at one point in space. It is nessesary to define the Input paramters    '
    '     lat/long of the point of interest, box siz, and interaction time.       '
    '  Grid: Both the seismolap 1 and probability values can be calculated        '
    '       using a grid of points. At each grid-point the time series            '
    '       is calcualted and the user can view different time cuts in a color    '
    '       representation. The time series at a user defined point can be viewed '
    '       by selecting the Mouse option. Since it take a while to               '
    '       calculate a grid, it is recommended to save the grid and re-load them '
    '       when desired.                                                         '
    ' Movie: A number of time cuts can be animated as a movie sequence.           '
    '        This movie file can be save and re-loaded.                           '
    '                                                                             '
    ' If   you have problems whith this software, please contact:                 '
    ' Stefan Wiemer                                                               '
    ' Geophysical Institute University of Alaska Fairbanks                        '
    ' Fairbanks, AK, 99775-7320, USA                                              '
    ' phone: 907 474 6171, Fax 907 474 7290                                       '
    ' e-mail stefan@giseis.alaska.edu                                             '
    '                                                                             '
    ' Enjoy!                                                                      '
    ' Stefan Wiemer   September . 95                                              '
    '                                                                             '];

zmaphelp(ttlStr,hlpStr)

