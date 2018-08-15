function [mCatalog_, mNumDeclus] = MonteAnnemarie( dMethod, mCatalog_,nSimul_)
    % Monter Carlo Simulation for time-space-declustering that leverages code
    % derrived from Annemarie's perl codes
    
    
    report_this_filefun();
    mCatalog_(:,10)=zeros(size(mCatalog_,1),1);
    mNumDeclus=[];
    
    for simNum = 1:nSimul_
        [mCatClus] = clusterAnnemarie(dMethod, mCatalog_, 0, 0, 3, 3);
        vSel=(mCatClus(:,13)==0);
        vSel=~vSel;
        mNumDeclus=[mNumDeclus,vSel];
        mCatalog_(:,10)=mCatalog_(:,10)+vSel;
    end
end
