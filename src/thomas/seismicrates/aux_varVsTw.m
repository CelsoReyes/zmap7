function aux_varVsTw(params, hParentFigure)
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



vTwLength_=[1 1.5 2 2.5 3 3.5 4 4.5 5]
for i = 1:1:length(vTwLength_)
    params(i).fTwLength = vTwLength_(i);
    params(i)=sr_calcZ(params(i))
    % Add parameter to params.sComment
     params(i).sComment = [params(i).rContainer ' Time Cut ' num2str(params(i).fTimeCut) ...
                   ', Time period ' num2str(params(i).fTwLength) ' yrs'];
    if i<length(vTwLength_)
        params=[params;params(1)]
    end
    mVarVsTw_(i,:)=[params(i).fTwLength mean(params(i).mValueGrid(:,1)) mean(params(i).mValueGrid(:,2)) mean(params(i).mValueGrid(:,3)) mean(params(i).mValueGrid(:,4)) mean(params(i).mValueGrid(:,5)) mean(params(i).mValueGrid(:,6)) mean(params(i).mValueGrid(:,7))]
end
gui_result(params(:))
clear fTwLength_ i
