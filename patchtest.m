function mypatch=patchtest(some_results, col_heading)
    
    %{
    some_results is the results from one of the ZmapGridFunctions. It will contain:
    1.  a field called "values" which is a table.  This table will have columns for 'x', 'y' and 
        col_heading (where col_heading is the name of one of the columns).
    2.  a field called Grid, which is a ZmapGrid and contains fields X, Y
        
    %}
    gr_s = some_results.Grid;
    results = some_results.values;
    
    myX=some_results.values.x;
    myX=reshape(myX,size(some_results.Grid.X));
    hold on;
    % assume: dx is constant for every latitude
    dx_at_lat = min(diff(myX,[],2),[],2);   % Nx1
    
    
    
    % fill all X position nans, because they will cause holes
    for i=1:size(myX,1)
        AnchorIdx = find(~ismissing(myX(i,:)),1,'first');
        AnchorVal = myX(i,AnchorIdx);
        missIdx = find(ismissing(myX(i,:)));
        myX(i,missIdx) = (missIdx - AnchorIdx) .* dx_at_lat(i) + AnchorVal;
    end
    
    % assume dy is constant everywhere
    dy = mean(min(diff(gr_s.Y)));
    shifted_X = myX - repmat(dx_at_lat ./2, 1, size(myX,2)) ;
    shifted_Y = gr_s.Y-dy./2;
    
    myresults=results.(col_heading);
    myresults=reshape(myresults,size(shifted_X));
    
    %% because surfaces and patches are based on the lower-left corner, add col & row.
    
    % add row to top with same values as existing last (top)row
    myresults(end+1,:)=myresults(end,:);
    shifted_X(end+1,:)=shifted_X(end,:);
    shifted_Y(end+1,:)=shifted_Y(end,:) + dy;
    
    % add column to end with same values as existing last (right) column
    myresults(:,end+1)=myresults(:,end);
    shifted_X(:,end+1)=shifted_X(:,end) + [dx_at_lat; dx_at_lat(end)];
    shifted_Y(:,end+1)=shifted_Y(:,end);
    
    pa=surf2patch(shifted_X,shifted_Y,zeros(size(shifted_X)),myresults);
    
    mypatch=patch(pa);
    mypatch.Faces(end,:)=[]; %this point was made up.
    mypatch.Tag='the_patch';
    mypatch.HitTest='off';
    shading faceted;
    
    set(gca,'Children',circshift(get(gca,'Children'),-1)); % put this patch at the end
end

