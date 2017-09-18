function focalmech(fm, centerX, centerY, diam, varargin)
%	>> focalmech(fm, centerX, centerY, diam, varargin)
%   Draws full moment tensor beachball diagram of earthquake focal mechanism.
%   Required inputs
%	fm: 3x3 or 1x6 vector of the six independent components of the 
%           moment tensor (mrr, mtt, mff, mrt, mrf, mtf).
%	centerX, centerY: position to place beachball at position
%	diam: diameter of drawn beachball.
%
%	Optional inputs
%	color for tensional region changed by 'r', 'g', 'b', 'y', 'm', 'c' or 
%       3 element color vector. default is black.
%   scalar argument is assumed to be an aspect ratio for non-equal axes.
%       Value is stretch in E-W direction.
%       'map' or 'Mercator' will do automatic Mercator aspect ratio
%       assuming centerY = lat
%   'dc' will force to best fitting double-couple solution
%   'nofill' will leave transparent (nodal lines only)
%   'text' will add following argument as a title to the beachball
%   'FontSize' with following argument will change fontsize for text
%
%   Written to give a MatLab equivalent of psmeca -Sm from GMT.
%   As such, this function requires a moment tensor. For planes (e.g.,
%   strikes and dips), use bb.m. bb is a nice beachball plotting function
%   from Oliver Boyd at CERI, but aimed strictly at double-couple
%   mechanisms.
%
%   Written by James Conder, Southern Illinois University, Jan 10, 2017
%   Please cite:
%   Conder, J.A. and C.A. Arciniegas, Conjugate Faulting in the Wabash
%       Valley Fault Zone exhibited by the Nov 20, 2012 M3.6 earthquake, 
%       a Mt Carmel Late Aftershock, Seismological Research Letters, 88,
%       1203-1209, doi:10.1785/0220170021, 2017
%
%   2/20/2017 realized that a vertical vector may not actually be within
%   a single contour if there is a large isotropic component.
%   Algorithm changed to using sign of vector explicitly inside contour.
%   3/12/2017 Vectorized main loop to improve efficiency.
%   (Speed gains of 4-10x).

% defaults
fillcolor = [0 0 0];  % black for tensional region(s)
unitratio = 1;      % axis equal
DC = false;         % show non double-couple components
colorit = true;     % fill in tensional regions
ctitle = [];        % text above beachball
fsize = 10;         % fontsize for text

% set parameters based on varargin inputs
if nargin > 4
    icheck(1:nargin-4) = true;
    for i = 1:nargin-4
        if icheck(i)
        if isnumeric(varargin{i})
            if isscalar(varargin{i})
                unitratio = varargin{i};
            end
            if length(varargin{i}) == 3
                fillcolor = varargin{i};
            end
        elseif ischar(varargin{i})
            switch varargin{i}
                case {'r'}
                    fillcolor = [ 1 0 0 ];
                case {'g'}
                    fillcolor = [ 0 1 0 ];
                case {'b'}
                    fillcolor = [ 0 0 1 ];
                case {'y'}
                    fillcolor = [ 1 1 0 ];
                case {'m'}
                    fillcolor = [ 1 0 1 ];
                case {'c'}
                    fillcolor = [ 0 1 1 ];
                
                case {'map','Map','mercator','Mercator'}
                    unitratio = 1/cos(centerY*pi/180);
                    
                case {'dc','DC','double-couple','doublecouple'}
                    DC = true;

                case {'nocolor','nofill','transparent'}
                    colorit = false;

                case {'text','title'}
                    ctitle = varargin{i+1};
                    icheck(i+1) = false;

                case {'fontsize','FontSize','Fontsize','fsize'}
                    fsize = varargin{i+1};
                    icheck(i+1) = false;
            end 
        end
        end
    end     
end

colormap([1 1 1; fillcolor])    % 2 color beachball fill 
sE = unitratio*0.5*diam; sN = 0.5*diam; % scaling for plotting
u = sE*cos(0:0.02:2*pi); w = sN*sin(0:0.02:2*pi);   % reference circle


%%% put fm (A&R convention, rtf) into 3x3 cartesian (xyz)
%%% x = north, y = East, Z = down (Aki & Richards pg 113)
M = eye(3);
if length(fm) == 6
   M(1,1) = fm(2); M(2,2) = fm(3); M(3,3) = fm(1);
   M(2,1) = -fm(6); M(1,2) = M(2,1);
   M(3,1) = fm(4); M(1,3) = M(3,1);
   M(3,2) = -fm(5); M(2,3) = M(3,2);
else
   M(1,1) = fm(2,2); M(2,2) = fm(3,3); M(3,3) = fm(1,1);
   M(2,1) = -fm(3,2); M(1,2) = M(2,1);
   M(3,1) = fm(2,1); M(1,3) = M(3,1);
   M(3,2) = -fm(3,1); M(2,3) = M(3,2);
end
    
% Tensional and compressional regions are determined by sign of 
%   local 'radius'.
% Negative length = compression, and positive length = tension
% Length is found by linear combination of three eigen vectors.

% find eigenvalues and eigenvectors of system and put in descending order
[V,D] = eig(M);
D = diag(D);
eig1 = max(D);      % largest eigenvalue
eig3 = min(D);      % smallest eigenvalue
if eig1 == eig3
    eig2 = eig1;
    i1 = 1; i2 = 2; i3 = 3;
else
    i1 = find(D == eig1,1);
    i3 = find(D == eig3,1);
    i2 = 6 - i1 - i3;
    eig2 = D(i2);
end

vT = V(:,i1);       % eigenvectors: TBP
vB = V(:,i2);
vP = V(:,i3);

% check for explosions or implosions
if eig1 <= 0     % implosion
    fill(centerX+u,centerY+w,'w')   % fill white circle
    return
end
if eig3 >= 0     % explosion
    fill(centerX+u,centerY+w,fillcolor)   % filled circle
    return
end

%%% if forced to be double couple
if DC
    eigB = 0.5*(eig1 - eig3);
    eig1 = eigB; eig2 = 0; eig3 = -eigB;
end

% Sweep out hemisphere to find negative & positive regions
dx = 0.02; dy = dx;     % grid loop
x = -1:dx:1; y = -1:dy:1;
nx = length(x); ny = length(y); % vectorization of previous code begins here
vij = zeros(3,nx,ny);

x2 = repmat(x',1,ny);
y2 = repmat(y,nx,1);
r2 = x2.*x2 + y2.*y2;        
trend = atan2(y2,x2);
plunge = pi/2 - 2*asin(sqrt(r2/2));  % equal area projection
ir = r2 > 1;
vij(1,:,:) = cos(trend).*cos(plunge);   % set up local vector grids
vij(2,:,:) = sin(trend).*cos(plunge);
vij(3,:,:) = sin(plunge);

% project eigenvectors onto local vectors
uT = 0*vij; uB = 0*vij; uP = 0*vij; 
uT(1,:,:) = vij(1,:,:)*vT(1) + vij(2,:,:)*vT(2) + vij(3,:,:)*vT(3);
uT(3,:,:) = uT(1,:,:)*vT(3);
uT(2,:,:) = uT(1,:,:)*vT(2);
uT(1,:,:) = uT(1,:,:)*vT(1);
uB(1,:,:) = vij(1,:,:)*vB(1) + vij(2,:,:)*vB(2) + vij(3,:,:)*vB(3);
uB(3,:,:) = uB(1,:,:)*vB(3);
uB(2,:,:) = uB(1,:,:)*vB(2);
uB(1,:,:) = uB(1,:,:)*vB(1);
uP(1,:,:) = vij(1,:,:)*vP(1) + vij(2,:,:)*vP(2) + vij(3,:,:)*vP(3);
uP(3,:,:) = uP(1,:,:)*vP(3);
uP(2,:,:) = uP(1,:,:)*vP(2);
uP(1,:,:) = uP(1,:,:)*vP(1);

% get weights for each eigenvector across hemisphere space
wT = uT(1,:,:).*uT(1,:,:) + uT(2,:,:).*uT(2,:,:) + uT(3,:,:).*uT(3,:,:);
wB = uB(1,:,:).*uB(1,:,:) + uB(2,:,:).*uB(2,:,:) + uB(3,:,:).*uB(3,:,:);
wP = uP(1,:,:).*uP(1,:,:) + uP(2,:,:).*uP(2,:,:) + uP(3,:,:).*uP(3,:,:);

uz = wT*eig1 + wB*eig2 + wP*eig3;   % lengths grid
uz = squeeze(uz); uz(ir) = nan;
clear vij uT uB uP wT wB wP

%%% plot
% Note centerX & centerY are in conventional cartesian coords unlike x,y
% above where x is north.
hold on
if ~colorit
    plot(centerX+u,centerY+w,'k')   % plot circle boundary
    c = contourc(centerX+sE*y,centerY+sN*x,uz,[0 0]);       % no fill
    i = c(2,:) >= 1;
    c(:,i) = nan;
    plot(centerX+sE*c(1,:),centerY+sN*c(2,:),'color',fillcolor)   % plot circle boundary    
else
    fill(centerX+u,centerY+w,'w')   % fill white circle
    plot(centerX+u,centerY+w,'k')   % plot circle boundary


% fill in tensional regions
%contourf(centerX+sE*y,centerY+sN*x,uz,[0 0]);   % fill in tensional regions
% Need to use 'fill' as contourf will change pallette of entire figure

% get contours of zero level. *Should* be one or two segments
c = contourc(y,x,uz,[0 0]); c = c';

% find contour breaks
nc = 1;
[~,I] = sort(c(:,2),'descend');
if c(I(2),2) > 7
    nc = 2;
end
I = I(1:nc);

%reset c with just contours of interest (maximum of 2)
if nc == 1
    c = [ c(I(1),:); c(I(1)+1:I(1)+c(I(1),2),:)];
else
    c = [ c(I(1),:); c(I(1)+1:I(1)+c(I(1),2),:); ...
          c(I(2),:); c(I(2)+1:I(2)+c(I(2),2),:)];
end
i = find(c(:,2) > 2);  % indices of contour breaks

% fill tensional regions
if nc == 1       % 1 contour (closed unless single vertical plane)
    c(1,:) = [];        % remove contour header 
    % closed contour must have vertical plunge in it - check for sign
    % not necessarily true if large isotropic component - fix
    
    % check for single vertical plane
    d2 = (c(1,1)-c(end,1))^2 + (c(1,2)-c(end,2))^2;
    
    if d2 > 2 % single vertical plane
        ang = atan2(c(end,2),c(end,1));     % location of contour end 
        dang = 0.1;
        vij = [ sin(ang+dang) cos(ang+dang) 0];
        uT = dot(vij,vT)*vT; wT = norm(uT)^2;
        uB = dot(vij,vB)*vB; wB = norm(uB)^2;  
        uP = dot(vij,vP)*vP; wP = norm(uP)^2;
        uvc = wT*eig1 + wB*eig2 + wP*eig3;
        if uvc > 0       
            a1 = (ang:0.02:ang+pi)';    % ccw along edge
        else
            a1 = flipud((ang-pi:0.02:ang)');    % cw along edge
        end   
        ac = [cos(a1) sin(a1)];
        c1 = [c; ac];
        fill(centerX+sE*c1(:,1),centerY+sN*c1(:,2),fillcolor)  
    else        % single closed contour
        xi = mean(c(:,1)); yi = mean(c(:,2)); % spot inside contour
        trend = atan2(xi,yi);   % x = north...     
        r2 = xi*xi + yi*yi;        
        plunge = pi/2 - 2*asin(sqrt(r2/2));  % equal area projection        
        vij(1) = cos(trend)*cos(plunge);
        vij(2) = sin(trend)*cos(plunge);
        vij(3) = sin(plunge);

        uT = dot(vij,vT)*vT; wT = norm(uT)^2;
        uB = dot(vij,vB)*vB; wB = norm(uB)^2;  
        uP = dot(vij,vP)*vP; wP = norm(uP)^2;
        uv = wT*eig1 + wB*eig2 + wP*eig3;
    
        if uv > 0   % fill inside contour
            fill(centerX+sE*c(:,1),centerY+sN*c(:,2),fillcolor)
        elseif uv < 0   % fill outside contour
            fill(centerX+u,centerY+w,fillcolor)
            fill(centerX+sE*c(:,1),centerY+sN*c(:,2),'w') 
        end
    end
else                    % 2 contours
    % find 4 spots where contours touch edge
    ia = ([ 2 i(2)-1 i(2)+1 length(c)])';
    dang = 0.02*pi;
    
    % determine whether contours bound positive or negative regions
    % get mid contour vector
    p1 = c(3,:);
    p2 = c(ia(2)-1,:);
    pmid = 0.5*(p1 + p2);
    ang = atan2(pmid(2),pmid(1));
    vij = [ sin(ang) cos(ang) 0]; 
    uT = dot(vij,vT)*vT; wT = norm(uT)^2;
    uB = dot(vij,vB)*vB; wB = norm(uB)^2;  
    uP = dot(vij,vP)*vP; wP = norm(uP)^2;
    uvc = wT*eig1 + wB*eig2 + wP*eig3;
        
    % first contour ending spot
    p2 = c(ia(2),:);
    ang2 = atan2(p2(2),p2(1));

    % angle between contour ends
    p1 = c(2,:);
    p2 = c(ia(2),:);
    ang = acos(dot(p1,p2)/(norm(p1)*norm(p2)));
    
    % determine direction to trace along edge
    d1 = acos(dot(vij,[sin(ang2+dang) cos(ang2+dang) 0]));
    d2 = acos(dot(vij,[sin(ang2-dang) cos(ang2-dang) 0]));
    if d1 < d2
        a1 = (ang2+0.01:0.02:ang2+ang-0.01)';    % ccw along edge
    else
        a1 = flipud((ang2-ang+0.01:0.02:ang2-0.01)');    % cw along edge
    end
        
    ac = [cos(a1) sin(a1)];
    c1 = [c(2:ia(2),:); ac; c(2,:)];
    if uvc < 0
        fill(centerX+u,centerY+w,fillcolor)   % fill colored circle
        fill(centerX+sE*c1(:,1),centerY+sN*c1(:,2),[ 1 1 1]) 
    else
        fill(centerX+sE*c1(:,1),centerY+sN*c1(:,2),fillcolor)
    end
     
    % second contour ending spot
    p2 = c(end-1,:);
    ang2 = atan2(p2(2),p2(1));
    
    % mid contour vector
    p1 = c(ia(3)+1,:);
    p2 = c(ia(end)-1,:);
    pmid = 0.5*(p1 + p2);
    ang = atan2(pmid(2),pmid(1));
    vij = [ sin(ang) cos(ang) 0]; 

    % angle between contour ends
    p1 = c(ia(3),:);
    p2 = c(end,:);
    ang = acos(dot(p1,p2)/(norm(p1)*norm(p2)));
    
    % determine direction to trace along edge
    d1 = acos(dot(vij,[sin(ang2+dang) cos(ang2+dang) 0]));
    d2 = acos(dot(vij,[sin(ang2-dang) cos(ang2-dang) 0]));
    if d1 < d2
        a1 = (ang2+0.01:0.02:ang2+ang-0.01)';    % ccw along edge
    else
        a1 = flipud((ang2-ang+0.01:0.02:ang2-0.01)');    % cw along edge
    end    

    ac = [cos(a1) sin(a1)];
    c2 = [c(ia(3):end,:); ac; c(ia(3),:)];
    if uvc < 0
        fill(centerX+sE*c2(:,1),centerY+sN*c2(:,2),'w')        
    else
        fill(centerX+sE*c2(:,1),centerY+sN*c2(:,2),fillcolor)
    end        

end
end

if ~isempty(ctitle)
    text(centerX,centerY+sN*1.1,ctitle,'HorizontalAlignment','center','FontSize',fsize)
end

end

        