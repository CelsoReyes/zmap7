function [mCatNew, mMagShift] =calc_magerr(mCat,mDeltaMag)
    % calculate magnitude shifts
    %
    % Example:  [mCatNew, mHyposhift]=calc_magerr(mCatalog,mDeltaMag)
    % Input parameter:
    % mCat    Earthquake catalog in zmap format
    % mDelta Error bounds given provided by network ( [dLon, dLat, dDepth] )
    % nDim  0 : error bounds in lon / lat, 1: errorbounds in [km]
    %
    % Output parameter
    % mCatNew Shifted hypocenter
    % mHyposhift   Values by which hypocenters were shifted
    %
    % Author
    % van Stiphout, Thomas
    % vanstiphout@sed.ethz.ch
    % Created
    % 09 Aug 2007
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    report_this_filefun();
    
    % reset random number generator
    rng('shuffle');
    % create randomly distributed errors within given errorbounds
    mMagShift=roundn((rand(size(mCat,1),1)*2-1).*mDeltaMag,-1);
    
    % add error to the catalog hypocenters
    mCatNew=mCat;
    mCatNew(:,6)=mCatNew(:,6)+mMagShift(:,1);
end