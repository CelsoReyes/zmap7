function nsquake=simulate(Nquake,lamda, nsim)
    % Distributes Nquakes events in cells with probability proportional to lamda
    %   function nsquake=simulate(Nquake,lamda, nsim)
    %   Distributes Nquakes events in cells with probability proportional to lamda
    %   Nquake is a scalar
    %   lamda is a vector of rates, with length ncell;
    %   nsim is the number of simulations to calculate
    %   result nsquake is a matrix with nsim columns; each element is the simulated number of events
    %   in that cell for that simulation
    %   Assu;mes Poisson occurrence
    %   ddj 2002/08/26
    ncell=length(lamda);
    R=rand(Nquake,nsim);
    %   make sure lamda is a column vector
    [n,m]=size(lamda);
    if n==1
        lamda=lamda';
    end
    lamcum=cumsum(lamda)/sum(lamda);
    edges=[0,lamcum'];
    H=histc(R,edges,1);
    nsquake=H(1:ncell,:);%strips off last row of zeros put in by histc
end