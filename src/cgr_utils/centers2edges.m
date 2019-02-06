function [xs, ys, values]=centers2edges(xs, ys, values)
    % CENTERS2EDGES converts matrices of measurement centers to cells with measurements at center
    %
    % edges=CENTERS2EDGES(centers) returns the edges of each bin, for a vector CENTERS containing
    % the center of each bin.  for centers of length N, edges will be of length N+1. edges for the 
    % first and last bin, are symmetrical about each bin's center.
    %
    % [xs, ys,values]=CENTERS2EDGES(xs, ys, values) 2-dimensional version. xs and ys are
    % matrices of the same size
    %
    % Pcolor typically uses the points as edges, and ignores the last values.
    %
    % warning, shading interp might look pretty, but it will shift items and is inaccurate.
    % instead, use 2interp
    %
    % ex.
    %  >> centers2edges([0 2 4 8])
    %  ans =
    %      -1     1     3     6    10
    %
    % see also EDGES2CENTERS, HISTCOUNTS, HISTOGRAM
    
    if nargout ~= nargin
        error('Each input should have a corresponding output');
    end
    
    if nargin==1 && isvector(xs)
        if isempty(xs)
            % nothing to do. return the empty value
        else
            if numel(xs) <2
                error('need at least 2 centers to determine bin size')
            end
            half_dx = diff(xs) ./ 2;
            if any(half_dx <= 0)
                error('values should be in ascending order');
            end
            half_dx = [-half_dx(1); half_dx(:); half_dx(end)];
            xs(2:end+1)=xs;
            xs = xs + reshape(half_dx,size(xs));
        end
    else
        if ~isequal(size(xs), size(ys))
            error('X and Y matrices should be same size');
        end
        if min(size(xs) ==1)
            error('X and Y must be matrices, not vectors');
        end
        % expand grid in each direction so that xs and ys are in the centers
        half_dx = diff(xs,[],2) ./ 2;
        if any(half_dx <= 0)
            error('X vector should be in ascending order') 
        end
        half_dx = [-half_dx(:,1) , half_dx , half_dx(:,end)];
        xs=[xs(:,1), xs] + half_dx;
        xs(end+1,:)=xs(end,:);
        
        half_dy = diff(ys,[],1) ./ 2;
        
        if any(half_dx <= 0)
            error('Y vector should be in ascending order');
        end
        half_dy = [-half_dy(1,:) ; half_dy ; half_dy(end,:)];
        ys=[ys(1,:); ys] + half_dy;
        ys(:,end+1)=ys(:,end);
        
        if exist('values','var')
            assert(isequal(size(xs)-1,size(values)),'size of VALUES doesn''t match X and Y matrices');
            values(end+1,:)=nan;
            values(:,end+1)=nan;
        elseif nargout >=3
            error('Values will only be returned if provided');
        end
    end
end