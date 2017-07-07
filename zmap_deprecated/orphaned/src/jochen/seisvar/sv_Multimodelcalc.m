function [params] = sv_Mulitmodelcalc(sDatafile)
% function [params] = sv_Mulitmodelcalc(sDatafile);
% ----------------------------------------------
% Function to calculate multiple models without using GUI of sv-software package
%
% Input variables:
% sDatafile: Includes params all variables from produced with sv_start
%
% Output variables
% params: Input for sv_result
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 03.01.02

% Initialize matrices
result = [];
vResults = [];

load(sDatafile);
% Create Indices to catalog
[params.caNodeIndices] = ex_CreateIndexCatalog(params.mCatalog, params.mPolygon, params.bMap, params.nGriddingMode, ...
    params.nNumberEvents, params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);

fRadius = params.fRadius;
% Perform the calculation
for fRadius = fRadius:10:100
    params.fRadius = fRadius;
    params
    [result] = sv_calc(params);
    vResults = result;
    save(['result_Radius' num2str(params.fRadius) '_km.mat'], 'vResults');
end
