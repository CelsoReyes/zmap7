report_this_filefun(mfilename('fullpath'));
load /home/guy/thesis/s_wave/data/figures/maps/europe_cil.mat
coastline = [euro_cil_lon  euro_cil_lat   ];
clear  euro_cil_lat  euro_cil_lon
figure_w_normalized_uicontrolunits(map)
overlay_
