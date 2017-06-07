function aux_movingwindow(params, hParentFigure)
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

fStartTime_ = params(1).fStartTime;
fTimeCut_   = params(1).fTimeCut;
vTimeCut_=[params(1).fStartTime+params(1).fTwLength:1:params(1).fTimeCut]
for i = 1:1:length(vTimeCut_)
    params(i).fTimeCut = vTimeCut_(i);
    params(i)=sr_calcZ(params(i))
    % Add parameter to params.sComment
     params(i).sComment = [params(i).rContainer ' Time Cut ' num2str(params(i).fTimeCut) ...
                   ', Time period ' num2str(params(i).fTwLength) ' yrs'];
    if i<length(vTimeCut_)
        params=[params;params(1)]
    end
end
gui_result(params(:))
clear fStartTime_ fTimeCut_ vTimeCut_ i
