c-----------------------------------------------------------------------
c
c    program to read cmt-ascii-list and write output to file
c    select certain region, magnitude range, and depth interval
c    based on lat-lon-dep-mag-constraints specified in file "select"
c
c
c    11/08/94
c
c-----------------------------------------------------------------------
      program cmtsel
c
c---------------------------------------------------
c "filter parameters"
      real latmi,latmx,lonmi,lonmx,depmi,depmx,magmi
c PDE/ISC hypo-parameters
      real sec,plat,plon,pdep,pmb,pms
c Centroid parameters (+scalar moment, mw)
      real ctime,clat,clon,cdep,hdur,smo,mw
c (more) PDE/ISC hypo-parameters
      integer mo,da,yr,hr,mi
c Double Couple parameters (+exponent of moment)
      integer expo,st1,di1,ra1,st2,di2,ra2
c Agency for hypo-parameters
	  character*3 agen
      character*200 filein,fileout,selectfile
c---------------------------------------------------
c
c read select-file:
c
      call getarg(1, selectfile)
      open(1,file=selectfile,status='old')
      read(1,10) latmi,latmx
      read(1,10) lonmi,lonmx
      read(1,10) depmi,depmx
      read(1,10) magmi
   10 format(2f7.2)
      close(1)
c
c read cmt-file name:
c
c     write(6,200)
c     read(5,*) filein
      call getarg(2, filein)
      open(2,file=filein,err=91,status='old')
      l=index(filein,' ')-1
c     fileout=filein(1:l)//'.cmt'
      call getarg(3, fileout)
      open(3,file=fileout,status='unknown')
c
      do 20 i=1,100000
      read(2,30,err=92,end=1000) mo,da,yr,hr,mi,sec,plat,plon,pdep,pmb,
     %pms
   30 format(1x,3i2,11x,i2,1x,i2,1x,f4.1,1x,f6.2,1x,f7.2,1x,f5.1,2f3.1)
      if (plat.lt.latmi.or.plat.gt.latmx) goto 40
      if (plon.lt.lonmi.or.plon.gt.lonmx) goto 40
      if (pdep.lt.depmi.or.pdep.gt.depmx) goto 40
      if (pmb.lt.magmi.and.pms.lt.magmi) goto 40
c
c you get here ONLY if event is within specs!!!
c more stuff is read in, and prepared for output
c
      read(2,60) agen,ctime,clat,clon,cdep
   60 format(a3,31x,f5.1,5x,f6.2,6x,f7.2,6x,f5.1)
c     read(2,60) agen,clat,clon,cdep
c  60 format(a3,41x,f6.2,6x,f7.2,6x,f5.1)
      read(2,70) hdur,expo
   70 format(4x,f4.1,4x,i2)
c     read(2,70) expo
c  70 format(12x,i2)
      read(2,80) smo,st1,di1,ra1,st2,di2,ra2
   80 format(44x,f5.2,1x,i3,1x,i2,1x,i4,1x,i3,1x,i2,1x,i4)
c calculate Mw
      mw=2./3.*alog10(smo)+expo*2./3.-10.7
c
c do output!
c
      write(3,90) yr,mo,da,hr,mi,sec,plat,plon,pdep,pmb,pms,clat,clon,
     %cdep,ctime,hdur,mw,st1,di1,ra1,st2,di2,ra2,agen
   90 format(5(i2,1x),f4.1,1x,f6.2,1x,f7.2,1x,f5.1,2(1x,f3.1),1x,f6.2,
     %1x,f7.2,1x,2(f5.1,1x),f4.1,1x,f4.2,2(1x,i3,1x,i2,1x,i4),1x,a3)
c  90 format(3(i2,1x),i2,1x,i2,1x,f4.1,1x,f5.1,1x,f6.1,1x,f5.1,1x,f3.1,
c    %1x,f3.1,1x,f6.2,1x,f7.2,1x,f5.1,1x,f4.2,2(1x,i3,1x,i2,1x,i4),1x,
c    %a3)
      goto 20
c if event is outside specs skip 3 lines
   40 do 50 j=1,3
         read(2,*)
   50 continue
c read new event
   20 continue
      goto 1000
c
   91 write(6,210)
      goto 1000
   92 write(6,220)
      goto 1000
c
c 200 format(' enter input file name:')
  210 format(' error when opening cmt-file!')
  220 format(' error when reading cmt-file!')
 1000 stop
      end
