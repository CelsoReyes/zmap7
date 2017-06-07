function plot_parvar2(params,nMode,vN,vTw,vTbin,fFix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: plot_parvar2(params, 1,params.vN,params.vTw, params.vTbin,100)
% plot_parvar2(params, 1,params.vN,params.vTw, params.vTbin,100)
%
% This function plots z, beta, and the probability of them as a function of
% input parameter like sampling size, window length and bin size. For each
% plot different graphs are plotted for a second, varying parameter while
% the third is kept fixed.
%
% Input:
% params        structural array from
% nMode         parameter to plot z, beta, prob's against. Each parameter
%               can be plotted with the one of the other two. Choose
%                      1 : vN for different vTw
%                      2 : vN for different vTbin
%                      3 : vTw for different vN
%                      4 : vTw for different vTbin
%                      5 : vTbin for different vN
%                      6 : vTbin for different vTw
% vN            Vector with range of sample sizes
% vTw           Vector with range of window length
% vTbin         Vector with range of bin size
% fFix          Fixed value for remaining parameter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author:
% van Stiphout, Thomas, vanstiphout@sed.ethz.ch
%
% Created on 16.08.2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prepare x-labels, and data for plots
switch nMode
    case 1
        sXLabel='Sampling Volume, N';       vSel=logical(params.mVar(:,3)==fFix);
        params.mVar(vSel,:);
        v1=vN;v2=vTw;n1=1;n2=2;
        sName=sprintf('z(N,Tw) - const. Tbin=%4.1f',fFix);
    case 2
        sXLabel='Sampling Volume, N';
        vSel=logical(params.mVar(:,2)==fFix);
        params.mVar(vSel,:);
        v1=vN;v2=vTbin;n1=1;n2=3;
        sName=sprintf('z(N,Tbin) - const. Tw=%4.1f',fFix);
    case 3
        sXLabel='Window Length, Tw';
        vSel=logical(params.mVar(:,3)==fFix);
        params.mVar(vSel,:);
        v1=vTw;v2=vN;n1=2;n2=1;
        sName=sprintf('z(Tw,N) - const. Tbin=%4.1f',fFix);
    case 4
        sXLabel='Window Length, Tw';
        vSel=logical(params.mVar(:,1) == fFix);
        params.mVar(vSel,:);
        v1=vTw;v2=vTbin;n1=2;n2=3;
        sName=sprintf('z(Tw,Tbin) - const. N=%4.1f',fFix);
    case 5
        sXLabel='Bin Size, Tbin';
        vSel= logical(params.mVar(:,2) == fFix);
        params.mVar(vSel,:);
        v1=vTbin;v2=vN;n1=3;n2=1;
        sName=sprintf('z(Tbin,N) - const. Tw=%4.1f',fFix);
    case 6
        sXLabel='Bin Size, Tbin';
        vSel= logical(params.mVar(:,1)==fFix);
        params.mVar(vSel,:);
        v1=vTbin;v2=vTw;n1=3;n2=2;
        sName=sprintf('z(Tbin,Tw) - const. N=%4.1f',fFix);
end

% prepare color matrix for plotting different graphs
mColor=repmat([0:0.8/size(v2,1):0.8]',1,3);

% plotit
figure_w_normalized_uicontrolunits('Position',[100 25 750 600],...
    'Name',sName);
% plot z(lta)
for nSubplot=1:4
    for j=1:size(v2,1)
        subplot(2,2,nSubplot);
        hold on;
        vSubSel=logical(vSel.*(params.mVar(:,n2)==v2(j)));
        Y=mean(squeeze(params.mResult_(:,nSubplot,vSubSel)));
        plot(v1,Y,'Color',mColor(j,:),'LineWidth',2);
    end
    legend(num2str(v2),'location','EastOutside');
    xlabel(sXLabel)
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
end
