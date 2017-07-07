function [fTafseq] = calc_Afseqlengtwomol(fPval1,fCval1,fKval1,fBgrate,nMod,fTsecaf,fPval2,fCval2,fKval2)
    % [fTafseq] = calc_Afseqlengtwomol(fPval1,fCval1,fKval1,fBgrate,nMod,fTsecaf,fPval2,fCval2,fKval2)
    % -------------------------------------------------------------------------
    % Determines the length of an aftershock sequence by determining the
    % intersection with the DAILY backgraund rate; MOL and nested MOL are allowed
    % (only one secondary sequence)
    %
    % Incoming:
    % fPval1   : Modified Omori law p-value
    % fCval1   : Modified Omori law c-value [days]
    % fKval1   : Modified Omori law k-value
    % fBgrate  : Daily background rate of events above Mc
    % nMod     : Aftershock sequence model choice
    %               1. Modified Omori law (MOL)
    %               2. MOL with one secondary sequence
    % fTsecaf
    % fPval2   : Modified Omori law p-value
    % fCval2   : Modified Omori law c-value [days]
    % fKval2   : Modified Omori law k-value

    % Outgoing:
    % fTafseq  : Length of aftershock sequence
    %
    % last update: 08.07.04
    % jochen.woessner@sed.ethz.ch

    % Time vector in days
    vT = [0:0.1:10000];
    vT = vT';

    % Check input
    if nargin < 4; disp('Not enough input parameters'); return; end
    if nargin == 4; nMod=1; end

    % Switch between MOL and nested MOL
    switch nMod
        case 1 % MOL
            vRate = abs(fKval1.*(vT+fCval1).^-fPval1-fBgrate);
            vSel = (min(vRate) == vRate);
            fTafseq = vT(vSel);
        case 2 % Nested Models
            vSelT = (vT >= fTsecaf);
            vRate1 = abs(fKval1.*(vT(~vSel)+fCval1).^-fPval1-fBgrate);
            vRate2 = abs(fKval1.*(vT(vSel)+fCval1).^-fPval1+fKval2.*(vT(vSel,:)-fTsecaf+fCval2).^-fPval2-fBgrate);
            vRate = [vRate1; vRate2];
            vSel = (min(vRate) == vRate);
            fTafseq = vT(vSel);
        otherwise
            disp('Not a valid model!');
    end
    % % Possible plot
    % figure
    % loglog(vT,vRate)
    % xlabel('Time [days after mainshock]')
    % ylabel('Daily rate of earthquakes')
