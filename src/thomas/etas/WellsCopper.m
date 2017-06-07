function [l,w] = WellsCopper(M,FL)

%This short code gives a fault's length and width, according to its
%magnitude, in accordance with Wells & Coppersmith (1994) average equations
%(over all focal mechs).
% FL : faktor zur multiplikation von l und w (see felzer2006 oder 2007)

logL = -2.44 + 0.59*M;

L = 10.^logL;

logW = -1.01 + 0.32*M;

W = 10.^logW;

l = FL*L;

w = FL*W;
