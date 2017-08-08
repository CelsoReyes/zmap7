function [in,bnd] = inpoly(p,node,cnect)

% Determine which points are inside a 2D polygonal region via the crossing
% number test. Should be much faster than inpolygon.
%
% TWO INPUT CALL:
%
%   [in,bnd] = inpoly(p,node)
%
% The first input is an Nx2 vector defining the points to be tested:
%
%   p = [x1,y1; x2,y2; etc]
%
% The second input defines the vertices of the polygon, which are assumed
% to be passed in consectutive order (so that the 1st is joined to the 2nd
% and so on):
%
%   node  = [x1,y1; x2,y2; etc], endpoints of boundaries
%
% Two length N logical arrays 'in' and 'bnd' are returned. The first is
% true for points inside and on the boundaries of the region, while the
% second is true for points on the boundary only.
%
% THREE INPUT CALL:
%
%   [in,bnd] = inpoly(p,node,cnect)
%
% Where the extra input explicitly defines the connectivity of the polygon:
%
%   cnect = [n1,n2; n2,n3; etc], boundary connectivity via node numbers
%
% This syntax is much more general and allows the specification of multiply
% connected domains (polygons with "islands").
%
% Type "polydemo" to see some examples.
%
% See also INPOLYGON

% The crossing number test determines point inclusion by counting the
% number of times a line from a point cuts the geometry of the polygon. If
% the count is even the point is outside, odd inside. Special care needs to
% be taken on boundaries and at the polygon vertices.
%
% This code gains efficiency by partitioning the test into a series of
% stages. The xy co-ordinates of each point is first checked against the
% bounding box for each wall so the expensive line intersection checking
% need only be done for points that are close to the boundaries.
%
% Additional efficiency is also gained by initially partitioning the walls
% into two groups, upper and lower, depending on their y co-ordinate. This
% means that, in general, only half the walls need to be checked for each
% point.
%
% Google "crossing number test" for more info.
%
% Darren Engwirda - 2006 (d_engwirda@hotmail.com)
%
% P.S: Don't try and tell me a vectorised code will be faster, it isn't,
% I've checked. Escpecially as of R14 loop based code can be significantly
% faster, espec when involving scalar boolean &&, ||, etc. Anyway, sorry,
% but that's my little rant...
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE 18/03/2006:
%
% Added output 'bnd' which is a length N logical array that is true for
% points on the boundaries of the polygon, as per MATLAB's INPOLYGON. It
% should be noted though, that detection of points "exactly" on the
% boundaries is prone to round-off error (This is also true of INPOLYGON).
%
% Also changed I/O so that if 'cnect' is not passed it is built by assuming
% the nodes are in consecutive order.
%
% Many thanks to Urs Schwarz and John D'Errico.

% I/O checking
if (nargin<2) || (nargin>3)
    error('Wrong number of inputs')
end
if nargout>2
    error('Wrong number of outputs')
end

% Error checking
if (size(p,2)~=2) || (size(node,2)~=2)
    error('Wrong input dimensions')
end

% Deal with connectivity
if nargin==2
    % Assume consecutive nodes if cnect not passed.
    n_nodes    = size(node,1);
    cnect = [(1:n_nodes-1)',(2:n_nodes)'; n_nodes,1];
else
    if size(cnect,2)~=2
        error ('Wrong input dimensions')
    end
    if (max(cnect(:))>size(node,1)) || (min(cnect(:))<=0)
        error('cnect is not a valid connectivity for node')
    end
end


% MAIN METHOD
n   = size(p,1);
tol = sqrt(eps);

% Setup walls (wall = [x1 y1 x2 y1; etc])
wall = [node(cnect(:,1),:),node(cnect(:,2),:)];
numw = size(wall,1);
mnyp = sum([wall(:,2); wall(:,4)])/(2*numw);

% Sort walls by y values
[w,i] = sort(min(wall(:,[2 4]),[],2));
[w,j] = sort(max(wall(:,[2 4]),[],2));

% Wall endpoints (not sorted)
Cb = wall(i,1); Db = wall(i,2); Eb = wall(i,3); Fb = wall(i,4);
Ct = wall(j,1); Dt = wall(j,2); Et = wall(j,3); Ft = wall(j,4);

% Wall endpoints (sorted - left, bottom, right, top)
x1b = min(Cb,Eb); y1b = min(Db,Fb); x2b = max(Cb,Eb); y2b = max(Db,Fb);
x1t = min(Ct,Et); y1t = min(Dt,Ft); x2t = max(Ct,Et); y2t = max(Dt,Ft);

% Endpoint for test lines
X = max(node(:,1))+sqrt(tol);

% Test each point in p
in  = false(n,1);
bnd = in;
i   = 1;
while i<=n

    % Current point
    x = p(i,1);
    y = p(i,2);

    % Initialise
    cn = 0;
    on = false;

    % If the point is in the effective lower half
    if y<=mnyp

        % Loop through walls bottom to top
        j = 1;
        while j<=numw

            % Partition the test
            if y>=y1b(j)
                if y<=y2b(j)
                    if x>=x1b(j)
                        if x<=x2b(j)
                            % True if on wall
                            c = Cb(j); d = Db(j);
                            e = Eb(j); f = Fb(j);
                            on = on || (abs((f-y)*(c-x)-(d-y)*(e-x))<tol);
                            if ~on && (y~=y2b(j))
                                % Check crossing
                                ub = ((e-c)*(d-y)-(f-d)*(c-x))/(-(X-x)*(f-d));
                                cn = cn + double((ub>-tol) && (ub<(1+tol)));
                            end
                        end
                    elseif y~=y2b(j)
                        % Has to cross
                        cn = cn+1;
                    end
                end
            else
                % Due to the sorting
                break
            end

            % Wall counter
            j = j+1;

        end

    % If the point is in the effective top half
    else

        % Loop through walls top to bottom
        j = numw;
        while j>0
            % Partition the test
            if y<=y2t(j)
                if y>=y1t(j)
                    if x>=x1t(j)
                        if x<=x2t(j)
                            % True if on wall
                            c = Ct(j); d = Dt(j);
                            e = Et(j); f = Ft(j);
                            on = on || (abs((f-y)*(c-x)-(d-y)*(e-x))<tol);
                            if ~on && (y~=y2t(j))
                                % Check crossing
                                ub = ((e-c)*(d-y)-(f-d)*(c-x))/(-(X-x)*(f-d));
                                cn = cn + double((ub>-tol) && (ub<(1+tol)));
                            end
                        end
                    elseif y~=y2t(j)
                        % Has to cross
                        cn = cn+1;
                    end
                end
            else
                % Due to the sorting
                break
            end

            % Wall counter
            j = j-1;

        end

    end

    % Point is inside if cn is odd or if it is on a wall
    in(i) = mod(cn,2) || on;

    % On wall
    bnd(i) = on;

    % Counter
    i = i+1;

end

return
