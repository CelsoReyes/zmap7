function plot_varN1(params,nMode,const)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example: plot_varN1(params, 1,1)
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
%         sXLabel='Sampling Volume, N';
switch nMode
    case 1
        %prepare calculation
        nPos1=1;
        vVariable2=params.vTw; nPos2=2;
        vVariable3=params.vTbin(const); nPos3=3;
        % perform calculation
        calc_plotval
        % prepare plotting
        sXLabel='Sampling Volume, N';
        sName=sprintf('z(N,Tw) - const. Tbin=%4.1f',vVariable3);
        sPrint=sprintf('RatesfN_Tw_const_Tbin-%03.0f.png',vVariable3);
        sPrintErr=sprintf('RatesErrfN_Tw_const_Tbin-%03.0f.png',vVariable3);
        plot_values
    case 2
        %prepare calculation
        nPos1=1;
        vVariable2=params.vTbin;nPos2=3;
        vVariable3=params.vTw(const); nPos3=2;
        % perform calculation
        calc_plotval;
        % prepare plotting
        sXLabel='Sampling Volume, N';
        sName=sprintf('z(N,Tbin) - const. Tw=%4.1f',vVariable3);
        sPrint=sprintf('RatesfN_Tbin_const_Tw-%03.0f.png',vVariable3);
        sPrint=sprintf('RatesErrfN_Tbin_const_Tw-%03.0f.png',vVariable3);
        plot_values;
    case 3
        %prepare calculation
        nPos1=2;
        vVariable2=params.vN;nPos2=1;
        vVariable3=params.vTbin(const); nPos3=3;
        % perform calculation
        calc_plotval;
        % prepare plotting
        sXLabel='Window Length, Tw';
        sName=sprintf('z(Tw,N) - const. Tbin=%4.1f',vVariable3);
        sPrint=sprintf('RatesfTw_N_const_Tbin-%03.0f.png',vVariable3);
        sPrintErr=sprintf('RatesErrfTw_N_const_Tbin-%03.0f.png',vVariable3);
        plot_values;
    case 4
        %prepare calculation
        nPos1=2;
        vVariable2=params.vTbin;nPos2=3;
        vVariable3=params.vN(const); nPos3=1;
        % perform calculation
        calc_plotval;
        % prepare plotting
        sXLabel='Sampling Volume, Tw';
        sName=sprintf('z(Tw,Tbin) - const. N=%4.1f',vVariable3);
        sPrint=sprintf('RatesfTw_Tbin_const_N-%03.0f.png',vVariable3);
        plot_values;
    case 5
        %prepare calculation
        nPos1=3;
        vVariable2=params.vN; nPos2=1;
        vVariable3=params.vTw(const); nPos3=2;
        % perform calculation
        calc_plotval;
        % prepare plotting
        sXLabel='Sampling Volume, Tbin';
        sName=sprintf('z(Tbin,N) - const. Tw=%4.1f',vVariable3);
        sPrint=sprintf('RatesfTbin_N_const_Tw-%03.0f.png',vVariable3);
        plot_values;
    case 6
        %prepare calculation
        nPos1=3;
        vVariable2=params.vTw; nPos2=2;
        vVariable3=params.vN(const); nPos3=1;
        % perform calculation
        calc_plotval;
        % prepare plotting
        sXLabel='Sampling Volume, Tbin';
        sName=sprintf('z(Tbin,Tw) - const. N=%4.1f',vVariable3);
        sPrint=sprintf('RatesfTbin_Tw_const_N-%03.0f.png',vVariable3);
        plot_values;
end  % end switch


    function calc_plotval
        for ii=1:size(vVariable2,1)
            vSel=logical((params.mVar(:,nPos2) == vVariable2(ii)).*(params.mVar(:,nPos3)==vVariable3));
            params.mVar(vSel,:);
            mN.V1=params.mVar(vSel,nPos1);
            for i=1:size(params.mResult_,1)
                mN.V2.Z{ii}(:,i)=squeeze(params.mResult_(i,1,vSel));
                mN.V2.B{ii}(:,i)=squeeze(params.mResult_(i,3,vSel));
                mN.V2.pZ{ii}(:,i)=squeeze(params.mResult_(i,2,vSel));
                mN.V2.pB{ii}(:,i)=squeeze(params.mResult_(i,4,vSel));
            end  % end for i
            mN.V2.Z_mean(:,ii)=mean(mN.V2.Z{ii},2);
            mN.V2.B_mean(:,ii)=mean(mN.V2.B{ii},2);
            mN.V2.pZ_mean(:,ii)=mean(mN.V2.pZ{ii},2);
            mN.V2.pB_mean(:,ii)=mean(mN.V2.pB{ii},2);
            mN.V2.Z_std(:,ii)=std(mN.V2.Z{ii},0,2);
            mN.V2.B_std(:,ii)=std(mN.V2.B{ii},0,2);
            mN.V2.pZ_std(:,ii)=std(mN.V2.pZ{ii},0,2);
            mN.V2.pB_std(:,ii)=std(mN.V2.pB{ii},0,2);
        end % end for ii
    end  % end function calc_plotval

    function plot_values
        figure_w_normalized_uicontrolunits('Position',[0 0 800 900],'Name',sName);
        mPlot{1}.X1=mN.V1
        mPlot{1}.Y1=mN.V2.Z_mean;
        mPlot{1}.Y2=mN.V2.Z_mean-mN.V2.Z_std;
        mPlot{1}.Y3=mN.V2.Z_mean+mN.V2.Z_std;
        mPlot{2}.X1=mN.V1;
        mPlot{2}.Y1=-log10(1-mN.V2.pZ_mean);
        mPlot{2}.Y2=-log10(1-mN.V2.pZ_mean-mN.V2.pZ_std./2);
        mPlot{2}.Y3=-log10(1-mN.V2.pZ_mean+mN.V2.pZ_std./2);
        mPlot{3}.X1=mN.V1;
        mPlot{3}.Y1=mN.V2.B_mean;
        mPlot{3}.Y2=mN.V2.B_mean-mN.V2.B_std;
        mPlot{3}.Y3=mN.V2.B_mean+mN.V2.B_std;
        mPlot{4}.X1=mN.V1;
        mPlot{4}.Y1=-log10(1-mN.V2.pB_mean);
        mPlot{4}.Y2=-log10(1-mN.V2.pB_mean-mN.V2.pB_std./2);
        mPlot{4}.Y3=-log10(1-mN.V2.pB_mean+mN.V2.pB_std./2);
%

        sTitle=[cellstr(char('z(lta)-variation')), cellstr(char('p(Z)-variation')),...
            cellstr(char('\beta-variation')),  cellstr(char('p(\beta)-variation'))];
        sYLabel=[cellstr(char('z(lta)')),cellstr(char('p(Z)')),cellstr(char('\beta')), cellstr(char('p(\beta)'))];

        for pp=1:4
            subplot(2,2,pp);
            hold on;plot(mN.V1,mPlot{pp}.Y1,'--','LineWidth',2)
            hold on;plot(mPlot{pp}.X1,mPlot{pp}.Y1,'x','MarkerSize',12)
            if pp==1  legend(num2str(vVariable2)); end
            if ((pp==1) || (pp==3))
                hold on;plot(mPlot{pp}.X1,mPlot{pp}.Y2  ,':','LineWidth',1)
                hold on;plot(mPlot{pp}.X1,mPlot{pp}.Y2,'+')
                hold on;plot(mPlot{pp}.X1,mPlot{pp}.Y3,':','LineWidth',1)
                hold on;plot(mPlot{pp}.X1,mPlot{pp}.Y3,'+')
            end
            if ((pp==2) || (pp==4))
%                 ylim([0,1]);
                set(gca,'YTickLabel',1-10.^-get(gca,'YTick'));
            end
            title(sTitle(pp));
            ylabel(sYLabel(pp));
            xlabel(sXLabel);
        end % end for pp
        sPrint=sprintf('print -dpng %s',sPrint);
        eval(sPrint)

        figure_w_normalized_uicontrolunits('Position',[800 0 800 400],'Name','standard Deviations of z and p');
            subplot(1,2,1);
            hold on;plot(mN.V1,mN.V2.Z_std,'-','LineWidth',2);
            hold on;plot(mN.V1,mN.V2.B_std,'--','LineWidth',2);
            ylabel('std of z and \beta');
            xlabel(sXLabel);
            legend(num2str(vVariable2));
            subplot(1,2,2);
            hold on;plot(mN.V1,mN.V2.pZ_std,'-','LineWidth',2);
            hold on;plot(mN.V1,mN.V2.pB_std,'--','LineWidth',2);
            ylabel('std of p(z) and p(\beta)');
            xlabel(sXLabel);
            legend(num2str(vVariable2));
        sPrintErr=sprintf('print -dpng %s',sPrintErr);
        eval(sPrintErr)
    end % end plot_values

mN;
%     sPrint=sprintf('print -dpng %s',sPrint);
%     eval(sPrint)
end % end function

%
%     xlabel(sXLabel);
%     switch nSubplot
%         case 1
%             title('z(lta)-variation');
%             ylabel('z(lta)');
%         case 2
%             title('p(z)-variation');
%             ylabel('p(z)');
%         case 3
%             title('\beta-variation');
%             ylabel('\beta');
%         case 4
%             title('p(\beta)-variation');
%             ylabel('p(\beta)');
%     end
%     subplot(2,2,nSubplot);
%     Y=mean(squeeze(params.mResult_(:,nSubplot,vSel)));
%     E=std(squeeze(params.mResult_(:,nSubplot,vSel)));
%     errorbar(params.mVar(vSel,nMode),Y,E,'xr','MarkerSize',10,'LineWidth',1);
% end
