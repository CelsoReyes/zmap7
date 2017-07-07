function aux_varwindow(params, hParentFigure)
% function aux_FMD(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% Thomas van Stiphout, thomas@sed.ethz.ch
% last update: 7.9.2005


report_this_filefun(mfilename('fullpath'));



vTwLength_=[1 2 3 4]
for i = 1:1:length(vTwLength_)
    params(i).fTwLength = vTwLength_(i);
    params(i)=sr_calcZ(params(i))
    % Add parameter to params.sComment
     params(i).sComment = [params(i).rContainer ' Time Cut ' num2str(params(i).fTimeCut) ...
                   ', Time period ' num2str(params(i).fTwLength) ' yrs'];
    if i<length(vTwLength_)
        params=[params;params(1)]
    end
end
gui_result(params(:))
clear fTwLength_ i
