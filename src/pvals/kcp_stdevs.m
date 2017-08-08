function [sdk, sdp, sdc] = kcp_stdevs()
    % calculate standard deviations for k, c, and p values
    %kcp_stdevs.m                          A.Allmann
    %
    %function to calculat the parameters of p-value
    %calls itself with different parameters for different loops in programm
    
    
    global p c tt pc pp 
    global pk ts dk 
    
    te=tt;
    p=pp;
    c=pc;
    dk=pk;
    
    %case1
    f1=((te+c)^(-p+1))/(-p+1);
    h1=((ts+c)^(-p+1))/(-p+1);
    s(1)=(1/dk)*(f1-h1);
    
    %case2
    f2=((te+c)^(-p));
    h2=((ts+c)^(-p));
    s(2)=f2-h2;
    
    %case3
    
    
    f3=(-(te+c)^(-p+1))*(((log(te+c))/(-p+1))-(1/((-p+1)^2)));
    h3=(-(ts+c)^(-p+1))*(((log(ts+c))/(-p+1))-(1/((-p+1)^2))); 
    s(3)=f3-h3;
    
    %case4
    
    s(4)=s(2);
    
    %case5
    
    f5=((te+c)^(-p-1))/(p+1);
    h5=((ts+c)^(-p-1))/(p+1);
    s(5)=(-dk)*(p^2)*(f5-h5);
    
    %case6
    
    
    f6=((te+c)^(-p))*(((log(te+c))/(-p))-(1/(p^2)));
    h6=((ts+c)^(-p))*(((log(ts+c))/(-p))-(1/(p^2)));
    s(6)=(dk*p)*(f6-h6);
    
    %case7
    
    s(7)=s(3);
    
    %case8
    
    s(8)=s(6);
    
    %case9
    
    f10=((te+c)^(-p+1))*((log(te+c))^2)/(-p+1);
    f11=(2*((te+c)^(-p+1)))/((-p+1)^2);
    f12=(log(te+c))-(1/(-p+1));
    f9=f10-(f11*f12);
    
    h10=((ts+c)^(-p+1))*((log(ts+c))^2)/(-p+1);
    h11=(2*((ts+c)^(-p+1)))/((-p+1)^2);
    h12=(log(ts+c))-(1/(-p+1));
    h9=h10-(h11*h12);
    s(9)=(dk)*(f9-h9);
    
    
    %assign the values of s to the matrix A(i,j)
    %invert the matrix to calculate the standard deviation
    %for k,c,p .
    
    if nargout == 3
        A=[s(1) s(2) s(3); s(4) s(5) s(6); s(7) s(8) s(9)];

        A=inv(A);

        sdk=sqrt(A(1,1));
        sdc=sqrt(A(2,2));
        sdp=sqrt(A(3,3));
        
    elseif nargout == 2
        A=[s(1) s(3); s(3) s(9)];
        A=inv(A);
        sdk=sqrt(A(1,1));
        sdp=sqrt(A(2,2));
    else
        error('wrong number of output arguments');
    end
end
