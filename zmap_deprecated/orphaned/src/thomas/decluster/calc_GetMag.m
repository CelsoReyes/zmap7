function m = calc_GetMag(L,Mmin,maxm)
%Getting aftershock magnitudes

m = Mmin - log10(rand(L,1));

x = find(m>maxm);


for i=1:length(x)

    while(m(x(i))>maxm)
        m(x(i)) = Mmin - log10(rand(1));

    end
end
