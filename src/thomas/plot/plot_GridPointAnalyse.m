function plot_GridPointAnalyse(params,nMode,nPlot)
% Example : plot_GridPointAnalyse(params,0,2)
% function to analyse grid points and plots distribution of rate change
% values
%
% Input
% params    : Input matrix with result
% nMode     : calculate gridpoint from synthetic PSQ (0) or ask for grid
%               point (1)
% nPlot     : plots Z (1), sigma(Z) (2), beta (3), sigma(beta) (4)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vIn,vBnd] = inpoly(params.mPolygon,params.mPSQ);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  controlling inpoly
figure;
plot(params.mPolygon(:,1),params.mPolygon(:,2),'.');
hold on;plot(params.mPSQ(:,1),params.mPSQ(:,2),'r')
hold on;plot(params.mPolygon(vIn,1),params.mPolygon(vIn,2),'ro')
hold on;plot(params.mPolygon(vBnd,1),params.mPolygon(vBnd,2),'ko')
%%


switch nPlot
    case 1
        mPlot=squeeze(params.mResult1(:,1,:));
    case 2
        mPlot=calc_ProbColorbar2Value(squeeze(params.mResult2(:,1,:)));
    case 3
        mPlot=squeeze(params.mResult3(:,1,:));
    case 4
        mPlot=calc_ProbColorbar2Value(squeeze(params.mResult4(:,1,:)));
end

mPlot=mPlot(vIn,:);
mPlot=reshape(mPlot,size(mPlot,1)*size(mPlot,2),1);
figure;
[n,xout] = hist(mPlot(~isinf(mPlot)));
plot(xout,n,'r');

