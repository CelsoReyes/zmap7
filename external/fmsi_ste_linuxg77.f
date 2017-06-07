C***********************************************************************
C*                                                                     *
C*              FOCAL MECHANISM STRESS INVERSION PACKAGE               *
C*                          JOHN W. GEPHART                            *
C*                          BROWN UNIVERSITY                           *
C*                                1985                                 *
C*                                                                     *
C*                 REVISED AT CORNELL UNIVERSITY, 1989                 *
C*                                                                     *
C***********************************************************************
C
C***********************************************************************
C*                                                                     *
C*  THIS PROGRAM PERFORMS THE STRESS INVERSION OF EARTHQUAKE FOCAL     *
C*  MECHANISM AND FAULT/SLICKENSIDE DATA USING THE METHODS OF GEPHART  *
C*  AND FORSYTH [1984]; RESULTS ARE PRESENTED IN TABLES OF R VS. PHI,  *
C*  WHERE PHI IS THE RAKE OF THE SIGMA-2 AXIS IN THE PLANE NORMAL TO   *
C*  THE PRIMARY STRESS DIRECTION (SIGMA-1 OR -3, AT THE USER'S CHOICE) *
C*                                                                     *
C*  REQUIRED SUBPROGRAMS:  XPSET, EULER, INVEUL, NORM, PRISTR, NPSF5,  *
C*    NPSF10, SECSTR, PHICLC, GRDTAB, BETCLC, XPROTP, XPCHKP, AXSYMP,  *
C*    XPROTA, XPCHKA, AXSYMA, XPROTE, AXSYME, AXRFN, OCTROT, GENROT,   *
C*    COSORT, POLY4, POLY3, AND SSCHK                                  *
C*                                                                     *
C*  THIS MAIN PROGRAM READS THE INPUT PARAMETERS, WHICH ARE USED TO    *
C*  CONSTRUCT THE GRID OF STRESS MODELS TO BE SEARCHED, AND INITIAL-   *
C*  IZES SOME VARIABLES AND ARRAYS                                     *
C*                                                                     *
C***********************************************************************
C
      PROGRAM FMSI
      DIMENSION C(40,3,3),AZ(470,2),DIP(470,2),Q(470),PH(40),CN1(470,2),
     1 CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470)
      dimension record(7)
      CHARACTER*30 INFILE,OUTFILE
      CHARACTER*1 DSKIP
      LOGICAL SSLP,PASS1,GRD
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / THREE / AZ,DIP,Q
      COMMON / FOUR / A1,A2,A3,A4,A5,A6
      COMMON / FIVE / NFM,KFP,KR,RFXS,RSTEP,RSMIN,NTAB,NR,NPHI,record
      COMMON / SIX / SSLP,PASS1
      COMMON / SEVEN / METHOD
C
C   OPEN INPUT (UNIT 5) AND OUTPUT (UNIT 6) FILES
C
c     WRITE(*,*) ' ENTER NAME OF INPUT FILE'
      READ(*,499) INFILE
  499 FORMAT(A30)
      OPEN(UNIT=1,FILE=INFILE,STATUS='OLD')
c     WRITE(*,*) ' ENTER NAME OF OUTPUT FILE'
      READ(*,499) OUTFILE
      open(unit=99,file='out95',status='unknown')
      OPEN(UNIT=2,FILE=OUTFILE,STATUS='UNKNOWN')
      OPEN(UNIT=3,FILE='tmp',STATUS='UNKNOWN')
      
C
C   ENTER DATA FOR DETERMINING PRINCIPAL STRESS DIRECTIONS TO BE TESTED
C
c     WRITE(*,485) ' ENTER INDEX OF THE PRIMARY PRINCIPAL STRESS',
c    1 ' (1 OR 3)'
  485 FORMAT(A44,A9)
      READ(*,*) ISIG
      JSIG=4-ISIG
c     WRITE(*,486) ' ENTER PLUNGE, AZIMUTH, AND VARIANCE OF 1ST',
c    1 ' PRINCIPAL STRESS AXIS--SIGMA ',ISIG
  486 FORMAT(A43,A30,I1)
      READ(*,*) PLPRI,AZPRI,APPRI
c     WRITE(*,*) 'SKIP ANY DIRECTIONS AT THE BEGINNING? Y/[N]'
      READ(*,490) DSKIP
  490 FORMAT(A1)
      IF(DSKIP.EQ.'Y'.OR.DSKIP.EQ.'y') THEN
c        WRITE(*,*) '   HOW MANY?'
         READ(*,*) NPS0
      ELSE
         NPS0=0
      ENDIF
c     WRITE(*,486) ' ENTER PLUNGE, AZIMUTH, AND VARIANCE OF 2ND',
c    1 ' PRINCIPAL STRESS AXIS--SIGMA ',JSIG
      READ(*,*) PLSEC,AZSEC,APSEC
c     WRITE(*,*) 'WHICH GRID?    (1)  5-DEGREE '
c     WRITE(*,*) '               (2) 10-DEGREE [DEFAULT]'
      READ(*,491) IGC
  491 FORMAT(I1)
      IF(IGC.EQ.1) THEN
         GRD=.TRUE.
      ELSE
         GRD=.FALSE.
      ENDIF
C
C   ENTER DATA FOR DETERMINING VALUES OF R TO BE TESTED
C
c     WRITE(*,*) 'ENTER R VALUES (0-1):  LOWEST, HIGHEST, INCREMENT'
      READ(*,*) RLOW,RHIGH,RSTEP
      IF(RSTEP.EQ.0.0) THEN
         KR=1
      ELSE
         KR=INT((RHIGH-RLOW+0.001)/RSTEP)+1
      ENDIF
C
C   SELECT A METHOD
C
c     WRITE(*,*) 'WHICH METHOD?  (1) POLE ROTATION'
c     WRITE(*,*) '               (2) APPROXIMATE'
c     WRITE(*,*) '               (3) EXACT [DEFAULT]'
      READ(*,491) METHOD
C
C   INPUT # OF DATA (NFM) AND # FOR WHICH FAULT PLANE IS KNOWN FROM 
C   THE 2 NODAL PLANES (KFP)--THESE MUST BE ENTERED BEFORE THOSE WITH
C   UNKNOWN FAULT PLANES.
C
c     READ(1,500) NFM,KFP
      READ(1,*) NFM,KFP
  500 FORMAT(2(1X,I3))
      RFXS=RLOW-RSTEP
      RSMIN=9999.0
      CALL XPSET(NFM,WT)
      CALL PRISTR(ISIG,NPS0,GRD,WT,AZPRI,PLPRI,APPRI,AZSEC,PLSEC,APSEC)
      WRITE(2,550) ' Best Model (Weighted Averages in degrees) - ',
     1 RSMIN,' (',NTAB,NR,NPHI,')'
C      WRITE(*,550) ' Best Model (Weighted Averages in degrees) - ',
C     1 RSMIN,' (',NTAB,NR,NPHI,')'
  550 FORMAT(//,A45,1X,F7.3,A2,3I3,A1)
C
     
c
C 555   format(7if10.2)
      CLOSE(UNIT=1)
      CLOSE(UNIT=2)
      close(unit=3)
      STOP
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE XPSET SETS UP THE COORDINATE AXES FIXED BY THE FAULT    *
C*  PLANE GEOMETRY (FPG) FOR EACH DATUM (THE PRIMED COORDINATES)       *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XPSET(NFM,WT)
      DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),
     1 CD2(470),AZ(470,2),DIP(470,2),Q(470)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / THREE / AZ,DIP,Q
      DATA RAD / 0.017453292 /
      WT=0.0
C
C   INPUT FAULT PLANE ORIENTATION DATA AND CALCULATE FAULT PLANE
C   COORDINATE AXES; EXTERNAL COORDINATES = NORTH, EAST, DOWN;
C   E.G., CN1(I,J) = COSINE OF THE ANGLE BETWEEN HORIZONTAL-NORTH
C   AND THE POLE TO THE JTH NODAL PLANE (EQUIVALENT TO THE SLIP
C   VECTOR OF THE ALTERNATE NODAL PLANE) OF THE ITH DATUM, AND 
C   CD2(I) = COSINE OF THE ANGLE BETWEEN VERTICAL-DOWN AND THE
C   B AXIS OF THE ITH DATUM
C
      DO 30 I=1,NFM
C         READ(1,502) (AZ(I,J),DIP(I,J),J=1,2),Q(I)
         READ(1,*) (AZ(I,J),DIP(I,J),J=1,2),Q(I)
	   write(6,*)(AZ(I,J),DIP(I,J),J=1,2),Q(I)
  502    FORMAT(2(1X,F7.3,1X,F6.3),1X,F3.0)
         DO 20 J=1,2
            AZR=AZ(I,J)*RAD
            DIPR=DIP(I,J)*RAD
            CD1(I,J)=COS(DIPR)
            CD3=SIN(DIPR)
            CN1(I,J)=SIN(AZR)*CD3
            CE1(I,J)=-COS(AZR)*CD3
   20    CONTINUE
         CD2(I)=(-CN1(I,2)+CN1(I,1)*CE1(I,2)/CE1(I,1))/(-CD1(I,1)
     1    *CE1(I,2)/CE1(I,1)+CD1(I,2))
         CE2(I)=(-CD2(I)*CD1(I,1)-CN1(I,1))/CE1(I,1)
         CN2(I)=1.0/SQRT(1.0+CE2(I)*CE2(I)+CD2(I)*CD2(I))
         IF(CD2(I).LT.0.0) CN2(I)=-CN2(I)
         CE2(I)=CE2(I)*CN2(I)
         CD2(I)=CD2(I)*CN2(I)
         WT=WT+ABS(Q(I))
   30 CONTINUE
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE EULER TRANSFORMS 3 CARTESIAN COORDINATES OF AN AXIS     *
C*  (WITH RESPECT TO EXTERNAL COORDINATES--NORTH, EAST, AND DOWN),     *
C*  INTO 2 EULER ANGLES (PLUNGE AND AZIMUTH)                           *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE EULER(CN,CE,CD,IPL,IAZ)
      DATA RAD / 0.017453292 /
      IF(CN.EQ.0.0.AND.CE.EQ.0.0) THEN
         IPL=90
         IAZ=0
      ELSE
         IPL=INT(ASIN(CD)/RAD+0.5)
         IAZ=INT(AMOD(ATAN2(CE,CN)/RAD+360.0,360.0)+0.5)
      ENDIF
      RETURN
      END
C       
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE INVEUL TRANSFORMS 2 EULER ANGLES OF AN AXIS (PLUNGE     *
C*  AND AZIMUTH) INTO 3 CARTESIAN COORDINATES RELATIVE TO A FAULT      *
C*  PLANE GEOMETRY COORDINATE SET                                      *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE INVEUL(I,THETA1,THETA2,K,C1,C2,C3)
      DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),
     1 CD2(470)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      DATA HPI / 1.5707963 /
      J=3-K
      CT2=COS(THETA2)
      C1R=COS(THETA1)*CT2
      C2R=SIN(THETA1)*CT2
      C3R=SIN(THETA2)
      C1=C1R*CN1(I,K)+C2R*CE1(I,K)+C3R*CD1(I,K)
      C2=C1R*CN2(I)+C2R*CE2(I)+C3R*CD2(I)
      C3=C1R*CN1(I,J)+C2R*CE1(I,J)+C3R*CD1(I,J)
      CALL NORM(C1,C2,C3)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE NORM ADJUSTS THE ANGLE COSINE COORDINATES OF ANY AXIS   *
C*  TO ENSURE THAT THE SUM OF THEIR SQUARES IS 1.0                     *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE NORM(X1,X2,X3)
      XNORM=X1*X1+X2*X2+X3*X3
      IF(XNORM.NE.1.0) THEN
         IF(XNORM.LT.0.0) XNORM=1.0E-30
         XNORM=SQRT(XNORM)
         X1=X1/XNORM
         X2=X2/XNORM
         X3=X3/XNORM
      ENDIF
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE PRISTR CONSTRUCTS A GRID OF PRINCIPAL STRESS DIRECTION  *
C*  COSINES (C(I,J,K)) OVER WHICH TO SEARCH.  I = INDEX OF PHI VALUE   *
C*  (1 - NSDP), J = STRESS INDEX (1 - 3), K = EXTERNAL COORDINATE      *
C*  INDEX (1 - 3); THE RESULTING GRID UNIFORMLY COVERS ALL ORIENTA-    *
C*  TIONS WITHIN THE SPECIFIED RANGES (APPRI AND APSEC) ABOUT THE      *
C*  PRESCRIBED PRIMARY (PLPRI,AZPRI) AND SECONDARY (PLSEC,AZSEC) PRIN- *
C*  CIPAL STRESS DIRECTIONS.  SUBSIDIARY SUBROUTINES:  NPSF5, NSPF10,  *
C*  SECSTR, PHICLC                                                     *    
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE PRISTR(ISIG,NPS0,GRD,WT,AZPRI,PLPRI,APPRI,AZSEC,PLSEC,
     1 APSEC)
      DIMENSION A(3,3),X(3),Z(3),C(40,3,3),PH(40)
      dimension record(7)
      LOGICAL GRD
      COMMON / TWO / C
      COMMON / FIVE / NFM,KFP,KR,RFXS,RSTEP,RSMIN,NTAB,NR,NPHI,record
      COMMON / SEVEN / METHOD
      DATA PI,HPI,RAD / 3.1415927,1.5707963,0.017453292 /
      PLSEC=PLSEC*RAD
      AZSEC=AZSEC*RAD
      APSEC=APSEC*RAD
      AZ3=AZPRI*RAD
      CPL3=HPI-PLPRI*RAD
      CPL2=HPI
      AZ2=AZ3+HPI
      CPL1=CPL3+HPI
      AZ1=AZ3
C
C   CALCULATE THE ROTATION MATRIX, A(I,J), THAT TRANSFORMS A FIXED
C   EXTERNAL COORDINATE SYSTEM (WITH AXES NORTH, EAST, AND DOWN)
C   INTO ONE FIXED TO THE CHOSEN PRIMARY AND SECONDARY STRESS 
C   DIRECTIONS
C
      CAUX=SIN(CPL1)
      A(1,1)=COS(AZ1)*CAUX
      A(2,1)=SIN(AZ1)*CAUX
      A(3,1)=COS(CPL1)
      A(1,2)=COS(AZ2)
      A(2,2)=SIN(AZ2)
      A(3,2)=0.0
      CAUX=SIN(CPL3)
      A(1,3)=COS(AZ3)*CAUX
      A(2,3)=SIN(AZ3)*CAUX
      A(3,3)=COS(CPL3)
C
C   OPEN THE FILE CONTAINING THE GRIDDED PRIMARY STRESS DIRECTIONS
C   ON THE EXTERNAL GRID
C
      IF(GRD) THEN
         OPEN(UNIT=4,FILE='GRID5.TAB',
     c        STATUS='OLD')
         CALL NPSF5(APPRI,NPS)
         PSTEP=4.5*RAD
      ELSE
         OPEN(UNIT=4,FILE='GRID10.TAB',
     c        STATUS='OLD')
         CALL NPSF10(APPRI,NPS)
         PSTEP=9.0*RAD
      ENDIF
      NPSTOT=NPS-NPS0
C
C   WRITE INFO AT THE BEGINNING OF THE OUTPUT FILE
C
      WRITE(2,*) ' This listing file presents the results of a grid
     1 search over '
      IF(METHOD.EQ.1) THEN
         WRITE(2,401) NPSTOT,' sigma-',ISIG,' direction(s), using the
     1 POLE ROTATION method.'
  401 FORMAT(5X,I3,A7,I1,A46)
      ELSEIF(METHOD.EQ.2) THEN
         WRITE(2,402) NPSTOT,' sigma-',ISIG,' direction(s), using the
     1 APPROXIMATE method.'
  402 FORMAT(5X,I3,A7,I1,A44)
      ELSE
         WRITE(2,403) NPSTOT,' sigma-',ISIG,' direction(s), using the
     1 EXACT method.'
  403 FORMAT(5X,I3,A7,I1,A38)
      ENDIF
      WRITE(2,404) ' The data set comprises ',NFM,' fault-slip data
     1 (weighted sum = ',WT,').'
  404 FORMAT(A24,I3,A33,F5.1,A2)
      RFACT=1.0/(RAD*WT)
      IF(ISIG.EQ.1) THEN
         IC=1
      ELSE
         IC=0
      ENDIF
C
C   READ OVER THE NUMBER OF PRIMARY STRESS DIRECTIONS THAT ARE TO BE
C   SKIPPED
C
      NPS1=NPS0+1
      IF(NPS0.GT.0) THEN
         DO 80 M=1,NPS0
            READ(4,495)
   80    CONTINUE
      ENDIF
C
C   FOR EACH PRIMARY STRESS DIRECTION TO BE TESTED, READ THE EX-
C   TERNAL COORDINATES, X(I), AND TRANSFORM TO NEW COORDINATES, Z(I),
C   FIXED TO THE DESIRED STRESS DIRECTIONS
C
      DO 100 M=NPS1,NPS
         READ(4,495) X(1),X(2),X(3)
  495    FORMAT(3(1X,F10.7))
         DO 90 I=1,3
            Z(I)=0.0
         DO 90 J=1,3
            Z(I)=Z(I)+A(I,J)*X(J)
   90    CONTINUE
         IF(Z(3).LT.0.0) THEN
            Z(1)=-Z(1)
            Z(2)=-Z(2)
            Z(3)=-Z(3)
         ENDIF
         CALL NORM(Z(1),Z(2),Z(3))
C
C   MAKE MINOR ADJUSTMENTS IN CERTAIN DEGENERATE CASES
C
         IF(ABS(Z(1)).LT.0.0035) THEN
            Z(1)=SIGN(0.0035,Z(1))
            IF(ABS(Z(2)).GE.0.0025.AND.Z(3).GE.0.0025) THEN
               ZZ22=Z(2)*Z(2)-6.125E-06
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               Z(2)=SIGN(SQRT(ZZ22),Z(2))
               ZZ22=1.0-6.125E-06-Z(2)*Z(2)
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               Z(3)=SQRT(ZZ22)
            ELSEIF(Z(3).LT.0.0025) THEN
               ZZ22=Z(2)*Z(2)-1.225E-05
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               Z(2)=SIGN(SQRT(ZZ22),Z(2))
               ZZ22=1.0-6.125E-06-Z(2)*Z(2)
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               Z(3)=SQRT(ZZ22)
            ELSE
               ZZ22=Z(3)*Z(3)-1.225E-05
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               Z(3)=SQRT(ZZ22)
               ZZ22=1.0-6.125E-06-Z(3)*Z(3)
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               Z(2)=SQRT(ZZ22)
            ENDIF
         ENDIF
         IF(Z(3).GT.0.99997) THEN
            Z(1)=SIGN(0.005477184,Z(3))
            Z(2)=SIGN(0.005477184,Z(2))
            Z(3)=0.99997
         ENDIF
C
C   FOR EACH PRIMARY STRESS DIRECTION TESTED, FIND THE OTHER 2
C   PRINCIPAL STRESS DIRECTIONS
C
         CALL SECSTR(ISIG,IC,Z(1),Z(2),Z(3),PLSEC,AZSEC,APSEC,PSTEP,
     1    NSDP,PH)
         MTAB=M-NPS0
C
C   IF THERE ARE ANY SETS OF MUTUALLY ADMISSIBLE PRINCIPAL STRESS
C   DIRECTIONS, CONSTRUCT A TABLE OF STRESS MODELS AND PROCEED
C
         IF(NSDP.NE.0) CALL GRDTAB(NSDP,PH,MTAB,NPSTOT,RFACT)
  100 CONTINUE
      CLOSE(UNIT=4)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINES NPSF5 (5-DEG GRID) AND NPSF10 (10-DEG GRID) FIND THE   *
C*  NUMBER (NPS) OF PRIMARY (SIGMA-1 OR SIGMA-3) STRESS DIRECTIONS     *
C*  (PLPRI,AZPRI) TO BE USED IN CONSTRUCTING THE GRID.  THIS NUMBER    *
C*  IS SELECTED FROM A PREDETERMINED GRID OF PRIMARY STRESS DIREC-     *
C*  TIONS ACCORDING THE PRESCRIBED VARIANCE (APPRI)                    *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE NPSF5(APPRI,NPS)
      IF(APPRI.LT.30.0) THEN
         IF(APPRI.GE.29.0) THEN
            NPS=73
         ELSEIF(APPRI.GE.24.5) THEN
            NPS=61
         ELSEIF(APPRI.GE.23.5) THEN
            NPS=45
         ELSEIF(APPRI.GE.19.0) THEN
            NPS=41
         ELSEIF(APPRI.GE.17.5) THEN
            NPS=33
         ELSEIF(APPRI.GE.14.0) THEN
            NPS=25
         ELSEIF(APPRI.GE.12.0) THEN
            NPS=17
         ELSEIF(APPRI.GE.9.0) THEN
            NPS=13
         ELSEIF(APPRI.GE.6.5) THEN
            NPS=9
         ELSEIF(APPRI.GE.5.0) THEN
            NPS=5
         ELSE
            NPS=1
         ENDIF
      ELSE
         NPS=85
      ENDIF
      RETURN
      END
C
      SUBROUTINE NPSF10(APPRI,NPS)
      IF(APPRI.LT.90.0) THEN
         IF(APPRI.GE.80.0) THEN
            NPS=133
         ELSEIF(APPRI.GE.74.0) THEN
            NPS=109
         ELSEIF(APPRI.GE.68.0) THEN
            NPS=97
         ELSEIF(APPRI.GE.60.0) THEN
            NPS=85
         ELSEIF(APPRI.GE.52.0) THEN
            NPS=61
         ELSEIF(APPRI.GE.45.0) THEN
            NPS=49
         ELSEIF(APPRI.GE.40.0) THEN
            NPS=37
         ELSEIF(APPRI.GE.30.0) THEN
            NPS=25
         ELSEIF(APPRI.GE.19.0) THEN
            NPS=13
         ELSEIF(APPRI.GE.9.0) THEN
            NPS=5
         ELSE
            NPS=1
         ENDIF
      ELSE
         NPS=145
      ENDIF
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE SECSTR CALCULATES ALL ADMISSIBLE ORIENTATIONS OF THE    *
C*  SECONDARY STRESS (SIGMA-3 OR SIGMA-1) RELATIVE TO A SPECIFIED      *
C*  PRIMARY STRESS (SIGMA-1 OR SIGMA-3).  THESE DIRECTIONS UNIFORMLY   *
C*  SAMPLE THE REGION WITHIN THE PRESCRIBED LIMITS (APSEC) AROUND THE  *
C*  OPTIMUM SECONDARY STRESS DIRECTION (PLSEC,AZSEC)                   *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE SECSTR(ISIG,IC,C11,C12,C13,PLSEC,AZSEC,APSEC,PSTEP,
     1 NSDP,PH)
      DIMENSION AZ(3),CPL(3),C(40,3,3),PH(40)
      COMMON / TWO / C
      DATA PI,HPI,RAD / 3.1415927,1.5707963,0.017453292 /
      CAP=COS(APSEC)
      CPLA=COS(PLSEC)
      C41=COS(AZSEC)*CPLA
      C42=SIN(AZSEC)*CPLA
      C43=SIN(PLSEC)
C
C   COORDINATES OF PRIMARY STRESS DIRECTION: C11,C12,C13
C   COORDINATES OF SECONDARY STRESS DIRECTION: C41,C42,C43
C   FOR A GIVEN PRIMARY STRESS DIRECTION, CALCULATE THE LIMITING
C   VALUES OF PHI (1ST VALUE, INCREMENT, # OF INCREMENTS)
C
      CALL PHICLC(C11,C12,C13,C41,C42,C43,CAP,P1ST,PSTEP,NSDP)
      IF(NSDP.EQ.0) RETURN
C
C   COORDINATES OF AXIS ORTHOGONAL TO BOTH (C11,C12,C13) AND
C   (C41,C42,C43): C21,C22,C23
C
      IF(ABS(C42*C11-C41*C12).LE.1.0E-05) THEN
         AZ0=ATAN2(C12,C11)+HPI
         C21=COS(AZ0)
         C22=SIN(AZ0)
         C23=0.0
      ELSE
         C22=(C13*C41-C43*C11)/(C42*C11-C41*C12)
         C21=-(C13+C12*C22)/C11
         C23=1.0/SQRT(1.0+C21*C21+C22*C22)
         C21=C21*C23
         C22=C22*C23
      ENDIF
C
C   COORDINATES OF AXIS ORTHOGONAL TO BOTH (C11,C12,C13) AND
C   (C21,C22,C23): C31,C32,C33
C
      IF(ABS(C11*C22-C21*C12).LE.1.0E-05.OR.C13*C13+C23*C23.GT.1.0) THEN
         AZ0=ATAN2(C12,C11)+HPI
         C31=COS(AZ0)
         C32=SIN(AZ0)
         C33=0.0
      ELSE
         ZZ22=1.0-C13*C13-C23*C23
         IF(ZZ22.LT.0.0) ZZ22=1.0E-30
         C33=SQRT(ZZ22)
         C32=C33*(C21*C13-C11*C23)/(C11*C22-C21*C12)
         C31=-(C12*C32+C13*C33)/C11
      ENDIF
C
C   TEST TO SEE IF THE NEW AXES ARE OF THE PROPER HAND, AND FIX IF
C   NECESSARY
C
      IF(C31*C12*C23+C21*C32*C13+C11*C22*C33-C11*C23*C32-C12*C21*C33-
     1 C13*C22*C31.LT.0.0) THEN
         C21=-C21
         C22=-C22
         C23=-C23
      ENDIF
      AZ5=ATAN2(C12,C11)+HPI
      C51=COS(AZ5)
      C52=SIN(AZ5)
C
C   FOR EACH PRIMARY STRESS DIRECTION, FIND THE PRINCIPAL STRESS
C   COORDINATES IN THE EXTERNAL REFERENCE FRAME (NORTH, EAST,
C   DOWN) FOR EACH SET OF STRESS DIRECTIONS (EACH PHI VALUE)
C
      DO 30 J=1,NSDP
         C(J,ISIG,1)=C11
         C(J,ISIG,2)=C12
         C(J,ISIG,3)=C13
         PROT=P1ST-FLOAT(J-1)*PSTEP
         CE=COS(PROT)
         CO=COS(HPI+PROT)
         C21P=CO*C31+CE*C21
         C22P=CO*C32+CE*C22
         C23P=CO*C33+CE*C23
         C31P=CE*C31-CO*C21
         C32P=CE*C32-CO*C22
         C33P=CE*C33-CO*C23
         DO 25 M=1,2
            IF((ISIG.EQ.1.AND.M.EQ.1).OR.(ISIG.EQ.3.AND.M.EQ.2)) THEN
               DCN=C21
               DCE=C22
               DCD=C23 
            ELSE
               DCN=C31
               DCE=C32
               DCD=C33
            ENDIF
            CR=DCN*C11+DCE*C12+DCD*C13
            CA=DCN*C21+DCE*C22+DCD*C23
            CC=DCN*C31+DCE*C32+DCD*C33
            CX1=CR*C11+CA*C21P+CC*C31P
            CX2=CR*C12+CA*C22P+CC*C32P
            CX3=CR*C13+CA*C23P+CC*C33P
            IF(CX3.LT.0.0) THEN
                CX1=-CX1
                CX2=-CX2
                CX3=-CX3
            ENDIF
            CALL NORM(CX1,CX2,CX3)
            C(J,IC+M,1)=CX1
            C(J,IC+M,2)=CX2
            C(J,IC+M,3)=CX3
   25    CONTINUE
C
C   CALCULATE PHI VALUE, PH(J), (= RAKE OF SIGMA-2 DIRECTION IN
C   PLANE NORMAL TO PRIMARY STRESS DIRECTION--USING RIGHTHAND RULE)
C
         PHCOS=C(J,2,1)*C51+C(J,2,2)*C52
         IF(ABS(PHCOS).GT.1.0) PHCOS=SIGN(1.0,PHCOS)
         PH(J)=ACOS(PHCOS)/RAD
         IF(PH(J).GE.90.05) PH(J)=PH(J)-180.0
   30 CONTINUE
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE PHICLC FINDS THE LIMITS IN PHI (P1ST=1ST PHI VALUE,     *
C*  NSDP=# OF PHI VALUES) OVER WHICH TO SEARCH AROUND THE SECONDARY    *
C*  STRESS DIRECTION.                                                  *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE PHICLC(C11,C12,C13,C41,C42,C43,CAP,P1ST,PSTEP,NSDP)
      DIMENSION C1(2),C2(2),C3(2)
C
C   FOR EACH PAIR OF SIGMA-1 AND SIGMA-3 DIRECTIONS TESTED, FIND
C   THE LIMITING PHI VALUES--THIS IS DONE BY CONSTRUCTING AND 
C   SOLVING A SECOND-ORDER POLYNOMIAL EQUATION IN ANGLE COSINE
C   COORDINATES: C1(I),C2(I),C3(I)
C
      F=-C12/C11
      G=-C13/C11
      ED=F*C41+C42
      IF(ABS(ED).LT.1.0E-04) THEN
         IF(G.EQ.0.0) THEN
            C3(1)=CAP/C43
            C3(2)=-C3(1)
            ZZ22=(1.0-C3(1)*C3(1))/(1.0+F*F)
            IF(ZZ22.LT.0.0) ZZ22=1.0E-30
            C2(1)=SQRT(ZZ22)
            C2(2)=C2(1)
            DO 20 I=1,2
               C1(I)=C2(I)*F
               CALL NORM(C1(I),C2(I),C3(I))
               IF(C3(I).LT.0.0.OR.(I.EQ.2.AND.C1(1).EQ.C1(2).AND.
     1          C2(1).EQ.C2(2))) THEN
                  C1(I)=-C1(I)
                  C2(I)=-C2(I)
                  C3(I)=-C3(I)
               ENDIF
   20       CONTINUE
            GO TO 51
         ENDIF
         EF=G*C41+C43
         E=-ED/EF
         D=CAP/EF
         C=G*E+F
         B=G*D
         A1=1.0+C*C+E*E
         A2=2.0*(B*C+D*E)
         A3=B*B+D*D-1.0
         RADICAL=A2*A2-4.0*A1*A3
         IF(RADICAL.LT.-1.0E-05) THEN
            NSDP=0
            RETURN
         ELSEIF(RADICAL.LE.0.0) THEN
            C2(1)=-A2/(A1+A1)
            C2(2)=C2(1)
         ELSE
            IF(RADICAL.LT.0.0) RADICAL=1.0E-30
            SQRAD=SQRT(RADICAL)
            A12=A1+A1
            C2(1)=(-A2+SQRAD)/A12
            C2(2)=(-A2-SQRAD)/A12
         ENDIF
         DO 30 I=1,2
            C3(I)=D+E*C2(I)
            C1(I)=F*C2(I)+G*C3(I)
   30    CONTINUE
         GO TO 51
      ENDIF
      E=-(G*C41+C43)/ED
      D=CAP/ED
      C=F*E+G
      B=F*D
      A1=1.0+E*E+C*C
      A2=2.0*(B*C+D*E)
      A3=B*B+D*D-1.0
      RADICAL=A2*A2-4.0*A1*A3
      IF(RADICAL.LT.-1.0E-05) THEN
        NSDP=0
        RETURN
      ENDIF
      IF(RADICAL.LE.0.0) THEN
         C3(1)=-A2/(A1+A1)
         C3(2)=C3(1)
      ELSE
         IF(RADICAL.LT.0.0) RADICAL=1.0E-30
         SQRAD=SQRT(RADICAL)
         A12=A1+A1
         C3(1)=(-A2+SQRAD)/A12
         C3(2)=(-A2-SQRAD)/A12
      ENDIF
      DO 50 M=1,2
         C2(M)=D+E*C3(M)
         C1(M)=F*C2(M)+G*C3(M)
         CALL NORM(C1(M),C2(M),C3(M))
   50 CONTINUE
   51 CDOT=C1(1)*C1(2)+C2(1)*C2(2)+C3(1)*C3(2)
      IF(ABS(CDOT).GE.1.0) CDOT=SIGN(0.999999,CDOT)
      PSPR=ACOS(CDOT)
      NSDP=INT(PSPR/PSTEP)+1
      P1ST=0.5*FLOAT(NSDP-1)*PSTEP
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE GRDTAB CREATES A SET OF TABLES PRESENTING RESULTS OF    *
C*  THE INVERSION, PLOTTING R VS. PHI FOR EACH PRESCRIBED INITIAL      *
C*  PRINCIPAL STRESS DIRECTION                                         *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE GRDTAB(NSDP,PH,MTAB,MTABF,RFACT)
      DIMENSION IPL(3),IAZ(3),SUMR(21,40),PH(40),C(40,3,3)
      dimension temp(40,7), record(7)
      COMMON / TWO / C
      COMMON / FIVE / NFM,KFP,KR,RFXS,RSTEP,RSMIN,NTAB,NR,NPHI,record
      DATA HPI / 1.5707963 /
      DO 100 JPHI=1,NSDP
         IF(JPHI.EQ.1) WRITE(2,5044) NSDP,MTAB,MTABF
C         IF(JPHI.EQ.1) WRITE(*,504) NSDP,MTAB,MTABF
  504    FORMAT(' PRINCIPAL STRESS AXES, IN ORDER OF INCREASING PHI
     1 (',I2,')','  TABLE #',I3,' OF',I3)
 5044    FORMAT(//,' PRINCIPAL STRESS AXES, IN ORDER OF INCREASING PHI
     1 (',I2,')','  TABLE #',I3,' OF',I3/)
         DO 91 L=1,3
           CALL EULER(C(JPHI,L,1),C(JPHI,L,2),C(JPHI,L,3),IPL(L),IAZ(L))
   91    CONTINUE

         WRITE(2,505) (IPL(L),IAZ(L),L=1,3),PH(JPHI)



C        WRITE(*,506)(IPL(L),IAZ(L),L=1,3),PH(JPHI),JPHI,NSDP,MTAB,MTABF
  505    FORMAT(3(2(1X,I3),1X),3X,'PHI=',F6.1)
  506    FORMAT(3(2(1X,I3),1X),3X,'PHI=',F6.1,3X,'#',I3,' OF',I3,
     1    ' IN TABLE #',I3,' OF',I3)
c
         temp(JPHI,1) = 1.0*IPL(1)
         temp(JPHI,2) = 1.0*IAZ(1)
         temp(JPHI,3) = 1.0*IPL(2)
         temp(JPHI,4) = 1.0*IAZ(2)
         temp(JPHI,5) = 1.0*IPL(3)
         temp(JPHI,6) = 1.0*IAZ(3)
         temp(JPHI,7) = PH(JPHI)
c
         DO 93 K=1,KR
            SUMR(K,JPHI)=0.0
   93    CONTINUE
         CALL BETCLC(JPHI,SUMR)
         IF(JPHI.NE.NSDP) GO TO 100
         WRITE(2,507) KR,NSDP
C        WRITE(*,507) KR,NSDP
  507    FORMAT(/,' SUMS OF MISFIT; MODELS TABULATED IN R VS. PHI (',I2,
     1    ' x ',I2,')',/)
         WRITE(2,508) (PH(JP),JP=1,NSDP)
C        WRITE(*,508) (PH(JP),JP=1,NSDP)
  508    FORMAT(4X,10F7.1)
         RFIX=RFXS
         DO 99 K=1,KR
            DO 95 JP=1,NSDP
               SUMR(K,JP)=SUMR(K,JP)*RFACT
   95       CONTINUE
            RFIX=RFIX+RSTEP
            WRITE(2,509) RFIX,(SUMR(K,JP),JP=1,MIN(10,NSDP))
C           WRITE(*,509) RFIX,(SUMR(K,JP),JP=1,MIN(10,NSDP))
            IF(NSDP.GT.10) WRITE(2,510) (SUMR(K,JP),JP=11,NSDP)
C           IF(NSDP.GT.10) WRITE(*,510) (SUMR(K,JP),JP=11,NSDP)
  509       FORMAT(1X,F4.2,1X,10F7.3)
  510       FORMAT(6X,10F7.3)
C
C   KEEP TRACK OF THE BEST MODEL SO FAR AND ITS TABLE #, ROW #, AND
C   COLUMN #
C
            DO 97 J=1,NSDP
               IF(SUMR(K,J).LT.RSMIN) THEN
                  RSMIN=SUMR(K,J)
                  NTAB=MTAB
                  NR=K
                  NPHI=J
c
                  do 98 j98=1,7
                     record(j98)=temp(J,j98)
   98             continue
5055     format(3(i4,i4),2f7.1,f10.3)
c
               ENDIF
   97       CONTINUE
         WRITE(3,5055)(int(record(i)),i=1,6),record(7),0.1*(NR-1),RSMIN
   99    CONTINUE
            RFIX=RFXS
         DO 199 K=1,KR
            RFIX=RFIX+RSTEP
            DO 195 JP=1,NSDP
         DO 991 L=1,3
           CALL EULER(C(jp,L,1),C(jp,L,2),C(jp,L,3),IPL(L),IAZ(L))
  991    CONTINUE
             WRITE(99,5051) (IPL(L),IAZ(L),L=1,3),PH(jp),RFIX,sumr(k,jp)
195      continue
199      continue
5051     FORMAT(3(2(1X,I3),1X),F7.3,F4.1,f7.3)
  100 CONTINUE
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE BETCLC CALCULATES THE MATRIX BETA (B(I,J)), RELATING    *
C*  THE PRINCIPAL STRESS AND FAULT PLANE COORDINATE AXES               *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE BETCLC(JPHI,SUMR)
      LOGICAL KFPQ
      DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),
     1 CD2(470),B(3,3),SUMR(21,40),C(40,3,3)
      dimension record(7)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / FIVE / NFM,KFP,KR,RFXS,RSTEP,RSMIN,NTAB,NR,NPHI,record
      COMMON / SEVEN / METHOD
      DO 95 I=1,NFM
         DO 90 JJ=1,3
            B(1,JJ)=CN1(I,1)*C(JPHI,JJ,1)+CE1(I,1)*C(JPHI,JJ,2)+
     1       CD1(I,1)*C(JPHI,JJ,3)
            B(2,JJ)=CN2(I)*C(JPHI,JJ,1)+CE2(I)*C(JPHI,JJ,2)+
     1       CD2(I)*C(JPHI,JJ,3)
            B(3,JJ)=CN1(I,2)*C(JPHI,JJ,1)+CE1(I,2)*C(JPHI,JJ,2)+
     1       CD1(I,2)*C(JPHI,JJ,3)
   90    CONTINUE
C
C   SET KFPQ=.TRUE. IF THE FAULT PLANE IS KNOWN, =.FALSE. IF IT IS
C   UNKNOWN
C
         IF(I.LE.KFP) THEN
            KFPQ=.TRUE.
         ELSE
            KFPQ=.FALSE.
         ENDIF
         IF(METHOD.EQ.1) THEN
            CALL XPROTP(I,JPHI,B,KFPQ,SUMR)
         ELSEIF(METHOD.EQ.2) THEN
            CALL XPROTA(I,JPHI,B,KFPQ,SUMR)
         ELSE
            CALL XPROTE(I,JPHI,B,KFPQ,SUMR)
         ENDIF
   95 CONTINUE
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE XPROTP CALCULATES THE ROTATION MISFITS FOR BOTH NODAL   *
C*  PLANES ABOUT THE AXES OF THE FAULT PLANE GEOMETRY (FPG, OR THE     *
C*  PRIMED AXES)--FOR THE POLE ROTATION METHOD                         *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XPROTP(I,JPHI,B,KFPQ,SUMR)
      LOGICAL KFPQ
      DIMENSION B(3,3),ROTM1(21,2),SUMR(21,40),CN1(470,2),CE1(470,2),
     1 CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),DIP(470,2),Q(470)
      dimension record(7)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / THREE / AZ,DIP,Q
      COMMON / FIVE / NFM,KFP,KR,RFXS,RSTEP,RSMIN,NTAB,NR,NPHI,record
      DATA PI,PI2,RAD,HPI / 3.1415927,6.2831854,0.017453292,1.5707963 /
C
C   JK = NODAL PLANE INDEX
C   IK = INDEX OF FPG AXIS WHICH IS THE POLE OF THE NODAL PLANE 
C   LK = INDEX OF FPG AXIS WHICH IS THE SLIP DIRECTION ON THE 
C      NODAL PLANE
C
      JK=0
      B12B32=B(1,2)*B(3,2)
      B13B33=B(1,3)*B(3,3)
      DO 120 IK=1,3,2
         JK=JK+1
         IF(JK.EQ.2.AND.KFPQ) GO TO 120
         LK=4-IK
         B13B23=B(IK,3)*B(2,3)
         B12B22=B(IK,2)*B(2,2)
C
C   FOR EACH SET OF STRESS DIRECTIONS, B(I,J), TEST ALL VALUES OF
C   R (= RFIX)
C
         RFIX=RFXS
         DO 110 K=1,KR
            RFIX=RFIX+RSTEP
C
C   FOR AXISYMMETRIC STRESSES FIND ROTATIONS USING SUBROUTINE AXSYMP;
C   FOR NON-AXISYMMETRIC STRESSES, FIND ROTATION ABOUT THE POLE
C
            IF(RFIX.LT.0.001.OR.RFIX.GT.0.999) THEN
               CALL AXSYMP(I,LK,B,RFIX,ROTM)
            ELSE
               BNUM=B13B23+RFIX*B12B22
               ROT=ATAN(BNUM/(RFIX*B12B32+B13B33))
               CALL XPCHKP(I,IK,LK,B,ROT,RFIX)
               ROTM=ABS(ROT)
            ENDIF
            ROTM1(K,JK)=ROTM
            IF(KFPQ.OR.JK.EQ.2) THEN
               ROTM=ROTM1(K,1)
               IF(.NOT.KFPQ.AND.ROTM1(K,2).LT.ROTM) ROTM=ROTM1(K,2)
C
C   SUM MISFITS FOR ALL DATA IN ARRAY SUMR(J,K)--APPLY RELATIVE
C   WEIGHTS (ABS(Q(I)) HERE
C
               SUMR(K,JPHI)=SUMR(K,JPHI)+ROTM*ABS(Q(I))
            ENDIF
  110    CONTINUE
  120 CONTINUE
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE XPCHKP TESTS THE ROTATION FOUND IN SUBROUTINE XPROTP    *
C*  TO ENSURE THAT IT RESULTS IN THE CORRECT SENSE OF SLIP ON THE      *
C*  FAULT PLANE                                                        *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XPCHKP(I,IK,LK,B,ROT,RFIX)
      DIMENSION B(3,3),AZ(470,2),DIP(470,2),Q(470)
      COMMON / THREE / AZ,DIP,Q
      DATA PI,HPI / 3.1415927,1.5707963 /
C
C   TEST ROTATIONS ABOUT THE POLE OF THE FAULT PLANE--FIND ROTATED
C   COORDINATES
C
      CROT=COS(ROT)
      SROT=SIN(ROT)
      BNK2=CROT*B(LK,2)+SROT*B(2,2)
      BNK3=CROT*B(LK,3)+SROT*B(2,3)
C
C   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF CORRECT,
C   THEN THE FOLLOWING CONDITION IS FALSE; IF THE SENSE OF SLIP IS
C   INCORRECT, FIND THE NEW ROTATION
C
      IF(Q(I)*(RFIX*B(IK,2)*BNK2+B(IK,3)*BNK3).GT.0.0) ROT=ROT-
     1 SIGN(PI,ROT)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE AXSYMP CALCULATES THE ROTATION MISFITS BETWEEN OBSER-   *
C*  VATIONS AND AXISYMMETRIC STRESS MODELS--FOR THE POLE ROTATION      *
C*  METHOD                                                             *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE AXSYMP(I,LK,B,RFIX,ROTM)
      DIMENSION B(3,3),C(3,3),AZ(470,2),DIP(470,2),Q(470)
      COMMON / THREE / AZ,DIP,Q
      DATA PI / 3.1415927 /
C
C   KS = INDEX OF UNIQUE PRINCIPAL STRESS
C
      IF(RFIX.LT.0.001) THEN
         KS=3
      ELSE
         KS=1
      ENDIF
C
C   FIND ANGLE (COSINE) NEEDED TO ROTATE THE B AXIS TO AN ORIENTATION
C   PERPENDICULAR TO THE UNIQUE PRINCIPAL STRESS AXIS (DO THIS ONLY
C   IF THE UNIQUE STRESS IS IN THE PROPER QUADRANT OF THE FOCAL
C   MECHANISM; OTHERWISE THE CORRECT ROTATION IS THE SUPPLEMENT OF
C   THE ABOVE ANGLE)
C
      ROTM=ABS(ATAN(B(2,KS)/B(LK,KS)))
      IF(Q(I)*(RFIX*B(1,2)*B(3,2)+B(1,3)*B(3,3)).GT.0.0) ROTM=PI-ROTM
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE XPROTA CALCULATES THE ROTATION MISFITS FOR BOTH NODAL   *
C*  PLANES ABOUT THE AXES OF THE FAULT PLANE GEOMETRY (FPG, OR THE     *
C*  PRIMED AXES)--FOR THE APPROXIMATE METHOD                           *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XPROTA(I,JPHI,B,KFPQ,SUMR)
      LOGICAL KFPQ
      DIMENSION B(3,3),ROT(3),ROTM1(21,2),SUMR(21,40),CN1(470,2),
     1 CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),
     1 DIP(470,2),Q(470)
      dimension record(7)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / THREE / AZ,DIP,Q
      COMMON / FIVE / NFM,KFP,KR,RFXS,RSTEP,RSMIN,NTAB,NR,NPHI,record
      DATA PI,PI2,RAD,HPI / 3.1415927,6.2831854,0.017453292,1.5707963 /
C
C   JK = NODAL PLANE INDEX
C   IK = INDEX OF FPG AXIS WHICH IS THE POLE OF THE NODAL PLANE 
C   LK = INDEX OF FPG AXIS WHICH IS THE SLIP DIRECTION ON THE 
C      NODAL PLANE
C
      JK=0
      B222=B(2,2)*B(2,2)
      B232=B(2,3)*B(2,3)
      B12B32=B(1,2)*B(3,2)
      B13B33=B(1,3)*B(3,3)
      DO 120 IK=1,3,2
         JK=JK+1
         IF(JK.EQ.2.AND.KFPQ) GO TO 120
         LK=4-IK
         B122=B(IK,2)*B(IK,2)
         B132=B(IK,3)*B(IK,3)
         B13B23=B(IK,3)*B(2,3)
         B12B22=B(IK,2)*B(2,2)
         B22B32=B(2,2)*B(LK,2)
         B23B33=B(2,3)*B(LK,3)
C
C   FOR EACH SET OF STRESS DIRECTIONS, B(I,J), TEST ALL VALUES OF
C   R (= RFIX)
C
         RFIX=RFXS
         DO 110 K=1,KR
            RFIX=RFIX+RSTEP
C
C   FOR AXISYMMETRIC STRESSES FIND ROTATIONS USING SUBROUTINE AXSYMA;
C   FOR NON-AXISYMMETRIC STRESSES FIND THE SMALLEST OF THE ROTATIONS
C   ABOUT THE 3 FPG AXES
C
            IF(RFIX.LT.0.001.OR.RFIX.GT.0.999) THEN
               IF(JK.EQ.1) THEN
                  CALL AXSYMA(I,B,RFIX,ROTM)
               ELSE
                  ROTM=PI2
               ENDIF
            ELSE
               BNUM=B13B23+RFIX*B12B22
               ROT(IK)=ATAN(BNUM/(RFIX*B12B32+B13B33))
               ROT(2)=ATAN(BNUM/(RFIX*B22B32+B23B33))
               RK=(RFIX*(B122-B222)+B132-B232)/BNUM
               SRK2=SQRT(0.25-1.0/(4.0+RK*RK))
               ROT(LK)=ACOS(SQRT(0.5+SRK2))
               ROT(LK)=-SIGN(ROT(LK),RK)
               CALL XPCHKA(I,IK,LK,JK,B,ROT,RFIX)
               ROTM=ABS(ROT(1))
               DO 100 L=2,3
                  IF(ABS(ROT(L)).LT.ROTM) ROTM=ABS(ROT(L))
  100          CONTINUE
            ENDIF
            ROTM1(K,JK)=ROTM
            IF(KFPQ.OR.JK.EQ.2) THEN
               ROTM=ROTM1(K,1)
               IF(.NOT.KFPQ.AND.ROTM1(K,2).LT.ROTM) ROTM=ROTM1(K,2)
C
C   SUM MISFITS FOR ALL DATA IN ARRAY SUMR(J,K)--APPLY RELATIVE
C   WEIGHTS (ABS(Q(I)) HERE
C
               SUMR(K,JPHI)=SUMR(K,JPHI)+ROTM*ABS(Q(I))
            ENDIF
  110    CONTINUE
  120 CONTINUE
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE XPCHKA TESTS THE ROTATIONS FOUND IN SUBROUTINE XPROTA   *
C*  TO ENSURE THAT THEY RESULT IN THE CORRECT SENSE OF SLIP ON THE     *
C*  FAULT PLANE--FOR THE APPROXIMATE AND EXACT METHODS                 *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XPCHKA(I,IK,LK,JK,B,ROT,RFIX)
      DIMENSION ROT(3),B(3,3),AZ(470,2),DIP(470,2),Q(470)
      COMMON / THREE / AZ,DIP,Q
      DATA PI,PI2,HPI / 3.1415927,6.2831854,1.5707963 /
C
C   TEST ROTATIONS ABOUT THE POLE AND SLIP DIRECTION (FPG)
C
      DO 80 MK=1,3,2
         IF(MK.EQ.IK) THEN
            F=1.0
         ELSE
            F=-1.0
         ENDIF
         NK=4-MK
C
C   FIND ROTATED COORDINATES
C
         CROT=COS(ROT(MK))
         SROT=SIN(ROT(MK))
         BNK2=CROT*B(NK,2)+F*SROT*B(2,2)
         BNK3=CROT*B(NK,3)+F*SROT*B(2,3)
C
C   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF CORRECT,
C   THEN THE FOLLOWING CONDITION IS FALSE
C
         IF(Q(I)*(RFIX*B(MK,2)*BNK2+B(MK,3)*BNK3).GT.0.0) THEN
C
C   FIND NEW ROTATION ABOUT POLE OR SLIP DIRECTION
C
            IF(IK.NE.NK) THEN
               ROT(MK)=ROT(MK)-SIGN(PI,ROT(MK))
            ELSE
               ROT(MK)=ROT(MK)-SIGN(HPI,ROT(MK))
               SROTA=SROT
               SROT=-SIGN(CROT,SROTA)
               CROT=ABS(SROTA)
               BNK2=CROT*B(NK,2)+F*SROT*B(2,2)
               BNK3=CROT*B(NK,3)+F*SROT*B(2,3)
               IF(Q(I)*(RFIX*B(MK,2)*BNK2+B(MK,3)*BNK3).GT.0.0) ROT(MK)=
     1          ROT(MK)-SIGN(PI,ROT(MK))
            ENDIF
         ENDIF
   80 CONTINUE
      F=-F
      ROTM=ABS(ROT(IK))
      IF(ABS(ROT(LK)).LT.ROTM) ROTM=ABS(ROT(LK))
C
C   TEST ROTATIONS ABOUT THE B AXIS (FPG)
C
      IF(ROTM.GE.ABS(ROT(2))) THEN
C
C   FIND ROTATED COORDINATES
C
         CROT=COS(ROT(2))
         SROT=SIN(ROT(2))
         B12=CROT*B(1,2)-F*SROT*B(3,2)
         B13=CROT*B(1,3)-F*SROT*B(3,3)
         B32=CROT*B(3,2)+F*SROT*B(1,2)
         B33=CROT*B(3,3)+F*SROT*B(1,3)
C
C   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF INCORRECT,
C   NO OTHER ROTATIONS ABOUT THIS AXIS ARE ADMISSIBLE
C
         IF(Q(I)*(RFIX*B12*B32+B13*B33).GT.0.0) ROT(2)=PI2
      ENDIF
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE AXSYMA CALCULATES THE ROTATION MISFITS BETWEEN OBSER-   *
C*  VATIONS AND AXISYMMETRIC STRESS MODELS--FOR THE APPROXIMATE        *
C*  METHOD                                                             *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE AXSYMA(I,B,RFIX,ROTM)
      DIMENSION B(3,3),AZ(470,2),DIP(470,2),Q(470)
      COMMON / THREE / AZ,DIP,Q
      DATA PI / 3.1415927 /
C
C   KS = INDEX OF UNIQUE PRINCIPAL STRESS
C
      IF(RFIX.LT.0.001) THEN
         KS=3
      ELSE
         KS=1
      ENDIF
C
C   FIND ANGLE (COSINE) NEEDED TO ROTATE THE B AXIS TO AN ORIENTATION
C   PERPENDICULAR TO THE UNIQUE PRINCIPAL STRESS AXIS (DO THIS ONLY
C   IF THE UNIQUE STRESS IS IN THE PROPER QUADRANT OF THE FOCAL
C   MECHANISM; OTHERWISE THE CORRECT ROTATION IS THE SUPPLEMENT OF
C   THE ABOVE ANGLE)
C
      ROT1=ABS(ATAN(B(2,KS)/B(3,KS)))
      ROT3=ABS(ATAN(B(2,KS)/B(1,KS)))
      IF(Q(I)*(RFIX*B(1,2)*B(3,2)+B(1,3)*B(3,3)).GT.0.0) THEN
         ROT1=PI-ROT1
         ROT3=PI-ROT3
      ENDIF
      IF(ROT1.GT.ROT3) THEN
         ROTM=ROT3
      ELSE
         ROTM=ROT1
      ENDIF
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE XPROTE CALCULATES THE ROTATION MISFITS FOR BOTH NODAL   *
C*  PLANES ABOUT THE AXES OF THE FAULT PLANE GEOMETRY (FPG, OR THE     *
C*  PRIMED AXES)--FOR THE EXACT METHOD                                 *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XPROTE(I,JPHI,B,KFPQ,SUMR)
      LOGICAL KFPQ,SSLP,PASS1
      DIMENSION B(3,3),ROT(3),ROTM1(21,2),SUMR(21,40),CN1(470,2),
     1 CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),
     1 DIP(470,2),Q(470)
      dimension record(7)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / THREE / AZ,DIP,Q
      COMMON / FIVE / NFM,KFP,KR,RFXS,RSTEP,RSMIN,NTAB,NR,NPHI,record
      COMMON / SIX / SSLP,PASS1
      DATA PI,PI2,RAD / 3.1415927,6.2831854,0.017453292 /
C
C   JK = NODAL PLANE INDEX
C   IK = INDEX OF FPG AXIS WHICH IS THE POLE OF THE NODAL PLANE 
C   LK = INDEX OF FPG AXIS WHICH IS THE SLIP DIRECTION ON THE 
C      NODAL PLANE
C
      JK=0
      B222=B(2,2)*B(2,2)
      B232=B(2,3)*B(2,3)
      B12B32=B(1,2)*B(3,2)
      B13B33=B(1,3)*B(3,3)
      DO 120 IK=1,3,2
         JK=JK+1
         IF(JK.EQ.2.AND.KFPQ) GO TO 120
         LK=4-IK
         B122=B(IK,2)*B(IK,2)
         B132=B(IK,3)*B(IK,3)
         B13B23=B(IK,3)*B(2,3)
         B12B22=B(IK,2)*B(2,2)
         B22B32=B(2,2)*B(LK,2)
         B23B33=B(2,3)*B(LK,3)
C
C   FOR EACH SET OF STRESS DIRECTIONS, B(I,J), TEST ALL VALUES OF
C   R (= RFIX)
C
         RFIX=RFXS
         DO 110 K=1,KR
            RFIX=RFIX+RSTEP
C
C   FOR AXISYMMETRIC STRESSES FIND ROTATIONS USING SUBROUTINE AXSYME
C
            IF(RFIX.LT.0.001.OR.RFIX.GT.0.999) THEN
               IF(JK.EQ.1) THEN
                  CALL AXSYME(I,B,RFIX,ROTM)
               ELSE
                  ROTM=PI2
               ENDIF
               GO TO 105
            ENDIF
C
C   FOR NON-AXISYMMETRIC STRESSES, FIND ROTATIONS ABOUT FPG AXES
C
            BNUM=B13B23+RFIX*B12B22
            ROT(IK)=ATAN(BNUM/(RFIX*B12B32+B13B33))
            ROT(2)=ATAN(BNUM/(RFIX*B22B32+B23B33))
            RK=(RFIX*(B122-B222)+B132-B232)/BNUM
            SRK2=SQRT(0.25-1.0/(4.0+RK*RK))
            ROT(LK)=ACOS(SQRT(0.5+SRK2))
            ROT(LK)=-SIGN(ROT(LK),RK)
C
C   IF THE SENSE OF SLIP ON THE OBSERVED FAULT PLANE IS "CORRECT"
C   FOR THE STRESS MODEL IN QUESTION, THEN SET PASS1 = .TRUE.--IN
C   WHICH CASE THE SENSE OF SLIP WILL NOT BE CHECKED UNTIL THE SMALL-
C   EST ROTATION IS FOUND (IF IT IS THEN INCORRECT, RETURN TO THIS
C   POINT AND REPEAT, THIS TIME CHECKING SENSE OF SLIP AS SUCCESSIVE
C   ROTATIONS ARE CALCULATED, AND ADMITTING ONLY CORRECT ONES).  IF
C   THE SENSE OF SLIP ON THE OBSERVED FAULT PLANE IS "INCORRECT", THEN
C   SET PASS1 = .FALSE. AND CHECK THE SENSE OF SLIP ALL ALONG THE PATH
C   TO THE SMALLEST ROTATION.  IN A SENSE, THIS APPROACH IS GAMBLING
C   THAT THE OBSERVED CONDITION PREDICTS THE SENSE OF SLIP ON THE
C   CLOSEST SOLUTION, THEREBY SAVING COMPUTATIONS WHERE POSSIBLE.
C
            IF(Q(I)*(RFIX*B12B32+B13B33).LE.0.0) THEN
               PASS1=.TRUE.
            ELSE
               PASS1=.FALSE.
               CALL XPCHKA(I,IK,LK,JK,B,ROT,RFIX)
            ENDIF
C
C   FIND THE SMALLEST OF THE ROTATIONS ABOUT THE 3 FPG AXES
C
   90       MX=1
            ROTM=ABS(ROT(1))
            DO 100 L=2,3
               IF(ABS(ROT(L)).LT.ROTM) THEN
                  MX=L
                  ROTM=ABS(ROT(L))
               ENDIF
  100       CONTINUE
            IF(JK.EQ.2) MX=4-MX
            IF(MX.EQ.3) THEN
               AZI=AMOD(AZ(I,3-JK)+270.0,360.0)*RAD
               PL=(90.0-DIP(I,3-JK))*RAD
            ELSEIF(MX.EQ.2) THEN
               AZI=AMOD(ATAN2(CE2(I),CN2(I))+PI2,PI2)
               PL=ASIN(CD2(I))
            ELSE
               AZI=AMOD(AZ(I,JK)+270.0,360.0)*RAD
               PL=(90.0-DIP(I,JK))*RAD
            ENDIF
C
C   FIND THE SMALLEST ROTATION ABOUT ALL AXES (OF GENERAL ORIENTATION)
C
            CALL AXRFN(I,JK,JPHI,B,RFIX,AZI,PL,ROTM)
C
C   IF THE SMALLEST ROTATION FOUND IN THE FIRST PASS YIELDS THE
C   WRONG SENSE OF SLIP ON THE ROTATED FAULT PLANE, START OVER,
C   THIS TIME KEEPING TRACK OF THE SENSE OF SLIP (AND NOT ADMIT-
C   TING SOLUTIONS YIELDING THE INCORRECT SENSE OF SLIP)--HOPE-
C   FULLY, THIS PATH IS TAKEN INFREQUENTLY
C
            IF(.NOT.SSLP.AND.PASS1) THEN
               CALL XPCHKA(I,IK,LK,JK,B,ROT,RFIX)
               PASS1=.FALSE.
               GO TO 90
            ENDIF
  105       ROTM1(K,JK)=ROTM
            IF(KFPQ.OR.JK.EQ.2) THEN
               ROTM=ROTM1(K,1)
               IF(.NOT.KFPQ.AND.ROTM1(K,2).LT.ROTM) ROTM=ROTM1(K,2)
C
C   SUM MISFITS FOR ALL DATA IN ARRAY SUMR(J,K)--APPLY RELATIVE
C   WEIGHTS (ABS(Q(I)) HERE
C
               SUMR(K,JPHI)=SUMR(K,JPHI)+ROTM*ABS(Q(I))
            ENDIF
  110    CONTINUE
  120 CONTINUE
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE AXSYME CALCULATES THE ROTATION MISFITS BETWEEN OBSER-   *
C*  VATIONS AND AXISYMMETRIC STRESS MODELS--FOR THE EXACT METHOD       *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE AXSYME(I,B,RFIX,ROTM)
      DIMENSION B(3,3),AZ(470,2),DIP(470,2),Q(470)
      COMMON / THREE / AZ,DIP,Q
C
C   KS = INDEX OF UNIQUE PRINCIPAL STRESS
C
      IF(RFIX.LT.0.001) THEN
         KS=3
      ELSE
         KS=1
      ENDIF
C
C   FIND ANGLE (COSINE) NEEDED TO ROTATE THE B AXIS TO AN ORIENTATION
C   PERPENDICULAR TO THE UNIQUE PRINCIPAL STRESS AXIS (DO THIS ONLY
C   IF THE UNIQUE STRESS IS IN THE PROPER QUADRANT OF THE FOCAL
C   MECHANISM; OTHERWISE ROTATE THE POLE OR SLIP DIRECTION TO ALIGN-
C   MENT WITH THE UNIQUE STRESS)
C
      IF(Q(I)*(RFIX*B(1,2)*B(3,2)+B(1,3)*B(3,3)).LE.0.0) THEN
         ZZ22=1.0-B(2,KS)*B(2,KS)
         IF(ZZ22.LT.0.0) ZZ22=1.0E-30
         ROTM=SQRT(ZZ22)
      ELSE
         ROTM=ABS(B(1,KS))
         IF(ABS(B(3,KS)).GT.ROTM) ROTM=ABS(B(3,KS))
      ENDIF
      IF(ROTM.GT.1.0) ROTM=SIGN(1.0,ROTM)
      ROTM=ACOS(ROTM)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE AXRFN LOCATES THE AXIS OF THE SMALLEST ROTATION THAT    *
C*  ACHIEVES A MATCH BETWEEN THE SHEAR STRESS AND SLIP DIRECTIONS ON   *
C*  ONE NODAL PLANE                                                    *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE AXRFN(I,KJ,JPHI,B,RFIX,AZAX,PLAX,RAX)
      DIMENSION B(3,3),PHI(2),PHIA(2),DZZ(2)
      LOGICAL SRF,SSLP,PASS1
      COMMON / FOUR / A1,A2,A3,A4,A5,A6
      COMMON / SIX / SSLP,PASS1
      DATA PINC1,PI,PI2 / 0.08726646,3.1415927,6.2831854 /
      DATA PINC2,RAD,HPI / 0.21816615,0.017453292,1.5707963 /
C
C   KJ = NODAL PLANE INDEX
C   K = INDEX OF THE POLE TO THE NODAL PLANE (FAULT PLANE COORD'S)
C   L = INDEX OF THE SLIP DIRECTION, OR THE POLE TO THE AUX. PLANE 
C
      K=1
      IF(KJ.EQ.2) K=3
      L=4-K
      RF=(RFIX-1.0)/RFIX
C
C   SRF = .TRUE. ON THE FINAL PASS, WHEN THE SIGN OF THE ROTATION
C   MUST BE FOUND (SO THAT THE SENSE OF SLIP ON THE ROTATED FAULT
C   PLANE CAN BE CHECKED); SRF = .FALSE. ON SOME INITIAL PASSES,
C   WHEN ONLY THE MAGNITUDE OF THE ROTATION MUST BE FOUND
C
      SRF=.NOT.PASS1
C
C   FIND COEFFICIENTS
C
      A1=B(K,1)*B(K,1)+RF*B(K,3)*B(K,3)
      A2=B(2,1)*B(2,1)+RF*B(2,3)*B(2,3)
      A3=B(L,1)*B(L,1)+RF*B(L,3)*B(L,3)
      A4=B(2,1)*B(L,1)+RF*B(2,3)*B(L,3)
      A5=B(K,1)*B(L,1)+RF*B(K,3)*B(L,3)
      A6=B(K,1)*B(2,1)+RF*B(K,3)*B(2,3)
C
C   TEST "OCTAHEDRAL" AXIS (EQUIANGULAR FROM THE THREE PRIMED
C   COORDINATE AXES--OF THE FAULT PLANE GEOMETRY), TO SEE IF
C   ROTATIONS ABOUT ANY OF THESE ARE SMALLER THAN THOSE ABOUT
C   THE FPG (SUBROUTINE XPROTE)--AND SO OFFER A BETTER STARTING
C   POSITION FOR FINDING THE BEST AXIS
C
      CALL OCTROT(I,KJ,B,BAZ,BPL,BR,SRF)
C
C   TAKE THE SMALLEST OF ALL AXES TESTED SO FAR (IN SUBROUTINES
C   XPROTE AND OCTROT)
C
      IF(BR.LE.RAX) THEN
         AZAX=BAZ
         PLAX=BPL
         RAX=BR
      ENDIF
      CR=COS(RAX)
      PHI(1)=AZAX
      PHI(2)=PLAX
      PINC=PINC1
      NV=0
C
C   REFINE ROTATION AXIS BY MOVING DOWN THE PATH OF STEEPEST
C   DESCENT IN SUCCESSIVE STEPS
C
      DO 105 II=1,100
         PHIA(1)=PHI(1)
         PHIA(2)=PHI(2)
         CRA=CR
C
C   CONSIDER 2 NEW AXES IN THE NEIGHBORHOOD OF THE CURRENT ONE--
C   FIND THE SMALLEST ROTATION ABOUT EACH
C
   90    DO 95 JI=1,2
            KI=3-JI
            PHI(KI)=PHIA(KI)
            PHI(JI)=PHIA(JI)+PINC
            CALL INVEUL(I,PHI(1),PHI(2),KJ,C1,C2,C3)
            CALL GENROT(I,KJ,B,RFIX,C1,C2,C3,CRZ,SRF)
            DZZ(JI)=CRZ-CRA
   95    CONTINUE
C
C   IF A LOCAL SLOPE CANNOT BE FOUND, TRY A BIGGER STEP; IF TOO
C   BIG A STEP, GET OUT OF LOOP
C
         IF(DZZ(1).EQ.0.0.AND.DZZ(2).EQ.0.0) THEN
            IF(PINC.LT.PINC2) THEN
               PINC=1.2*PINC
               GO TO 90
            ELSE
               PHI(1)=PHIA(1)
               PHI(2)=PHIA(2)
               CR=CRA
               GO TO 107
            ENDIF
         ENDIF
C
C   FIND A NEW AXIS DOWN-SLOPE FROM THE CURRENT ONE
C
         PSI=ATAN2(DZZ(2),DZZ(1))
         PHI(1)=PHIA(1)+COS(PSI)*PINC
         IF(PHI(1).LT.0.0.OR.PHI(1).GE.PI2) PHI(1)=AMOD(PHI(1)+PI2,PI2)
         PHI(2)=PHIA(2)+SIN(PSI)*PINC
         IF(PHI(2).LT.0.0.OR.PHI(2).GT.HPI) THEN
            PHI(2)=-PHI(2)
            IF(PHI(2).LT.0.0) PHI(2)=PI+PHI(2)
            PHI(1)=AMOD(PHI(1)+PI,PI2)
         ENDIF
         CALL INVEUL(I,PHI(1),PHI(2),KJ,C1,C2,C3)
         CALL GENROT(I,KJ,B,RFIX,C1,C2,C3,CR,SRF)
C
C   IF THE MAGNITUDE OF ROTATION HAS INCREASED FROM THE PREVIOUS
C   STEP, REDUCE THE SIZE OF THE STEP AND TRY AGAIN--STOP AFTER
C   4 REDUCTIONS
C
         IF(CR.LE.CRA) THEN
            NV=NV+1
            IF(NV.EQ.4) THEN
               PHI(1)=PHIA(1)
               PHI(2)=PHIA(2)
               CR=CRA
               GO TO 107
            ELSE
               PINC=0.5*PINC
               GO TO 90
            ENDIF
         ENDIF
  105 CONTINUE
C
C   SET SRF = .TRUE. AND CHECK TO ENSURE PROPER SENSE OF SLIP ON
C   THE FINAL SOLUTION
C
  107 SRF=.TRUE.
      CALL INVEUL(I,PHI(1),PHI(2),KJ,C1,C2,C3)
      CALL GENROT(I,KJ,B,RFIX,C1,C2,C3,CR,SRF)
C
C   AT THE END, COMPARE THE BEST ROTATION TO THE ANGLE NEEDED TO
C   SUPERIMPOSE THE POLE TO THE NODAL PLANE AND EACH PRINCIPAL
C   STRESS AXIS (ADMISSIBLE SOLUTIONS); SELECT THE SMALLEST OF
C   THESE.  THIS IS NECESSARY ONLY FOR VERY ERRATIC DATA FOR
C   WHICH IT IS DIFFICULT TO FIND THE OPTIMUM AXIS OWING TO THE
C   SENSE-OF-SLIP CONSTRAINT
C
      IF(.NOT.PASS1) THEN
         K=1
         IF(KJ.EQ.2) K=3
         DO 110 L=1,3
            IF(ABS(B(K,L)).GT.CR) CR=ABS(B(K,L))
  110    CONTINUE
      ENDIF
      IF(CR.GT.1.0) CR=SIGN(1.0,CR)
      RAX=ACOS(CR)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE OCTROT DETERMINES THE SMALLEST ROTATION ABOUT THE FOUR  *
C*  "OCTAHEDRAL" AXES (RELATIVE TO THE FAULT PLANE COORDINATES) NEEDED *
C*  TO MATCH THE SHEAR STRESS AND SLIP DIRECTIONS ON A FAULT PLANE;    *
C*  THE SMALLEST AMONG THESE FOUR OR THE THREE AXES TESTED IN SUBROU-  *
C*  TINE XPROTE IS TAKEN THE INITIAL GUESS OF THE OPTIMUM ROTATION     *
C*  AXIS (THE STARTING MODEL IN SUBROUTINE AXRFN)                      *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE OCTROT(I,J,B,AZIM,PLNG,RBD,SRF)
      DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),
     1 CD2(470),BDCR(4),B(3,3)
      LOGICAL SRF
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      DATA SQ3I,PI2 / 0.5773503,6.2831854 /
      K=3-J
C
C   FIND THE ROTATIONS ABOUT THE 4 "OCTAHEDRAL" AXES (EQUALLY SPACED
C   BETWEEN THE AXIS OF THE FAULT PLANE GEOMETRY)
C
      CALL GENROT(I,J,B,RFIX,SQ3I,SQ3I,SQ3I,BDCR(1),SRF)
      CALL GENROT(I,J,B,RFIX,SQ3I,SQ3I,-SQ3I,BDCR(2),SRF)
      CALL GENROT(I,J,B,RFIX,SQ3I,-SQ3I,SQ3I,BDCR(3),SRF)
      CALL GENROT(I,J,B,RFIX,SQ3I,-SQ3I,-SQ3I,BDCR(4),SRF)
C
C   SELECT THE SMALLEST OF THESE AND FIND ITS AXIS
C
      LBD=1
      DO 10 L=2,4
         IF(BDCR(L).GT.BDCR(LBD)) LBD=L
   10 CONTINUE
      F1=1.0
      IF(LBD.GE.3) F1=-F1
      F2=1.0
      IF(MOD(LBD,2).EQ.0) F2=-F2
      CN=CN1(I,J)+F1*CN2(I)+F2*CN1(I,K)
      CE=CE1(I,J)+F1*CE2(I)+F2*CE1(I,K)
      CD=(CD1(I,J)+F1*CD2(I)+F2*CD1(I,K))*SQ3I
      IF(CD.LT.0.0) THEN
         CN=-CN
         CE=-CE
         CD=-CD
      ENDIF
      PLNG=ASIN(CD)
      AZIM=AMOD(ATAN2(CE,CN)+PI2,PI2)
      IF(BDCR(LBD).GT.1.0) BDCR(LBD)=SIGN(1.0,BDCR(LBD))
      RBD=ACOS(BDCR(LBD))
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE GENROT FINDS THE MAGNITUDE OF THE SMALLEST ROTATION     *
C*  ABOUT A SINGLE AXIS (OF GENERAL ORIENTATION) NEEDED TO MATCH A     *
C*  STRESS MODEL AND A FAULT PLANE GEOMETRY;  THIS IS ACCOMPLISHED     *
C*  BY CONSTRUCTING AND SOLVING A FOURTH-ORDER POLYNOMIAL EQUATION     *
C*  (SUBROUTINE POLY4)                                                 *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE GENROT(I,KJ,B,RFIX,C1,C2,C3,YY,SRF)
      LOGICAL SRF
      DIMENSION D(5),B(3,3),Y(4),Z(4)
      COMMON / FOUR / A1,A2,A3,A4,A5,A6
      DATA DEG20 / 0.00087266 /
      DELTA=DEG20
C
C   SET UP COEFFICIENTS
C
   10 C1C2=C1*C2
      C1C3=C1*C3
      C2C3=C2*C3
      C1C1=C1*C1
      C2C2=C2*C2
      C3C3=C3*C3
      B1=C1C2*(A1*C1C1+A2*C2C2+A3*(C3C3-1.0)+2.0*(A6*C1C2+A5*C1C3+A4*
     1 C2C3))+A4*C1C3+A5*C2C3-A6*C3C3
      B2=C3*(C1C1*(A1-A3)+C2C2*(A3-A2))+A4*C2*(C2C2+C2C2-1.0)+A5*C1*
     1 (1.0-C1C1-C1C1)
      B3=C1C2*(A1+A2-2.0*((A1*C1C1+A2*C2C2+A3*C3C3)+2.0*(A4*C2C3+A5*
     1 C1C3+A6*C1C2)))+A4*C1C3+A5*C2C3+A6*(1.0-C3C3)
      B4=2.0*(A4*C2*(1.0-C2C2)+A5*C1*(C1C1-1.0))+C3*(A1*(1.0-C1C1)-
     1 A2*(1.0-C2C2)+A3*(C1C1-C2C2))
      B5=C1C2*(A1*(C1C1-1.0)+A2*(C2C2-1.0)+A3*(C3C3+1.0)+2.0*(A6*C1C2+
     1 A5*C1C3+A4*C2C3))+2.0*(A6*C3C3-A5*C2C3-A4*C1C3)
      B6=B2*B4
      B7=B2*B2
      B8=B4*B4
      D(1)=B5*B5+B8
C
C   IF THE MAGNITUDE OF D(1) IS TOO SMALL, THE RESULTS OF THE FOLLOWING
C   CALCULATIONS MAY BE IMPRECISE; MAKE SMALL ADJUSTMENTS IN THE AXIS
C   ORIENTATION TO AVOID THIS CONDITION
C
      IF(ABS(D(1)).LT.1.0E-08) THEN
         DELTA=1.1*DELTA
         IF(ABS(C1).GT.ABS(C2)) THEN
            IF(ABS(C1).GT.ABS(C3)) THEN
               IF(C1.GT.1.0) C1=SIGN(1.0,C1)
               C1=COS(ACOS(C1)+DELTA)
               ZZ22=1.0-C1*C1-C3*C3
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               C2=SQRT(ZZ22)
            ELSE
               IF(C3.GT.1.0) C3=SIGN(1.0,C3)
               C3=COS(ACOS(C3)+DELTA)
               ZZ22=1.0-C1*C1-C3*C3
               IF(ZZ22.LT.0.0) ZZ22=1.0E-30
               C2=SQRT(ZZ22)
            ENDIF
         ELSEIF(ABS(C2).GT.ABS(C3)) THEN
            IF(C2.GT.1.0) C2=SIGN(1.0,C2)
            C2=COS(ACOS(C2)+DELTA)
            ZZ22=1.0-C2*C2-C3*C3
            IF(ZZ22.LT.0.0) ZZ22=1.0E-30
            C1=SQRT(ZZ22)
         ELSE
            IF(C3.GT.1.0) C3=SIGN(1.0,C3)
            C3=COS(ACOS(C3)+DELTA)
            ZZ22=1.0-C2*C2-C3*C3
            IF(ZZ22.LT.0.0) ZZ22=1.0E-30
            C1=SQRT(ZZ22)
         ENDIF
         GO TO 10
      ENDIF
      D(2)=2.0*(B3*B5+B6)
      D(3)=2.0*B1*B5+B3*B3+B7-B8
      D(4)=2.0*(B1*B3-B6)
      D(5)=B1*B1-B7
C
C   SOLVE 4TH ORDER POLYNOMIAL EQUATION FOR COS
C
      CALL POLY4(D,Y)
C
C   IF THE SIGN OF THE ROTATION IS NEEDED, SOLVE 4TH ORDER POLYNOMIAL
C   EQUATION FOR SIN ALSO
C
      IF(SRF) THEN
         B1=B1+B5
         D(2)=2.0*(B3*B4-B2*B5)
         D(3)=B7-2.0*B1*B5+B3*B3-B8
         D(4)=2.0*(B1*B2-B3*B4)
         D(5)=B1*B1-B3*B3
         CALL POLY4(D,Z)
      ENDIF
C
C   ARRANGE THE ROTATION SOLUTIONS IN ORDER OF INCREASING MAGNITUDES
C
      CALL COSORT(1,Y,Z,YY,SRF,ZZ)
C
C   IF NECESSARY, CHECK TO ENSURE THE PROPER SENSE OF SLIP ON THE
C   ROTATED FAULT PLANE
C
      IF(SRF) CALL SSCHK(I,KJ,B,RFIX,C1,C2,C3,Y,Z,YY,ZZ)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE COSORT ARRANGES THE SOLUTIONS FROM SUBROUTINE GENROT    *
C*  IN ORDER OF INCREASING MAGNITUDES                                  *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE COSORT(J,Y,Z,YY,SRF,ZZ)
      LOGICAL SRF
      DIMENSION Y(4),Z(4)
C
C   FIND THE JTH SMALLEST ROTATION (JTH LARGEST ANGLE COSINE), BY
C   SORTING Y(I)--ARRAY OF UP TO 4 ROTATION ANGLE COSINES
C
      DO 120 K=1,J
         IF(K.NE.4) THEN
            K1=K+1
            DO 115 L=K1,4
               IF(Y(K).LT.Y(L).AND.Y(L).LE.1.0) THEN
                  YA=Y(K)
                  Y(K)=Y(L)
                  Y(L)=YA
               ENDIF
  115       CONTINUE
         ENDIF
  120 CONTINUE
      YY=Y(J)
      IF(ABS(YY).GT.1.0) YY=SIGN(1.0,YY)
      IF(.NOT.SRF) RETURN
C
C   IF CHECKING SENSE OF SLIP, ASSOCIATE THE SOLUTIONS OF THE
C   COSINE EQUATION, Y(I), WITH THE CORRESPONDING SOLUTIONS OF
C   THE SINE EQUATION, Z(I)
C
      ZZ22=1.0-YY*YY
      IF(ZZ22.LT.0.0) ZZ22=1.0E-30
      ZC=SQRT(ZZ22)
      DO 125 K=1,4
         IF(ABS(ZC-ABS(Z(K))).LE.0.0001) THEN
            ZA=Z(J)
            Z(J)=Z(K)
            Z(K)=ZA
         ENDIF
  125 CONTINUE
      DO 130 K=1,4
         IF(K.NE.J) THEN
            IF(ABS(ZC-ABS(Z(K))).LT.ABS(ZC-ABS(Z(J)))) THEN
               ZA=Z(K)
               Z(K)=Z(J)
               Z(J)=ZA
            ENDIF
         ENDIF
  130 CONTINUE
      IF(YY.EQ.1.0) THEN
         YA=1.0-Z(J)*Z(J)
         IF(YA.LT.0.0) YA=0.0
         YY=SIGN(SQRT(YA),YY)
      ENDIF
      ZZ=Z(J)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE POLY4 (DOUBLE PRECISION) DETERMINES UP TO FOUR REAL     *
C*  ROOTS OF A FOURTH ORDER POLYNOMIAL EQUATION WITH COEFFICIENTS      *
C*  FOUND IN SUBROUTINE GENROT                                         *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE POLY4(D,Y)
      IMPLICIT DOUBLE PRECISION (A-C,E-H,O-X,Z)
      DIMENSION D(5),E(5),C(4),Y(4)
      DO 10 I=2,5
         E(I)=DBLE(D(I)/D(1))
   10 CONTINUE
      E(1)=1.0D0
      C(4)=1.0D0
      C(3)=-E(3)
      C(2)=E(4)*E(2)-4.0*E(5)
      C(1)=-E(4)*E(4)-E(5)*E(2)*E(2)+4.0*E(5)*E(3)
      CALL POLY3(C,X)
      RAUX=0.25*E(2)*E(2)-E(3)+X
      IF(RAUX.LT.0.0D0) RAUX=0.0D0
      R=DSQRT(RAUX)
      IF(R.NE.0.0D0) THEN
         F1=0.75*E(2)*E(2)-R*R-E(3)-E(3)
         F2=(E(2)*E(3)-E(4)-E(4)-0.25*E(2)*E(2)*E(2))/R
      ELSE
         F1=0.75*E(2)*E(2)-E(3)-E(3)
         FAUX=X*X-4.0*E(5)
         IF(FAUX.LT.0.0D0) FAUX=0.0D0
         F2=2.0*DSQRT(FAUX)
      ENDIF
      G=F1+F2
      IF(G.LT.0.0D0) THEN
         Y(1)=-1.0
         Y(2)=-1.0
      ELSE
         IF(G.LT.0.0) G=1.0E-30
         G=DSQRT(G)
         Y(1)=SNGL(0.5*(R-0.5*E(2)+G))
         Y(2)=SNGL(0.5*(R-0.5*E(2)-G))
      ENDIF
      H=F1-F2
      IF(H.LT.0.0D0) THEN
         Y(3)=-1.0
         Y(4)=-1.0
      ELSE
         IF(H.LT.0.0) H=1.0E-30
         H=DSQRT(H)
         Y(3)=SNGL(-0.5*(R+0.5*E(2)-H))
         Y(4)=SNGL(-0.5*(R+0.5*E(2)+H))
      ENDIF
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE POLY3 (DOUBLE PRECISION) DETERMINES ONE REAL ROOT OF    *
C*  OF A THIRD ORDER POLYNOMIAL EQUATION, AS NEEDED IN SUBROUTINE      *
C*  POLY4                                                              *
C*                                                                     *
C*  NOTE:  VARIABLES IN THIS SUBROUTINE MAY ATTAIN EXTREME VALUES;     *
C*  E.G., ON VAX-11 COMPUTERS USE THE /G_FLOATING COMPILER OPTION      *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE POLY3(C,X)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION C(4)
      DATA OT,TT / 0.3333333333333333D0,0.6666666666666667D0 /
      DATA SQRT2 / 1.414213562D0 /
      Q=C(2)/3.0-C(3)*C(3)/9.0
      R=(C(2)*C(3)-3.0*C(1))/6.0-C(3)*C(3)*C(3)/27.0
      QA=DABS(Q)
      RA=DABS(R)
      DIV=QA
      IF(RA.GT.QA) DIV=RA
      S=(Q/DIV)*(Q/DIV)*Q+(R/DIV)*(R/DIV)
      IF(S.GE.0.0D0) THEN
         IF(S.LT.0.0) S=1.0E-35
         S=DIV*DSQRT(S)
         R1=R+S
         S1=(DABS(R1))**OT
         S1=DSIGN(S1,R1)
         R2=R-S
         S2=(DABS(R2))**OT
         S2=DSIGN(S2,R2)
         X=S1+S2-C(3)*OT
      ELSE
         C(1)=-C(1)
         C(3)=-C(3)
         C3=C(3)*OT
         H1=C(3)*C3-C(2)
         H2=C(1)-C(2)*C3+2.0*C3*C3*C3
         ZZ22=TT*H1
         IF(ZZ22.LT.0.0D0) ZZ22=1.0D-30
         H=DSQRT(ZZ22)
         H4=H2*SQRT2/(H*H*H)
         IF(H4.GT.1.0) H4=DSIGN(1.0D0,H4)
         ALPHA=(DACOS(H4))*OT
         IF(ALPHA.GT.1.0D0) ALPHA=DSIGN(1.0D0,ALPHA)
         X=H*SQRT2*DCOS(ALPHA)+C3
      ENDIF
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE SSCHK TESTS TO ENSURE THAT THE ROTATIONS FOUND IN SUB-  *
C*  ROUTINE GENROT RESULT IN THE CORRECT SENSE OF SLIP ON THE FAULT    *
C*  PLANE                                                              *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE SSCHK(I,KJ,B,RFIX,C1,C2,C3,Y,Z,CRA,SR)
      DIMENSION CA(3),A(3,3),B(3,3),B1(3,3),Y(4),Z(4),AZ(470,2),
     1 DIP(470,2),Q(470)
      LOGICAL SSLP,PASS1
      COMMON / THREE / AZ,DIP,Q
      COMMON / SIX / SSLP,PASS1
C
C   INDICES AS IN SUBROUTNE AXRFN
C
      K=KJ
      IF(KJ.EQ.2) K=3
      L=4-K
C
C   ROTATION AXIS COORDINATES: CA(I), ROTATION ANGLE COSINE =
C   CRA, SINE = SR
C
      CA(1)=C1
      CA(2)=C2
      CA(3)=C3
      JF=1
  140 IF(ABS(CRA).GT.1.0) CRA=SIGN(1.0,CRA)
      CCRA=1.0-CRA
C
C   CALCULATE ROTATION MATRIX, A(I,J)
C
      DO 150 M=1,3
         DO 145 N=M,3
            A(M,N)=CCRA*CA(M)*CA(N)
            IF(M.NE.N) A(N,M)=A(M,N)
  145    CONTINUE
         A(M,M)=A(M,M)+CRA
  150 CONTINUE
      Q1=1.0
      DO 160 M=1,3,2
      DO 160 N=1,3
         IF(M.NE.N) THEN
            A(M,N)=A(M,N)-Q1*SR*CA(6-M-N)
            Q1=-Q1
         ENDIF
  160 CONTINUE
C
C   FIND ROTATED FAULT PLANE GEOMETRY, B1(I,J)
C
      DO 170 M=1,3,2
      DO 170 N=2,3
         B1(M,N)=A(M,1)*B(K,N)+A(M,2)*B(2,N)+A(M,3)*B(L,N)
  170 CONTINUE
C
C   CHECK SENSE OF SLIP
C
      IF(Q(I)*(RFIX*B1(1,2)*B1(3,2)+B1(1,3)*B1(3,3)).LT.0.0) THEN
         SSLP=.TRUE.
      ELSE
         SSLP=.FALSE.
      ENDIF
C
C   IF THE SENSE OF SLIP IS INCORRECT AND THIS IS THE FINAL PASS,
C   FIND THE NEXT SMALLEST ROTATION AND CHECK IT
C
      IF(.NOT.(SSLP.OR.PASS1)) THEN
         IF(JF.NE.4) THEN
            JF=JF+1
            CALL COSORT(JF,Y,Z,CRA,.TRUE.,SR)
            GO TO 140
         ELSE
            CRA=-1.0
         ENDIF
      ENDIF
      RETURN
      END
