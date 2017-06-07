      parameter (nf0=500)
      character hdr*100
      real strike,dip,rake,ddir,pln1(3),pln2(3),sign
      real f1norm(3,nf0),f2norm(3,nf0),var_est(2),var_avg
      real strike2,dip2,rake2,ddir2
      integer nout,ic
      
      degrad=180./3.1415927

      open (11,file='Xtemp')
      read (11,*) hdr
      do 10 ic=1,nf0
        read (11,*,end=11) ddir,dip,rake
        strike=ddir-90.
        if (strike.lt.-180.) strike=strike+360.
        call GETAUX(strike,dip,rake,strike2,dip2,rake2)
        ddir2=strike2+90.
        if (ddir2.gt.180.) ddir2=ddir2-360.
        sign=1.
        if (rake.lt.0.) sign=-1.
        if (rake.gt.180.) sign=-1.
        f1norm(1,ic)=sin(dip/degrad)*cos(ddir/degrad)
        f1norm(2,ic)=sin(dip/degrad)*sin(ddir/degrad)
        f1norm(3,ic)=cos(dip/degrad)
        f2norm(1,ic)=sign*sin(dip2/degrad)*cos(ddir2/degrad)
        f2norm(2,ic)=sign*sin(dip2/degrad)*sin(ddir2/degrad)
        f2norm(3,ic)=sign*cos(dip2/degrad)
10    continue
11    nout=ic-1      
      close (11)
      call MECH_AVG(nout,f1norm,f2norm,pln1,pln2)  
      call MECH_VAR(nout,f1norm,f2norm,pln1,pln2,var_est)               
      var_avg=(var_est(1)+var_est(2))/2.
      open (11,file='Xtemp.div')
      write (11,*) var_avg
      close (11)
      stop
      end    



c ------------------------------------------------------------ c

c subroutine MECH_AVG determines the average focal mechanism of a set
c   of mechanisms
c
c  Inputs:  nf     =  number of fault planes
c           norm1(3,nf) = normal to fault plane
c           norm2(3,nf) = slip vector
c  Output:  norm1_avg(3)    = normal to avg plane 1
c           norm2_avg(3)    = normal to avg plane 2
c
c    Written  10/4/2000 by Jeanne Hardebeck                              
c    Modified 5/14/2001 by Jeanne Hardebeck                              
c
      subroutine MECH_AVG(nf,norm1,norm2,norm1_avg,norm2_avg)
           
      real dot1,fract1
      real misf,maxmisf,avang1,avang2
      real norm1(3,nf),norm2(3,nf)
      real norm1_avg(3),norm2_avg(3),ln_norm1,ln_norm2
      real theta1,theta2
      integer nf

      pi=3.1415927
      degrad=180./3.1415927
      
c if there is only one mechanism, return that mechanism
   
      if (nf.le.1) then
        do 5 i=1,3
          norm1_avg(i)=norm1(i,1)
          norm2_avg(i)=norm2(i,1)
5       continue
        goto 120
      end if
            
c find the average normal vector for each plane - determine which
c nodal plane of each event corresponds to which running sum by 
c computing the dot product of both nodal planes with the fault  
c plane of the first mechanism and taking the one which is closer

      do 30 j=1,3
        norm1_avg(j)=norm1(j,1)
        norm2_avg(j)=norm2(j,1)
30    continue
      do 50 i=2,nf
        d11=norm1(1,i)*norm1(1,1)+norm1(2,i)*norm1(2,1)+
     &                              norm1(3,i)*norm1(3,1)
        d12=norm1(1,i)*norm2(1,1)+norm1(2,i)*norm2(2,1)+
     &                              norm1(3,i)*norm2(3,1)
        d21=norm2(1,i)*norm1(1,1)+norm2(2,i)*norm1(2,1)+
     &                              norm2(3,i)*norm1(3,1)
        d22=norm2(1,i)*norm2(1,1)+norm2(2,i)*norm2(2,1)+
     &                              norm2(3,i)*norm2(3,1)
        if ((d11*d22.ge.d21*d12).or.(abs(d11).gt.0.99999).or.
     &                              (abs(d22).gt.0.99999)) then
          if (abs(d11).gt.0.000001) then
            isgn=sign(1.,d11)
          else
            isgn=sign(1.,d22)
          end if
          do 40 j=1,3
            norm1_avg(j)=norm1_avg(j)+isgn*norm1(j,i)
            norm2_avg(j)=norm2_avg(j)+isgn*norm2(j,i)
40        continue
        else
          if (abs(d21).gt.0.000001) then
            isgn=sign(1.,d21)
          else
            isgn=sign(1.,d12)
          end if
          do 45 j=1,3
            norm1_avg(j)=norm1_avg(j)+isgn*norm2(j,i)
            norm2_avg(j)=norm2_avg(j)+isgn*norm1(j,i)
45        continue
        end if
50    continue
 
      ln_norm1=0
      ln_norm2=0
      do 60 j=1,3
        ln_norm1=ln_norm1+norm1_avg(j)*norm1_avg(j)
        ln_norm2=ln_norm2+norm2_avg(j)*norm2_avg(j)
60    continue
      ln_norm1=sqrt(ln_norm1)
      ln_norm2=sqrt(ln_norm2)
      do 70 i=1,3
        norm1_avg(i)=norm1_avg(i)/ln_norm1
        norm2_avg(i)=norm2_avg(i)/ln_norm2
70    continue

c determine the RMS observed angular difference between the average 
c normal vectors and the normal vectors of each mechanism

      avang1=0.
      avang2=0.

      do 80 i=1,nf
        d11=norm1(1,i)*norm1_avg(1)+norm1(2,i)*norm1_avg(2)+
     &                              norm1(3,i)*norm1_avg(3)
        d12=norm1(1,i)*norm2_avg(1)+norm1(2,i)*norm2_avg(2)+
     &                              norm1(3,i)*norm2_avg(3)
        d21=norm2(1,i)*norm1_avg(1)+norm2(2,i)*norm1_avg(2)+
     &                              norm2(3,i)*norm1_avg(3)
        d22=norm2(1,i)*norm2_avg(1)+norm2(2,i)*norm2_avg(2)+
     &                              norm2(3,i)*norm2_avg(3)
        if (d11.ge.1.) d11=1.
        if (d11.le.-1.) d11=-1.
        if (d12.ge.1.) d12=1.
        if (d12.le.-1.) d12=-1.
        if (d21.ge.1.) d21=1.
        if (d21.le.-1.) d21=-1.
        if (d22.ge.1.) d22=1.
        if (d22.le.-1.) d22=-1.
        a11=acos(abs(d11))
        a22=acos(sign(1.,d11)*d22)
        a21=acos(abs(d21))
        a12=acos(sign(1.,d21)*d12)
        if (d11*d22.ge.d21*d12) then
          avang1=avang1+a11*a11
          avang2=avang2+a22*a22
        else
          avang1=avang1+a21*a21
          avang2=avang2+a12*a12
        end if
80    continue
      avang1=sqrt(avang1/nf)
      avang2=sqrt(avang2/nf)

c the average normal vectors may not be exactly orthogonal (although
c usually they are very close) - find the misfit from orthogonal and 
c adjust the vectors to make them orthogonal - adjust the more poorly 
c constrained plane more
 
      if ((avang1+avang2).lt.0.0001) goto 120

      maxmisf=0.01
      fract1=avang1/(avang1+avang2)
90    do 115 count=1,100  
        dot1=norm1_avg(1)*norm2_avg(1)+norm1_avg(2)
     &     *norm2_avg(2)+norm1_avg(3)*norm2_avg(3)
        misf=90.-acos(dot1)*degrad
        if (abs(misf).le.maxmisf) goto 120
        theta1=misf*fract1/degrad
        theta2=misf*(1.-fract1)/degrad
        do 100 j=1,3
          temp=norm1_avg(j)
          norm1_avg(j)=norm1_avg(j)-norm2_avg(j)*sin(theta1)
          norm2_avg(j)=norm2_avg(j)-temp*sin(theta2)
100     continue
        ln_norm1=0
        ln_norm2=0
        do 105 j=1,3
          ln_norm1=ln_norm1+norm1_avg(j)*norm1_avg(j)
          ln_norm2=ln_norm2+norm2_avg(j)*norm2_avg(j)
105      continue
        ln_norm1=sqrt(ln_norm1)
        ln_norm2=sqrt(ln_norm2)
        do 110 i=1,3
          norm1_avg(i)=norm1_avg(i)/ln_norm1
          norm2_avg(i)=norm2_avg(i)/ln_norm2
110      continue
115   continue

120   continue      
      return 
      end
      

c ------------------------------------------------------------ c

c subroutine MECH_VAR:  estimate of the variability of a set of mechanisms
c with respect to a given average mechanism
c
c  Inputs:  nf     =  number of fault planes
c           norm1(3,nf) = normal to fault plane
c           norm2(3,nf) = slip vector
c           norm1_avg(3)    = normal to avg plane 1
c           norm2_avg(3)    = normal to avg plane 2
c  Output:  var_est(2) = estimated variability of the two planes, 
c               if >= ~25-30, the mechanisms are a ball of string
c
c
      subroutine MECH_VAR(nf,norm1,norm2,norm1_avg,
     &             norm2_avg,var_est)
           
      parameter (nf0=500)
      real var_est(2),avang1,avang2
      real norm1(3,nf0),norm2(3,nf0)
      real norm1_avg(3),norm2_avg(3)
      integer nf

      pi=3.1415927
      degrad=180./3.1415927
      
c determine the RMS observed angular difference between the average 
c normal vectors and the normal vectors of each mechanism

      avang1=0.
      avang2=0.

      do 80 i=1,nf
        d11=norm1(1,i)*norm1_avg(1)+norm1(2,i)*norm1_avg(2)+
     &                              norm1(3,i)*norm1_avg(3)
        d12=norm1(1,i)*norm2_avg(1)+norm1(2,i)*norm2_avg(2)+
     &                              norm1(3,i)*norm2_avg(3)
        d21=norm2(1,i)*norm1_avg(1)+norm2(2,i)*norm1_avg(2)+
     &                              norm2(3,i)*norm1_avg(3)
        d22=norm2(1,i)*norm2_avg(1)+norm2(2,i)*norm2_avg(2)+
     &                              norm2(3,i)*norm2_avg(3)
        if (d11.ge.1.) d11=1.
        if (d11.le.-1.) d11=-1.
        if (d12.ge.1.) d12=1.
        if (d12.le.-1.) d12=-1.
        if (d21.ge.1.) d21=1.
        if (d21.le.-1.) d21=-1.
        if (d22.ge.1.) d22=1.
        if (d22.le.-1.) d22=-1.
        a11=acos(abs(d11))
        a22=acos(sign(1.,d11)*d22)
        a21=acos(abs(d21))
        a12=acos(sign(1.,d21)*d12)
        if (d11*d22.ge.d21*d12) then
          avang1=avang1+a11*a11
          avang2=avang2+a22*a22
        else
          avang1=avang1+a21*a21
          avang2=avang2+a12*a12
        end if
80    continue
      var_est(1)=sqrt(avang1/nf)*degrad
      var_est(2)=sqrt(avang2/nf)*degrad

      print *,"var_est = ",var_est(1),var_est(2)
     
      return 
      end    


c ------------------------------------------------------------ c

c GETAUX returns auxilary fault plane, given strike,dip,rake
c of main fault plane.  See page 318 of Seth Stein's book.
c rake is measured using A.&R. convention (opposite to the
c slip used by Guy and Freeman).
      subroutine GETAUX(s1deg,d1deg,r1deg,s2,d2,r2)
      degrad=180./3.14159265
      s1=s1deg/degrad
      d1=d1deg/degrad
      r1=r1deg/degrad

      d2=acos(sin(r1)*sin(d1))

      sr2=cos(d1)/sin(d2)
      cr2=-sin(d1)*cos(r1)/sin(d2)
      r2=atan2(sr2,cr2)

      s12=cos(r1)/sin(d2)
      c12=-1./(tan(d1)*tan(d2))
      s2=s1-atan2(s12,c12)

      s2=s2*degrad
      d2=d2*degrad
      r2=r2*degrad

      if (d2.gt.90.) then
         s2=s2+180.
         d2=180.-d2
         r2=360.-r2
      end if
      if (s2.gt.360.) s2=s2-360.

      return
      end 


