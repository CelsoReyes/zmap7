function ploop3(var1)
    %ploop3.m                          B. Enescu
    %Last change   5/2001
    %function to calculat the parameters of p-value
    %calls itsself with different parameters for different loops in program
    %C is fixed. The covariance matrix is 2X2, because there are 2 free parameters,
    %K and p. However, the program AFT (IASPEI software) considers the covariance
    %matrix as 3X3. The procedure in AFT is followed in the m file ploop31.m.
    %If you choose to use ploop31.m, please modify mypval2m.m.


    global p c dk tt loop nn nit t err1x err2x ieflag isflag
    global pp pc pk qp err1 err2 cstep pstep aic ts eps1 eps2
    global sdc sdk sdp cof cog pcheck loopcheck
    global h2 he

report_this_filefun(mfilename('fullpath'));
    %%
    % pp = initial p = 1.1
    % nn = length of catalog (# of events)
    % tt = end time (last event)
    % ts = start time (1st event)
    % pc = initial c???
    % t  = time of each event (a vector)
    %%

    if var1==1
        if pp==1.0
            pp=1.001;
        end

        loopcheck=loopcheck+1;
        qp=1-pp;
        pk=(qp*nn)/((tt+pc)^qp-(ts+pc)^qp);
        nit=nit+1;

        %%
        %psum=0;
        %psum=sum(1./(t+pc));
        %qsum=pk*((1/(tt+pc)^pp)-(1/(ts+pc)^pp));
        %esum=qsum+pp*psum;
        %err1=esum;
        %%

        sumln=0;
        sumln=sum(log(t+pc));
        qsumln=pk/qp^2;
        qsumln=qsumln*(((tt+pc)^qp)*(1-qp*log(tt+pc))-((ts+pc)^qp)*(1-qp*log(ts+pc)));
        esumln=qsumln+sumln;
        err2=esumln;
        cof=pk/qp;
        cog=cof*((ts+pc)^qp);
        qlike=(nn*log(pk))-(pp*sumln)-nn;
        aic=-2*qlike+4;


        %stop searching if errors are small enough
        if (abs(err2) <  eps2)  % eps2 = .001
            ieflag=1;
            ploop3(3);
            pcheck=1;
        end

        if pcheck ~= 1
            %stop searching if steps are small enough
            if (pstep <= 0.0001)
                isflag=1;
                ploop3(3);
                pcheck=1;
            end;  %if cstep
        end;   %if pcheck

        if pcheck ~=1

            if nit>1
                %if error has changed sign,reduce the step size
                if ((err2x*err2)<0  &&  pstep>=0.0001)
                    pstep=pstep*0.9;
                end
            end;   % if nit


            if err2 < 0 % still going so advance the step towards 0
                pp=pp+pstep;
            end
            if err2>0
                pp=pp-pstep; % still going so advance the step towards 0
            end

            %store current errors
            err2x=err2;

            if loopcheck<500
                ploop3(1);
            else;
                p= pp;
            end
        end   %if pcheck


    elseif var1==3
        te=tt;
        p=pp;
        c=pc;
        dk=pk;



        %case1
        f1=((te+c)^(-p+1))/(-p+1);
        h1=((ts+c)^(-p+1))/(-p+1);
        s(1)=(1/dk)*(f1-h1);


        %case2


        f3=(-(te+c)^(-p+1))*(((log(te+c))/(-p+1))-(1/((-p+1)^2)));
        h3=(-(ts+c)^(-p+1))*(((log(ts+c))/(-p+1))-(1/((-p+1)^2)));
        s(2)=f3-h3;


        %case3

        s(3)=s(2);


        %case4

        f10=((te+c)^(-p+1))*((log(te+c))^2)/(-p+1);
        f11=(2*((te+c)^(-p+1)))/((-p+1)^2);
        f12=(log(te+c))-(1/(-p+1));
        f9=f10-(f11*f12);

        h10=((ts+c)^(-p+1))*((log(ts+c))^2)/(-p+1);
        h11=(2*((ts+c)^(-p+1)))/((-p+1)^2);
        h12=(log(ts+c))-(1/(-p+1));
        h9=h10-(h11*h12);
        s(4)=(dk)*(f9-h9);


        %assign the values of s to the matrix a(i,j)
        %start inverting the matrix and calculate the standard deviation
        %for k and p .


        ainv=[s(1) s(2); s(3) s(4)];

        ainv=inv(ainv);

        sdk=sqrt(ainv(1,1));
        sdp=sqrt(ainv(2,2));

    end
