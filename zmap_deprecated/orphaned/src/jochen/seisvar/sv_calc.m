function [params] = sv_calc(params)
% function [vResults] = sv_calc(params)
% -----------------------------------
% Calculation of seismicity variations
%
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon           Polygon (defined by ex_selectgrid)
%   params.vX                 X-vector (defined by ex_selectgrid)
%   params.vY                 Y-vector (defined by ex_selectgrid)
%   params.vUsedNodes         Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
%   params.bRandom            Perform random simulation (=1) or real calculation (=0)
%   params.nCalculation       Number of random simulations
%   params.bMap               Calculate a map (=1) or a cross-section (=0)
%   params.bNumber            Use constant number (=1) or constant radius (=0)
%   params.nNumberEvents      Number of earthquakes if bNumber == 1
%   params.fRadius            Radius of gridnode if bNumber == 0
%   params.nMinimumNumber     Minimum number of earthquakes per node for determining a b-value
%   params.nCalculateMC       Method to calculate magnitude of completeness (see also: help calc_Mc)
%   params.bMinMagMc          Use magnitude of completeness as lower limit of magnitude range for testing (=1)
%                             Use params.fMinMag as lower limit (=0)
%   params.fMinMag            Lower limit of magnitude range for testing
%   params.fMaxMag            Upper limit of magnitude range for testing
%
%   params.bSplitTime         Calculate seismicity difference for 2 periods: see help ex_SplitCatalog
%   params.fSplitTime         Date of seperation of earthquake catalog
%   params.bTimePeriod        Calculate seismicity difference for 2 periods (0) until start and end of catalog or
%                             a specific time period before and after fSplitTime (1)
%   params.fTimePeriod        Length of time periods
%   params.nDeclMethod        Window choice for declustering with windowing technique by Gardner & Knopoff 1974
%   params.bDecluster         Decluster catalog (1) or not (0)
%   params.bSeisModel         Fit seismicity variation by (0) Grid search technique or (1) b-value fitting
%
% Output parameters:
%   Same as input parameters including
%   params.mValueGrid         Matrix of calculated values
% Check sv_NodeCalc.m for a list of variables!!
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% last update: 18.11.02

global bDebug;
if bDebug
    report_this_filefun(mfilename('fullpath'));
end

%%% Determinations for entire EQ catalog
% Determine overall magnitude of completeness
params.fMcOrg = calc_Mc(params.mCatalog, params.nCalculateMC);
% Determine FMDs
[vFMDOrg, vNonCFMDOrg] = calc_FMD(params.mCatalog);
%% Calculate a and b for entire catalog, b max. likelihood
vSel = (params.mCatalog(:,6) >= params.fMcOrg);
[fMeanMagOrg, params.fBValueOrg, fStdDevOrg, params.fAValueOrg] =  calc_bmemagMag(params.mCatalog(vSel,:));
sOrg = ['Entire Catalog: Mc = ' num2str(params.fMcOrg) ' a = ' num2str(params.fAValueOrg)...
        ' b = ' num2str(params.fBValueOrg)];
% Perform the real calculation
% ----------------------------
if params.bDecluster == 1
    %%% Decluster the EQ catalogue
    [mCatDecluster, mCatAfter, params.vCluster, params.vCl, params.vMainCluster] = calc_decluster(params.mCatalog,params.nDeclMethod);
    % Init result matrix
    mValueGrid_ = [];
    % Loop over all grid nodes
    for nNode_ = 1:length(params.mPolygon(:,1))
        % Create node catalog
        mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);
        % Vector of cluster events
        vNodeCluster = params.vCluster(params.caNodeIndices{nNode_}, :);
        [rCalcNodeResult_] = sv_NodeCalc(mNodeCatalog_, params.fSplitTime, params.bTimePeriod, params.fTimePeriod,...
            params.nCalculateMC, vNodeCluster, params.bDecluster, params.fMcOrg, params.fBValueOrg, params.bSeisModel);
        % Store the results
        %         mValueGrid_= [mValueGrid_; rCalcNodeResult_.dNdiffsumVal rCalcNodeResult_.dNdiffsumYearVal rCalcNodeResult_.dNdiffsumMonthVal...
        %                 rCalcNodeResult_.fMc rCalcNodeResult_.fMcFirstPeriod rCalcNodeResult_.fMcSecondPeriod rCalcNodeResult_.fMshift...
        %                 rCalcNodeResult_.nPoissDeg rCalcNodeResult_.nPoissDeg_Dec rCalcNodeResult_.fClusterDeg];
        mValueGrid_= [mValueGrid_; rCalcNodeResult_.nPoissDeg rCalcNodeResult_.nPoissDeg_Dec rCalcNodeResult_.fClusterDeg];
    end; % for nNode
    params.vcsGridNames = cellstr(char('Poissonian Degree Org. Catalog', 'Poissonian Degree declustered Catalog',...
        'Degree of Clustering'));
    params.mValueGrid = mValueGrid_;
elseif (params.bSeisModel == 1)
    % Init result matrix
    mValueGrid_ = [];
    % Loop over all grid nodes
    for nNode_ = 1:length(params.mPolygon(:,1))
        % Create node catalog
        mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);
        % Vector of cluster events as dummy
        vNodeCluster = [];
        % Calculate the difference of cumulative sums
        %[rCalcNodeResult_] = sv_totdiff(mNodeCatalog_, params.fSplitTime);
        [rCalcNodeResult_] = sv_NodeCalc(mNodeCatalog_, params.fSplitTime, params.bTimePeriod, params.fTimePeriod,...
            params.nCalculateMC, vNodeCluster, params.bDecluster, params.fMcOrg, params.fBValueOrg, params.bSeisModel);
        % Store the results
        mValueGrid_= [mValueGrid_; rCalcNodeResult_.dNdiff...
                rCalcNodeResult_.fMc rCalcNodeResult_.fMcFirstPeriod rCalcNodeResult_.fMcSecondPeriod rCalcNodeResult_.fdMc...
                rCalcNodeResult_.fMshift rCalcNodeResult_.fPerHi rCalcNodeResult_.fPerLow rCalcNodeResult_.fFactorHi...
                rCalcNodeResult_.fFactorLow rCalcNodeResult_.fMshiftCom rCalcNodeResult_.fStretch rCalcNodeResult_.fdMag...
                rCalcNodeResult_.fMshiftSig rCalcNodeResult_.fMshiftFit rCalcNodeResult_.fMTransFit rCalcNodeResult_.fMRateFit...
                rCalcNodeResult_.fARate];
    end; % for nNode
    params.vcsGridNames = cellstr(char('Percentage change','Mc entire catalog','Mc1 first period',...
        'Mc2 second period','Mc difference (Mc2-Mc1)', 'Magnitude shift','Percent change EQ >= Mc1', 'Percent change EQ < Mc1',...
        'Rate factor >= Mc1','Rate factor < Mc1', 'Combined shift', 'Stretch factor', 'Magnitude fitting', '99 % significant shift',...
        'Goodness of fit by simple shift', 'Goodness of fit by transformation', 'Goodness of fit by rate factor','Rate factor from a-ratio'));
    params.mValueGrid = mValueGrid_;
else
    % Init result matrix
    mValueGrid_ = [];
    % Loop over all grid nodes
    hWaitbar1 = waitbar(0,'Processing nodes...');
    set(hWaitbar1,'Numbertitle','off','Name','Percentage of nodes finished');
    for nNode_ = 1:length(params.mPolygon(:,1))
        nNode_
        % Create node catalog
        mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);
        [nX,nY] = size(mNodeCatalog_);
        if (nX < params.nMinimumNumber)
            mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
        else
            % Vector of cluster events as dummy
            vNodeCluster = [];
            %%!!! WATCH sv_NODECALC2 NOW in use !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            [rCalcNodeResult_] = sv_NodeCalc2(mNodeCatalog_, params.fSplitTime, params.bTimePeriod, params.fTimePeriod,...
                params.nCalculateMC, vNodeCluster, params.bDecluster, params.fMcOrg, params.fBValueOrg, params.bSeisModel);
            % Store the results
            mValueGrid_= [mValueGrid_; rCalcNodeResult_.dNdiffsum...
                    rCalcNodeResult_.fMc rCalcNodeResult_.fMcFirstPeriod rCalcNodeResult_.fMcSecondPeriod rCalcNodeResult_.fdMc...
                    rCalcNodeResult_.nModelChoice rCalcNodeResult_.fdM rCalcNodeResult_.fdS rCalcNodeResult_.fRf rCalcNodeResult_.fdMcMod nX];
        end
        if rem(nNode_,10) == 0
            waitbar(nNode_/length(params.mPolygon(:,1)))
        end; % End updating waitbar
    end; % for nNode
    close(hWaitbar1);
    params.vcsGridNames = cellstr(char('Cumulativ sum of seismicity difference','Mc entire catalog','Mc1 first period',...
        'Mc2 second period','Mc difference (Mc2-Mc1)', 'Model choice', 'fdM', 'fdS', 'fRf', 'dMc', 'Number EQ'));
    params.mValueGrid = mValueGrid_;
end; % END of IF bDecluster

% Save data grid
vResults = params;
save sv_resultgrid.mat vResults;
