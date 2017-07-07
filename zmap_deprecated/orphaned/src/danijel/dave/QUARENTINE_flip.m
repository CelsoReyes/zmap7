function y=flip(x)
%   function y=flip(x)
%   reverses the order of the elements of a vector, first->last, etc.
%   ddj 02 08 26
n=length(x);
for i=1:n
  y(i)=x(n+1-i);
end
