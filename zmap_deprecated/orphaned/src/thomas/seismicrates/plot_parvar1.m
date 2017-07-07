function plot_parvar1(params,nMode,N,Tw,Tbin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: plot_parvar1(params, 2,200,[],100)
%
% This function plots z, beta, and the probability of them as a function of
% input parameter like sampling size, window length and bin size. For each
% plot the other two parameters are kept fixed.
% The plot shows the distribution of values over all the grid point, the
% mean and the error as a standard deviation.
%
% Input
% params        structural array from
% nMode         parameter to plot z, beta, prob's against. Choose
%                      1 : Sampling Volume, N
%                      2 : Window Length, Tw
%                      3 : Bin Size, Tbin
% vN            Vector with range of sample sizes
% vTw           Vector with range of window length
% vTbin         Vector with range of bin size
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author:
% van Stiphout, Thomas, vanstiphout@sed.ethz.ch
%
% Created on 16.08.2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% prepare x-labels and ...
switch nMode
    case 1
        sXLabel='Sampling Volume, N';
        vSel=logical((params.mVar(:,2) == Tw).*(params.mVar(:,3)==Tbin));
        params.mVar(vSel,:)
        sName=sprintf('z(N) - const. Tw=%4.1f Tbin=%4.1f',Tw,Tbin);

    case 2
        sXLabel='Window Length, Tw';
        vSel=logical((params.mVar(:,1) == N).*(params.mVar(:,3)==Tbin));
        params.mVar(vSel,:);
        sName=sprintf('z(Tw) - const. N=%4.1f Tbin=%4.1f',N,Tbin);
    case 3
        sXLabel='Bin Size, Tbin';
        vSel= logical((params.mVar(:,2) == Tw).*(params.mVar(:,1)==N));
        params.mVar(vSel,:);
        sName=sprintf('z(Tbin) - const. N=%4.1f Tw=%4.1f',N,Tw);
end


figure_w_normalized_uicontrolunits('Position',[100 25 750 600],...
    'Name',sName);
% plot z(lta)
for nSubplot=1:4
    subplot(2,2,nSubplot);
    for i=1:size(params.mResult_,1)
        hold on;
        plot(params.mVar(vSel,nMode),squeeze(params.mResult_(i,nSubplot,vSel)), '.','MarkerSize',3);
    end
    xlabel(sXLabel);
    switch nSubplot
        case 1
            title('z(lta)-variation');
            ylabel('z(lta)');
        case 2
            title('p(z)-variation');
            ylabel('p(z)');
        case 3
            title('\beta-variation');
            ylabel('\beta');
        case 4
            title('p(\beta)-variation');
            ylabel('p(\beta)');
    end
    subplot(2,2,nSubplot);
    Y=mean(squeeze(params.mResult_(:,nSubplot,vSel)));
    E=std(squeeze(params.mResult_(:,nSubplot,vSel)));
    errorbar(params.mVar(vSel,nMode),Y,E,'xr','MarkerSize',10,'LineWidth',1);
end
