function [xs, ys] = cols2matrix(x0,lonCol,latCol)
    % COLS2MATRIX convert columns of lats & lons into a matrix.
    % this takes lots of stuff into account
    %
    % [xs, ys] = COLS2MATRIX(x0,lonCol,latCol)
    
    % assign pgrid
    ugy=unique(latCol); % lats in matrix
    nrows=numel(ugy); % number of latitudes in matrix
    [~,example]=min(abs(latCol(:))); % latitude closest to equator will have most number of lons in matrix
    mostCommonY=latCol(example); % account for the abs possibly flipping signs
    base_lon_idx=find(lonCol(latCol==mostCommonY)==x0); % longitudes that must line up
    ncols=sum(latCol(:)==mostCommonY); % most number of lons in matrix
    ys=repmat(ugy(:),1,ncols);
    xs=nan(nrows,ncols);
    for n=1:nrows
        thislat=ugy(n); % lat for this row
        idx_lons=(latCol==thislat); % mask of lons in this row
        these_lons=lonCol(idx_lons); % lons in this row
        row_length=numel(these_lons); % number of lons in this row
        
        main_lon_idx=find(these_lons==x0); % offset of X in this row
        offset=base_lon_idx - main_lon_idx;
        xs(n,(1:row_length)+offset)=these_lons;
    end
end