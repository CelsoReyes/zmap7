C**********************************************************************
C*                                                                    *
C*              FOCAL MECHANISM STRESS INVERSION PACKAGE              *
C*                          JOHN W. GEPHART                           *
C*                          BROWN UNIVERSITY                          *
C*                                1985                                *
C*                                                                    *
C*                 REVISED AT CORNELL UNIVERSITY, 1989                *
C*                                                                    *
C**********************************************************************
C
C**********************************************************************
C*                                                                    *
C*  THIS PROGRAM TABULATES: (1) THE MINIMUM ROTATION MISFITS BETWEEN  *
C*  INDIVIDUAL FAULT PLANES AND STRESS MODELS AS CALCULATED USING THE *
C*  THE EXACT METHOD, (2) THE ORIENTATIONS OF THESE AXES, (3) THE OB- *
C*  SERVED (ORIGINAL) ORIENTATIONS OF THE NODAL PLANES (FAULT PLANES/ *
C*  SLIP DIRECTIONS), AND (4) THE FINAL (ROTATED) ORIENTAIONS OF THE  *
C*  NODAL PLANES--CORRESPONDING TO THE SOLUTIONS TO THE STRESS MODELS *
C*  CLOSEST TO THE OBSERVATIONS.  THESE SOLUTIONS ARE THE SAME ONES   *
C*  DETERMINED IN PROGRAM FMSIE.                                      *
C*                                                                    *
C*  THIS MAIN PROGRAM READS THE INPUT PARAMETERS, DESCRIBED ON A      *
C*  SEPARATE LISTING, AND INITIALIZES SOME VARIABLES AND ARRAYS       *
C*                                                                    *
C**********************************************************************
C
C comments by Zhong Lu
c	ENTER NAME OF INPUT FILE
c	ENTER NAME OF OUTPUT FILE
c	ENTER INDEX OF 1ST PRESCRIBED PRINCIPAL STRESS (1 OR 3)
c	ENTER PLUNGE AND AZIMUTH OF 1ST PRINCIPAL STRESS AXIS--SIGMA 1
c	ENTER VALUE OF PHI
c	ENTER R VALUE (0-1)
c	ENTER Number of Fault Soulutions
c

      PROGRAM FMSIETAB_MATLAB
      USE MSFLIB
      DIMENSION CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),
     1 CD2(9999),C(3,3),AZ(9999,2),DIP(9999,2),Q(9999)
      real   mis1, mis2, mis
      CHARACTER*80 INFILE,OUTFILE
      CHARACTER*1 MORE
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / THREE / AZ,DIP,Q
      COMMON / FIVE / NFM,KFP,KR,RFIX
C
      INTEGER(2)  status, control, controlo

      CALL GETCONTROLFPQQ(control)
      control  = control .OR. 5
      CALL SETCONTROLFPQQ(control)
C     
C   OPEN INPUT AND OUTPUT FILES
C    
c   3 WRITE(*,*) ' ENTER NAME OF INPUT FILE'
      READ(*,499) INFILE
499   FORMAT(A)
      OPEN(UNIT=7,FILE=INFILE,STATUS='OLD')
      WRITE(*,*) ' ENTER NAME OF OUTPUT FILE'
      READ(*,499) OUTFILE
      OPEN(UNIT=9,FILE=OUTFILE,STATUS='NEW')
      OPEN(UNIT=8,FILE='TMP')
C
C   ENTER DATA FOR DETERMINING PRINCIPAL STRESS DIRECTIONS OF MODEL
C   TO BE TESTED
C
       WRITE(*,485) ' ENTER INDEX OF 1ST PRESCRIBED PRINCIPAL',
     1 ' STRESS (1 OR 3)'
  485 FORMAT(A40,A16)
      READ(*,*) ISIG
      JSIG=4-ISIG
c     WRITE(*,486) ' ENTER PLUNGE AND AZIMUTH OF 1ST PRINCIPAL',
c    1 ' STRESS AXIS--SIGMA ',ISIG
  486 FORMAT(A42,A20,I1)
      READ(*,*) PLPRI
      READ(*,*) AZPRI
c     WRITE(*,*) 'ENTER VALUE OF PHI'
      READ(*,*) PHI
      PH=PHI
C
C   SELECT R-VALUE OF MODEL TO BE TESTED
C
      WRITE(*,*) 'ENTER R VALUE (0-1)'
      READ(*,*) RFIX
C
C   INPUT # OF DATA (NFM) AND # FOR WHICH FAULT PLANE IS KNOWN FROM 
C   THE 2 NODAL PLANES (KFP)--THESE MUST BE ENTERED BEFORE THOSE WITH
C   UNKNOWN FAULT PLANES.
C
c     READ(7,500) NFM, KFP
      WRITE(*,*) RFIX
      READ(*,*) NFM
      WRITE(*,*) 'test  '
c     READ(*,*) KFP
      KFP = 0
  500 FORMAT(2(1X,I3))
C
C   FIND THE PRINCIPAL STRESS COORDINATES
C
      CALL CFIND(ISIG,PLPRI,AZPRI,PHI)
      CALL XPSET(NFM)
C
C   WRITE A HEADER FOR THE OUTPUT LISTING
C
c     CALL HEADER
      CALL GRDCLC(PH,ISIG)
      CLOSE(UNIT=7)
      CLOSE(UNIT=8)
c     MORE='N'
c     WRITE(*,*)
c     WRITE(*,*) 'ANOTHER MODEL?  Y/[N]'
c     READ(*,502) MORE
c 502 FORMAT(A1)
c     IF(MORE.EQ.'Y'.OR.MORE.EQ.'y') GO TO 3
c
        OPEN(UNIT=8,FILE='TMP')
        do 103 i=1,NFM
        read(8,101,end=103)mis1
        read(8,101)mis2
        if(mis1.gt.mis2) then
        mis=mis2
        else
        mis=mis1
        end if
        write(9,102)i,mis
103     continue
101     format(7x,f6.2)
102     format(i5,2x,f9.2)
      CLOSE(UNIT=8)
      CLOSE(UNIT=9)

      STOP
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE HEADER WRITES A KEY AT THE BEGINNING OF THE OUTPUT     *
C*  FILE EXPLAINING THE OUTPUT FORMAT                                 *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE HEADER
      WRITE(8,501)
      WRITE(*,501)
  501 FORMAT('   The table below gives the misfit rotations and the',
     1 ' corresponding',/,'solutions for each of the data relative to',
     1 ' a specific stress model,',/,'based on the EXACT method.  For',
     1 ' each set of principal stress direc-',/,'tions, the following',
     1 ' columns indicate:  ',//,
     1 '   1) Datum number',/,
     1 '   2) Nodal plane number (1=1st plane, 2=2nd plane)',/,
     1 '   3) Misfit rotation (degrees)',/,
     1 '   4) Azimuth of misfit rotation axis',/,
     1 '   5) Plunge of misfit rotation axis',/,
     1 '   6) Azimuth of original fault plane',/,
     1 '   7) Dip of original fault plane',/,
     1 '   8) Azimuth of original auxiliary plane',/,
     1 '   9) Dip of original auxiliary plane',/,
     1 '  10) Azimuth of rotated fault plane',/,
     1 '  11) Dip of rotated fault plane',/,
     1 '  12) Azimuth of rotated auxiliary plane',/,
     1 '  13) Dip of rotated auxiliary plane',/,
     1 '  14) Slip/Wgt index (with initial & final signs, *',
     1 ' indicates low shear stress)',//)
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE CFIND DETERMINES THE COORDINATES OF THE PRINCIPAL      *
C*  STRESS AXES (C(I,J)) FROM THE PRIMARY STRESS DIRECTION (PL, AZ)   *
C*  AND A VALUE OF PHI                                                *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE CFIND(I,PL,AZ,PHI)
      DIMENSION C(3,3)
      COMMON / TWO / C
      DATA RAD,HPI / 0.017453292,1.5707963 /
C
C   FIND THE COORDINATES OF THE PRIMARY STRESS DIRECTION: C(I,1),
C   C(I,2), C(I,3)
C
      PL=PL*RAD
      AZ=AZ*RAD
      PHI=PHI*RAD
      CAUX=COS(AZ)
      SAUX=SIN(AZ)
      C33=COS(PL)
      C(I,1)=CAUX*C33
      C(I,2)=SAUX*C33
      C(I,3)=SIN(PL)
C
C   FIND THE COORDINATES OF THE OTHER TWO PRINCIPAL STRESS DIRECTIONS
C
      AZ2=AZ+HPI
      C21=COS(AZ2)
      C22=SIN(AZ2)
      C31=-CAUX*C(I,3)
      C32=-SAUX*C(I,3)
      J=4-I
      IF(PHI.EQ.0.0) THEN
         C(2,1)=C21
         C(2,2)=C22
         C(2,3)=C23
         C(J,1)=C31
         C(J,2)=C32
         C(J,3)=C33
         RETURN
      ENDIF
      TP=TAN(PHI)
      D21=C31-TP*C21
      D22=C32-TP*C22
      D23=C33
      C(2,2)=(D23*C(I,1)-D21*C(I,3))/(D21*C(I,2)-D22*C(I,1))
      C(2,1)=-(D22*C(2,2)+D23)/D21
      C(2,3)=1.0/SQRT(1.0+C(2,1)*C(2,1)+C(2,2)*C(2,2))
      C(2,1)=C(2,1)*C(2,3)
      C(2,2)=C(2,2)*C(2,3)
      C(J,2)=(C(I,3)*C(2,1)-C(I,1)*C(2,3))/(C(I,1)*C(2,2)-
     1 C(I,2)*C(2,1))
      C(J,1)=-(C(I,2)*C(J,2)+C(I,3))/C(I,1)
      C(J,3)=1.0/SQRT(1.0+C(J,1)*C(J,1)+C(J,2)*C(J,2))
      C(J,1)=C(J,1)*C(J,3)
      C(J,2)=C(J,2)*C(J,3)
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE XPSET SETS UP THE COORDINATE AXES FIXED BY THE FAULT   *
C*  PLANE GEOMETRY AND ADJUSTS ORIENTATIONS AS NECESSARY TO ENSURE    *
C*  THAT THE NODAL PLANES ARE ORTHOGONAL                              *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE XPSET(NFM)
      DIMENSION CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),
     1 CD2(9999),AZ(9999,2),DIP(9999,2),Q(9999)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / THREE / AZ,DIP,Q
      DATA RAD / 0.017453292 /
C
C   INPUT FAULT PLANE ORIENTATION DATA AND CALCULATE FAULT PLANE
C   COORDINATE AXES
C
      IQ=0
      DO 30 I=1,NFM
      READ(7,*) (AZ(I,J),DIP(I,J),J=1,2),Q(I)
  502 FORMAT(2(1X,F7.3,1X,F6.3),1X,F3.0)
      DO 20 J=1,2
      AZR=AZ(I,J)*RAD
      DIPR=DIP(I,J)*RAD
      CD1(I,J)=COS(DIPR)
      CD3=SIN(DIPR)
      CN1(I,J)=SIN(AZR)*CD3
      CE1(I,J)=-COS(AZR)*CD3
   20 CONTINUE
      CD2(I)=(-CN1(I,2)+CN1(I,1)*CE1(I,2)/CE1(I,1))/(-CD1(I,1)*CE1(I,2)
     1 /CE1(I,1)+CD1(I,2))
      CE2(I)=(-CD2(I)*CD1(I,1)-CN1(I,1))/CE1(I,1)
      CN2(I)=1.0/SQRT(1.0+CE2(I)*CE2(I)+CD2(I)*CD2(I))
      IF(CD2(I).LT.0.0) CN2(I)=-CN2(I)
      CE2(I)=CE2(I)*CN2(I)
      CD2(I)=CD2(I)*CN2(I)
   30 CONTINUE
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE RESOLV TRANSFORMS 3 CARTESIAN COORDINATES OF AN AXIS   *
C*  (WITH RESPECT TO EXTERNAL COORDINATES--NORTH, EAST, AND DOWN),    *
C*  INTO 2 EULER ANGLES (PLUNGE AND AZIMUTH)                          *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE RESOLV(CN,CE,CD,IPL,IAZ)
      DATA RAD / 0.017453292 /
      IF(CN.EQ.0.0.AND.CE.EQ.0.0) THEN
         IPL=90
         IAZ=0
      ELSE
         IPL=INT(ASIN(CD)/RAD+0.5)
         AZ=ATAN2(CE,CN)/RAD
         IF(AZ.LT.0.0) AZ=AZ+360.0
         IAZ=INT(AZ+0.5)
      ENDIF
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE GRDCLC CREATES A SET OF TABLES PRESENTING RESULTS OF   *
C*  THE INVERSION, PLOTTING R VS. PHI FOR EACH PRESCRIBED INITIAL     *
C*  PRINCIPAL STRESS DIRECTION                                        *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE GRDCLC(PH,ISIG)
      DIMENSION IPL(3),IAZ(3),C(3,3),Q(9999),AZ(9999,2),DIP(9999,2)
      COMMON / TWO / C
      COMMON / THREE / AZ,DIP,Q
      COMMON / FIVE / NFM,KFP,KR,RFIX
c     WRITE(8,504)
c     WRITE(*,504)
  504 FORMAT(' PRINCIPAL STRESS AXES',/)
      DO 55 L=1,3
      CALL RESOLV(C(L,1),C(L,2),C(L,3),IPL(L),IAZ(L))
   55 CONTINUE
c     WRITE(8,499) (IPL(L),IAZ(L),L=1,3),PH,RFIX,ISIG
c     WRITE(*,499) (IPL(L),IAZ(L),L=1,3),PH,RFIX,ISIG
  499 FORMAT(3(2(1X,I3),1X),3X,'PHI=',F6.1,3X,'R=',F5.2,
     1 '   (primary stress = sigma ',I1,')',/)
      SUMR=0.0
      CALL BETSET(SUMR)
CDOMI      SUMR=SUMR*180.0/FLOAT(NFM)
C
      IQ=0
      DO 66 I=1,NFM
         IQ=IQ+ABS(Q(I))
   66 CONTINUE
c     WRITE(*,*) 'WEIGHT IQ: ',IQ
C
      SUMR=SUMR*180.0/FLOAT(IQ)
c     WRITE(8,597) SUMR
c     WRITE(*,597) SUMR
  597 FORMAT(/,' Average Minimum Rotation Misfit',2X,F7.3,' degrees')
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE NORM ADJUSTS THE ANGLE COSINE COORDINATES OF ANY AXIS  *
C*  TO ENSURE THAT THE SUM OF THEIR SQUARES IS 1.0                    *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE NORM(X1,X2,X3)
      XNORM=X1*X1+X2*X2+X3*X3
      IF(XNORM.NE.1.0) THEN
         XNORM=SQRT(XNORM)
         X1=X1/XNORM
         X2=X2/XNORM
         X3=X3/XNORM
      ENDIF
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE BETSET CALCULATES THE MATRIX BETA (B(I,J)), RELATING   *
C*  THE PRINCIPAL STRESS AND FAULT PLANE COORDINATE AXES              *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE BETSET(SUMR)
      LOGICAL KFPQ
      DIMENSION CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),
     1 CD2(9999),B(3,3),C(3,3)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / FIVE / NFM,KFP,KR,RFIX
      DO 95 I=1,NFM
      DO 60 JJ=1,3
      B(1,JJ)=CN1(I,1)*C(JJ,1)+CE1(I,1)*C(JJ,2)+CD1(I,1)*C(JJ,3)
      B(2,JJ)=CN2(I)*C(JJ,1)+CE2(I)*C(JJ,2)+CD2(I)*C(JJ,3)
      B(3,JJ)=CN1(I,2)*C(JJ,1)+CE1(I,2)*C(JJ,2)+CD1(I,2)*C(JJ,3)
   60 CONTINUE
C
C   SET KFPQ=.TRUE. IF THE FAULT PLANE IS KNOWN, =.FALSE. IF IT IS
C   UNKNOWN
C
      IF(I.LE.KFP) THEN
         KFPQ=.TRUE.
      ELSE
         KFPQ=.FALSE.
      ENDIF
      CALL ROTXP(I,B,KFPQ,SUMR)
   95 CONTINUE
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE ROTXP CALCULATES THE ROTATION MISFITS FOR BOTH NODAL   *
C*  PLANES ABOUT THE AXES OF THE FAULT PLANE GEOMETRY                 *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE ROTXP(I,B,KFPQ,SUMR)
      CHARACTER*1 NSFLAG,INSOS
      LOGICAL KFPQ,SSLP,PASS1,NOSLIP
      DIMENSION B(3,3),ROT(3),ROTM1(2),AZ(9999,2),DIP(9999,2),Q(9999)
     1,CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),CD2(9999)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / THREE / AZ,DIP,Q
      COMMON / FIVE / NFM,KFP,KR,RFIX
      COMMON / SIX / SSLP,PASS1
      COMMON / SEVEN / AZN,DIPN,AZS,DIPS
      DATA PI,PI2,RAD,HPI / 3.1415927,6.2831854,0.017453292,1.5707963 /
      B222=B(2,2)*B(2,2)
      B232=B(2,3)*B(2,3)
      B12B32=B(1,2)*B(3,2)
      B13B33=B(1,3)*B(3,3)
C
C   JK = NODAL PLANE INDEX
C   IK = INDEX OF FPG AXIS WHICH IS THE POLE OF THE NODAL PLANE 
C   LK = INDEX OF FPG AXIS WHICH IS THE SLIP DIRECTION ON THE 
C      NODAL PLANE
C
      JK=0
      DO 103 IK=1,3,2
      JK=JK+1
      IF(JK.EQ.2.AND.KFPQ) GO TO 103
C
C   FOR AXISYMMETRIC STRESSES FIND ROTATIONS USING SUBROUTINE AXSYMS
C   (FIRST NODAL PLANES ONLY)
C
      IF(RFIX.LT.0.001.OR.RFIX.GT.0.999) THEN
         IF(JK.EQ.1) THEN
            CALL AXSYMS(I,B,RFIX,AZI,PL,ROTM)
            GO TO 108
         ELSE
C
C   FOR AXISYMMETRIC STRESSES (SECOND NODAL PLANES)--RESULTS ARE THE
C   SAME AS FOR FIRST NODAL PLANES EXCEPT THAT FAULT AND AUXILIARY
C   PLANES ARE EXCHANGED
C
            AUX=AZN
            AZN=AZS
            AZS=AUX
            AUX=DIPN
            DIPN=DIPS
            DIPS=AUX
            GO TO 109
         ENDIF
      ENDIF
C
C   FOR NON-AXISYMMETRIC STRESSES, FIND ROTATIONS ABOUT FPG AXES
C
      PASS1=.TRUE.
      SSLP=.TRUE.
      LK=4-IK
      B122=B(IK,2)*B(IK,2)
      B132=B(IK,3)*B(IK,3)
      B13B23=B(IK,3)*B(2,3)
      B12B22=B(IK,2)*B(2,2)
      B22B32=B(2,2)*B(LK,2)
      B23B33=B(2,3)*B(LK,3)
      BNUM=B13B23+RFIX*B12B22
      ROT(IK)=ATAN(BNUM/(RFIX*B12B32+B13B33))
      ROT(2)=ATAN(BNUM/(RFIX*B22B32+B23B33))
      RK=(RFIX*(B122-B222)+B132-B232)/BNUM
      SRK2=SQRT(0.25-1.0/(4.0+RK*RK))
      ROT(LK)=ACOS(SQRT(0.5+SRK2))
      ROT(LK)=-SIGN(ROT(LK),RK)
C
C   FIND THE SMALLEST OF THE ROTATIONS ABOUT THE 3 FPG AXES; MX =
C   INDEX OF ROTATION AXIS
C
   90 MX=1
      ROTM=ABS(ROT(1))
      DO 102 L=2,3
      IF(ABS(ROT(L)).LT.ROTM) THEN
         MX=L
         ROTM=ABS(ROT(L))
      ENDIF
  102 CONTINUE
C
C   FIND THE ORIENTATION (PL, AZI) OF THE BEST OF THE FPG
C   ROTATIONS
C
      IF(JK.EQ.2) MX=4-MX
      IF(MX.EQ.3) THEN
         AZI=AMOD(AZ(I,3-JK)+270.0,360.0)*RAD
         PL=(90.0-DIP(I,3-JK))*RAD
      ELSE
         IF(MX.EQ.2) THEN
            AZI=AMOD(ATAN2(CE2(I),CN2(I))+PI2,PI2)
            PL=ASIN(CD2(I))
         ELSE
            AZI=AMOD(AZ(I,JK)+270.0,360.0)*RAD
            PL=(90.0-DIP(I,JK))*RAD
         ENDIF
      ENDIF
C
C   FIND THE SMALLEST ROTATION ABOUT ALL AXES (OF GENERAL ORIENTATION)
C
      CALL AXRFN(I,JK,B,RFIX,AZI,PL,ROTM)
C
C   IF THE SMALLEST ROTATION FOUND IN THE FIRST PASS YIELDS THE
C   WRONG SENSE OF SLIP ON THE ROTATED FAULT PLANE, START OVER,
C   THIS TIME KEEPING TRACK OF THE SENSE OF SLIP (AND NOT ADMIT-
C   TING SOLUTIONS YIELDING THE INCORRECT SENSE OF SLIP)--HOPE-
C   FULLY, THIS PATH IS TAKEN INFREQUENTLY
C
      IF(.NOT.SSLP.AND.PASS1) THEN
         CALL XPCHK(I,IK,LK,JK,B,ROT,RFIX)
         PASS1=.FALSE.
         GO TO 90
      ENDIF
  108 AZIC=AZI/RAD
      PLC=PL/RAD
      ROTMC=ROTM/RAD
C
C   FIND THE SLIP INDEX ON THE ROTATED FAULT PLANE BY CHECKING THE
C   MAGNITUDE OF SHEAR STRESS ON ROTATED FAULT PLANE.  IF THE SHEAR
C   STRESS MAGNITUDE IS NEGLIGIBLE, FLAG THE LISTING WITH A '*'
C
  109 CALL SENSLIP(I,JK,B,Q0,NOSLIP)
      IF(NOSLIP) THEN
         NSFLAG='*'
      ELSE
         NSFLAG=' '
      ENDIF
      IF(Q(I).GT.0.0) THEN
         INSOS='+'
      ELSE
         INSOS='-'
      ENDIF
C
C   WRITE INFORMATION TO OUTPUT LISTING
C
      IF(ROTMC.LT.100.0) THEN
         WRITE(8,500) I,JK,ROTMC,AZIC,PLC,AZ(I,JK),DIP(I,JK),
     1    AZ(I,3-JK),DIP(I,3-JK),AZN,DIPN,AZS,DIPS,INSOS,Q0,NSFLAG
c        WRITE(*,500) I,JK,ROTMC,AZIC,PLC,AZ(I,JK),DIP(I,JK),
c    1    AZ(I,3-JK),DIP(I,3-JK),AZN,DIPN,AZS,DIPS,INSOS,Q0,NSFLAG
  500 FORMAT(2X,I3,1X,I1,1X,F5.2,5(2X,F5.1,1X,F4.1),1X,A1,SP,F4.1,SS,A1)
      ELSE
         WRITE(8,501) I,JK,ROTMC,AZIC,PLC,AZ(I,JK),DIP(I,JK),
     1    AZ(I,3-JK),DIP(I,3-JK),AZN,DIPN,AZS,DIPS,INSOS,Q0,NSFLAG
c        WRITE(*,501) I,JK,ROTMC,AZIC,PLC,AZ(I,JK),DIP(I,JK),
c    1    AZ(I,3-JK),DIP(I,3-JK),AZN,DIPN,AZS,DIPS,INSOS,Q0,NSFLAG
  501 FORMAT(2X,I3,1X,I1,1X,F5.1,5(2X,F5.1,1X,F4.1),1X,A1,SP,F4.1,SS,A1)
      ENDIF
      ROTM1(JK)=ROTM
      IF(KFPQ.OR.JK.EQ.2) THEN
         ROTM=ROTM1(1)
         IF(.NOT.KFPQ.AND.ROTM1(2).LT.ROTM) ROTM=ROTM1(2)
         ROTM=ROTM/PI
C
C   SUM MISFITS FOR ALL DATA IN SUMR--APPLY RELATIVE WEIGHTS (ABS(Q(I)) HERE
C
         SUMR=SUMR+ROTM*ABS(Q(I))
      ENDIF
  103 CONTINUE
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE XPCHK TESTS THE ROTATIONS FOUND IN SUBROUTINE ROTXP    *
C*  TO ENSURE THAT THEY RESULT IN THE CORRECT SENSE OF SLIP ON THE    *
C*  FAULT PLANE                                                       *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE XPCHK(I,IK,LK,JK,B,ROT,RFIX)
      DIMENSION ROT(3),B(3,3),AZ(9999,2),DIP(9999,2),Q(9999)
      COMMON / THREE / AZ,DIP,Q
      DATA PI,PI2,HPI / 3.14159277,6.2831854,1.5707963 /
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
      BNK1=CROT*B(NK,1)+F*SROT*B(2,1)
      BNK2=CROT*B(NK,2)+F*SROT*B(2,2)
      BNK3=CROT*B(NK,3)+F*SROT*B(2,3)
C
C   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF CORRECT,
C   THEN THE FOLLOWING CONDITION IS FALSE
C
      IF(Q(I)*(RFIX*B(MK,2)*BNK2+B(MK,3)*BNK3).GT.0.0) THEN
C
C   FIND NEW ROTATION ABOUT POLE
C
         IF(IK.NE.NK) THEN
            ROT(MK)=ROT(MK)-SIGN(PI,ROT(MK))
         ELSE
C
C   FIND NEW ROTATION ABOUT SLIP DIRECTION
C
            ROT(MK)=ROT(MK)-SIGN(HPI,ROT(MK))
            SROTA=SROT
            SROT=-SIGN(CROT,SROTA)
            CROT=ABS(SROTA)
            BNK1=CROT*B(NK,1)+F*SROT*B(2,1)
            BNK2=CROT*B(NK,2)+F*SROT*B(2,2)
            BNK3=CROT*B(NK,3)+F*SROT*B(2,3)
            IF(Q(I)*(RFIX*B(MK,2)*BNK2+B(MK,3)*BNK3).GT.0.0) ROT(MK)=
     1       ROT(MK)-SIGN(PI,ROT(MK))
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
         B11=CROT*B(1,1)-F*SROT*B(3,1)
         B12=CROT*B(1,2)-F*SROT*B(3,2)
         B13=CROT*B(1,3)-F*SROT*B(3,3)
         B31=CROT*B(3,1)+F*SROT*B(1,1)
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
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE AXSYMS CALCULATES THE ROTATION MISFITS BETWEEN OBSER-  *
C*  VATIONS AND AXISYMMETRIC STRESS MODELS.                           *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE AXSYMS(I,B,RFIX,AZI,PL,ROTM)
      DIMENSION CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),
     1 CD2(9999),B(3,3),C(3,3),AZ(9999,2),DIP(9999,2),Q(9999)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / THREE / AZ,DIP,Q
      COMMON / SEVEN / AZN,DIPN,AZS,DIPS
      DATA HPI,PI2,RAD / 1.5707963,6.2831854,0.017453292 /
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
      IF(Q(I)*(RFIX*B(1,2)*B(3,2)+B(1,3)*B(3,3)).GT.0.0) THEN
         CR=SQRT(1.0-B(2,KS)*B(2,KS))
C
C   FIND THE ROTATED FAULT PLANE GEOMETRY
C
         C2=(CD2(I)*C(KS,1)-CN2(I)*C(KS,3))/(CN2(I)*C(KS,2)-
     1    CE2(I)*C(KS,1))
         C1=-(CD2(I)+CE2(I)*C2)/CN2(I)
         C3=1.0/SQRT(1.0+C1*C1+C2*C2)
         C1=C1*C3
         C2=C2*C3
         B3=SQRT(1.0-CD2(I)*CD2(I)-C3*C3)
         IF(B3.LT.0.1) THEN
            B2=SQRT(1.0-CE2(I)*CE2(I)-C2*C2)
            B3=-(C2*C3+CE2(I)*CD2(I))/B2
            IF(B3.LT.0.0) THEN
               B2=-B2
               B3=-B3
            ENDIF
         ELSE
            B2=-(CE2(I)*CD2(I)+C2*C3)/B3
         ENDIF
         B1=-(B2*C2+B3*C3)/C1
         CALL NORM(B1,B2,B3)
         SR=B(2,KS)
         BAUX=B1*C(KS,1)+B2*C(KS,2)+B3*C(KS,3)
         IF(BAUX.GT.0.0) SR=-SR
         DO 50 K=1,2
         CP=CN1(I,K)*C1+CE1(I,K)*C2+CD1(I,K)*C3
         SP=CN1(I,K)*B1+CE1(I,K)*B2+CD1(I,K)*B3
         BP1=B1*CR-CN2(I)*SR
         BP2=B2*CR-CE2(I)*SR
         BP3=B3*CR-CD2(I)*SR
         CALL NORM(BP1,BP2,BP3)
         Z1=C1*CP+BP1*SP
         Z2=C2*CP+BP2*SP
         Z3=C3*CP+BP3*SP
         CALL NORM(Z1,Z2,Z3)
         IF(Z3.LT.0.0) THEN
            Z1=-Z1
            Z2=-Z2
            Z3=-Z3
         ENDIF
C
C   FIND THE NEW FAULT PLANE AND SLIP DIRECTION
C
         IF(Z1.NE.0.0.OR.Z2.NE.0.0) THEN
            IF(ABS(Z3).GT.1.0) Z3=SIGN(1.0,Z3)
            DIPS=ACOS(Z3)/RAD
            AZS=AMOD(ATAN2(Z2,Z1)+PI2+HPI,PI2)/RAD
         ELSE
            DIPS=90.0
            AZS=0.0
         ENDIF
         IF(K.EQ.1) THEN
            AZN=AZS
            DIPN=DIPS
         ENDIF
   50    CONTINUE
      ELSE
         CR=ABS(B(1,KS))
C
C   FIND THE ROTATED FAULT PLANE GEOMETRY
C
         C2=(CD1(I,1)*C(KS,1)-CN1(I,1)*C(KS,3))/(CN1(I,1)*
     1    C(KS,2)-CE1(I,1)*C(KS,1))
         C1=-(CD1(I,1)+CE1(I,1)*C2)/CN1(I,1)
         C3=1.0/SQRT(1.0+C1*C1+C2*C2)
         C1=C1*C3
         C2=C2*C3
         M=1
         N=2
         K=1
         IF(ABS(B(3,KS)).GT.CR) THEN
            CR=ABS(B(3,KS))
            C2=(CD1(I,2)*C(KS,1)-CN1(I,2)*C(KS,3))/(CN1(I,2)*
     1       C(KS,2)-CE1(I,2)*C(KS,1))
            C1=-(CD1(I,2)+CE1(I,2)*C2)/CN1(I,2)
            C3=1.0/SQRT(1.0+C1*C1+C2*C2)
            C1=C1*C3
            C2=C2*C3
            M=2
            N=1
            K=3
         ENDIF
C
C   FIND THE NEW FAULT PLANE AND SLIP DIRECTION
C
         AZN=AMOD(ATAN2(C(KS,2),C(KS,1))+HPI+PI2,PI2)/RAD
         DIPN=ACOS(C(KS,3))/RAD
         B3=SQRT(1.0-CD1(I,M)**2-C3**2)
         IF(B3.LT.0.1) THEN
            B2=SQRT(1.0-CE1(I,M)*CE1(I,M)-C2*C2)
            B3=-(C2*C3+CE1(I,M)*CD1(I,M))/B2
            IF(B3.LT.0.0) THEN
               B2=-B2
               B3=-B3
            ENDIF
         ELSE
            B2=-(C2*C3+CE1(I,M)*CD1(I,M))/B3
         ENDIF
         B1=-(C2*B2+C3*B3)/C1
         CALL NORM(B1,B2,B3)
         SR=B1*C(KS,1)+B2*C(KS,2)+B3*C(KS,3)
         CP=C1*CN1(I,N)+C2*CE1(I,N)+C3*CD1(I,N)
         SP=B1*CN1(I,N)+B2*CE1(I,N)+B3*CD1(I,N)
         F=SIGN(1.0,B(K,KS))
         BP1=B1*CR-F*CN1(I,M)*SR
         BP2=B2*CR-F*CE1(I,M)*SR
         BP3=B3*CR-F*CD1(I,M)*SR
         CALL NORM(BP1,BP2,BP3)
         Z1=C1*CP+BP1*SP
         Z2=C2*CP+BP2*SP
         Z3=C3*CP+BP3*SP
         CALL NORM(Z1,Z2,Z3)
         IF(Z3.LT.0.0) THEN
            Z1=-Z1
            Z2=-Z2
            Z3=-Z3
         ENDIF
         IF(Z1.NE.0.0.OR.Z2.NE.0.0) THEN
            IF(ABS(Z3).GT.1.0) Z3=SIGN(1.0,Z3)
            DIPS=ACOS(Z3)/RAD
            AZS=AMOD(ATAN2(Z2,Z1)+PI2+HPI,PI2)/RAD
         ELSE
            DIPS=90.0
            AZS=0.0
         ENDIF
      ENDIF
      IF(C1.NE.0.0.OR.C2.NE.0.0) THEN
         PL=ASIN(C3)
         AZI=AMOD(ATAN2(C2,C1)+PI2,PI2)
      ELSE
         PL=HPI
         AZI=0.0
      ENDIF
      ROTM=ACOS(CR)
      RETURN
      END
C       
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE AXC TRANSFORMS 2 EULER ANGLES OF AN AXIS (PLUNGE AND   *
C*  AZIMUTH) INTO 3 CARTESIAN COORDINATES RELATIVE TO A FAULT PLANE   *
C*  GEOMETRY COORDINATE SET                                           *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE AXC(I,THETA1,THETA2,K,C1,C2,C3)
      DIMENSION CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),
     1 CD2(9999)
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
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
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE AXRFN LOCATES THE AXIS OF THE SMALLEST ROTATION THAT   *
C*  ACHIEVES A MATCH BETWEEN THE SHEAR STRESS AND SLIP DIRECTIONS ON  *
C*  ONE NODAL PLANE                                                   *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE AXRFN(I,KJ,B,RFIX,AZAX,PLAX,RAX)
      DIMENSION B(3,3),PHI(2),PHIA(2),DZZ(2),CN1(9999,2),CE1(9999,2),
     1 CD1(9999,2),CN2(9999),CE2(9999),CD2(9999),C(3,3),AZ(9999,2),
     2 DIP(9999,2),Q(9999)
      LOGICAL SRF,SSLP,PASS1
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / THREE / AZ,DIP,Q
      COMMON / FOUR / A1,A2,A3,A4,A5,A6
      COMMON / SIX / SSLP,PASS1
      COMMON / SEVEN / AZN,DIPN,AZS,DIPS
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
C   TEST "OCTAHEDRAL" AXIS (EQUIDISTANT FROM ALL AXES OF THE FAULT
C   PLANE COORD'S), TO SEE IF ROTATIONS ABOUT ANY OF THESE ARE 
C   SMALLER THAN THOSE ABOUT THE FPG (SUBROUTINE ROTXP)--AND SO
C   OFFER A BETTER STARTING POSITION FOR FINDING THE BEST AXIS
C
      CALL BDAX(I,KJ,B,RFIX,BAZ,BPL,BR,SRF)
C
C   TAKE THE SMALLEST OF ALL AXES TESTED SO FAR (IN SUBROUTINES
C   ROTXP AND BDAX)
C
      IF(BR.LE.RAX) THEN
         AZAX=BAZ
         PLAX=BPL
         RAX=BR
      ENDIF
      IF(RAX.LT.0.00087) THEN
         AZN=AZ(I,KJ)
         DIPN=DIP(I,KJ)
         AZS=AZ(I,3-KJ)
         DIPS=DIP(I,3-KJ)
         RETURN
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
   87 DO 98 JI=1,2
      KI=3-JI
      PHI(KI)=PHIA(KI)
      PHI(JI)=PHIA(JI)+PINC
      CALL AXC(I,PHI(1),PHI(2),KJ,C1,C2,C3)
      CALL ROTANG(II,I,KJ,B,RFIX,C1,C2,C3,CRZ,SRF)
      DZZ(JI)=CRZ-CRA
   98 CONTINUE
C
C   IF A LOCAL SLOPE CANNOT BE FOUND, TRY A BIGGER STEP; IF TOO
C   BIG A STEP, GET OUT OF LOOP
C
      IF(DZZ(1).EQ.0.0.AND.DZZ(2).EQ.0.0) THEN
         IF(PINC.LT.PINC2) THEN
            PINC=1.2*PINC
            GO TO 87
         ELSE
            PHI(1)=PHIA(1)
            PHI(2)=PHIA(2)
            CR=CRA
            GO TO 107
         ENDIF
      ENDIF
C
C   STEP DOWN-SLOPE FROM THE CURRENT AXIS
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
      CALL AXC(I,PHI(1),PHI(2),KJ,C1,C2,C3)
      CALL ROTANG(II,I,KJ,B,RFIX,C1,C2,C3,CR,SRF)
C
C   IF THE MAGNITUDE OF ROTATION HAS INCREASED FROM THE PREVIOUS
C   STEP, REDUCE THE SIZE OF THE STEP AND TRY AGAIN--STOP AFTER
C   4 FAILURES
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
            GO TO 87
         ENDIF
      ENDIF
  105 CONTINUE
C
C   SET SRF = .TRUE. AND CHECK TO ENSURE PROPER SENSE OF SLIP ON
C   THE FINAL SOLUTION
C
  107 SRF=.TRUE.
      CALL AXC(I,PHI(1),PHI(2),KJ,C1,C2,C3)
      CALL ROTANG(II,I,KJ,B,RFIX,C1,C2,C3,CR,SRF)
C
C   AT THE END, COMPARE THE BEST ROTATION TO THE ANGLE NEEDED TO
C   SUPERIMPOSE THE POLE TO THE NODAL PLANE AND EACH PRINCIPAL
C   STRESS AXIS (ADMISSIBLE SOLUTIONS); SELECT THE SMALLEST OF
C   THESE.  THIS IS LIKELY TO BE NEEDED ONLY FOR VERY ERRATIC DATA
C   FOR WHICH IT IS DIFFICULT TO FIND THE OPTIMUM AXIS.
C
      IF(.NOT.PASS1) THEN
         K=1
         IF(KJ.EQ.2) K=3
         CRA=ABS(B(K,3))
         KS=3
         DO 110 L=1,2
         IF(ABS(B(K,L)).GT.CRA) THEN
            CRA=ABS(B(K,L))
            KS=L
         ENDIF
  110    CONTINUE
         IF(CRA.GT.CR) THEN
            CR=CRA
C
C   FIND THE ROTATED FAULT PLANE GEOMETRY AND ROTATION AXIS
C
            C2=(CD1(I,KJ)*C(KS,1)/CN1(I,KJ)-C(KS,3))/(C(KS,2)-C(KS,1)
     1       *CE1(I,KJ)/CN1(I,KJ))
            C1=-(CD1(I,KJ)+CE1(I,KJ)*C2)/CN1(I,KJ)
            C3=1.0/SQRT(1.0+C1*C1+C2*C2)
            C1=C1*C3
            C2=C2*C3
            IF(C1.NE.0.0.OR.C2.NE.0.0) THEN
               PHI(2)=ASIN(C3)
               PHI(1)=AMOD(ATAN2(C2,C1)+PI2,PI2)
            ELSE
               PHI(2)=HPI
               PHI(1)=0.0
            ENDIF
C
C   FIND THE NEW FAULT PLANE AND SLIP DIRECTION
C
            AZN=AMOD(ATAN2(C(KS,2),C(KS,1))+HPI+PI2,PI2)/RAD
            DIPN=ACOS(C(KS,3))/RAD
            B3=SQRT(1.0-C3*C3-CD1(I,KJ)*CD1(I,KJ))
            B2=-(C2*C3+CE1(I,KJ)*CD1(I,KJ))/B3
            B1=-(C2*B2+C3*B3)/C1
            SR=B1*C(KS,1)+B2*C(KS,2)+B3*C(KS,3)
            KL=3-KJ
            CP=C1*CN1(I,KL)+C2*CE1(I,KL)+C3*CD1(I,KL)
            SP=B1*CN1(I,KL)+B2*CE1(I,KL)+B3*CD1(I,KL)
            F=SIGN(1.0,B(K,KS))
            BP1=B1*CR-F*CN1(I,KJ)*SR
            BP2=B2*CR-F*CE1(I,KJ)*SR
            BP3=B3*CR-F*CD1(I,KJ)*SR
            Z1=C1*CP+BP1*SP
            Z2=C2*CP+BP2*SP
            Z3=C3*CP+BP3*SP
            IF(Z3.LT.0.0) THEN
               Z1=-Z1
               Z2=-Z2
               Z3=-Z3
            ENDIF
            IF(Z1.NE.0.0.OR.Z2.NE.0.0) THEN
               IF(ABS(Z3).GT.1.0) Z3=SIGN(1.0,Z3)
               DIPS=ACOS(Z3)/RAD
               AZS=AMOD(ATAN2(Z2,Z1)+PI2+HPI,PI2)/RAD
            ELSE
               DIPS=90.0
               AZS=0.0
            ENDIF
         ENDIF
      ENDIF
C
C   THE OPTIMUM ROTATION AXIS AND ANGLE
C
      AZAX=PHI(1)
      PLAX=PHI(2)
      RAX=ACOS(CR)
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE ROTANG FINDS THE MAGNITUDE OF THE SMALLEST ROTATION    *
C*  ABOUT A SINGLE AXIS (OF GENERAL ORIENTATION) NEEDED TO MATCH A    *
C*  STRESS MODEL AND A FAULT PLANE GEOMETRY;  THIS IS ACCOMPLISHED    *
C*  BY CONSTRUCTING AND SOLVING A FOURTH-ORDER POLYNOMIAL EQUATION    *
C*  (SUBROUTINE POLY4)                                                *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE ROTANG(II,I,KJ,B,RFIX,C1,C2,C3,YY,SRF)
      LOGICAL SRF,SSLP,PASS1
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
         CALL PTRBAX(C1,C2,C3,DELTA)
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
      IF(SRF) CALL SCHK(II,I,KJ,B,RFIX,C1,C2,C3,Y,Z,YY,ZZ)
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*  SUBROUTINE PTRBAX ADJUSTS THE ORIENTATION OF THE ROTATION AXIS AS  *
C*  NECESSARY TO AVOID EXTREME VALUES OF D(1)                          *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE PTRBAX(C1,C2,C3,DELTA)
C
C   FIND THE LARGEST AND SMALLEST COMPONENTS OF THE ROTATION AXIS
C
      CMIN=AMIN1(C1,C2,C3)
      CMAX=AMAX1(C1,C2,C3)
      IF(C1.EQ.CMIN) MINC=1
      IF(C1.EQ.CMAX) MAXC=1
      IF(C2.EQ.CMIN) MINC=2
      IF(C2.EQ.CMAX) MAXC=2
      IF(C3.EQ.CMIN) MINC=3
      IF(C3.EQ.CMAX) MAXC=3
      IF(MINC.EQ.1) THEN
         IF(MAXC.EQ.2) THEN
             C2=COS(ACOS(C2)+DELTA)
             C1=SIGN(SQRT(1.0-C2*C2-C3*C3),C1)
          ELSE
             C3=COS(ACOS(C3)+DELTA)
             C1=SIGN(SQRT(1.0-C2*C2-C3*C3),C1)
          ENDIF
       ELSEIF(MINC.EQ.2) THEN
          IF(MAXC.EQ.3) THEN
             C3=COS(ACOS(C3)+DELTA)
             C2=SIGN(SQRT(1.0-C1*C1-C3*C3),C2)
          ELSE
             C1=COS(ACOS(C1)+DELTA)
             C2=SIGN(SQRT(1.0-C1*C1-C3*C3),C2)
          ENDIF
       ELSE
          IF(MAXC.EQ.1) THEN
             C1=COS(ACOS(C1)+DELTA)
             C3=SIGN(SQRT(1.0-C1*C1-C2*C2),C3)
          ELSE
             C2=COS(ACOS(C2)+DELTA)
             C3=SIGN(SQRT(1.0-C1*C1-C2*C2),C3)
          ENDIF
      ENDIF
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE COSORT ARRANGES THE SOLUTIONS FROM SUBROUTINE ROTANG   *
C*  IN ORDER OF INCREASING MAGNITUDES                                 *
C*                                                                    *
C**********************************************************************
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
         DO 118 L=K1,4
         IF(Y(K).LT.Y(L).AND.Y(L).LE.1.0) THEN
            YA=Y(K)
            Y(K)=Y(L)
            Y(L)=YA
         ENDIF
  118    CONTINUE
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
      ZC=SQRT(1.0-YY*YY)
      DO 130 K=1,4
      IF(ABS(ZC-ABS(Z(K))).LE.0.0001) THEN
         ZA=Z(J)
         Z(J)=Z(K)
         Z(K)=ZA
C        GO TO 135
      ENDIF
  130 CONTINUE
      DO 133 K=1,4
      IF(K.NE.J) THEN
         IF(ABS(ZC-ABS(Z(K))).LT.ABS(ZC-ABS(Z(J)))) THEN
            ZA=Z(K)
            Z(K)=Z(J)
            Z(J)=ZA
         ENDIF
      ENDIF
  133 CONTINUE
      IF(YY.EQ.1.0) THEN
         YA=1.0-Z(J)*Z(J)
         IF(YA.LT.0.0) YA=0.0
         YY=SIGN(SQRT(YA),YY)
      ENDIF
  135 ZZ=Z(J)
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE POLY4 (DOUBLE PRECISION) DETERMINES UP TO FOUR REAL    *
C*  ROOTS OF A FOURTH ORDER POLYNOMIAL EQUATION WITH COEFFICIENTS     *
C*  FOUND IN SUBROUTINE ROTANG                                        *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE POLY4(D,Y)
      IMPLICIT DOUBLE PRECISION (A-C,E-H,O-X,Z)
      DIMENSION D(5),E(5),C(4),Y(4)
      DO 10 I=2,5
      E(I)=DBLE(D(I)/D(1))
   10 CONTINUE
C     E(1)=1.0D0
C     C(4)=1.0D0
      C(3)=-E(3)
      C(2)=E(4)*E(2)-4.0*E(5)
      C(1)=-E(4)*E(4)-E(5)*E(2)*E(2)+4.0*E(5)*E(3)
      CALL POLY3(C,X)
      RAUX=0.25*E(2)*E(2)-E(3)+X
      IF(RAUX.LT.0.0D0) RAUX=0.0D0
      R=DSQRT(RAUX)
      IF(R.NE.0.0D0) THEN
         F1=0.75*E(2)*E(2)-R*R-E(3)-E(3)
         F2=(E(2)*E(3)-E(4)-E(4)-E(2)*E(2)*E(2)/4.0)/R
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
         G=DSQRT(G)
         Y(1)=SNGL(0.5*(R-0.5*E(2)+G))
         Y(2)=SNGL(0.5*(R-0.5*E(2)-G))
      ENDIF
      H=F1-F2
      IF(H.LT.0.0D0) THEN
         Y(3)=-1.0
         Y(4)=-1.0
      ELSE
         H=DSQRT(H)
         Y(3)=SNGL(-0.5*(R+0.5*E(2)-H))
         Y(4)=SNGL(-0.5*(R+0.5*E(2)+H))
      ENDIF
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE POLY3 (DOUBLE PRECISION) DETERMINES ONE REAL ROOT OF   *
C*  OF A THIRD ORDER POLYNOMIAL EQUATION, AS NEEDED IN SUBROUTINE     *
C*  POLY4                                                             *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE POLY3(C,X)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION C(4)
      DATA OT,TT / 0.3333333333333333D0,0.6666666666666667D0 /
      DATA SQRT2 / 1.414213562D0 /
      Q=C(2)/3.0-C(3)*C(3)/9.0
      R=(C(2)*C(3)-3.0*C(1))/6.0-C(3)*C(3)*C(3)/27.0
      S=Q*Q*Q+R*R
      IF(S.GE.0.0D0) THEN
         S=DSQRT(S)
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
         H=DSQRT(TT*H1)
         H4=H2*SQRT2/(H*H*H)
         ALPHA=(DACOS(H4))*OT
         X=H*SQRT2*DCOS(ALPHA)+C3
      ENDIF
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE SCHK TESTS TO ENSURE THAT THE ROTATIONS FOUND IN SUB-  *
C*  ROUTINE ROTANG RESULT IN THE CORRECT SENSE OF SLIP ON THE FAULT   *
C*  PLANE                                                             *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE SCHK(II,I,KJ,B,RFIX,C1,C2,C3,Y,Z,CRA,SR)
      DIMENSION CA(3),A(3,3),B(3,3),B1(3,3),Y(4),Z(4),CN(3),CE(3),CD(3)
     1,CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999)
     2,C(3,3),AZ(9999,2),DIP(9999,2),Q(9999), CD2(9999)
      LOGICAL SSLP,PASS1
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / THREE / AZ,DIP,Q
      COMMON / SIX / SSLP,PASS1
      COMMON / SEVEN / AZN,DIPN,AZS,DIPS
      DATA HPI,PI2,RAD / 1.5707963,6.2831854,0.017453292 /
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
  112 IF(ABS(CRA).GT.1.0) CRA=SIGN(1.0,CRA)
      CCRA=1.0-CRA
C
C   CALCULATE ROTATION MATRIX, A(I,J)
C
      DO 150 M=1,3
      DO 145 N=M,3
      A(M,N)=CCRA*CA(M)*CA(N)
      IF(M.NE.N) A(N,M)=A(M,N)
  145 CONTINUE
      A(M,M)=A(M,M)+CRA
  150 CONTINUE
      Q1=1.0
      DO 160 M=1,3
      Q1=-Q1
      DO 160 N=1,3
      IF(M.NE.N) THEN
         A(M,N)=A(M,N)+Q1*SR*CA(6-M-N)
         Q1=-Q1
      ENDIF
  160 CONTINUE
C
C   FIND ROTATED FAULT PLANE GEOMETRY, B1(I,J)
C
      DO 170 M=1,3,2
      DO 170 N=1,3
      B1(M,N)=A(M,1)*B(K,N)+A(M,2)*B(2,N)+A(M,3)*B(L,N)
  170 CONTINUE
C
C   FIND THE ROTATED FAULT PLANE GEOMETRY
C
      DO 200 M=1,3,2
      CN(M)=B1(M,1)*C(1,1)+B1(M,2)*C(2,1)+B1(M,3)*C(3,1)
      CE(M)=B1(M,1)*C(1,2)+B1(M,2)*C(2,2)+B1(M,3)*C(3,2)
      CD(M)=B1(M,1)*C(1,3)+B1(M,2)*C(2,3)+B1(M,3)*C(3,3)
      IF(CD(M).LT.0.0) THEN
         CN(M)=-CN(M)
         CE(M)=-CE(M)
         CD(M)=-CD(M)
      ENDIF
  200 CONTINUE
C
C   CHECK SENSE OF SLIP AND FIND THE NEW FAULT PLANE AND SLIP DIRECTION
C
      IF(Q(I)*(RFIX*B1(1,2)*B1(3,2)+B1(1,3)*B1(3,3)).LT.0.0) THEN
         SSLP=.TRUE.
         IF(CE(1).NE.0.0.OR.CN(1).NE.0.0) THEN
            AZN=ATAN2(CE(1),CN(1))
         ELSE
            AZN=0.0
         ENDIF
         AZN=AMOD(AZN+HPI+PI2,PI2)/RAD
         IF(CD(1).GT.1.0) CD(1)=1.0
         DIPN=ACOS(CD(1))/RAD
         IF(CE(3).NE.0.0.OR.CN(3).NE.0.0) THEN
            AZS=ATAN2(CE(3),CN(3))
         ELSE
            AZS=0.0
         ENDIF
         AZS=AMOD(AZS+HPI+PI2,PI2)/RAD
         IF(CD(L).GT.1.0) CD(3)=1.0
         DIPS=ACOS(CD(3))/RAD
      ELSE
         SSLP=.FALSE.
         AZN=AZ(I,KJ)
         DIPN=DIP(I,KJ)
         AZS=AZ(I,3-KJ)
         DIPS=DIP(I,3-KJ)
      ENDIF
C
C   IF THE SENSE OF SLIP IS INCORRECT AND THIS IS THE FINAL PASS,
C   FIND THE NEXT SMALLEST ROTATION AND CHECK IT
C
      IF(.NOT.(SSLP.OR.PASS1)) THEN
         IF(JF.NE.4) THEN
            JF=JF+1
            CALL COSORT(JF,Y,Z,CRA,.TRUE.,SR)
            GO TO 112
         ELSE
            CRA=-1.0
         ENDIF
      ENDIF
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE BDAX DETERMINES THE SMALLEST ROTATION ABOUT THE FOUR   *
C*  "OCTAHEDRAL" AXES OF THE FAULT PLANE GEOMETRY NEEDED TO MATCH THE *
C*  SHEAR STRESS AND SLIP DIRECTIONS ON A FAULT PLANE; THE SMALLEST   *
C*  AMONG THESE FOUR OR THE THREE AXES TESTED IN SUBROUTINE ROTXP     *
C*  IS TAKEN THE INITIAL GUESS OF THE OPTIMUM ROTATION AXIS (THE      *
C*  STARTING MODEL IN SUBROUTINE AXRFN)                               *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE BDAX(I,J,B,RFIX,AZIM,PLNG,RBD,SRF)
      DIMENSION CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),
     1 CD2(9999),BDCR(4),B(3,3)
      LOGICAL SRF
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      DATA SQ3I,PI2 / 0.5773503,6.2831854 /
      K=3-J
C
C   FIND THE ROTATIONS ABOUT THE 4 "OCTAHEDRAL" AXES (EQUALLY SPACED
C   BETWEEN THE AXIS OF THE FAULT PLANE GEOMETRY)
C
      CALL ROTANG(II,I,J,B,RFIX,SQ3I,SQ3I,SQ3I,BDCR(1),SRF)
      CALL ROTANG(II,I,J,B,RFIX,SQ3I,SQ3I,-SQ3I,BDCR(2),SRF)
      CALL ROTANG(II,I,J,B,RFIX,SQ3I,-SQ3I,SQ3I,BDCR(3),SRF)
      CALL ROTANG(II,I,J,B,RFIX,SQ3I,-SQ3I,-SQ3I,BDCR(4),SRF)
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
      RBD=ACOS(BDCR(LBD))
      RETURN
      END
C
C**********************************************************************
C*                                                                    *
C*  SUBROUTINE SENSLIP DETERMINES THE SENSE OF SLIP (E.G., NORMAL VS. *
C*  REVERSE DIP SLIP COMPONENT) OF THE ROTATED FAULT PLANE GEOMETRY,  *
C*  WHICH IS CONSISTENT WITH THE PRESCRIBED STRESS MODEL.  FOR SOME   *
C*  POORLY-FITTING CASES, THE SMALLEST ROTATION ALIGNS THE FAULT POLE *
C*  OR SLIP VECTOR WITH ONE OF THE PRINCIPAL STRESS AXES--WHILE THESE *
C*  ORIENTATIONS ARE ACCEPTABLE SOLUTIONS (OR AT LEAST SMALL PERTUR-  *
C*  BATIONS ABOUT THEM ARE), THE MAGNITUDE OF SHEAR STRESS ON THE     *
C*  FAULTS IS VERY SMALL.  THESE CASES ARE FLAGGED BY SETTING NOSLIP  *
C*  = .TRUE.                                                          *
C*                                                                    *
C**********************************************************************
C
      SUBROUTINE SENSLIP(I,JK,B,Q0,NOSLIP)
      DIMENSION CN1(9999,2),CE1(9999,2),CD1(9999,2),CN2(9999),CE2(9999),
     1 CD2(9999),B(3,3),B0(3,3),C(3,3),AZ(9999,2),DIP(9999,2),Q(9999)
      LOGICAL NOSLIP
      COMMON / ONE / CN1,CE1,CD1,CN2,CE2,CD2
      COMMON / TWO / C
      COMMON / THREE / AZ,DIP,Q
      COMMON / FIVE / NFM,KFP,KR,RFIX
      COMMON / SEVEN / AZN,DIPN,AZS,DIPS
      DATA RAD / 0.017453292 /
C
C   FIND THE COORDINATES OF THE ROTATED FAULT PLANE GEOMETRY:
C   C11, C12, C13, C21, C22, C23, C31, C32, C33
C
      AZN0=AZN*RAD
      DIPN0=DIPN*RAD
      AZS0=AZS*RAD
      DIPS0=DIPS*RAD
      CAUX=SIN(DIPN0)
      C11=SIN(AZN0)*CAUX
      C12=-COS(AZN0)*CAUX
      C13=COS(DIPN0)
      CAUX=SIN(DIPS0)
      C31=SIN(AZS0)*CAUX
      C32=-COS(AZS0)*CAUX
      C33=COS(DIPS0)
      DEN=C12*C31-C11*C32
      IF(DEN.NE.0.0.AND.C12.NE.0.0) THEN
         C21=(C13*C32-C12*C33)/DEN
         C22=-(C21*C11+C13)/C12
         C23=1.0/SQRT(1.0+C21*C21+C22*C22)
         C21=C21*C23
         C22=C22*C23
      ELSE
         C22=(C11*C33-C13*C31)/(C13*C32-C12*C33)
         C23=-(C11+C12*C22)/C13
         C21=1.0/SQRT(1.0+C22*C22+C23*C23)
         IF(C23.LT.0.0) C21=-C21
         C22=C22*C21
         C23=C23*C21
      ENDIF
C
C   FIND THE MATRIX BETA (B0(I,J)) RELATIVE TO THE ROTATED FAULT
C   PLANE GEOMETRY
C
      DO 60 J=1,3
      B0(1,J)=C11*C(J,1)+C12*C(J,2)+C13*C(J,3)
      B0(3,J)=C31*C(J,1)+C32*C(J,2)+C33*C(J,3)
   60 CONTINUE
C
C   FIND THE MAGNITUDE OF SHEAR STRESS ON THE ROTATED FAULT PLANE (Q0)
C
      Q0=-RFIX*B0(1,2)*B0(3,2)-B0(1,3)*B0(3,3)
      IF(ABS(Q0).GT.1.0E-03) THEN
         NOSLIP=.FALSE.
      ELSE
         NOSLIP=.TRUE.
C
C   IF THE MAGNITUDE OF SHEAR STRESS IS NEGLIGIBLE, CHECK TO SEE IF
C   THE FAULT PLANE HAS OVERTURNED (BY EXAMINING THE HANDEDNESS OF
C   THE FPG BEFORE AND AFTER ROTATION)--IF IT HAS OVERTURNED, THEN
C   CHANGE THE SIGN OF THE FAULT SLIP INDEX (Q(I))
C
         DET0=CN2(I)*CE1(I,1)*CD1(I,2)+CN1(I,2)*CE2(I)*CD1(I,1)+
     1    CE1(I,2)*CD2(I)*CN1(I,1)-CN2(I)*CE1(I,2)*CD1(I,1)-CN1(I,1)*
     1    CE2(I)*CD1(I,2)-CE1(I,1)*CD2(I)*CN1(I,2)
         DET1=C21*C12*C33+C31*C22*C13+C32*C23*C11-C21*C32*C13-C11*C22*
     1    C33-C12*C23*C31
         IF(JK.EQ.2) DET1=-DET1
         IF(DET0*DET1.LT.0.0) THEN
            Q0=-SIGN(Q(I),Q0)
            RETURN
         ENDIF
      ENDIF
C
C   FIND THE SIGN OF THE SLIP INDEX ON THE ROTATED FAULT PLANE 
C   (INDICATES THE SENSE OF SLIP)
C
      Q0=SIGN(Q(I),Q0)
      RETURN
      END
