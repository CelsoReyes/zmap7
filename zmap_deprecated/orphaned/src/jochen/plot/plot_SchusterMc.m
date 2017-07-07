function [fMc, fProbability, mResult] =  plot_SchusterMc(mCatalog)
% function [fMc, fProbability, mResult] = plot_SchusterMc(mCatalog)
% ----------------------------------------------------
% Determine the magnitude of completness using Schuster's Method
% objectively. Philosophy: Detect if walkout > 95%
% significance level two times, then set upper magnitude as Mc. If that
% happens more times, choose the smaller magnitude!
%
% Incoming variables:
% mCatalog : EQ catalog
%
% Outgoing variables:
% fMc          : Magnitude of completeness
% fProbability : Probability of exceeding the 95% level radius
% mResult      : Result matrix for all cases
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 04.06.02

fMinMag = round(min(mCatalog(:,6))*10)/10;
fMaxMag = round(max(mCatalog(:,6))*10)/10;

prompt = {'Enter minimum magnitude:','Enter maximum magnitude:','Magnitude increment:'};
dlg_title = 'Search parameters';
num_lines= 1;
def     = {num2str(fMinMag),num2str(fMaxMag),'0.2'};
answer  = inputdlg(prompt,dlg_title,num_lines,def);
fMinMag = str2double(answer(1));
fMaxMag = str2double(answer(2));
fMagIncr = str2double(answer(3));

% Initialize
mResult = [];

fMag=fMinMag;
i=0;
figure_w_normalized_uicontrolunits('tag','schuster','Name','Schuster Walkout');
figure_w_normalized_uicontrolunits('tag','schuster2','Name','Schuster Walkout');
%n = floor((fMaxMag-fMag)/fMagIncr);
n = floor((fMaxMag-fMagIncr-fMag)/0.1)+2;
if mod(n,2) ~= 0
    fN=round(n/2);
else
    fN=floor(n/2);
end
while (fMag+fMagIncr) < (fMaxMag)
    % Calculate result matrix
    vSel = (mCatalog(:,6) >= fMag & mCatalog(:,6) < fMag+fMagIncr);
    mCat = mCatalog(vSel,:);
    [mWalkout, fR95, fProb, PHI, R] = calc_Schusterwalk(mCat);
    [vThetaWalkout,vRadWalkout] = cart2pol(mWalkout(:,1),mWalkout(:,2));
    fMaxRadius = max(abs(vRadWalkout(:,1)));
    mResult = [mResult; fMag+fMagIncr, fMaxRadius, max(abs(mWalkout(:,1))), max(abs(mWalkout(:,2))), fR95, fProb, R];

    % Subplot count
    i=i+1;
    figure_w_normalized_uicontrolunits(findobj('tag','schuster'));
    % Plot Schuster walkout
    subplot(fN,2,i)
    plot(mWalkout(:,1),mWalkout(:,2),'-','Color',[0.5 0.5 0.5]);
    hold on;
    polar([0:360]*pi/180,ones(1,361)*fR95,'--k');
    [x, y] =pol2cart(PHI,R);
    %plot([0,x],[0 y],'g');
    plot ([0 0],[-1/5*fR95,1/5*fR95],'k');
    plot ([-1/5*fR95,1/5*fR95],[0 0],'k');
%     hold off
%     text (0,2/5*fR95,'0:00','HorizontalAlignment','center');
%     text (2/5*fR95,0,'6:00','HorizontalAlignment','left');
%     text (0,-2/5*fR95,'12:00','HorizontalAlignment','center');
%     text (-2/5*fR95,0,'18:00','HorizontalAlignment','right');
%     text (0,fR95 ,'95KI','VerticalAlignment','bottom','HorizontalAlignment','center')
    axis square;
    sTitlestr = ['M = ' num2str(fMag) ' - ' num2str(fMag+fMagIncr)];
    title(sTitlestr);
    % Radius comparison for the plot
    sTextstr = [num2str(length(mCat(:,8))) ' / ' num2str(fMaxRadius/fR95)];
    text (-fR95,-fR95,sTextstr);

    % Plot hourly histogram
    figure_w_normalized_uicontrolunits(findobj('tag','schuster2'));
    subplot(n,1,i);
    vTime = (mCat(:,8)*60+mCat(:,9))/60; % Calculate decimal hour
    histogram(vTime,-0.5:1:24.5)
    fMag= fMag+0.1;
end % END of WHILE

% Select walkout > 95% level
try
    vSel = (mResult(:,2) >= mResult(:,5));
    mResOut = mResult(vSel,:);
    mDiffResOut=diff(mResOut);
    mDiffResOut(:,1) = round(mDiffResOut(:,1)*10)/10;
    [vIndice]=find(mDiffResOut(:,1) == 0.1);
    if isempty(vIndice)
        fMc = nan;
        fProbability = nan;
    else
        fMc = mResult(max(vIndice)+2,1); % Maximum value for Mc
        fProbability = mResult(max(vIndice)+2,6);
        for nCnt=length(vIndice):-1:2
            fdI = vIndice(nCnt)-vIndice(nCnt-1);
            if fdI > 1
                fMc = mResult(vIndice(nCnt-1)+2,1); % Find Mc
                fProbability = mResult(max(vIndice)+2,6);
            end
        end
    end
catch
    fMc = nan;
    fProbability = nan;
end
