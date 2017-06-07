c dnstrng.for    []
      character*(*) function dnstrng(array)
c
c  program to change string to uppercase
c
c  array - a character variable
      character*(*) array
      integer offset
      data offset/32/
c
c  get length of array
c
      dnstrng = ' '
      lenstr = len(array)
      if (lenstr .eq. 0) return
      do 10 i = 1, lenstr
        ic = ichar(array(i:i))
        if ((ic .ge. 65) .and. (ic .le. 90)) then
          dnstrng(i:i) = char(ic + offset)
        else
          dnstrng(i:i) = array(i:i)
        endif
   10 continue
      return
      end
c end dnstrng
	function raskk (prompt,dflt)
c
c--askr prompts then reads a real value from the terminal.
c--the default value is returned on a cr response.
c	askr   = real response
c	prompt = prompt string
c	dflt   = default supplied on carriage return and
c		 displayed in prompt.
c
	character prompt*(*), temp*20, temp2*20
	integer outunt
	data outunt/0/
	entry askr(prompt,dflt)
	write (temp,1000) dflt
1000	format (g20.5)
	do 2 i=1,20
	  if (temp(i:i).ne.' ') goto 3
2	continue
3	do 4 j=20,1,-1
	  if (temp(j:j).ne.' ')goto 5
4	continue
5	write (outunt,1001) prompt, temp(i:j)
C %% Inserted commas before and after a and before $, JW, 05/05/04
1001	format (1x,a,' [cr=',a,']? ',$)
	read (5,1002,err=5,end=9) temp2
1002	format (a)
	do 6 i=20, 1, -1
	  if (temp2(i:i).ne.' ') goto 7
6	continue
	nch = 0
	goto 8
7	nch = i
8	if (nch.eq.0) then
	  raskk = dflt
	else
	  read (temp2,1003,err=5) raskk
1003	  format (f20.0)
	end if
9	return
	end
	function iaskk(prompt,idflt)
c
c--jask prompts then reads an integer value from the terminal.
c--the default value is returned on a cr response.
c	jask   = integer response
c	prompt = prompt string
c	idflt  = default supplied on carriage return, and
c		 displayed in prompt.
c
	character prompt*(*), temp*20, temp2*20
	integer outunt
	data outunt/0/
	entry jask(prompt, idflt)
	write (temp,1002) idflt
1002	format (i20)
	do 3 i=1,20
	if (temp(i:i).ne.' ') goto 5
3	continue
5	write (outunt,1001) prompt,temp(i:20)
1001	format (1x,a,' [cr=',a,']? ',$)
	read (5,1000,err=5,end=9) temp2
1000	format (a)
	do 6 i=20, 1, -1
	if (temp2(i:i).ne.' ') goto 7
6	continue
	nch = 0
	goto 8
7	nch = i
8	if (nch.eq.0) then
		iaskk = idflt
	else
		read (temp2,1003) iaskk
1003		format (i20)
	end if
9	return
	end
c***********************************************************************
c*                                                                     *
c*               focal mechanism stress inversion package              *
c*                          by john w. gephart                         *
c*                           brown university                          *
c*                                 1985                                *
c*                                                                     *
c***********************************************************************
c
c***********************************************************************
c*                                                                     *
c*  this program arranges the data used in the stress inversion pro-   *
c*  grams in a standard format and tests to ensure orthogonality.      *
c*  data may be read into this program in a variety of formats.        *
c*                                                                     *
c***********************************************************************
c* 12/10/92  jcl
c*  added option to read fpfit .ray file
c*  equivalent solutions are also sent to the output
c*  rake is usually defined positive counter clockwise, looking down at
c*  fault plane.  however, here rake must always be measured downward from
c*  strike direction.  for positive rake, new_rake = 180 - old_rake.
c*  for negative rake, new_rake = abs(rake).
c***********************************************************************
      program datasetup
c   
      character*64  	fn
      character*132  	event
      character*50  	fmt
      character*10  	dnstrng
      character*1  	uq(11)
      real		dan(11)
      real		ddn(11)
      real		san(11)
      integer           ipt(11)
      logical ptchk,skip,wtchk
      dimension az(100000,2),dip(100000,2),oth(100000),q(100000),
     1 wt(100000),cpn(2),
     1 cpe(2),cpd(2),czn(2),cze(2),czd(2),cdet(2),nevent(100000)
      data pi,pi2,rad,hpi /3.1415927,6.2831854,0.017453292,1.570796327/
c
c  select and open file containing fault data in user format
c
	print *, 'welcome to datasetup!'
	print *, 'this program arranges the data used in the stress'
	print *, 'inversion programs in a standard format and tests'
	print *, 'to ensure orthogonality.  data may be read into'
        print *, 'this program in a following format: '
        print *, 'Dip_Direction, Dip, Rake for earthquake'
        print *, '~~~~~~~~~~~~~  ~~~  ~~~~'
        print *, '  The fault plane is unknown!!!!'
c

c*           
c
c  indicate input format of data
c
c     write(*,*)' Enter data type:'
c     write(*,*)'(1) 2 nodal planes'
c     write(*,*)'  az1, dip1, az2, dip2, q wt'
c     write(*,*)'  The fault plane is unknown.'
c     write(*,*)'(2) p & t axes'
c     write(*,*)'  az1, plunge1, az2, plunge2, wt'
c     write(*,*)'  The fault plane is unknown.'
c     write(*,*)'(3) fault slickenside (az, dip, trace, plunge)'
c     write(*,*)'  az1, dip1, trace, plunge, q, wt'
c     write(*,*)'  az2 = mod(trace+90.,360.)'
c     write(*,*)'  dip2 = 90.0 - plunge'
c     write(*,*)'  The fault plane is known.'
c     write(*,*)'(4) fault slickenside (az, dip, trace, wt)'
c     write(*,*)'  The fault plane is known.'
c     write(*,*)'(5) fault slickenside (az, dip, plunge, wt)'
c     write(*,*)'  The fault plane is known.'
c     write(*,*)'(6) fault slickenside (az, dip, rake, wt)'
c     write(*,*)'  The fault plane is known.'
c     write(*,*)'(7) focal mechanism - fpfit .ray file'
c     write(*,*)'  dip_direction, dip, rake'
c     write(*,*)'  The fault plane is unknown.'
c     write(*,*)'(8) Dip_direction, dip, rake for earthquake'
c     write(*,*)'  The fault plane is unknown.'
c
c     read(*,*) kdatatyp
      kdatatyp=8

      write(*,*) ' enter name of input file'
      read(*,499) fn
  499 format(a64)
      open(unit=7,file=fn,status='old')
c
c  select and open listing file (formatted data file)
c
      write(*,*) ' enter name of output file'

      read(*,499) fn
      open(unit=8,file=fn,status='unknown')
c
c  read data into arrays
c
      ndata=0
      nev = 0
      if(kdatatyp .eq. 7) then
        nnp = 1
	fitmax = raskk('maximum discrepancy (%)', 10.)
	minfirst = iaskk('minimum number of first motions', 17)
	amxptarea = raskk('maximum P or T area (%)', 20.)
c read an fpfit .ray file
1031    continue
        read (7, '(1x, a)', end = 6) event
        if (dnstrng(event(1:2)) .ne. 'f*') goto 1031
        read (event, 1033) dd1, da1, sa1, fit, nfirst, star
1033    format (2x, f4.0, f3.0, f4.0, f6.3, 1x, i3, t55, a1)
1035    read (7, '(1x, a)', end = 6) event
        if (dnstrng(event(1:2)) .ne. 'm*') goto 1035
        read (event, 1037) nstar, npline, fmt
1037    format (2x, 2i6, 1x, a)
1040    read (7, '(1x, a)', end = 6) event
        if(dnstrng(event(1:10)) .ne. 'c* p and t') goto 1040
        read(event, '(30x, 2f10.3)') parea, tarea
        nev = nev + 1
        if((nfirst .lt. minfirst) .or. 
     *     (parea .ge. amxptarea) .or.
     *     (tarea .ge. amxptarea) .or.
     *     (fit .ge. fitmax)) goto 1031
        nequiv = 1
	ndata = ndata + 1
        az(ndata,1) = dd1 - 90.
	if(az(ndata,1) .lt. 0.0) az(ndata,1) = az(ndata,1) + 360.
	dip(ndata,1) = da1
c oth is always downward pointing no matter for any direction of motion
	if(sa1 .gt. 0) then
	  oth(ndata) = 180 - sa1
	else
	  oth(ndata) = abs(sa1)
	endif
        wt(ndata) = 1.

c set q according to rake
	if(sa1 .eq. 0.) then
c         left lateral
	  q(ndata) = 4
        else if(sa1 .eq. 180.) then
c         right lateral
          q(ndata) = 3
        else if(sa1 .gt. 0) then
c         reverse
	  q(ndata) = 2
	else
c         normal
	  q(ndata) = 1
        endif
c	print *, 'az dip oth q ', az(ndata,1), 
c    *    dip(ndata,1), oth(ndata), q(ndata)

      	nevent(ndata) = nev
1042    read (7, '(1x, a)', end = 6) event
        if(dnstrng(event(1:2)) .ne. 'b*') goto 1042
c
c read alternate solutions
c
        if (nstar .gt. 0) then
          nline = (nstar - 1)/npline + 1
          do 1050 i = 1, nline
1044        read (7, '(a)', end = 6) event
            if (event(2:2) .eq. '#') goto 1044
            if (i .lt. nline) then
              nread = npline
            else
              nread = mod(nstar-1, npline) + 1
            end if
            read (event(2:132), fmt) (uq(n), ddn(n),
     &      dan(n), san(n), ipt(n), n = 1, nread)
            do 1048 n = 1, nread
              if(uq(n) .eq. 'e') then
c add equivalent solutions to the list
	        ndata = ndata + 1
                nequiv = nequiv + 1
                az(ndata,1) = ddn(n) - 90.
		if(az(ndata,1) .lt. 0.0) 
     *	          az(ndata,1) = az(ndata,1) + 360.
                dip(ndata,1) = dan(n)
	        if(san(n) .gt. 0) then
	          oth(ndata) = 180 - san(n)
	        else
	          oth(ndata) = abs(san(n))
	        endif
	        wt(ndata) = 1.
	        nevent(ndata) = nev
c set q according to rake
                if(sa1 .eq. 0.) then 
c                 left lateral 
                  q(ndata) = 4 
                else if(sa1 .eq. 180.) then 
c                 right lateral 
                  q(ndata) = 3 
                else if(sa1 .gt. 0) then 
c                 reverse 
                  q(ndata) = 2       
                else   
c                 normal 
                  q(ndata) = 1 
                endif  

              endif
1048        continue
            
1050      continue
        end if
        goto 1031
      else if(kdatatyp .eq. 8) then
        nnp = 1
1055    read (7, '(a)', end = 6) event
	if(event .eq. ' ') goto 6
        read (event, *) dd1, da1, sa1
        ndata = ndata + 1
        nevent(ndata) = ndata
        az(ndata,1) = dd1 - 90.
	if(az(ndata,1) .lt. 0.0) az(ndata,1) = az(ndata,1) + 360.
        dip(ndata,1) = da1
        if(sa1 .gt. 0) then
          oth(ndata) = 180 - sa1 
        else
          oth(ndata) = abs(sa1)  
        endif
        wt(ndata) = 1.   
 
c set q according to rake
        if(sa1 .eq. 0.) then
c         left lateral
          q(ndata) = 4
        else if(sa1 .eq. 180.) then
c         right lateral
          q(ndata) = 3
        else if(sa1 .gt. 0) then 
c         reverse
          q(ndata) = 2
        else
c         oblique
          q(ndata) = 1
        endif
c	print *, 'az dip oth q ', az(ndata,1), 
c    *    dip(ndata,1), oth(ndata), q(ndata)
	goto 1055
 
      else
        do 5 j=1,100000
          nevent(j) = j
          if(kdatatyp.eq.1.or.kdatatyp.eq.3) then
            read(7,*,end=6) az(j,1),dip(j,1),az(j,2),dip(j,2),q(j),wt(j)
            nnp=2
            if(kdatatyp.eq.3) then
              az(j,2)=amod(az(j,2)+90.0,360.0)
              dip(j,2)=90.0-dip(j,2)
            endif
         else
            if(kdatatyp.ne.2) then
c              kdatatyp is 4, 5, or 6
               read(7,*,end=6) az(j,1),dip(j,1),oth(j),q(j),wt(j)
               nnp=1
            else
              read(7,*,end=6) az(j,1),dip(j,1),az(j,2),dip(j,2),wt(j)
	      q(j) = 0.0
              nnp=2
	    endif
          endif
          ndata=ndata+1
    5   continue
      endif

    6 if((kdatatyp.le.2) .or. (kdatatyp .ge. 7)) then
         kdata=0
      else
         kdata=ndata
      endif
c
c  write the # of data (ndata) and the # with known fault planes (kdata) 
c  in the formatted data file (output to this program)--for focal mechanism
c  data, assume that no fault planes are known; for fault/slick data,
c  assume that all faults are known
c
      write(8,501) ndata,kdata
  501 format(2(1x,i5))
c
c  resolve the data into cartesian coordinates:  cpn(i), cpe(i), cdp(i)
c
      do 60 j=1,ndata
        do 10 i=1,nnp
          dipr=dip(j,i)*rad
          if(kdatatyp.ne.2) then
             azp=az(j,i)*rad-hpi
             spd=sin(dipr)
             cpd(i)=cos(dipr)
          else
             azp=az(j,i)*rad
    	     spd=cos(dipr)
             cpd(i)=sin(dipr)
          endif
          cpn(i)=cos(azp)*spd
          cpe(i)=sin(azp)*spd
c	  print *, 'direction cosines (n,e,d) = ', 
c    *    i, cpn(i), cpe(i), cpd(i)
   10   continue
c
c  find azimuth or dip of auxiliary plane if unknown (data types 4-7)
c
      if(nnp.eq.1) then
         if(kdatatyp.eq.4) then
	    call plfind(az(j,2),dip(j,2),oth(j),cpn,cpe,cpd)
	 else
	    if(kdatatyp.eq.5) then
	       call trfind(az(j,1),dip(j,1),dip(j,2),oth(j),cpn,
     1          cpe,cpd,skip)
	       if(skip) go to 60
            else
	       call slfrake(az(j,1),oth(j),cpn,cpe,cpd)
c	       print *, 'direction cosines of aux plane (n,e,d) = ', 
c    *         i, cpn(2), cpe(2), cpd(2)
               dip(j,2)=acos(cpd(2))/rad
	    endif
            az(j,2)=amod((atan2(cpe(2),cpn(2))+hpi)/rad+360.0,360.0)
	 endif
      endif
c
c  find wt(j) = combined index for relative weight (magnitude) and
c  sense of slip (sign)
c
      if(q(j).eq.2.0) wt(j)=-wt(j)
      azd=az(j,1)-az(j,2)

      if(q(j).eq.3.0.and.((azd.lt.0.0.and.azd.gt.-180.0).or.
     1 (azd.gt.180.0))) wt(j)=-wt(j)

      if(q(j).eq.4.0.and.((azd.gt.0.0.and.azd.lt.180.0).or.
     1 (azd.lt.-180.0))) wt(j)=-wt(j)

c     write(*,502) az(j,1),dip(j,1),az(j,2),dip(j,2),wt(j)
c 502 format(/,5x,f9.3,1x,f8.3,2x,f9.3,1x,f8.3,1x,f4.1)
      abp0=cpn(1)*cpn(2)+cpe(1)*cpe(2)+cpd(1)*cpd(2)

      if(abs(abp0).lt.1.0e-06.and.kdatatyp.ne.2) go to 50
c
c  find coordinates of b axis:  cxn, cxe, cxd
c
      call ortheq(cpn(1),cpe(1),cpd(1),cpn(2),cpe(2),cpd(2),cxn,
     1 cxe,cxd)
c
c  ra = half-angle of deviation from orthogonality of the two poles;
c  correct by rotating each pole through this angle (in opposite
c  directions) about b axis
c
      ra=0.5*asin(abp0)
      cra=cos(ra)
      sra=sin(ra)
      icount=0
c
c  for each nodal plane, check sign of determinant of coordinates (indicates
c  handedness); if these are the same for the two planes before correction,
c  then the sign of rotation must be changed for one of them
c
c  f not defined the first time through!  jcl  11/14/93
c  added next statement
      f = 1.0
   15 do 20 i=1,2
      call ortheq(cxn,cxe,cxd,cpn(i),cpe(i),cpd(i),cyn,cye,cyd)
      cdet(i)=cyn*cxe*cpd(i)+cpn(i)*cye*cxd+cxn*cpe(i)*cyd-cxn*cpd(i)*
     1 cye-cxe*cpn(i)*cyd-cxd*cpe(i)*cyn
      if(i.eq.2) then
         if(cdet(1)*cdet(2).gt.0.0) f=-1.0
      else
         f=1.0
      endif
c
c  corrected orientation of pole:  czn(i), cze(i), czd(i)
c
      czn(i)=cpn(i)*cra-f*cyn*sra
      cze(i)=cpe(i)*cra-f*cye*sra
      czd(i)=cpd(i)*cra-f*cyd*sra
   20 continue
c
c  test for orthogonality--if fail, change sign of rotation and repeat;
c  if fail on second pass, note in listing file
c
      abp=czn(1)*czn(2)+cze(1)*cze(2)+czd(1)*czd(2)
      if(abs(abp).le.1.0e-06) go to 30
      if(icount.eq.1) then
         write(8,600) j,abp1,abp,' correction failed '
         write(6,*) j,abp1,abp,' correction failed '
  600    format(5x,i4,3x,f7.5,1x,f7.5,a19)
      else
         abp1=abp
         sra=-sra
         icount=1
         go to 15
      endif
c
c  invert vectors that point upward, keep track of flipped vectors--
c  this will require change in sense-of-slip index (wt(i)) in some
c  cases
c
   30 wtchk=.false.
      do 35 i=1,2
      if(czd(i).lt.0.0) then
         czn(i)=-czn(i)
         cze(i)=-cze(i)
         czd(i)=-czd(i)
	 if(kdatatyp.ne.2) wtchk=.not.wtchk
      endif
   35 continue
      if(wtchk) wt(j)=-wt(j)
c
c  find azimuth and dip of (corrected) nodal planes
c
      do 40 i=1,2
      if(kdatatyp.ne.2) then
         az(j,i)=amod(atan2(cze(i),czn(i))+pi2+hpi,pi2)/rad
         dip(j,i)=acos(czd(i))/rad
      else
         az(j,i)=atan2(cze(i),czn(i))
         dip(j,i)=asin(czd(i))
      endif
   40 continue
c
c  find nodal planes and sense-of-slip index for data type # 2
c  (p and t axes)
c
      if(kdatatyp.eq.2) then
         if(dip(j,1).lt.dip(j,2)) wt(j)=-wt(j)
	 if(dip(j,1).eq.dip(j,2)) then
	    ptchk=.true.
	 else
            ptchk=.false.
	 endif
         call ptnp(az(j,1),dip(j,1),az(j,2),dip(j,2),wt(j),ptchk)
      endif
c
c  write corrected data to listing file and screen
c  abp0 = angle between original poles, abpa = angle between corrected
c  poles (should = 90 deg)
c
   50 abpa=acos(abp)/rad
      abp0=acos(abp0)/rad
c     write(8,601) az(j,1),dip(j,1),az(j,2),dip(j,2),wt(j),
c    *  nevent(j)
      write(8,601) az(j,1),dip(j,1),az(j,2),dip(j,2),wt(j)
c     write(*,*) az(j,1),dip(j,1),az(j,2),dip(j,2),wt(j),
c    *  nevent(j),abp0,abpa,j
c 601 format(1x,2(f7.3,1x,f6.3,1x),f4.1,2x,i7,2(1x,f8.5),5x,i3)
  601 format(1x,2(f7.3,1x,f6.3,1x),f4.1,2x,i7,2(1x,f8.5))
   60 continue
   61 close(unit=7)
      close(unit=8)
      end
c
c  find fault plane coordinates for case in which only the trend of
c  the slip vector is known
c
      subroutine plfind(az,dip,oth,cpn,cpe,cpd)
      dimension cpn(2),cpe(2),cpd(2)
      data rad,hpi / 0.017453292,1.5707963 /
      az=amod(oth+90.0,360.0)
      tr=oth*rad
      cn=cos(tr)
      ce=sin(tr)
      plg=atan(abs((cpn(1)*cn+cpe(1)*ce)/cpd(1)))
      azp=oth*rad
      cplg=hpi-plg
      dip=(cplg)/rad
      spd=sin(cplg)
      cpn(2)=cos(azp)*spd
      cpe(2)=sin(azp)*spd
      cpd(2)=cos(cplg)
      return
      end
c
c  find fault plane coordinates for case in which only the plunge of
c  the slip vector is known
c
      subroutine trfind(az,dip1,dip,oth,cpn,cpe,cpd,skip)
      logical skip
      dimension cpn(2),cpe(2),cpd(2)
      data rad,hpi / 0.017453292,1.5707963 /
      skip=.false.
      dip=90.0-abs(oth)
      cpd(2)=cos(dip*rad)
      if(abs(oth).eq.dip1) then
         az2=az*rad+hpi
	 cpn(2)=cos(az2)*cpd(1)
	 cpe(2)=sin(az2)*cpd(1)
	 return
      endif
      cpe12=cpe(1)*cpe(1)
      a=1.0+cpn(1)*cpn(1)/cpe12
      b=2.0*cpn(1)*cpd(1)*cpd(2)/cpe12
      c=cpd(2)*cpd(2)*(cpd(1)*cpd(1)/cpe12+1.0)-1.0
      if((b*b-4.0*a*c).lt.0.0) then
         write(8,*) '**** no solution ****'
         write(*,*) '**** no solution ****'
	 skip=.true.
         return
      else
         cpn(2)=(-b+sqrt(b*b-4.0*a*c))/(a+a)
         cpe(2)=(-cpn(2)*cpn(1)-cpd(1)*cpd(2))/cpe(1)
         az1=az*rad
         caz1=cos(az1)
         saz1=sin(az1)
         aux=cpn(2)*caz1+cpe(2)*saz1
         if(aux*oth.lt.0.0) then
            cpn(2)=(-b-sqrt(b*b-4.0*a*c))/(a+a)
            cpe(2)=(-cpn(2)*cpn(1)-cpd(1)*cpd(2))/cpe(1)
         endif
      endif
      return
      end
c
c  find fault plane coordinates for case in which only the rake of
c  the slip vector is known
c
c  input:
c	az = strike of known nodal plane
c	oth = rake of unknown plane
c	cpn(1), cpe(1), cpd(1) = north, east, down direction cosines of known plane
c  output:
c	cpn(2), cpe(2), cpd(2) = north, east, down direction cosines of unknown plane 

      subroutine slfrake(az,oth,cpn,cpe,cpd)
      dimension cpn(2),cpe(2),cpd(2)
      data rad,hpi / 0.017453292,1.5707963 /
      az1=az*rad
      a1=cos(az1)
      a2=sin(az1)
      call ortheq(cpn(1),cpe(1),cpd(1),a1,a2,0.0,b1,b2,b3)
      tr=tan(oth*rad)
      c1=b1-tr*a1
      c2=b2-tr*a2
      call ortheq(cpn(1),cpe(1),cpd(1),c1,c2,b3,cpn(2),cpe(2),cpd(2))
      return
      end
c
c  find fault plane coordinates for case in which the trend and plunge
c  of the p and t axes are known
c
      subroutine ptnp(az1,pl1,az2,pl2,w,ptchk)
      logical ptchk
      data rad,hpi / 0.017453292,1.5707963 /
      caux=cos(pl1)
      p1=caux*cos(az1)
      p2=caux*sin(az1)
      p3=sin(pl1)
      caux=cos(pl2)
      t1=caux*cos(az2)
      t2=caux*sin(az2)
      t3=sin(pl2)
      call ortheq(p1,p2,p3,t1,t2,t3,b1,b2,b3)
      a1=p1-t1
      a2=p2-t2
      a3=p3-t3
      call ortheq(b1,b2,b3,a1,a2,a3,x1,x2,x3)
      pl1=acos(x3)/rad
      az1=amod(atan2(x2,x1)/rad+450.0,360.0)
      a1=p1+t1
      a2=p2+t2
      a3=p3+t3
      call ortheq(b1,b2,b3,a1,a2,a3,y1,y2,y3)
      pl2=acos(y3)/rad
      az2=amod(atan2(y2,y1)/rad+450.0,360.0)
      if(ptchk) then
         px=p1*x1+p2*x2+p3*x3
	 py=p1*y1+p2*y2+p3*y3
	 if(px*py.lt.0.0) w=-w
      endif
      return
      end
c
c  for any 2 mutually orthogonal (unit) vectors, find the third
c
      subroutine ortheq(x1,x2,x3,y1,y2,y3,z1,z2,z3)
      den=x2*y1-x1*y2
      if((abs(den).ge.0.1.and.abs(x2).ge.0.1).or.abs(x3).lt.0.01)
     1then
        z1=(x3*y2-x2*y3)/den
        z2=-(z1*x1+x3)/x2
        z3=1.0/sqrt(1.0+z1*z1+z2*z2)
   	z1=z1*z3
  	z2=z2*z3
      else
	denom = x3*y2 - x2*y3
	if(denom .ne. 0.0) then
          z2=(x1*y3-x3*y1)/(x3*y2-x2*y3)
  	  z3=-(x1+x2*z2)/x3
  	  z1=1.0/sqrt(1.0+z2*z2+z3*z3)
  	  if(z3.lt.0.0) z1=-z1
  	  z2=z2*z1
  	  z3=z3*z1
	else
          z1 = x2*y3 - y2*x3
          z2 = -x1*y3 + y1*x3
          z3 = x1*y2 - y1*x2
          if(z3 .lt. 0.0) then
            z1 = -z1
            z2 = -z2
            z3 = -z3
          endif
          alen = sqrt(z1*z1 + z2*z2 + z3*z3)
          z1 = z1/alen
          z2 = z2/alen
          z3 = z3/alen
	endif
      endif
      return
      end
