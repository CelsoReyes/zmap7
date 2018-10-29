function patchtest(some_results, col)
    gr_s = some_results.Grid;
    results = some_results.values;
    %% testing the grid conversion, to display results in a patch
    %{
gr_s =

  struct with fields:

    ActivePoints: [41×37 logical]
               X: [41×37 double]  %  [Lat, Lon]
               Y: [41×37 double]
         Xactive: [1517×1 double]
         Yactive: [1517×1 double]
      GridVector: [1517×2 double]

This has 41 unique Y values
    %}
    myX = gr_s.X;
    %f=figure(3);
    %clf
    %f.Name='patchy patch patch';
    ax=gca;
    hold on;
    % assume: dx is constant for every latitude
    dx_at_lat = min(diff(myX,[],2),[],2);   % Nx1
    
    % assume dy is constant everywhere
    dy = mean(min(diff(gr_s.Y)));
    
    % fill all nans.
    for i=1:size(myX,1)
        AnchorIdx = find(~ismissing(myX(i,:)),1,'first');
        AnchorVal = myX(i,AnchorIdx);
        missIdx = find(ismissing(myX(i,:)));
        myX(i,missIdx) = (missIdx - AnchorIdx) .* dx_at_lat(i) + AnchorVal;
    end
    
    vX = [myX(:,1)-dx_at_lat ./2 , myX + repmat(dx_at_lat,1,size(myX,2)) ./2];
    vX= [vX ; vX(end,:)]; % ugly approximation
    
    dy = diff(gr_s.Y,[],1)./2;
    dy = [ -dy(1,:) ; dy ; dy(end,:) ];
    vY = [gr_s.Y(1,:) ; gr_s.Y] + dy;
    vY=  [vY, vY(:,end)];
    
    %pa=surf2patch(gr_s.X, gr_s.Y,zeros(size(gr_s.X))); % as surf2patch(X,Y,Z)
    pa=surf2patch(vX, vY, zeros(size(vX)),'triangles'); % as surf2patch(X,Y,Z)
    %pa=surf2patch(gr_s.X, gr_s.Y);
    pa.FaceVertexCData = linspace(0,1,length(pa.vertices))';
    mypatch=patch(pa);
    shading flat;
    hold on;
     scatter(gr_s.X(:),gr_s.Y(:),'r+','Tag','thegrid');
    
    do_not_use = isnan(results.x)|isnan(results.y)|isnan(results.(col));
    results(do_not_use,:)=[];
    F=scatteredInterpolant(results.x,results.y,results.(col));
    F.ExtrapolationMethod='none';
    F.Method='linear';
    vert=F(vX,vY);
    mypatch.FaceVertexCData=vert(:);
    disp(F)
    set(gca,'Children',circshift(get(gca,'Children'),-1))
end