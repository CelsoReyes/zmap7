function ploop(var1)
    %ploop.m                          A.Allmann
    %
    %function to calculat the parameters of p-value
    %calls itsself with different parameters for different loops in programm
    %


    global p c k tt pc loop nn pp nit t err1x err2x ieflag isflag
    global pk qp err1 err2 cstep pstep aic ts tend eps1 eps2 tmp1 tmp2
    global sdc sdk sdp cof cog aa bb dk pcheck loopcheck
    global h2 pplot freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button
    global  Info_p close_p print_p he


    if var1==1
        if pp==1.0
            pp=1.001;
        end
        loop=loop+1;
        loopcheck=loopcheck+1;
        pp
        qp=1-pp;
        pk=(qp*nn)/((tt+pc)^qp-(ts+pc)^qp);
        nit=nit+1;
        psum=0;
        psum=sum(1./(t+pc));
        qsum=pk*((1/(tt+pc)^pp)-(1/(ts+pc)^pp));
        esum=qsum+pp*psum;
        err1=esum;
        sumln=0;
        sumln=sum(log(t+pc));
        qsumln=pk/qp^2;
        qsumln=qsumln*(((tt+pc)^qp)*(1-qp*log(tt+pc))-((ts+pc)^qp)*(1-qp*log(ts+pc)));
        esumln=qsumln+sumln;
        err2=esumln;
        cof=pk/qp;
        cog=cof*((ts+pc)^qp);
        qlike=(nn*log(pk))-(pp*sumln)-nn;
        aic=-2*qlike+6;


        %stop searching if errors are small enough
        if abs(err1)< eps1 & abs(err2) <  eps2
            ieflag=1;
            ploop(3);
            pcheck=1;
        end
        if pcheck ~= 1
            %stop searching if steps are small enough
            if cstep <=0.000001 & pstep <= 0.00001
                isflag=1;
                ploop(3);
                pcheck=1;
            end  %if cstep
        end   %if pcheck
        if pcheck ~=1
            if nit>1
                %if error has changed sign,reduce the step size
                if (err1x*err1)<0  &&  cstep>= 0.000001
                    cstep=cstep*0.9;
                end
                if (err2x*err2)<0  &&  pstep>=0.00001
                    pstep=pstep*0.9;
                end
            end   % if nit
            if err1 < 0
                pc=pc+cstep;
            elseif err1>0
                pc=pc-cstep;
            end
            dt=ts+pc;
            if dt<=0
                pc=ts+cstep;
            end
            if loop ==30
                cstep=cstep*0.9;
                loop=0;
            end
            if err2 < 0
                pp=pp+pstep;
            end
            if err2>0
                pp=pp-pstep;
            end
            err1x=err1;
            err2x=err2;
            if loopcheck<500
                ploop(1);
            else;
                p= pp;
            end
            % end
        end   %if pcheck


    elseif var1==3
        te=tt;
        p=pp;
        c=pc;
        dk=pk;

        f=(te+c)^(1-p)-(ts+c)^(1-p);
        bb=(log10(f*dk/(1-p)))/(tmp1-tmp2);
        aa=bb*tmp1;

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
        %start inverting the matrix and calculate the standard deviation
        %for k,c,p .


        A=[s(1) s(2) s(3); s(4) s(5) s(6); s(7) s(8) s(9)];

        A=inv(A);

        sdk=sqrt(A(1,1));
        sdc=sqrt(A(2,2));
        sdp=sqrt(A(3,3));
    end
