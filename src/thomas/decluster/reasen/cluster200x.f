      program CLUSTER200x
c
C -- PROGRAM CLUSTER2000X  (FOR SUN COMPUTER)
C
C    RECOGNIZE CLUSTERS IN SPACE-TIME IN AN EARTHQUAKE CATALOG
C
C    VERSION CLUSTER2000 IS A MODIFICATION OF CLUSTER5, INCORPORATING
C    YEAR-2000 FORMAT COMPATIBILITY FOR INPUT FILES.
C
C    This code is a pre-release of a Y2K-version, developed for Rob Wesson.
C    It does not implement full Y2K compatibility. For example, the time calculations
C    are NOT Y2K-compatible because the century is ignored, so this code will NOT WORK
C    if the catalog bridges a century change. A real Y2K version is coming, which 
c    will accept catalogs that bridge century change.
c
c    When hypoinverse-2000 format is used:
c	- century is ignored (year in output files is always 19xx)
c	- equivalent events are composed as follows. 
c		- date is date of largest event in cluster (year is always 19xx)
c		- magnitude reflects summed moment of cluster
c		- hypocenter is centroid of cluster
c		- error ellipses and erh,erz are taken from largest event in cluster
c
c 
C
C
C      -  USES HYPOCENTRAL ERROR ESTIMATES IN DISTANCE CALCULATION
C
CC     DESCRIPTION OF VARIABLES:
c
c          list     pointer from event to cluster number
c          nc       number of events in cluster
c          nclust   number of clusters
c          n        index for new cluster number
c          ctim0    time of first event in cluster
c          ctim1    time of largest event in custer
c          ctim2    time of second largest event in cluster
c          clat,clon,cdep   position of 'equivalent event' corresponding
c                   to cluster
c          cmag1    magnitude of largest event in cluster
c          cmag2    magnitude of second largest event in cluster
c          ibigst   event index pointing to biggest event in cluster
c          cdur     duration (first event to last) of cluster
c          cmoment  summed moment of events in cluster
c
c          tau      look-ahead time (minutes) for building cluster.
c          taumin   value for tau when event1 is not clustered
c          rtest    look-around (radial) distance (km) for building cluster
c          r1       circular crack radius for event1
c          rmain    circular crack radius for largest event in current cluster
c
c          xmeff    "effective" lower magnitude cutoff for catalog.
c                   xmeff is raised above its base value 
c                   by the factor xk*cmag1(list(i)) during clusters.
c
c          rfact    number of crack radii (see Kanamori and Anderson,
c                   1975) surrounding each earthquake within which to
c                   consider linking a new event into cluster.
c
c	   mpref    array of 4 integers specifying preferences for 
c		    selection of magnitude from hypoinverse record.
c			mpref(1) is the most prefered value, if it exists.
c			mpref(2) is the next-most prefered,  if it exists.
c			mpref(3) is the third-most prefered, if it exists.
c			mpref(4) is the least-prefered.
c
c	   	    where  1=fmag; 2=amag; 3=BKY-Mag (B); 4=Recalculated ML (L)
c
c		   for example, mpref=(3,1,2,4) means
c		        first use BKY (B) mag.
c			if it doesnt exist, next use fmag 
c			if it doesnt exist, next use amag 
c			if it doesnt exist, use Recalculated ML (L).
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      input/output units:
c          unit 1       scratch file on scr:
c          unit 2       output - cluster summary
c          unit 3       input  - earthquake catalog to read
c          unit 7       output - original catalog, annotated to show 
c                                cluster membership
c          unit 8       output - declustered catalog: original catalog with
c                                clusters removed and replaced by their 
c                                equivalent events.
c          unit 9       output - cluster catalog: all events that belong to 
c                                a cluster (in chronological order, not  
c                                sorted by cluster)
c 
c       call getarg(1, catalog)
      

      dimension clat(9000),clon(9000),cdep(9000)
      dimension cmag1(9000),cmag2(9000),cdur(9000),cmoment(9000)
      dimension mpref(4), zmag(4)
      data  nmag, mpref /4, 3,1,2,4/
      integer*2 ctim0(5,9000),ctim1(5,9000),ctim2(5,9000)
      integer*2 list(250000),nc(9000)
      integer*2 jcent, icent
      integer*2 itime(5),jtime(5),ltime(5),ytim1(5),ytim2(5)
      integer   fore, ibigst(9000), ibigx
      character*1 q1,q2,ichr,ins,iew,insx,iewx,fflag,aflag,cm1,cm2
      character*2 rmk2
      character*5 dum5
      character*3 eid1, eid2
      character*1 blank/' '/
      integer zero /0/
      double precision dif
      character*40 catalog
      character*2 sIY1, sIY2
      character*132 stamp
      logical cluster
      common/a/ rfact,tau
      data list,cmag1/250000*0,9000*0./
!       data tau0,taumin,taumax,p1,xk /2880., 2880., 14400., 0.99, .5/
      integer ierradj
      real p1,xk, xmeff, rfact, tau0,taumin,taumax
!       data xmeff,rfact,ierradj /1.5, 10.0, 1/
      data q1,q2,ins,iew,fflag,aflag /' ',' ',' ',' ',' ',' '/
      nmagrej = 0
      ntimrej = 0
      nquarej = 0
      ifile = 1

C-- OPEN A DIRECT ACCESS SCRATCH FILE FOR CATALOG
      open (1, status='scratch',
     1      access='direct', recl=109)
c     Record length for an unformatted file is specified  in bytes 
c     Records are 109 bytes long



C-vst- READ INPUT DATA FILE
      open(10, file='input.cmn',status='unknown',err=9910)
 9910 write(6, 54)
   54 format ('error reading input file : input.cmn ')
      read(10, '(a)') catalog
      read(10, '(i1)') infmt
      read(10, '(i2)') IY1
      read(10, '(i2)') IY2
      read(10, '(f3.1)') xmeff
      read(10, '(f6.3)') rfact
      read(10, '(f8.3)') tau0
      read(10, '(f10.2)') taumin
      read(10, '(f10.2)') taumax
      read(10, '(f5.2)') p1
      read(10, '(f5.2)') xk

      write (6,*)catalog, infmt, IY1, IY2, xmeff, rfact, tau0,
     1  taumin, taumax, p1, xk
C-- SPECIFY THE SOURCE OF THE DATA
!    20 write (6,1)
!    20 write (6,2) catalog
!     1 format (' Enter catalog filename: ')
!       read (5,2) catalog
!     2 format (a)
    

C-- DECLARE THE DATA FORMAT
!         write (6, 3)
!     3   format (' Data format for input file '/
!      1  '(1=HYPOINV, 2=HYPOINV-2000, 3=HYPO71, 4=HYPO71-2000, 5=FREE):')
!          read (5, *) infmt
!         infmt=4
! 	write (6,*) infmt
! 
! C-- SPECIFY STARTING AND ENDING DATES TO PROCESS
!       write (6, 52) 
!    52 format (' Enter EARLIEST and LATEST YEAR to be accepted: ')
! !       read (5, *) IY1, IY2
!       write(6,*) IY1, IY2
! C-- SPECIFY MINIMUM MAGNITUDE TO ACCEPT
!       write (6, 50) 
!    50 format (' Enter MINIMUM MAGNITUDE to be accepted: ')
!       read (5, *) xmagcut
! 
! C-- SPECIFY KEY PARAMETERS
!       write (6, 51) 
!    51 format (' Enter RFACT value (default=10): ')
!       read (5, *) rfact

C-- SPECIFY HANDLING OF EPICENTRAL ERRORS
!       write (6, 53) 
!    53 format (' Indicate method for treating hypocentral',
!      1  ' location errors: '/' (1=IGNORE ERRORS, 2=ADJUST FOR ERRORS)')
!       read (5, *) ierradj
        ierradj=1
C--  READ DATA FROM THE NAMED CATALOG
        write (6,29) catalog
   29   format (' OPENING USER FILE ', a)
        open (3,file=catalog,status='old')
        irec = 1
        iorec = 1
   31   goto (101, 102, 103, 104, 105) infmt


C--HYPOINVERSE FORMAT - INPUT
  101 READ (3, 13, err=900, END=35) itime,lat1,ins,xlat1,lon1,iew,
     1               xlon1,dep1,amag1,
     1               e1az,e1dip,e1, e2az,e2dip,e2,  
     1               fmag1,eid1,rmk2,
     1               erh1,erz1, cm1,altmag1, cm2,altmag2
   13 FORMAT (5I2,4X,i2,a1,F4.2,i3,a1,
     1       F4.2,F5.2,F2.1,
     1       T50,f3.0,f2.0,f4.2, f3.0,f2.0,f4.2,
     1       T68,F2.1,a3,T77,a2,
     1       t81, 2f4.2, t115, a1, f3.2, 3x, a1, f3.2)
C---Magnitude selection for Hypoinverse according to Dave Oppenheimer
c--Choose magnitude from preference list. Search down the list of mags in
c  the preferred order until a non-zero magnitude is found.
	  zmag(3)=0.
	  zmag(4)=0.
c--Find the Berkeley & local mag if present
	  if (cm1.eq.'B') zmag(3)=altmag1
	  if (cm1.eq.'L') zmag(4)=altmag1
	  if (cm2.eq.'B') zmag(3)=altmag2
	  if (cm2.eq.'L') zmag(4)=altmag2
c--Assemble preference list
	  zmag(1)=fmag1
	  zmag(2)=amag1
c--The preferred mag is the first non-zero one
	  do i=1,nmag
	    xmag1=zmag(mpref(i))
	    if (xmag1.gt.0) goto 108
	  end do
        icent = 19
        GOTO 108 

C--HYPOINVERSE-2000 FORMAT - INPUT
  102 READ (3, 2013, err=900, END=35) icent, itime, lat1,ins,xlat1,
     1               lon1,iew,xlon1,
     1               dep1,amag1,
     1               e1az,e1dip,e1, e2az,e2dip,e2,  
     1               fmag1, eid1, rmk2,
     1               erh1,erz1, cm1,altmag1, cm2,altmag2, 
     1               xmag1
 2013 FORMAT (6i2,4x, i2,a1,F4.2,
     1        i3,a1,F4.2,
     1        F5.2,F3.2, 
     1        T53,f3.0,f2.0,f4.2, f3.0,f2.0,f4.2,
     1        T71,F3.2, a3, T81,a2,
     1        t86, 2f4.2, t123, a1, f3.2, 3x, a1, f3.2,
     1        t148, f3.2)
        GOTO 108 


C--HYPO71 FORMAT - INPUT
  103 read (3, 10, err= 900, END=35) itime,lat1,ins,xlat1,lon1,iew,
     1                              xlon1,dep1,xmag1,erh1,erz1,q1
   10 format (3i2,1x,2i2,6x,i3,a1,f5.2,1x,i3,a1,f5.2,
     1        2x,f5.2,3x,f4.2,18x,f4.1,1x,f4.1,1x,a1)
      icent = 19
      goto 108

C--HYPO71-2000 FORMAT
  104 read (3, 2010, err= 900, END=35) icent,itime,lat1,ins,xlat1,
     1                     lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1
 2010 format (4i2,1x,2i2,6x,i3,a1,f5.2,i4,a1,f5.2,
     1        f7.2,2x,f5.2,17x,2f5.1,1x,a1)
      goto 108

C--FREE FORMAT - INPUT
  105 read (3, *, err= 900, END=35) jyr, itime(2), itime(3),
     1     xjlat, xjlon, xmag1
      icent = 19
      itime(1)=jyr-1900
      itime(4) = 0
      itime(5)=0
      lat1=xjlat
      xlat1=(xjlat-lat1)*60.0
      lon1= -xjlon
      xlon1=(-xjlon-lon1)*60.0
      dep1=0.
      erh1=0.
      erz1=0.
      q1=' '
      iew=' '
      ins=' '
      goto 108

108   irec = irec + 1
c- debug      write (6,*) irec,zmag(1),zmag(2),zmag(3),zmag(4),zmag(5),xmag1

C--     ... ACCEPT ONLY EVENTS PASSING INPUT CRITERIA...

C     APPLY MAGNITUDE CUT:
        if (xmag1 .lt. xmagcut) then
          nmagrej = nmagrej + 1 
          goto 31
        end if
C     REMOVE QUARRY SHOTS:
       if (rmk2(1:1) .eq. 'Q' .or. rmk2(1:1) .eq. 'q' .or.
     1     rmk2(2:2) .eq. 'Q' .or. rmk2(2:2) .EQ. 'q') then
         nquarej = nquarej + 1
         goto 31
       end if
C     APPLY TIME LIMITS:
        if (itime(1) .lt. iy1 .or. itime(1) .gt. iy2) then
          ntimrej = ntimrej + 1
          goto 31
        end if

C--     ...AND WRITE AN UNFORMATTED RECORD TO A SCRATCH DIRECT-ACCESS FILE

c        write (6,*) iorec,itime,dep1,xmag1
c        write (6,*)

        write(1,rec=iorec)icent,itime,lat1,ins,xlat1,lon1,iew,xlon1,
     1             dep1, xmag1,erh1,erz1,q1,dlat1, dlon1, ddep1, rms, 
     2             nst, amag1, aflag, fmag1, fflag, dum5,
     2             e1az,e1dip,e1, e2az,e2dip,e2, eid1

        iorec = iorec + 1
        goto 31

   35   neq = iorec - 1
        inrec = irec - 1
        close (unit=3,status='keep')

      write (6,39) iy1, iy2, xmagcut, inrec, neq, ntimrej, 
     1             nmagrej, nquarej
   39 format ('   RANGE OF YEARS TO ACCEPT: ', I2, ' TO ', I2, /
     1        ' ...USING MINIMUM MAGNITUDE CUTOFF = ', F5.2 /
     1        i12, '   EVENTS READ', / 
     2        i12, '   EVENTS ACCEPTED' / 
     3        i12, '   EVENTS WERE OUTSIDE TIME WINDOW' /
     4        i12, '   EVENTS WERE REJECTED FOR MAGNITUDE' /
     5        i12, '   EVENTS WERE REJECTED AS QUARRY BLASTS')

      if (ierradj .eq. 1) write (6, 37) 
   37 format ('   LOCATION ERRORS IGNORED in distance calculations')
      if (ierradj .eq. 2) write (6, 38)
   38 format ('   LOCATION ERRORS SUBTRACTED in distance calculations')


C-- GET TO WORK
      i=0
      n=0
      nclust=0
      open (2,file='cluster.out',status='new')
      open (7,file='cluster.ano',status='new')
      open (8,file='cluster.dec',status='new')
      open (9,file='cluster.clu',status='new')

c--- process one event at a time

c     get the ith event
  100 i=i+1
      read(1,rec=i,err=500)icent,itime,lat1,ins,xlat1,lon1,iew,xlon1,
     1             dep1, xmag1,erh1,erz1,q1,dlat1, dlon1, ddep1, rms, 
     2             nst, amag1, aflag, fmag1, fflag, dum5,
     2             e1az,e1dip,e1, e2az,e2dip,e2, eid1

c      write (6,*) i,itime,dep1,xmag1

      if (mod(i,1000) .ne. 0) goto 115
      call fdate (stamp)
      write (6,110) stamp(11:20), icent,itime, i, nclust
  110 format (2x, a, '  (',4i2,1x,2i2, ')', i10, 
     1       ' events read',i6,' clusters found')
      
  115 continue

c---- calculate tau (days), the look-ahead time for event 1.
c     When event1 belongs to a cluster, tau is a function of
c     the magnitude of and the time since the largest event in the
c     cluster.  When event1 is not (yet) clustered, tau = TAU0
c  set look-ahead time (in minutes) if event1 is not yet clustered
      if (list(i) .ne. 0) goto 32
   30 tau = TAU0
      goto 40

c  calculate look-ahead time for events belonging to a cluster
   32 do 33 it=1,5
   33 jtime(it) = ctim1(it,list(i))
      call tdif(jtime,itime,dif)
      t=dif
      if (t .le. 0.) goto 30

      deltam = (1.-xk)*cmag1(list(i)) - xmeff
      denom = 10.**((deltam-1.)*2./3.)
      top = -alog(1.-p1)*t
      tau = top/denom
c  truncate tau to not exceed taumax, OR DROP BELOW TAUMIN
      if (tau .gt. taumax) tau = taumax
      IF (TAU .LT. TAUMIN) TAU = TAUMIN

   40 continue

c     keep getting jth events until dif > tau
      j=i
  200 j=j+1

c--   skip the jth event if it is already identified as being part of
c     the cluster associated with the ith event
      if (list(j) .eq. list(i) .and. list(j) .ne. 0) goto 200

      read(1,rec=j,err=400)jcent,jtime,lat2,ins,xlat2,lon2,iew,xlon2,
     1             dep2, xmag2,erh2,erz2,q2,dlat2, dlon2, ddep2, rms, 
     2             nst, amag2, aflag, fmag2, fflag, dum5,
     2             e1az2,e1dip2,e12, e2az2,e2dip2,e22, eid2

c      write (6,*) j,jtime,dep2,xmag2

c--- test for temporal clustering
  208 call tdif (itime, jtime, dif)

c--debug      write (6,*) i,j,itime,jtime,lat1,xlat1,lon1,xlon1,
c--debug     1            lat2,xlat2,lon2,xlon2,list(i), dif, tau

      if (dif .gt. tau) goto 400

c--- test for spatial clustering
      call ctest(itime,lat1,xlat1,lon1,xlon1,dep1,xmag1,erh1,erz1,q1,
     1           jtime,lat2,xlat2,lon2,xlon2,dep2,xmag2,erh2,erz2,q2,
     2           cmag1(list(i)),cluster,ierradj)

      if (cluster .eqv. .false.) goto 200

c---- cluster declared
c     if event i and event j are both already associated with 
c     clusters, combine the clusters.
      if (list(i) .ne. 0 .and. list(j) .ne. 0) goto 375

c     if event i is already associated with a cluster, add event j to it
      if (list(i) .ne. 0) goto 300

c     if event j is already associated with a cluster, add event i to it
      if (list(j) .ne. 0) goto 280

c--- initialize new cluster
      n=n+1
      nclust=nclust+1
      list(i)=n
      clat(n)=lat1+xlat1/60.
      clon(n)=lon1+xlon1/60.
      cdep(n)=dep1
      nc(n)=1
      ibigst(n) = i
      cmag1(n)=xmag1
      cmag2(n)=-2.
      cmoment(n)=10**(1.2*xmag1)
      do 250 it=1,5
      ctim1(it,n)=itime(it)
      ctim2(it,n)=0
  250 ctim0(it,n)=itime(it)
      goto 300

c--- prepare to add ith event to existing cluster
  280 l=i
      k=list(j)
      lat=lat1
      xlat=xlat1
      lon=lon1
      xlon=xlon1
      xmag=xmag1
      ibigx = i
      dep=dep1
      do 285 it=1,5
  285 ltime(it)=itime(it)
      goto 320

c--- prepare to add jth event to existing cluster
  300 l=j
      k=list(i)
      lat=lat2
      xlat=xlat2
      lon=lon2
      xlon=xlon2
      dep=dep2
      xmag=xmag2
      ibigx = j
      do 305 it=1,5
  305 ltime(it)=jtime(it)

c---- add new event to cluster
  320 nc(k)=nc(k)+1
      w1=(nc(k)-1.)/nc(k)
      w2=  1.0/nc(k)
      list(l)=k

c     update cluster focal parameters
      clat(k)=clat(k)*w1 + (lat+xlat/60.)*w2
      clon(k)=clon(k)*w1 + (lon+xlon/60.)*w2
      cdep(k)=cdep(k)*w1 + dep*w2

c     update other cluster parameters
      cmoment(k)=cmoment(k) + 10**(1.2*xmag)
      if (xmag .gt. cmag1(k)) goto 350
      if (xmag .le. cmag2(k)) goto 200

c     current event is second largest event in cluster k
      cmag2(k)=xmag
      do 330 it=1,5
  330 ctim2(it,k)=ltime(it)
      goto 200

c     current event is largest in cluster k
  350 cmag2(k)=cmag1(k)
      cmag1(k)=xmag
      ibigst(k) = ibigx
      do 355 it=1,5
      ctim2(it,k)=ctim1(it,k)
  355 ctim1(it,k)=ltime(it)
      goto 200

c---- combine existing clusters by merging into earlier cluster
c     and keeping earlier cluster's identity
  375 k=list(i)
      l=list(j)

      if (k. lt. l) goto 376
      k=list(j)
      l=list(i)
c     merge cluster l into cluster k
  376 w1=float(nc(k))/float((nc(k)+nc(l)))
      w2=float(nc(l))/float((nc(k)+nc(l)))
      clat(k)=clat(k)*w1 + clat(l)*w2
      clon(k)=clon(k)*w1 + clon(l)*w2
      cdep(k)=cdep(k)*w1 + cdep(l)*w2
      cmoment(k)=cmoment(k) + cmoment(l)
      do 380 ii=1,neq
  380 if (list(ii) .eq. l) list(ii)=k
      nc(k)=nc(k)+nc(l)
      nc(l)=0
      nclust=nclust-1

c     identify largest and second largest magnitude events in
c     merged cluster
      if (cmag1(k) .ge. cmag1(l)) then
            ymag1=cmag1(k)
            ibigx = ibigst(k)
            do 382 it=1,5
  382       ytim1(it)=ctim1(it,k)
            if (cmag1(l) .gt. cmag2(k)) then
                  ymag2=cmag1(l)
                  do 383 it=1,5
  383             ytim2(it)=ctim1(it,l)
            else
                  ymag2=cmag2(k)
                  do 384 it=1,5
  384             ytim2(it)=ctim2(it,k)
            end if
      else
            ymag1=cmag1(l)
            ibigx = ibigst(l)
            do 392 it=1,5
  392       ytim1(it)=ctim1(it,l)
            if (cmag1(k) .ge. cmag2(l)) then
                  ymag2=cmag1(k)
                  do 393 it=1,5
  393             ytim2(it)=ctim1(it,k)
            else
                  ymag2=cmag2(l)
                  do 394 it=1,5
  394             ytim2(it)=ctim2(it,l)
            end if
      end if

      cmag1(k)=ymag1
      cmag2(k)=ymag2
      ibigst(k) = ibigx
      do 395 it=1,5
      ctim1(it,k)=ytim1(it)
  395 ctim2(it,k)=ytim2(it)

c     update duration of merged event
      do 396 it=1,5
  396 jtime(it)=ctim0(it,k)
      call tdif(jtime,itime,dif)
      cdur(k)=dif/1440.

      goto 200
c
c---- finish processing ith event
  400 if (list(i) .eq. 0) goto 100

c     update duration of cluster k for event i
      do 360 it=1,5
  360 jtime(it)=ctim0(it,list(i))
      call tdif(jtime,itime,dif)
      cdur(list(i))=dif/1440.
      goto 100

c---- entire catalog has been searched
c     output results

  500 neqcl = 0
      do 502 i=1,neq-1
  502 if (list(i) .ne. 0) neqcl=neqcl+1

      call fdate (stamp)

      do 680 i=1,neq

C-- MAIN OUTPUT LOOP
      read (1, rec=i) icent,itime,lat1,ins,xlat1,lon1,iew,xlon1,
     1                dep1,xmag1,erh1,erz1,q1,dlat1, dlon1,
     2   ddep1, rms, nst, amag1, aflag, fmag1, fflag, dum5,
     3   e1az,e1dip,e1, e2az,e2dip,e2, eid1

      icr = 43
      if (list(i).ne.0) icr = mod(list(i)-1,26)+65
      ichr = char(icr)

C-------- OUTPUT FORMATS--------------------------------------
c--------- HYPOINVERSE
611   format (5i2.2, t15,i2,a1,i4,i3,a1,i4,i5, 
     1        t50,i3,i2,i4,i3,i2,i4,i2,a3,
     2        t81,2i4, t129,i10,a1)
C--------- HYPOINVERSE-2000
612   format (6i2.2, t17,i2,a1,i4, 
     1        i3,a1,i4, i5,
     1        t53, i3,i2,i4, i3,i2,i4,  i3,a3,
     1        t86, 2i4, t137,i10,a1, i3)
C--------- HYPO71
613   format (3i2.2,1x,2i2.2,6x,i3,a1,f5.2,1x,i3,a1,f5.2,
     1        2x,f5.2,3x,f4.2,18x,f4.1,1x,f4.1,1x,a1, 
     1        t82,i10,1x,a1)
C--------- HYPO71-2000
614   format (4i2.2,1x,2i2.2,6x,i3,a1,f5.2,1x,i3,a1,f5.2,
     1        2x,f5.2,3x,f4.2,18x,f4.1,1x,f4.1,1x,a1, 
     1        t84,i10,1x,a1)
C--------------------------------------------------------------


CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C   DECLUSTERED CATALOG - ONLY UNCLUSTERED EVENTS
      if (list(i) .ne. 0) goto 630

600   goto (601, 602, 603, 604, 605) infmt

c HYPOINVERSE format for output
601   write (8, 611) itime,lat1,ins,int(100*xlat1+0.5),
     1     lon1, iew, int(100*xlon1+.5), int(100*dep1+.5), 
     1     int(e1az), int(e1dip), int(100*e1+0.5), 
     1     int(e2az),int(e2dip),int(100*e2+0.5), int(10*xmag1+.5),
     1     eid1,int(100*erh1+0.5), int(100*erz1+0.5)
      goto 650

C HYPOINVERSE-2000 format for output
602   WRITE (8, 612) icent,itime,lat1,ins,int(100*xlat1+0.5),
     1     lon1, iew, int(100*xlon1+.5), int(100*dep1+.5), 
     1     int(e1az), int(e1dip), int(100*e1+0.5), 
     1     int(e2az),int(e2dip),int(100*e2+0.5), 
     1     int(100*fmag1+0.5), eid1, 
     1     int(100*erh1+0.5), int(100*erz1+0.5),
     1     zero, blank, int(100*xmag1+.5)
      goto 650

C HYPO71 format for output
603   WRITE (8, 613) itime,lat1,ins,xlat1,
     1 lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1
      goto 650
        
C HYPO71-2000 format for output
604   write (8, 614) icent,itime,lat1,ins,xlat1,
     1 lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1
      goto 650

C Special free format
605    write (8, *) (itime(k), k=1,3), 
     1              lat1+xlat1/60, lon1+xlon1/60, xmag1
       goto 650


CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C   WRITE TO CLUSTERED EVENTS LIST 
630   goto (631, 632, 633, 634, 633) infmt

c HYPOINVERSE format for output
631   WRITE (9, 611) itime,lat1,ins,int(100*xlat1+0.5),
     1     lon1, iew, int(100*xlon1+.5), int(100*dep1+.5), 
     1     int(e1az), int(e1dip), int(100*e1+0.5), 
     1     int(e2az),int(e2dip),int(100*e2+0.5),int(10*xmag1+.5),
     1     eid1, int(100*erh1+0.5), int(100*erz1+0.5), LIST(I)
      goto 650

C HYPOINVERSE-2000 format for output
632   WRITE (9, 612) icent,itime,lat1,ins,int(100*xlat1+0.5),
     1     lon1, iew, int(100*xlon1+.5), int(100*dep1+.5), 
     1     int(e1az), int(e1dip), int(100*e1+0.5), 
     1     int(e2az),int(e2dip),int(100*e2+0.5),
     1     int(100*fmag1+.5), eid1, 
     1     int(100*erh1+0.5), int(100*erz1+0.5), list(i),
     1     blank, int(100*xmag1+.5)
      goto 650

C HYPO71 format for output
633   WRITE (9, 613) itime,lat1,ins,xlat1,
     1 lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1, list(i)
      goto 650
        
C HYPO71-2000 format for output
634   write (9, 614) icent,itime,lat1,ins,xlat1,
     1 lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1,list(i)
      goto 650

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C   ANNOTATED CATALOG - ALL EVENTS
650   goto (651, 652, 653, 654, 653) infmt

c HYPOINVERSE format for output
651   WRITE (7, 611) itime,lat1,ins,int(100*xlat1+0.5),
     1     lon1, iew, int(100*xlon1+.5), int(100*dep1+.5), 
     1     int(e1az), int(e1dip), int(100*e1+0.5), 
     1     int(e2az),int(e2dip),int(100*e2+0.5),int(10*xmag1+.5),
     1     eid1, int(100*erh1+0.5), int(100*erz1+0.5), 
     1     LIST(I), ICHR
      goto 680

C HYPOINVERSE-2000 format for output
652   WRITE (7, 612) icent,itime,lat1,ins,int(100*xlat1+0.5),
     1     lon1, iew, int(100*xlon1+.5), int(100*dep1+.5), 
     1     int(e1az), int(e1dip), int(100*e1+0.5), 
     1     int(e2az),int(e2dip),int(100*e2+0.5),
     1     int(100*fmag1+.5), eid1, 
     1     int(100*erh1+0.5), int(100*erz1+0.5), 
     1     LIST(I), ICHR, int(100*xmag1+.5)
      goto 680

C HYPO71 format for output
653   WRITE (7, 613) itime,lat1,ins,xlat1,
     1 lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1, LIST(I),ICHR
      goto 680
        
C HYPO71-2000 format for output
654   write (7, 614) icent,itime,lat1,ins,xlat1,
     1 lon1,iew,xlon1,dep1,xmag1,erh1,erz1,q1, LIST(I),ICHR
      goto 680

680   continue
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

c-- write the output file summarizing the run and the listing the clusters
      write (2,503) catalog, inrec, neq, ntimrej, nquarej, 
     1     nmagrej, xmagcut, neq, nclust, neqcl, stamp,
     1     rfact, tau0, taumin, taumax, p1, xk, ierradj
  503 format (//8x,'Program: CLUSTER2000X (test version)', //
     1    '        SUMMARY OF CLUSTERS IN  ',A,//
     1    i8, ' EVENTS READ', i8, ' EVENTS ACCEPTED', 
     2    i8, ' EVENTS WERE OUTSIDE TIME RANGE SPECIFIED',/
     3    i8, ' EVENTS WERE REJECTED AS QUARRY BLASTS'/
     2    i8, ' EVENTS REJECTED FOR MAGNITUDE  (MINIMUM MAGNITUDE = ',
     2    f5.2, ')' //
     3    i10,' earthquakes tested;  ',i6,' clusters identified',5x,
     4    i6,' clustered events',5x,a, /
     5    '   rfact=',f6.3,'   tau0=',f8.3,'   taumin=',f10.2,
     6    '   taumax=',f10.2,'   p1=',f6.3,'   xk=',f5.2,
     6    '   ierradj=',i2,///
     7    '    N  -1ST EVENT-   DUR(DAYS)   NC  -------EQUIVALENT',
     8    ' EVENT-------   --LARGEST EVENT--   2ND LARGEST EVENT',
     9    ' PCT(F)   DT     DM  '/)

C  Loop through clusters, k=1,n
      do 700 k=1,n
      if (nc(k) .eq. 0) goto 700
      lat=clat(k)
      xlat=(clat(k)-lat)*60.
      lon=clon(k)
      xlon=(clon(k)-lon)*60.
      xmag=(alog10(cmoment(k)))/1.2

c---- calculate percentage of cluster duration taken by foreshocks
      do 504 it=1,5
      itime(it)=ctim0(it,k)
  504 jtime(it)=ctim1(it,k)
      call tdif(itime,jtime,dif)
      if (cdur(k) .lt. 0.001) cdur(k)=.001
      fore =  (dif/14.40) / cdur(k) + .5

c---- calculate time (days) from largest event to 2nd-largest event.
c     (positive = aftershock-like,  negative = foreshock-like).
      do 505 it=1,5
      itime(it)=ctim1(it,k)
  505 jtime(it)=ctim2(it,k)
      call tdif(itime,jtime,dif)
      t12dif=dif/1440.
      xmdif=cmag1(k)-cmag2(k)

c---- calculate DT, the absolute time difference between largest and 
c                   2nd-largest events,
c           and DM, the magnitude of the second of these events minus
c                   the magnitude of the first.
      if (t12dif .lt. 0.0) then
         dm =   xmdif
         dt = - t12dif
      else
         dm = - xmdif
         dt =   t12dif
      end if

C Write out cluster summary to "output" file
      ichr = char(mod(k-1,26)+65)
  510 write (2,511) ichr,k,(ctim0(it,k),it=1,5),cdur(k),nc(k),lat,xlat,
     1       lon,xlon,cdep(k),xmag,(ctim1(it,k),it=1,5),cmag1(k),
     2       (ctim2(it,k),it=1,5),cmag2(k),fore,DT,DM
  511 format (1x,a1,i4,1x,3i2.2,1x,2i2.2,2x,f8.3,2x,i5,
     1        2(i4,f6.2),2f6.2,2(3x,5i2.2,1x,f6.2),i5,1x,f7.3,f6.2)

c--- Write out (append) the "equivalent events" to declustered catalog
c    Use error parameters from largest event in cluster
        read(1,rec=ibigst(k),err=903) icent,itime,lat1,insx,xlat1,
     2        lon1,iewx,xlon1,
     3        dep1, xmag1,erh1,erz1,q1,dlat1, dlon1, ddep1, rms, 
     4        nst, amag1, aflag, fmag1, fflag, dum5,
     5        e1az,e1dip,e1, e2az,e2dip,e2, eid1

      goto (691, 692, 693, 694, 695) infmt

c HYPOINVERSE format for output
691   WRITE (8, 611) (ctim1(it,k),it=1,5),
     1                  lat,ins,int(100*xlat+0.5),
     1                  lon, iew, int(100*xlon+.5),
     1                  int(100*cdep(k)+.5),
     2                  int(e1az),int(e1dip),int(100*e1+.5), 
     1                  int(e2az),int(e2dip),int(100*e2+.5),
     1                  int(10*xmag+0.5), eid1,
     1                  int(100*erh1+0.5), int(100*erz1+0.5), k
      goto 700

C HYPOINVERSE-2000 format for output
692   WRITE (8, 612)  icent, (ctim1(it,k),it=1,5),
     1                  lat,ins,int(100*xlat+0.5),
     1                  lon, iew, int(100*xlon+.5),
     1                  int(100*cdep(k)+.5),
     2                  int(e1az),int(e1dip),int(100*e1+.5), 
     1                  int(e2az),int(e2dip),int(100*e2+.5),
     1                  int(100*xmag+0.5), eid1,
     1                  int(100*erh1+0.5), int(100*erz1+0.5), k
      goto 700

C HYPO71 format for output
693   WRITE (8, 613) (ctim1(it,k),it=1,5),lat,ins,xlat,
     1 lon,iew,xlon,cdep(k),xmag,erh1,erz1,q1, k
      goto 700
        
C HYPO71-2000 format for output
694   write (8, 614) icent,(ctim1(it,k),it=1,5),lat,ins,xlat,
     1 lon,iew,xlon,cdep(k),xmag,erh1,erz1,q1, k
      goto 700

C Special free format
695    write (8, *)  (ctim1(it,k),it=1,3), lat+xlat/60.,
     1                 lon+xlon/60., xmag
      goto 700


  700 continue
      close (unit=1,status='delete')
      close (unit=2,status='keep')
      close (unit=3,status='keep')
      close (unit=4,status='keep')
      stop
  900 WRITE (2, 902) IREC
  902 FORMAT (' ***** READ ERROR ON INPUT FILE, LINE ', I8)
      stop
  903 WRITE (2, 904) ibigst(k)
  904 FORMAT (' ***** READ ERROR ON DIRECT ACCESS FILE, LINE ', I8)
      stop
      end

c**********************************************************************
c**********************************************************************

      subroutine ctest (itime,lat1,xlat1,lon1,xlon1,dep1,xmag1,erh1,
     1                  erz1,q1,jtime,lat2,xlat2,lon2,xlon2,dep2,xmag2,
     2                  erh2,erz2,q2,cmag1,cluster,ierradj)

c      Determine whether event1 and event2 are 'clustered'
c      according to the radial distance criterion:

c            reduced hypocentral distance .le. rtest 
c
c	Hypocentral distance r may be reduced by the hypocentral
c	uncertainty, or ignored, depending on an option set in the
c	beginning of the main program.
c	To reduce distance by location error, set ierradj = 2.
c	Or, to ignore the hypocentral errors, set ierradj = 1. 

      logical cluster
      character*1 q1,q2,qual(4)
      integer*2 itime(5),jtime(5)
      dimension erhqual(4), erhearly(4),erzqual(4), erzearly(4) 
      common/a/ rfact,tau

      data erhqual/.5,1.,2.5,5./              
      data erhearly/1.,3.,7.,10./            
      data erzqual/1.,2.,5.,10./            
      data erzearly/5.,10.,10.,10./        
      data qual/'A','B','C','D'/          

      cluster=.false.
c-- the interaction distance about an event is defined as
   
c         r  =  rfact * a(M, dsigma)

c  where a(M, dsigma) is the radius of a circular crack
c  (Kanamori and Anderson, 1975) corresponding to an earthquake of 
c  magnitude M and stress drop dsigma.  The value dsigma = 30 bars
c  is adopted implicitly in the calculation.

c     log a  =  0.4*M - (log(dsigma))/3 - 1.45

c  The term (log(dsigma)/3 - 1.45) evaluates to the
c  factor 0.011 in calculation below, when dsigma=30 bars.
c  a is in kilometers.

c---- determine hypocentral distance between events
      alat=lat1+xlat1/60.
      alon=lon1+xlon1/60.
      blat=lat2+xlat2/60.
      blon=lon2+xlon2/60.
      call delaz(alat,alon,blat,blon,r,azr)
      z=abs(dep1-dep2)
      r=sqrt(z**2 + r**2)
      if (z .lt. 0.01 .and. r .lt. 0.01) goto 30

c---- assign hypocentral errors if a quality code was given
	if (q1. ne. ' ') then
	DO 4 I=1,4
4	IF (Q1 .EQ. QUAL(I)) GOTO 5
	I=4
5	IF (Itime(1) .LT. 70) THEN
		ERH1 = ERHEARLY(I)
		ERZ1 = ERZEARLY(I)
	ELSE
		ERH1 = ERHQUAL(I)
		ERZ1 = ERZQUAL(I)
	ENDIF
	DO 14 I=1,4
14	IF (Q2 .EQ. QUAL(I)) GOTO 15
	I=4
15	IF (Itime(1) .LT. 70) THEN
		ERH2 = ERHEARLY(I)
		ERZ2 = ERZEARLY(I)
	ELSE
		ERH2 = ERHQUAL(I)
		ERZ2 = ERZQUAL(I)
	ENDIF
	endif
	
c---- reduce hypocentral distance by location uncertainty of both events
c     Note that r can be negative when location uncertainties exceed
c     hypocentral distance
      if (ierradj .eq. 2) then
	alpha = atan2(z,r)
	ca = cos(alpha)
	sa = sin(alpha)
	e1 = sqrt(erh1*erh1 * ca*ca + erz1*erz1 * sa*sa)
	e2 = sqrt(erh2*erh2 * ca*ca + erz2*erz2 * sa*sa)
	r = r - e1 - e2
      endif

c     calculate interaction radius the first event of the pair
c     and for the largest event in the cluster associated with
c     the first event
   30 r1 = rfact * 0.011 * 10.**(0.4*xmag1)
      rmain =      0.011 * 10.**(0.4*cmag1)
      rtest = r1 + rmain
c     limit interaction distance to one crustal thickness
      if (rtest .gt. 30.) rtest=30.

c---- test distance criterion
      if (r .le. rtest) cluster=.true.
      return
      end

c***************************************************************************
c
       subroutine tdif (itime,jtime,dif)
c      Calculates the time difference (jtime - itime)
c      where the elements of itime of jtime represent year,
c      month, day, hour and minute.  Leap years are accounted for.
c      The time difference, in minutes, is returned in the
c      double precision variable dif.

c      dif = (jtime - itime)

      integer*2 days(12),itime(5),jtime(5)
      data days/0,31,59,90,120,151,181,212,243,273,304,334/
      double precision t1,t2,t1a,t2a,t1b,t2b,dif

c---- t1a is number of minutes from 00:00 1/1/itime(1) to itime
      t1a = ( (days(itime(2)) + itime(3)-1)*24. + itime(4))*60. 
     1      + itime(5)
      if (mod(itime(1),4).eq.0 .and. itime(2).gt.2) t1a = t1a + 1440.

c---- t1b is number of days from 00:00 1/1/69 to 00:00 1/1/itime(1)
      t1b = (itime(1)-69)*365 + int((itime(1)-69.)/4.)

      t1 = t1a + t1b *1440.

c---- t2a is number of minutes from 00:00 1/1/jtime(1) to jtime
      t2a = ( (days(jtime(2)) + jtime(3)-1)*24. + jtime(4))*60. 
     1        + jtime(5)
      if (mod(jtime(1),4).eq.0 .and. jtime(2).gt.2) t2a = t2a + 1440.

c---- t2b is number of days from 00:00 1/1/69 to 00:00 1/1/jtime(1)
      t2b = (jtime(1)-69)*365 + int((jtime(1)-69.)/4.)

      t2 = t2a + t2b *1440.

      dif = t2 - t1
      return
      end


c***************************************************************************
c
       subroutine tdif2 (itime,jtime,dif)
c      Calculates the time difference (jtime - itime)
c      where the elements of itime of jtime represent year,
c      month, day, hour and minute.  Leap years are accounted for.
c      The time difference, in minutes, is returned in the
c      double precision variable dif.

c	This version (tdif2) uses seconds (assumed truncated in the
c	data to nearest hundredth of a second)
c
c	itime(1)=years, itime(2)=mo, ... itime(5)=min, itime(6)=sec*100
c
c		itime(6) will range from 0 to 6000, and can be held
c		by integer*2 storage.

c      dif = (jtime - itime)

      integer*2 days(12),itime(6),jtime(6)
      data days/0,31,59,90,120,151,181,212,243,273,304,334/
      double precision t1,t2,t1a,t2a,t1b,t2b,dif

c---- t1a is number of minutes from 00:00 1/1/itime(1) to itime
      t1a = ( (days(itime(2)) + itime(3)-1)*24. + itime(4))*60. 
     1      + itime(5)
      if (mod(itime(1),4).eq.0 .and. itime(2).gt.2) t1a = t1a + 1440.

c---- t1b is number of days from 00:00 1/1/69 to 00:00 1/1/itime(1)
      t1b = (itime(1)-69)*365 + int((itime(1)-69.)/4.)

      seci = itime(6)/100.
      t1 =   seci/60. + t1a + t1b *1440. 

c---- t2a is number of minutes from 00:00 1/1/jtime(1) to jtime
      t2a = ( (days(jtime(2)) + jtime(3)-1)*24. + jtime(4))*60. 
     1        + jtime(5)
      if (mod(jtime(1),4).eq.0 .and. jtime(2).gt.2) t2a = t2a + 1440.

c---- t2b is number of days from 00:00 1/1/69 to 00:00 1/1/jtime(1)
      t2b = (jtime(1)-69)*365 + int((jtime(1)-69.)/4.)

      secj = jtime(6)/100.
      t2 =   secj/60. + t2a + t2b *1440.

      dif = t2 - t1
      return
      end

      subroutine delaz(alat,alon,blat,blon,dist,azr)
c
c        double precision version
c
c        computes cartesian distance from a to b
c        a and b are in decimal degrees and n-e coordinates
c        del -- delta in degrees
c        dist -- distance in km
c        az -- azimuth from a to b clockwise from north in degrees
c
      real*8 pi2,rad,flat,alatr,alonr,blatr,blonr,geoa,geob,
     1       tana,tanb,acol,bcol,diflon,cosdel,delr,top,den,
     2       colat,radius
c
      data pi2/1.570796e0/
      data rad/1.745329e-02/
      data flat/.993231e0/
      if (alat.eq.blat.and.alon.eq.blon) goto 10
c-----convert to radians
      alatr=alat*rad
      alonr=alon*rad
      blatr=blat*rad
      blonr=blon*rad
      tana=flat*dtan(alatr)
      geoa=datan(tana)
      acol=pi2-geoa
      tanb=flat*dtan(blatr)
      geob=datan(tanb)
      bcol=pi2-geob
c-----calcuate delta
      diflon=blonr-alonr
      cosdel=dsin(acol)*dsin(bcol)*dcos(diflon)+dcos(acol)*dcos(bcol)
      delr=dacos(cosdel)
c-----calcuate azimuth from a to b
      top=dsin(diflon)
      den=dsin(acol)/dtan(bcol)-dcos(acol)*dcos(diflon)
      azr=datan2(top,den)
c-----compute distance in kilometers
      colat=pi2-(alatr+blatr)/2.
      radius=6371.227*(1.0+3.37853d-3*(1./3.-((dcos(colat))**2)))
      dist=delr*radius
      return
   10 dist=0.0
      azr=0.0
      return
      end
c
c**********************************************************************
c
	subroutine getrec (rec, iunit, istat)
c--Getrec reads a buffer of ASCII records, the returns them one at a time

	save		nsize			
c				number of records in buffer (presently 500 max)
	character*(*)	rec
c				record to be "read"
	integer		iunit			
c				input unit number
	integer		istat
c				0 for normal return of a record
c				1 end of file reached, no more records
	save		nrec
	data nrec /0/
c			current position of last record returned in buffer
	character*128	buf(500)
c				character buffer

c--Read in a new buffer if its empty
	if (nrec.eq.0 .or. nrec.eq.nsize) then
	  nrec=0
	  read (iunit, end=9) nsize, (buf(i),i=1,nsize)
	end if

	istat=0
c--Grab the next record from the buffer
	nrec = nrec +1
	rec = buf(nrec)
	return

c--End of file
9	istat=1
	return
	end
