%
%                                                                     *
%              FOCAL MECHANISM STRESS INVERSION PACKAGE               *
%                          JOHN W. GEPHART                            *
%                          BROWN UNIVERSITY                           *
%                                1985                                 *
%                                                                     *
%                 REVISED AT CORNELL UNIVERSITY, 1989                 *
%                                                                     *
%
%
%
%                                                                     *
%  THIS PROGRAM PERFORMS THE STRESS INVERSION OF EARTHQUAKE FOCAL     *
%  MECHANISM AND FAULT/SLICKENSIDE DATA USING THE METHODS OF GEPHART  *
%  AND FORSYTH [1984]; RESULTS ARE PRESENTED IN TABLES OF R VS. PHI,  *
%  WHERE PHI IS THE RAKE OF THE SIGMA-2 AXIS IN THE PLANE NORMAL TO   *
%  THE PRIMARY STRESS DIRECTION (SIGMA-1 OR -3, AT THE USER'S CHOICE) *
%                                                                     *
%  REQUIRED SUBPROGRAMS:  XPSET, EULER, INVEUL, NORM, PRISTR, NPSF5,  *
%    NPSF10, SECSTR, PHICLC, GRDTAB, BETCLC, XPROTP, XPCHKP, AXSYMP,  *
%    XPROTA, XPCHKA, AXSYMA, XPROTE, AXSYME, AXRFN, OCTROT, GENROT,   *
%    COSORT, POLY4, POLY3, AND SSCHK                                  *
%                                                                     *
%  THIS MAIN PROGRAM READS THE INPUT PARAMETERS, WHICH ARE USED TO    *
%  CONSTRUCT THE GRID OF STRESS MODELS TO BE SEARCHED, AND INITIAL-   *
%  IZES SOME VARIABLES AND ARRAYS                                     *
%
% Turned into very basic
function [data] = FMSI() % MAIN PROGRAM FMSI
    %  THIS MAIN PROGRAM READS THE INPUT PARAMETERS, WHICH ARE USED TO    *
    %  CONSTRUCT THE GRID OF STRESS MODELS TO BE SEARCHED, AND INITIAL-   *
    %  IZES SOME VARIABLES AND ARRAYS                                     *
    
    % DIMENSION C(40,3,3),AZ(470,2),DIP(470,2),Q(470),PH(40),CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470);
    % dimension record(7);
    % CHARACTER*30 INFILE,OUTFILE
    % CHARACTER*1 DSKIP
    % LOGICAL SSLP,PASS1,GRD
    
    %global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
    %global C                        %COMMON_DEF TWO
    
    
    PI = pi; % 3.1415927
    HPI = PI/2; % 1.5707963
    RAD = deg2rad(1); % 0.017453292;
    PI2 = 2*pi; % 6.2831854;
    
    C=[];
    
    %global AZ DIP Q                 %COMMON_DEF THREE
    %global A1 A2 A3 A4 A5 A6        % COMMON_DEF FOUR
    KR = [];
    RFXS = [];
    RSTEP = [];
    record = [];
    SSLP = [];
    PASS1 = [];
    % global KR RFXS RSTEP record  % COMMON_DEF FIVE %removed is [RSMIN, NTAB, NR, NPHI]
    %global SSLP PASS1       % COMMON_DEF SIX
    % global METHOD          % COMMON_DEF SEVEN
    %   OPEN INPUT (UNIT 5) AND OUTPUT (UNIT 6) FILES
    params = read_params('AP1.IN');
    disp(params)
    [~, params.KFP, tb] = read_input(params.INFILE);
    KR = params.KR;
    RSTEP = params.RSTEP;
    
    unit99 = fopen('out95','w'); % this is the output that will be used
    fid_out_tmp3 = fopen(params.OUTFILE,'w'); % some summary statement of the best model
    unit3 = fopen('tmp.tmp','w'); %
    
    
    %   SELECT A METHOD
    
    RFXS = params.RLOW - params.RSTEP;
    METHOD = params.METHOD;
    Q = double(tb.Q);
    [WT, data] = XPSET_new(tb);
    %[WT, data] = XPSET(tb);
    NFM=height(data);
    CN1=data.CN1
    CE1=data.CE1;
    CD1=data.CD1;
    CN2 = data.CN2;
    CE2 = data.CE2;
    CD2 = data.CD2;
    [RSMIN, NTAB, NR, NPHI] = PRISTR(WT, data, params, fid_out_tmp3);
    fprintf(fid_out_tmp3, '\n\n Best Model (Weighted Averages in degrees) -  %7.3f (%3d %3d %3d)\n',...
        RSMIN, NTAB, NR, NPHI);
    fprintf(' Best Model (Weighted Averages in degrees) -  %7.3f (%3d%3d%3d)\n',...
        RSMIN, NTAB, NR, NPHI);
    %
    fclose(fid_out_tmp3);
    fclose(unit3);
    
    return % end of main program
    
    %
    % The following should be constants, not functions
    
    function [WT,data] = XPSET(data)
        %% verified that this works the same as the new version -CGR
        %  SUBROUTINE XPSET SETS UP THE COORDINATE AXES FIXED BY THE FAULT    *
        %  PLANE GEOMETRY (FPG) FOR EACH DATUM (THE PRIMED COORDINATES)       *
        
        % DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),DIP(470,2),Q(470);
        
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        % global AZ DIP Q                 %COMMON_DEF THREE
        
        WT = 0.0;
        
        %   INPUT FAULT PLANE ORIENTATION DATA AND CALCULATE FAULT PLANE
        %   COORDINATE AXES; EXTERNAL COORDINATES = NORTH, EAST, DOWN;
        %   E.G., CN1(I,J) = COSINE OF THE ANGLE BETWEEN HORIZONTAL-NORTH
        %   AND THE POLE TO THE JTH NODAL PLANE (EQUIVALENT TO THE SLIP
        %   VECTOR OF THE ALTERNATE NODAL PLANE) OF THE ITH DATUM, AND
        %   CD2(I) = COSINE OF THE ANGLE BETWEEN VERTICAL-DOWN AND THE
        %   B AXIS OF THE ITH DATUM
        
        NFM = height(data);
        AZ = data.AZ;
        % AZ=nan(NFM, 2);
        DIP=nan(NFM, 2);
        % Q=nan(NFM,1);
        [CD1,CD2,CE1,CE2,CN1,CN2]=deal(nan(NFM,1));
        
        for I = 1:height(data)   % DO until line 30
            AZ(I,:) = data.AZ(I,:);
            DIP(I,:) = data.DIP(I,:);
            % Q(I) = data.Q(I);
            for J = 1:2
                AZR = AZ(I,J)*RAD;
                DIPR = DIP(I,J)*RAD;
                CD1(I,J) = cos(DIPR);
                CD3 = sin(DIPR);
                CN1(I,J) = sin(AZR)*CD3;
                CE1(I,J) = -cos(AZR)*CD3;                
                fprintf("  %d   %d AZR:%g DIPR:%g CD3:%g\n",AZR,DIPR,CD3)
            end % line 20
            CD2(I)=(-CN1(I,2)+CN1(I,1)*CE1(I,2)/CE1(I,1)) / (-CD1(I,1)*CE1(I,2)/CE1(I,1)+CD1(I,2));
            CE2(I)=(-CD2(I)*CD1(I,1)-CN1(I,1))/CE1(I,1);
            CN2(I) = 1.0/sqrt(1.0+CE2(I)*CE2(I)+CD2(I)*CD2(I));
            if CD2(I) < 0.0
                CN2(I) = -CN2(I);
            end
            CE2(I) = CE2(I)*CN2(I);
            CD2(I) = CD2(I)*CN2(I);
            WT = WT + abs(Q(I));
        end % line 30
        
        data.CD1 = CD1;
        data.CE1 = CE1;
        data.CN1 = CN1;
        data.CN2 = CN2;
        data.CE2 = CE2;
        data.CD2 = CD2;
        
    end
    function [WT,data] = XPSET_new(data)
        %  SUBROUTINE XPSET SETS UP THE COORDINATE AXES FIXED BY THE FAULT    *
        %  PLANE GEOMETRY (FPG) FOR EACH DATUM (THE PRIMED COORDINATES)       *
        
        % DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),DIP(470,2),Q(470);
        
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        %global AZ DIP % Q                 %COMMON_DEF THREE
        
        %
        %   INPUT FAULT PLANE ORIENTATION DATA AND CALCULATE FAULT PLANE
        %   COORDINATE AXES; EXTERNAL COORDINATES = NORTH, EAST, DOWN;
        %   E.G., CN1(I,J) = COSINE OF THE ANGLE BETWEEN HORIZONTAL-NORTH
        %   AND THE POLE TO THE JTH NODAL PLANE (EQUIVALENT TO THE SLIP
        %   VECTOR OF THE ALTERNATE NODAL PLANE) OF THE ITH DATUM, AND
        %   CD2(I) = COSINE OF THE ANGLE BETWEEN VERTICAL-DOWN AND THE
        %   B AXIS OF THE ITH DATUM
        %
        AZR = data.AZ*RAD;
        DIPR = data.DIP * RAD;
        CD1=cos(DIPR);
        CD3=sin(DIPR);
        CN1=sin(AZR).* CD3;
        CE1=-cos(AZR).* CD3;
        WT = sum(abs(Q));
        CD2 = (-CN1(:,2) + CN1(:,1).* CE1(:,2)./ CE1(:,1)) ./ ...
            (-CD1(:,1) .* CE1(:,2) ./ CE1(:,1) + CD1(:,2));
        CE2 = (-CD2 .* CD1(:,1) - CN1(:,1)) ./ CE1(:,1);
        CN2 = 1.0 ./ sqrt(1.0 + CE2.^2 + CD2.^2);
        CN2(CD2 < 0.0) = -CN2(CD2<0.0);
        CE2 = CE2 .* CN2;
        CD2 = CD2 .* CN2;
        data.CD1 = CD1;
        data.CE1 = CE1;
        data.CN1 = CN1;
        data.CN2 = CN2;
        data.CE2 = CE2;
        data.CD2 = CD2;
    end
    
    
    
    function [IPL, IAZ] = EULER(CN,CE,CD)
        %  SUBROUTINE EULER TRANSFORMS 3 CARTESIAN COORDINATES OF AN AXIS     *
        %  (WITH RESPECT TO EXTERNAL COORDINATES--NORTH, EAST, AND DOWN),     *
        %  INTO 2 EULER ANGLES (PLUNGE AND AZIMUTH)                           *

        IPL = zeros(size(CN)) + 90;
        IAZ = zeros(size(CN));
        to_calc = ~(CN == 0.0 & CE == 0.0);
        IPL(to_calc) = fix(asin(CD(to_calc)) ./ RAD+0.5);
        IAZ(to_calc) = fix(rem(atan2(CE(to_calc), CN(to_calc)) ./ RAD + 360.0, 360.0) + 0.5);
    end
    
    function [C1, C2, C3] = INVEUL(I,THETA1,THETA2, data)
        %  SUBROUTINE INVEUL TRANSFORMS 2 EULER ANGLES OF AN AXIS (PLUNGE     *
        %  AND AZIMUTH) INTO 3 CARTESIAN COORDINATES RELATIVE TO A FAULT      *
        %  PLANE GEOMETRY COORDINATE SET                                      *
        
        % DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470);
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        J = 3 - K;
        CT2 = cos(THETA2);
        C1R = cos(THETA1)*CT2;
        C2R = sin(THETA1)*CT2;
        C3R = sin(THETA2);
        C1 = C1R*CN1(I,K) + C2R*CE1(I,K)+C3R*CD1(I,K);
        C2 = C1R*CN2(I) + C2R*CE2(I) + C3R*CD2(I);
        C3 = C1R*CN1(I,J) + C2R*CE1(I,J) + C3R*CD1(I,J);
        [C1,C2,C3] = NORM(C1,C2,C3);
    end
    
    function [X, x2, x3] = NORM(X, x2, x3)
        %  SUBROUTINE NORM ADJUSTS THE ANGLE COSINE COORDINATES OF ANY AXIS   *
        %  TO ENSURE THAT THE SUM OF THEIR SQUARES IS 1.0                     *
        if nargin == 3
            X = [X, x2, x3];
        end
        XNORM = sum(X.^2);
        
        if XNORM ~= 1.0
            if XNORM < 0.0
                XNORM = 1.0E-30;
            end
            XNORM = sqrt(XNORM);
            X = X ./ XNORM;
        end
        if nargin == 3
            x3 = X(3);
            x2 = X(2);
            X = X(1);
        end
    end
    
    
    function [RSMIN, NTAB, NR, NPHI] = PRISTR(WT, data, params, fid_out_tmp3)
        %  SUBROUTINE PRISTR CONSTRUCTS A GRID OF PRINCIPAL STRESS DIRECTION  *
        %  COSINES (C(I,J,K)) OVER WHICH TO SEARCH.  I = INDEX OF PHI VALUE   *
        %  (1 - NSDP), J = STRESS INDEX (1 - 3), K = EXTERNAL COORDINATE      *
        %  INDEX (1 - 3); THE RESULTING GRID UNIFORMLY COVERS ALL ORIENTA-    *
        %  TIONS WITHIN THE SPECIFIED RANGES (APPRI AND APSEC) ABOUT THE      *
        %  PRESCRIBED PRIMARY (PLPRI,AZPRI) AND SECONDARY (PLSEC,AZSEC) PRIN- *
        %  CIPAL STRESS DIRECTIONS.  SUBSIDIARY SUBROUTINES:  NPSF5, NSPF10,  *
        %  SECSTR, PHICLC                                                     *
        
        % DIMENSION A(3,3),X(3),Z(3),C(40,3,3),PH(40);
        % dimension record(7);
        % LOGICAL GRD
        
        % global C                        %COMMON_DEF TWO
        % global NFM KFP KR RFXS RSTEP record  % COMMON_DEF FIVE
        
        RSMIN = 9999.0;
        
        PLSEC = params.PLSEC*RAD;
        AZSEC = params.AZSEC*RAD;
        APSEC = params.APSEC*RAD;
        AZ3 = params.AZPRI*RAD;
        CPL3 = HPI-params.PLPRI*RAD;
        CPL2 = HPI;
        AZ2 = AZ3+HPI;
        CPL1 = CPL3+HPI;
        AZ1 = AZ3;
        
        %   CALCULATE THE ROTATION MATRIX, A(I,J), THAT TRANSFORMS A FIXED
        %   EXTERNAL COORDINATE SYSTEM (WITH AXES NORTH, EAST, AND DOWN);
        %   INTO ONE FIXED TO THE CHOSEN PRIMARY AND SECONDARY STRESS
        %   DIRECTIONS
        
        CAUX = sin(CPL1);
        A(1,1) = cos(AZ1)*CAUX;
        A(2,1) = sin(AZ1)*CAUX;
        A(3,1) = cos(CPL1);
        A(1,2) = cos(AZ2);
        A(2,2) = sin(AZ2);
        A(3,2) = 0.0;
        CAUX = sin(CPL3);
        A(1,3) = cos(AZ3)*CAUX;
        A(2,3) = sin(AZ3)*CAUX;
        A(3,3) = cos(CPL3);
        
        %   OPEN THE FILE CONTAINING THE GRIDDED PRIMARY STRESS DIRECTIONS
        %   ON THE EXTERNAL GRID
        
        if params.GRD
            grid5raw = fileread('GRID5.TAB');
            the_grid = str2num(grid5raw); %#ok<ST2NM> % X,Y,Z ALT_deg,AZ_deg
            PSTEP = 4.5*RAD;
        else
            grid10raw = fileread('GRID10.TAB');
            the_grid = str2num(grid10raw); %#ok<ST2NM> % X,Y,Z ALT_deg,AZ_deg
            PSTEP = 9.0*RAD;
        end
        
        % FIND THE NUMBER (NPS) OF PRIMARY (SIGMA-1 OR SIGMA-3) STRESS
        % DIRECTIONS (PLPRI,AZPRI) TO BE USED IN CONSTRUCTING THE GRID.
        % THIS NUMBER IS SELECTED FROM A PREDETERMINED GRID OF PRIMARY
        % STRESS DIRECTIONS ACCORDING THE PRESCRIBED VARIANCE (APPRI)
        NPS = sum(the_grid(:,4)>= (90 - params.APPRI));
        NPSTOT = NPS - params.NPS0;
        
        %   WRITE INFO AT THE BEGINNING OF THE OUTPUT FILE
        
        fprintf(fid_out_tmp3,'  This listing file presents the results of a grid search over\n');
        switch params.METHOD
            case 1
                methname = 'POLE ROTATION';
            case 2
                methname = 'APPROXIMATE';
            otherwise
                methname = 'EXACT';
        end
        
        fprintf(fid_out_tmp3,'     %3d sigma-%d direction(s), using the %s method.\n', NPSTOT,params.ISIG, methname);
        fprintf(fid_out_tmp3,' The data set comprises %3d fault-slip data (weighted sum = %5.1f).\n',height(data), WT);
        
        RFACT = 1.0/(RAD*WT);
        if params.ISIG == 1
            IC = 1;
        else
            IC = 0;
        end
        
        %   READ OVER THE NUMBER OF PRIMARY STRESS DIRECTIONS THAT ARE TO BE
        %   SKIPPED
        
        NPS1 = params.NPS0+1;
        if params.NPS0 > 0
            for M = 1:params.NPS0   % DO until line 80
                fread(unit4,' %10.7f %10.7f %10.7f');
            end % line 80
        end
        
        
        NTAB = nan;
        NR = nan;
        NPHI = nan;
        
        
        %   FOR EACH PRIMARY STRESS DIRECTION TO BE TESTED, READ THE EX-
        %   TERNAL COORDINATES, X(I), AND TRANSFORM TO NEW COORDINATES, Z(I),
        %   FIXED TO THE DESIRED STRESS DIRECTIONS
        
        for M = NPS1:NPS   % DO until line 100
            % fread(unit4,' %10.7f %10.7f %10.7f', X(1),X(2),X(3));
            X = the_grid(M,1:3);
            for I = 3:-1:1
                Z(I) = sum(A(I,:).* X);
            end 
            if Z(3) < 0.0
                Z = -Z;
            end
            Z = NORM(Z);
            %   MAKE MINOR ADJUSTMENTS IN CERTAIN DEGENERATE CASES
            
            if abs(Z(1)) < 0.0035
                Z(1) = SIGN(0.0035,Z(1));
                if abs(Z(2)) >= 0.0025 && Z(3) >= 0.0025
                    ZZ22 = Z(2)*Z(2)-6.125E-06;
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    Z(2) = SIGN(sqrt(ZZ22),Z(2));
                    ZZ22 = 1.0-6.125E-06-Z(2)*Z(2);
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    Z(3) = sqrt(ZZ22);
                elseif Z(3) < 0.0025
                    ZZ22 = Z(2)*Z(2)-1.225E-05;
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    Z(2) = SIGN(sqrt(ZZ22),Z(2));
                    ZZ22 = 1.0-6.125E-06-Z(2)*Z(2);
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    Z(3) = sqrt(ZZ22);
                else
                    ZZ22 = Z(3)*Z(3)-1.225E-05;
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    Z(3) = sqrt(ZZ22);
                    ZZ22 = 1.0-6.125E-06-Z(3)*Z(3);
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    Z(2) = sqrt(ZZ22);
                end
            end
            if Z(3) > 0.99997
                Z(1) = SIGN(0.005477184,Z(3));
                Z(2) = SIGN(0.005477184,Z(2));
                Z(3) = 0.99997;
            end
            %   FOR EACH PRIMARY STRESS DIRECTION TESTED, FIND THE OTHER 2
            %   PRINCIPAL STRESS DIRECTIONS
            
            [NSDP,PH] = SECSTR(params.ISIG,IC,Z(1),Z(2),Z(3),PLSEC, AZSEC, APSEC, PSTEP);
            MTAB = M-params.NPS0;
            
            %   IF THERE ARE ANY SETS OF MUTUALLY ADMISSIBLE PRINCIPAL STRESS
            %   DIRECTIONS, CONSTRUCT A TABLE OF STRESS MODELS AND PROCEED
            
            if NSDP ~= 0
                % GRDTAB(NSDP,PH,MTAB,NPSTOT,RFACT,fid_out_tmp3);
                [RSMIN, NTAB, NR, NPHI] = GRDTAB_new(NSDP, PH, MTAB, NPSTOT, RFACT, RSMIN, NTAB, NR, NPHI, fid_out_tmp3);
            end
        end % line 100
    end
    
    
    function [NSDP, PH] = SECSTR(ISIG, IC, C11, C12, C13, PLSEC, AZSEC, APSEC, PSTEP)
        %  SUBROUTINE SECSTR CALCULATES ALL ADMISSIBLE ORIENTATIONS OF THE    *
        %  SECONDARY STRESS (SIGMA-3 OR SIGMA-1) RELATIVE TO A SPECIFIED      *
        %  PRIMARY STRESS (SIGMA-1 OR SIGMA-3).  THESE DIRECTIONS UNIFORMLY   *
        %  SAMPLE THE REGION WITHIN THE PRESCRIBED LIMITS (APSEC) AROUND THE  *
        %  OPTIMUM SECONDARY STRESS DIRECTION (PLSEC,AZSEC)                   *
        
        % DIMENSION AZ(3),CPL(3),C(40,3,3),PH(40);
        % global C
        CAP = cos(APSEC);
        CPLA = cos(PLSEC);
        C41 = cos(AZSEC)*CPLA;
        C42 = sin(AZSEC)*CPLA;
        C43 = sin(PLSEC);
        
        %   COORDINATES OF PRIMARY STRESS DIRECTION: C11,C12,C13
        %   COORDINATES OF SECONDARY STRESS DIRECTION: C41,C42,C43
        %   FOR A GIVEN PRIMARY STRESS DIRECTION, CALCULATE THE LIMITING
        %   VALUES OF PHI (1ST VALUE, INCREMENT, # OF INCREMENTS);
        
        [NSDP, P1ST] = PHICLC(C11, C12, C13, C41, C42, C43, CAP, PSTEP);
        if NSDP == 0
            return
        end
        
        %   COORDINATES OF AXIS ORTHOGONAL TO BOTH (C11,C12,C13) AND
        %   (C41,C42,C43): C21,C22,C23
        
        if abs(C42*C11-C41*C12) <= 1.0E-05
            AZ0 = atan2(C12,C11)+HPI;
            C21 = cos(AZ0);
            C22 = sin(AZ0);
            C23 = 0.0;
        else
            C22=(C13*C41-C43*C11)/(C42*C11-C41*C12);
            C21 = -(C13+C12*C22)/C11;
            C23 = 1.0/sqrt(1.0+C21*C21+C22*C22);
            C21 = C21*C23;
            C22 = C22*C23;
        end
        
        %   COORDINATES OF AXIS ORTHOGONAL TO BOTH (C11,C12,C13) AND
        %   (C21,C22,C23): C31,C32,C33
        
        if abs(C11*C22-C21*C12) <= 1.0E-05 || C13*C13+C23*C23 > 1.0
            AZ0 = atan2(C12,C11)+HPI;
            C31 = cos(AZ0);
            C32 = sin(AZ0);
            C33 = 0.0;
        else
            ZZ22 = 1.0-C13*C13-C23*C23;
            if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
            C33 = sqrt(ZZ22);
            C32 = C33*(C21*C13-C11*C23)/(C11*C22-C21*C12);
            C31 = -(C12*C32+C13*C33)/C11;
        end
        
        %   TEST TO SEE IF THE NEW AXES ARE OF THE PROPER HAND, AND FIX IF
        %   NECESSARY
        
        if C31*C12*C23 + C21*C32*C13 + C11*C22*C33 - C11*C23*C32 - C12*C21*C33 - C13*C22*C31 < 0.0
            C21 = -C21;
            C22 = -C22;
            C23 = -C23;
        end
        AZ5 = atan2(C12,C11)+HPI;
        C51 = cos(AZ5);
        C52 = sin(AZ5);
        
        %   FOR EACH PRIMARY STRESS DIRECTION, FIND THE PRINCIPAL STRESS
        %   COORDINATES IN THE EXTERNAL REFERENCE FRAME (NORTH, EAST,
        %   DOWN) FOR EACH SET OF STRESS DIRECTIONS (EACH PHI VALUE);
        
        for J = 1:NSDP   % DO until line 30
            C(J,ISIG,1) = C11;
            C(J,ISIG,2) = C12;
            C(J,ISIG,3) = C13;
            PROT = P1ST-double(J-1)*PSTEP;
            CE = cos(PROT);
            CO = cos(HPI+PROT);
            C21P = CO*C31+CE*C21;
            C22P = CO*C32+CE*C22;
            C23P = CO*C33+CE*C23;
            C31P = CE*C31-CO*C21;
            C32P = CE*C32-CO*C22;
            C33P = CE*C33-CO*C23;
            for M = 1:2   % DO until line 25
                if (ISIG == 1 && M == 1) || (ISIG == 3 && M == 2)
                    DCN = C21;
                    DCE = C22;
                    DCD = C23;
                else
                    DCN = C31;
                    DCE = C32;
                    DCD = C33;
                end
                CR = DCN*C11+DCE*C12+DCD*C13;
                CA = DCN*C21+DCE*C22+DCD*C23;
                CC = DCN*C31+DCE*C32+DCD*C33;
                CX1 = CR*C11+CA*C21P+CC*C31P;
                CX2 = CR*C12+CA*C22P+CC*C32P;
                CX3 = CR*C13+CA*C23P+CC*C33P;
                if CX3 < 0.0
                    CX1 = -CX1;
                    CX2 = -CX2;
                    CX3 = -CX3;
                end
                CX = NORM([CX1,CX2,CX3]);
                C(J,IC+M,:) = CX;
            end % line 25
            
            %   CALCULATE PHI VALUE, PH(J), (= RAKE OF SIGMA-2 DIRECTION IN
            %   PLANE NORMAL TO PRIMARY STRESS DIRECTION--USING RIGHTHAND RULE);
            
            PHCOS = C(J,2,1)*C51+C(J,2,2)*C52;
            if abs(PHCOS) > 1.0
                PHCOS = SIGN(1.0,PHCOS);
            end
            PH(J) = acos(PHCOS)/RAD;
            if PH(J) >= 90.05
                PH(J) = PH(J)-180.0;
            end
        end % line 30
        assert(~isempty(PH))
    end
    
    
    function [NSDP, P1ST] = PHICLC(C11,C12,C13,C41,C42,C43,CAP,PSTEP)
        %  SUBROUTINE PHICLC FINDS THE LIMITS IN PHI (P1ST = 1ST PHI VALUE,     *
        %  NSDP=# OF PHI VALUES) OVER WHICH TO SEARCH AROUND THE SECONDARY    *
        %  STRESS DIRECTION.                                                  *
        
        % DIMENSION C1(2),C2(2),C3(2);
        
        %   FOR EACH PAIR OF SIGMA-1 AND SIGMA-3 DIRECTIONS TESTED, FIND
        %   THE LIMITING PHI VALUES--THIS IS DONE BY CONSTRUCTING AND
        %   SOLVING A SECOND-ORDER POLYNOMIAL EQUATION IN ANGLE COSINE
        %   COORDINATES: C1(I),C2(I),C3(I);
        F = -C12/C11;
        G = -C13/C11;
        ED = F*C41+C42;
        if abs(ED) < 1.0E-04
            if G == 0.0
                C3(1) = CAP/C43;
                C3(2) = -C3(1);
                ZZ22=(1.0-C3(1)*C3(1))/(1.0+F*F);
                if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                C2(1) = sqrt(ZZ22);
                C2(2) = C2(1);
                for I = 1:2   % DO until line 20
                    C1(I) = C2(I)*F;
                    [C1(I),C2(I),C3(I)] = NORM(C1(I), C2(I), C3(I));
                    if C3(I) < 0.0 || (I == 2 && C1(1) == C1(2) && C2(1) == C2(2))
                        C1(I) = -C1(I);
                        C2(I) = -C2(I);
                        C3(I) = -C3(I);
                    end
                end % 20
            else
                EF = G*C41+C43;
                E = -ED/EF;
                D = CAP/EF;
                C_ = G*E+F;
                B = G*D;
                A1 = 1.0+C_*C_+E*E;
                A2 = 2.0*(B*C_+D*E);
                A3 = B*B+D*D-1.0;
                RADICAL = A2*A2-4.0*A1*A3;
                if RADICAL < -1.0E-05
                    NSDP = 0;
                    return
                elseif RADICAL <= 0.0
                    C2(1) = -A2/(A1+A1);
                    C2(2) = C2(1);
                else
                    if RADICAL < 0.0 , RADICAL = 1.0E-30; end
                    SQRAD = sqrt(RADICAL);
                    A12 = A1+A1;
                    C2(1)=(-A2+SQRAD)/A12;
                    C2(2)=(-A2-SQRAD)/A12;
                end
                for I = 1:2   % DO until line 30
                    C3(I) = D+E*C2(I);
                    C1(I) = F*C2(I)+G*C3(I);
                end % line 30
            end
        else
            E = -(G*C41+C43)/ED;
            D = CAP/ED;
            C_ = F*E+G;
            B = F*D;
            A1 = 1.0+E*E+C_*C_;
            A2 = 2.0*(B*C_+D*E);
            A3 = B*B+D*D-1.0;
            RADICAL = A2*A2-4.0*A1*A3;
            if RADICAL < -1.0E-05
                NSDP = 0;
                return
            end
            if RADICAL <= 0.0
                C3(1) = -A2/(A1+A1);
                C3(2) = C3(1);
            else
                if RADICAL < 0.0
                    RADICAL = 1.0E-30;
                end
                SQRAD = sqrt(RADICAL);
                A12 = A1+A1;
                C3(1)=(-A2+SQRAD)/A12;
                C3(2)=(-A2-SQRAD)/A12;
            end
            for M = 1:2   % DO until line 50
                C2(M) = D+E*C3(M);
                C1(M) = F*C2(M)+G*C3(M);
                [C1(M),C2(M),C3(M)] = NORM(C1(M),C2(M),C3(M));
            end % line 50
        end
        CDOT = C1(1)*C1(2) + C2(1)*C2(2) + C3(1)*C3(2);
        if abs(CDOT) >= 1.0
            CDOT = SIGN(0.999999, CDOT);
        end
        PSPR = acos(CDOT);
        NSDP = fix(PSPR/PSTEP)+1;
        P1ST = 0.5 * double(NSDP-1) * PSTEP;
        
    end
    
    %{
    function [RSMIN, NTAB, NR, NPHI] = GRDTAB(NSDP,PH,MTAB,MTABF,RFACT, RSMIN, data, params, fid_out_tmp3)
        %  SUBROUTINE GRDTAB CREATES A SET OF TABLES PRESENTING RESULTS OF    *
        %  THE INVERSION, PLOTTING R VS. PHI FOR EACH PRESCRIBED INITIAL      *
        %  PRINCIPAL STRESS DIRECTION                                         *
        
        % DIMENSION IPL(3),IAZ(3),SUMR(21,40),PH(40),C(40,3,3);
        % dimension temp(40,7), record(7);
        
        %global C                        %COMMON_DEF TWO
        %global KR RFXS RSTEP record  % COMMON_DEF FIVE
        fmt_505 = " %3d %3d  %3d %3d  %3d %3d    PHI=%6.1\n"; %"3(2(1X,I3),1X),3X,'PHI=',F6.1";
        fmt_507 = " SUMS OF MISFIT; MODELS TABULATED IN R VS. PHI (%2d x %2d)\n";
        fmt_508 = '    %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f %7.1f\n';% "4X,10F7.1"
        fmt_509 = " %4.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n";%"1X,F4.2,1X,10F7.3";
        fmt_510 = "      %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n";%"      6X,10F7.3";
        fmt_5051 = " %3d %3d  %3d %3d  %3d %3d  %7.3f %4.1f %7.3f";%"3(2(1X,I3),1X),F7.3,F4.1,f7.3";
        fmt_5055 = '%4d %4d %4d %4d %4d %4d %7.1f %7.1f %10.3f\n'; %"3(i4,i4),2f7.1,f10.3";
        for JPHI = 1:NSDP   % DO until line 100
            if JPHI == 1
                fmt_5044 = ' PRINCIPAL STRESS AXES, IN ORDER OF INCREASING PHI(%2d)   TABLE #%3d OF %3d\n\n';
                
                fprintf(fid_out_tmp3, fmt_5044 , NSDP, MTAB, MTABF);
            end
            for L = 1:3
                [IPL(L), IAZ(L)] = EULER(C(JPHI,L,1), C(JPHI,L,2), C(JPHI,L,3));
            end % [L-loop]
            fprintf(fid_out_tmp3, fmt_505, IPL(1:3), IAZ(1:3), PH(JPHI));
            
            temp(JPHI,1) = 1.0*IPL(1);
            temp(JPHI,2) = 1.0*IAZ(1);
            temp(JPHI,3) = 1.0*IPL(2);
            temp(JPHI,4) = 1.0*IAZ(2);
            temp(JPHI,5) = 1.0*IPL(3);
            temp(JPHI,6) = 1.0*IAZ(3);
            temp(JPHI,7) = PH(JPHI);
            
            SUMR(1:KR, JPHI) = 0.0;
            
            [~] = BETCLC(JPHI, SUMR,METHOD);
            
            if JPHI ~= NSDP
                continue  % next JPHI iteration;
            end
            fprintf(fid_out_tmp3,fmt_507, KR, NSDP);
            %        WRITE(*,fmt_507) KR,NSDP
            fprintf(fid_out_tmp3, fmt_508, PH(1:NSDP));
            RFIX = RFXS;
            for K = 1:KR   % DO until line 99
                SUMR(K,1:NSDP) = SUMR(K,1:NSDP)*RFACT;
                RFIX = RFIX + RSTEP;
                fprintf(fid_out_tmp3, fmt_509, RFIX, SUMR(K,1:min(10,NSDP)));
                if NSDP > 10
                    fprintf(fid_out_tmp3, fmt_510, SUMR(K,11:NSDP));
                end
                
                %   KEEP TRACK OF THE BEST MODEL SO FAR AND ITS TABLE #, ROW #, AND
                %   COLUMN #
                
                for J = 1:NSDP   % DO until line 97
                    if SUMR(K,J) < RSMIN
                        RSMIN = SUMR(K,J);
                        NTAB = MTAB;
                        NR = K;
                        NPHI = J;
                        
                        for j98 = 1:7 % do 98
                            record(j98) = temp(J,j98);
                        end % line 98
                        
                    end
                end % line 97 J-loop
                fprintf(unit3, fmt_5055, fix(record(1:6)), record(7), 0.1*(NR-1), RSMIN);
            end % line 99 [K loop]
            RFIX = RFXS;
            for K = 1:KR   % DO until line 199
                RFIX = RFIX+RSTEP;
                for JP = 1:NSDP
                    [IPL(1:3),IAZ(1:3)] = EULER(C(jp,:,1),C(jp,:,2),C(jp,:,3));
                    fprintf(unit99, fmt_5051, IPL, IAZ, PH(jp), RFIX, sumr(k,jp));
                end
            end % line 199 [K loop]
        end % line 100 [JPHI loop]
    end
    %}
    
    function [RSMIN, NTAB, NR, NPHI] = GRDTAB_new(NSDP,PH, MTAB,MTABF, RFACT, RSMIN, NTAB, NR, NPHI,fid_out_tmp3)
        %  SUBROUTINE GRDTAB CREATES A SET OF TABLES PRESENTING RESULTS OF    *
        %  THE INVERSION, PLOTTING R VS. PHI FOR EACH PRESCRIBED INITIAL      *
        %  PRINCIPAL STRESS DIRECTION                                         *
        
        % DIMENSION IPL(3),IAZ(3),SUMR(21,40),PH(40),C(40,3,3);
        % dimension temp(40,7), record(7);
        
        %global C                        %COMMON_DEF TWO
        %global KR RFXS RSTEP record  % COMMON_DEF FIVE

        fmt_5051 = " %3d %3d  %3d %3d  %3d %3d %7.3f%4.1f%7.3f\n";%"3(2(1X,I3),1X),F7.3,F4.1,f7.3";
        fmt_5055 = '%4d %4d %4d %4d %4d %4d %7.1f %7.1f %10.3f\n'; %"3(i4,i4),2f7.1,f10.3";
        fmt_5044 = '\n\n PRINCIPAL STRESS AXES, IN ORDER OF INCREASING PHI(%2d)   TABLE #%3d OF %3d\n\n';
        
        fprintf(fid_out_tmp3, fmt_5044 , NSDP, MTAB, MTABF);
        SUMR = zeros(KR, NSDP);
        for JPHI = 1:NSDP   % DO until line 100
            [IPL(1:3,1), IAZ(1:3,1)] = EULER(C(JPHI,:,1), C(JPHI,:,2), C(JPHI,:,3));
            fprintf(fid_out_tmp3,...
                " %3d %3d  %3d %3d  %3d %3d    PHI=%6.1f\n",...
                [IPL, IAZ]', PH(JPHI));
            
            temp(JPHI,1:7) = [IPL(1), IAZ(1), IPL(2), IAZ(2), IPL(3), IAZ(3), PH(JPHI)];
                        
            SUMR = BETCLC(JPHI, SUMR);
            if JPHI ~= NSDP
                continue  % next JPHI iteration;
            end
            % fmt_507 = " SUMS OF MISFIT; MODELS TABULATED IN R VS. PHI (',I2,' x ',I2,')'";
            fprintf(fid_out_tmp3,...
                "\n SUMS OF MISFIT; MODELS TABULATED IN R VS. PHI (%2d x %2d)\n\n",...
                KR, NSDP);
            %        WRITE(*,fmt_507) KR,NSDP
            % fmt_508  =  "4X,10F7.1";
            fprintf(fid_out_tmp3,'    ');
            fprintf(fid_out_tmp3,'%7.1f',PH(1: min(10, NSDP)));
            fprintf(fid_out_tmp3,'\n');
            if NSDP>10
                fprintf(fid_out_tmp3,'    ');
                fprintf(fid_out_tmp3,'%7.1f',PH(11: min(20,NSDP)));
                fprintf(fid_out_tmp3,'\n');
            end
            if NSDP>20
                fprintf(fid_out_tmp3,'    ');
                fprintf(fid_out_tmp3,'%7.1f',PH(21: min(30,NSDP)));
                fprintf(fid_out_tmp3,'\n');
            end
            if NSDP>30
                fprintf(fid_out_tmp3,'    ');
                fprintf(fid_out_tmp3,'%7.1f',PH(31: NSDP));
                fprintf(fid_out_tmp3,'\n');
            end
            RFIX = RFXS;
            for K = 1:KR   % DO until line 99
                SUMR(K,1:NSDP) = SUMR(K,1:NSDP)*RFACT;
                RFIX = RFIX + RSTEP;
                fprintf(fid_out_tmp3,...
                    " %4.2f %7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f\n",...
                    RFIX, SUMR(K,1:min(10,NSDP)));
                if NSDP > 10
                    fprintf(fid_out_tmp3,...
                        "      %7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f\n",...
                        SUMR(K, 11:NSDP));
                end
                
                %   KEEP TRACK OF THE BEST MODEL SO FAR AND ITS TABLE #, ROW #, AND
                %   COLUMN #
                
                for J = 1:NSDP   % DO until line 97
                    if SUMR(K,J) < RSMIN
                        RSMIN = SUMR(K,J);
                        NTAB = MTAB;
                        NR = K;
                        NPHI = J;
                        
                        for j98 = 1:7 % do 98
                            record(j98) = temp(J,j98);
                        end % line 98
                        
                    end
                end % line 97 J-loop
                fprintf(unit3, fmt_5055, fix(record(1:6)), record(7), 0.1*(NR-1), RSMIN);
            end % line 99 [K loop]
            RFIX = RFXS;
            for K = 1:KR   % DO until line 199
                RFIX = RFIX+RSTEP;
                for JP = 1:NSDP
                 	[IPL(1:3),IAZ(1:3)] = EULER(C(JP,:,1),C(JP,:,2),C(JP,:,3));
                    fprintf(unit99, fmt_5051, IPL(1), IAZ(1), IPL(2), IAZ(2), IPL(3), IAZ(3), PH(JP), RFIX, SUMR(K,JP));
                end
            end % line 199 [K loop]
        end % line 100 [JPHI loop]
    end
    
    
    
    function [SUMR] = BETCLC(JPHI, SUMR)
        %  SUBROUTINE BETCLC CALCULATES THE MATRIX BETA (B(I,J)), RELATING    *
        %  THE PRINCIPAL STRESS AND FAULT PLANE COORDINATE AXES               *
        
        % LOGICAL KFPQ
        % DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),B(3,3),SUMR(21,40),C(40,3,3);
        % DIMENSION record(7);
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        % global C                        %COMMON_DEF TWO
        %global KFP % COMMON_DEF FIVE
        % global METHOD           % COMMON_DEF SEVEN
        
        for I = 1:height(data)   % DO until line 95
            for JJ=1:3% 90 JJ=1,3
                B(1:3,JJ) = [CN1(I,1)*C(JPHI,JJ,1) + CE1(I,1)*C(JPHI,JJ,2) + CD1(I,1)*C(JPHI,JJ,3);...
                             CN2(I)*C(JPHI,JJ,1) + CE2(I)*C(JPHI,JJ,2) + CD2(I)*C(JPHI,JJ,3);...
                             CN1(I,2)*C(JPHI,JJ,1) + CE1(I,2)*C(JPHI,JJ,2) + CD1(I,2)*C(JPHI,JJ,3)];
            end
            %   SET KFPQ = true IF THE FAULT PLANE IS KNOWN, =false IF IT IS
            %   UNKNOWN
            KFPQ = I <= params.KFP;
            
            if params.METHOD == 1
                [SUMR] = XPROTP(I, JPHI, B, KFPQ, SUMR);
            elseif params.METHOD == 2
                [SUMR] = XPROTA(I, JPHI, B, KFPQ, SUMR);
            else
                [SUMR] = XPROTE(I, JPHI, B, KFPQ, SUMR);
            end
        end % line 95
    end
    
    function [SUMR] = XPROTP(I,JPHI,B,KFPQ,SUMR)
        %  SUBROUTINE XPROTP CALCULATES THE ROTATION MISFITS FOR BOTH NODAL   *
        %  PLANES ABOUT THE AXES OF THE FAULT PLANE GEOMETRY (FPG, OR THE     *
        %  PRIMED AXES)--FOR THE POLE ROTATION METHOD                         *
        
        % LOGICAL KFPQ
        % DIMENSION B(3,3),ROTM1(21,2),SUMR(21,40),CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),DIP(470,2),Q(470);
        % DIMENSION record(7);
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        
        % global AZ DIP Q                 %COMMON_DEF THREE
        %global KFP KR RFXS RSTEP record  % COMMON_DEF FIVE
        
        
        %   JK = NODAL PLANE INDEX
        %   IK = INDEX OF FPG AXIS WHICH IS THE POLE OF THE NODAL PLANE
        %   LK = INDEX OF FPG AXIS WHICH IS THE SLIP DIRECTION ON THE
        %      NODAL PLANE
        
        JK = 0;
        B12B32 = B(1,2)*B(3,2);
        B13B33 = B(1,3)*B(3,3);
        for IK = 1 :2:3   % DO until line 120
            JK = JK+1;
            if JK == 2 && KFPQ
                continue;
            end
            LK = 4-IK;
            B13B23 = B(IK,3)*B(2,3);
            B12B22 = B(IK,2)*B(2,2);
            
            %   FOR EACH SET OF STRESS DIRECTIONS, B(I,J), TEST ALL VALUES OF R (= RFIX);
            
            RFIX = RFXS;
            for K = 1:KR   % DO until line 110
                RFIX = RFIX+RSTEP;
                
                %   FOR AXISYMMETRIC STRESSES FIND ROTATIONS USING SUBROUTINE AXSYMP;
                %   FOR NON-AXISYMMETRIC STRESSES, FIND ROTATION ABOUT THE POLE
                
                if RFIX < 0.001 || RFIX > 0.999
                    [ROTM] = axsymp(I,LK,B,RFIX, Q);
                else
                    BNUM = B13B23+RFIX*B12B22;
                    ROT = atan(BNUM / (RFIX*B12B32+B13B33));
                    [ROT] = xpchkp(I,IK,LK,B,ROT,RFIX,Q);
                    ROTM = abs(ROT);
                end
                ROTM1(K,JK) = ROTM;
                if KFPQ || JK == 2
                    ROTM = ROTM1(K,1);
                    if ~KFPQ && ROTM1(K,2) < ROTM
                        ROTM = ROTM1(K,2);
                    end
                    
                    %   SUM MISFITS FOR ALL DATA IN ARRAY SUMR(J,K)--APPLY RELATIVE
                    %   WEIGHTS (abs(Q(I)) HERE
                    
                    SUMR(K,JPHI) = SUMR(K,JPHI) + ROTM * abs(Q(I));
                end
            end % line 110
        end % line 120
    end
    
    function [ROT] = xpchkp(I,IK,LK,B,ROT,RFIX,Q)
        %  SUBROUTINE XPCHKP TESTS THE ROTATION FOUND IN SUBROUTINE XPROTP    *
        %  TO ENSURE THAT IT RESULTS IN THE CORRECT SENSE OF SLIP ON THE      *
        %  FAULT PLANE                                                        *
        
        % DIMENSION B(3,3),AZ(470,2),DIP(470,2),Q(470);
        
        %global AZ DIP Q                 %COMMON_DEF THREE
        
        %   TEST ROTATIONS ABOUT THE POLE OF THE FAULT PLANE--FIND ROTATED
        %   COORDINATES
        
        CROT = cos(ROT);
        SROT = sin(ROT);
        BNK2 = CROT*B(LK,2)+SROT*B(2,2);
        BNK3 = CROT*B(LK,3)+SROT*B(2,3);
        
        %   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF CORRECT,
        %   THEN THE FOLLOWING CONDITION IS FALSE; IF THE SENSE OF SLIP IS
        %   INCORRECT, FIND THE NEW ROTATION
        
        if Q(I)*(RFIX*B(IK,2)*BNK2+B(IK,3)*BNK3) > 0.0
            ROT = ROT - (PI * sign(ROT));
        end
    end
    
    function [ROTM] = axsymp(I,LK,B,RFIX, Q)
        %  SUBROUTINE AXSYMP CALCULATES THE ROTATION MISFITS BETWEEN OBSER-   *
        %  VATIONS AND AXISYMMETRIC STRESS MODELS--FOR THE POLE ROTATION      *
        %  METHOD                                                             *
        
        % DIMENSION B(3,3),C(3,3),AZ(470,2),DIP(470,2),Q(470);
        %global Q                 %COMMON_DEF THREE
        
        %   KS = INDEX OF UNIQUE PRINCIPAL STRESS
        
        if RFIX < 0.001
            KS = 3;
        else
            KS = 1;
        end
        
        %   FIND ANGLE (COSINE) NEEDED TO ROTATE THE B AXIS TO AN ORIENTATION
        %   PERPENDICULAR TO THE UNIQUE PRINCIPAL STRESS AXIS (DO THIS ONLY
        %   IF THE UNIQUE STRESS IS IN THE PROPER QUADRANT OF THE FOCAL
        %   MECHANISM; OTHERWISE THE CORRECT ROTATION IS THE SUPPLEMENT OF
        %   THE ABOVE ANGLE);
        
        ROTM = abs(atan(B(2,KS) / B(LK,KS)));
        if Q(I)*(RFIX*B(1,2)*B(3,2)+B(1,3)*B(3,3)) > 0.0
            ROTM = PI-ROTM;
        end
    end
    
    
    function [SUMR] = XPROTA(I, JPHI, B, KFPQ, SUMR)
        %  SUBROUTINE XPROTA CALCULATES THE ROTATION MISFITS FOR BOTH NODAL   *
        %  PLANES ABOUT THE AXES OF THE FAULT PLANE GEOMETRY (FPG, OR THE     *
        %  PRIMED AXES)--FOR THE APPROXIMATE METHOD                           *
        %                                                                     *
        
        % LOGICAL KFPQ
        % DIMENSION B(3,3),ROT(3),ROTM1(21,2),SUMR(21,40),CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),DIP(470,2),Q(470);
        % DIMENSION record(7);
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        % global AZ DIP Q                 %COMMON_DEF THREE
        % global KFP KR RFXS RSTEP record  % COMMON_DEF FIVE
        
        %   JK = NODAL PLANE INDEX
        %   IK = INDEX OF FPG AXIS WHICH IS THE POLE OF THE NODAL PLANE
        %   LK = INDEX OF FPG AXIS WHICH IS THE SLIP DIRECTION ON THE
        %      NODAL PLANE
        JK = 0;
        
        % let B be [a, b, c; d, e, f; g, h, i];
        %Bs = B([1,2],[2,3]) .* B([3,2],[2,3]);  % where Bs(1,1) = B12B32, Bs(1,2)=B13B33, Bs(2,1)=B222,Bs(2,2)=B232
        B222 = B(2,2).^2; ee = B222;
        B232 = B(2,3).^2; ff = B232;
        B12B32 = B(1,2).*B(3,2); bh = B12B32;
        B13B33 = B(1,3).*B(3,3); ci = B13B33;
        bs = [ee, ff, bh, ci];
        
        bb = B(1,2).^2;
        cc = B(1,3).^2;
        cf = B(1,3) .* B(2,3);
        be = B(1,2) .* B(2,2);
        eh = B(2,2) .* B(3,2);
        fi = B(2,3) .* B(3,3);
        hh = B(3,2).^2;
        ii = B(3,3).^2;
        
        ROT = nan(3,1);
        ROTM1 = nan(KR, 2);
        
        RFIX_all = (RFXS + (1:KR).* RSTEP)';
        do_xpchka = RFIX_all >= 0.001 & RFIX_all <=0.999; 
            
        % nect loop executes with following values:
        %    IK, JK   LK
        %    1   1    3
        %    3   2    1
        if KFPQ
            IKs = 1;
            JKs = 1;
            LKs = 3;
        else
            IKs = [1,3];
            JKs = [1,2];
            LKs = [3,1];
        end
        
        for n = 1:length(IKs)   % DO until line 120
            IK = IKs(n);
            JK = JKs(n);
            LK = LKs(n);
            if n==1
                bt = [bb,cc,cf,be, eh,fi];
            else
                bt = [hh,ii,fi,eh,be,cf];
            end
            B122 = B(IK,2).^2;   %bt(1)
            B132 = B(IK,3).^2;   %bt(2)
            B13B23 = B(IK,3) * B(2,3); %bt(3)
            B12B22 = B(IK,2) * B(2,2); %bt(4)
            B22B32 = B(2,2) * B(LK,2); %bt(5)
            B23B33 = B(2,3) * B(LK,3); %bt(6)
            
            %   FOR EACH SET OF STRESS DIRECTIONS, B(I,J), TEST ALL VALUES OF
            %   R (= RFIX);
            
            % RFIX = RFXS;
            do_axsyma = ~do_xpchka & JK==1;
            all_bnum = bt(3) + RFIX_all*bt(4);
            all_rot=zeros(KR,3);
            all_rot(1:KR,IK) = atan(all_bnum./(RFIX_all .* bh + ci));
            all_rot(1:KR,2) = atan(all_bnum./(RFIX_all .* bt(5) + bt(6)));
            
            rk = (RFIX_all .* (bt(1)-ee) + bt(2) - ff) ./ all_bnum;
            srk2 = sqrt(0.25 - 1.0 ./ (4.0 + rk.^2));
            all_rot(1:KR,LK) = -abs(acos(sqrt(0.5 + srk2))) .* sign(rk);
            xpchka_rotms = min(abs(XPCHKA_new(I, IK, LK, B, all_rot, RFIX_all)),[],2);
            for K = 1:KR
                %   FOR AXISYMMETRIC STRESSES FIND ROTATIONS USING SUBROUTINE AXSYMA;
                %   FOR NON-AXISYMMETRIC STRESSES FIND THE SMALLEST OF THE ROTATIONS
                %   ABOUT THE 3 FPG AXES
                if do_axsyma(K)
                    ROTM = AXSYMA(I, B, RFIX_all(K));
                elseif do_xpchka(K)
                    ROTM = xpchka_rotms(K);
                else
                    ROTM = PI2;
                end
                ROTM1(K,JK) = ROTM;
                if KFPQ || JK == 2
                    ROTM = ROTM1(K,1);
                    if ~KFPQ && ROTM1(K,2) < ROTM
                        ROTM = ROTM1(K,2);
                    end
                    
                    %   SUM MISFITS FOR ALL DATA IN ARRAY SUMR(J,K)--APPLY RELATIVE
                    %   WEIGHTS (abs(Q(I)) HERE
                    
                    SUMR(K,JPHI) = SUMR(K,JPHI) + ROTM * abs(Q(I));
                end
            end % line 110 [K-loop]
        end % line 120 [IK loop]

    end
    
    
    function [ROT] = XPCHKA_new(I,IK,LK,B,ROT,RFIX)
        %  SUBROUTINE XPCHKA TESTS THE ROTATIONS FOUND IN SUBROUTINE XPROTA   *
        %  TO ENSURE THAT THEY RESULT IN THE CORRECT SENSE OF SLIP ON THE     *
        %  FAULT PLANE--FOR THE APPROXIMATE AND EXACT METHODS                 *
        
        % DIMENSION ROT(3),B(3,3),AZ(470,2),DIP(470,2),Q(470);
        % global AZ DIP Q                 %COMMON_DEF THREE
        
        %   TEST ROTATIONS ABOUT THE POLE AND SLIP DIRECTION (FPG);
        for MK = [1, 3]   % DO until line 80
            if MK == IK
                F = 1.0;
            else
                F = -1.0;
            end
            NK = 4-MK;
            
            %   FIND ROTATED COORDINATES
            
            CROT = cos(ROT(:,MK));
            SROT = sin(ROT(:,MK));
            BNK2 = CROT*B(NK,2) + F.*SROT.*B(2,2);
            BNK3 = CROT*B(NK,3) + F.*SROT.*B(2,3);
            %
            %   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF CORRECT,
            %   THEN THE FOLLOWING CONDITION IS FALSE
            %
            testvala = Q(I).*(RFIX(:).*B(MK,2).*BNK2 + B(MK,3).*BNK3) > 0;
            if any(testvala)
                
                %   FIND NEW ROTATION ABOUT POLE OR SLIP DIRECTION
                
                if IK ~= NK
                    ROT(testvala,MK) = ROT(testvala,MK) - PI * sign(ROT(testvala,MK));
                else
                    ROT(testvala,MK) = ROT(testvala,MK) - HPI * sign(ROT(testvala,MK));
                    SROTA = SROT(testvala);
                    SROT = -abs(CROT(testvala)) .* sign(SROTA);
                    CROT = abs(SROTA); %changes size of CROT
                    BNK2 = CROT.*B(NK,2) + F.*SROT.*B(2,2);
                    BNK3 = CROT.*B(NK,3) + F.*SROT.*B(2,3);
                    
                    % now, BNK2, BNK3 are of size A (A<=size(ROT))
                    % testvalg is of size B (B <= A)
                    % to recompose, the positional index is required
                    tva_idx = find(testvala);
                    testvalg = Q(I).*(RFIX(testvala) .* B(MK,2).*BNK2 + B(MK,3).*BNK3) > 0.0;
                    these_ROT = ROT(tva_idx(testvalg),MK);
                    ROT(tva_idx(testvalg),MK) = these_ROT - PI .* sign(these_ROT);
                end
            end
        end % line 80
        F = -F;
        ROTM = min(abs(ROT(:,[LK,IK])),[],2);
        
        %   TEST ROTATIONS ABOUT THE B AXIS (FPG);
        testvalb = ROTM >= abs(ROT(:,2));
        if any(testvalb)
            %   FIND ROTATED COORDINATES
            
            CROT = cos(ROT(testvalb,2));
            SROT = sin(ROT(testvalb,2));
            B12 = CROT.*B(1,2) - F.*SROT.*B(3,2);
            B13 = CROT.*B(1,3) - F.*SROT.*B(3,3);
            B32 = CROT.*B(3,2) + F.*SROT.*B(1,2);
            B33 = CROT.*B(3,3) + F.*SROT.*B(1,3);
            
            %   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF INCORRECT,
            %   NO OTHER ROTATIONS ABOUT THIS AXIS ARE ADMISSIBLE
            tvb_idx = find(testvalb);
            testvalc = Q(I).*(RFIX(testvalb).*B12.*B32 + B13.*B33) > 0.0;
            ROT(tvb_idx(testvalc),2) = PI2;
        end
    end
    
    function [ROT] = XPCHKA(I,IK,LK,B,ROT,RFIX)
        %  SUBROUTINE XPCHKA TESTS THE ROTATIONS FOUND IN SUBROUTINE XPROTA   *
        %  TO ENSURE THAT THEY RESULT IN THE CORRECT SENSE OF SLIP ON THE     *
        %  FAULT PLANE--FOR THE APPROXIMATE AND EXACT METHODS                 *
        
        % DIMENSION ROT(3),B(3,3),AZ(470,2),DIP(470,2),Q(470);
        % global AZ DIP Q                 %COMMON_DEF THREE
               
        %   TEST ROTATIONS ABOUT THE POLE AND SLIP DIRECTION (FPG);
        for MK = [1, 3]   % DO until line 80
            if MK == IK
                F = 1.0;
            else
                F = -1.0;
            end
            NK = 4-MK;
            
            %   FIND ROTATED COORDINATES
            
            CROT = cos(ROT(MK));
            SROT = sin(ROT(MK));
            BNK2 = CROT*B(NK,2) + F.*SROT.*B(2,2);
            BNK3 = CROT*B(NK,3) + F.*SROT.*B(2,3);
            %
            %   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF CORRECT,
            %   THEN THE FOLLOWING CONDITION IS FALSE
            %
            testval = Q(I).*(RFIX.*B(MK,2).*BNK2 + B(MK,3).*BNK3) > 0.0;
            if testval
                
                %   FIND NEW ROTATION ABOUT POLE OR SLIP DIRECTION
                
                if IK ~= NK
                    ROT(MK) = ROT(MK) - PI * sign(ROT(MK));
                else
                    ROT(MK) = ROT(MK) - HPI * sign(ROT(MK));
                    SROTA = SROT;
                    SROT = -abs(CROT) * sign(SROTA);
                    CROT = abs(SROTA);
                    BNK2 = CROT*B(NK,2) + F*SROT*B(2,2);
                    BNK3 = CROT*B(NK,3) + F*SROT*B(2,3);
                    testvalg = Q(I)*(RFIX*B(MK,2)*BNK2+B(MK,3)*BNK3) > 0.0;
                    if Q(I)*(RFIX*B(MK,2)*BNK2+B(MK,3)*BNK3) > 0.0
                        ROT(MK) = ROT(MK) - PI * sign(ROT(MK));
                    end
                end
            end
        end % line 80
        
        F = -F;
        ROTM = min(abs(ROT([LK,IK])));
        
        %   TEST ROTATIONS ABOUT THE B AXIS (FPG);
        
        if ROTM >= abs(ROT(2))
            
            %   FIND ROTATED COORDINATES
            
            CROT = cos(ROT(2));
            SROT = sin(ROT(2));
            B12 = CROT*B(1,2) - F*SROT*B(3,2);
            B13 = CROT*B(1,3) - F*SROT*B(3,3);
            B32 = CROT*B(3,2) + F*SROT*B(1,2);
            B33 = CROT*B(3,3) + F*SROT*B(1,3);
            
            %   TEST FOR SENSE OF SLIP ON THE ROTATED FAULT PLANE--IF INCORRECT,
            %   NO OTHER ROTATIONS ABOUT THIS AXIS ARE ADMISSIBLE
            
            if Q(I)*(RFIX*B12*B32 + B13*B33) > 0.0
                ROT(2) = PI2;
            end
        end
    end
    
    function [ROTM] = AXSYMA(I,B,RFIX)
        %  SUBROUTINE AXSYMA CALCULATES THE ROTATION MISFITS BETWEEN OBSER-   *
        %  VATIONS AND AXISYMMETRIC STRESS MODELS--FOR THE APPROXIMATE        *
        %  METHOD                                                             *
        
        % DIMENSION B(3,3),AZ(470,2),DIP(470,2),Q(470);
        % global AZ DIP %Q                 %COMMON_DEF THREE
        
        %   KS = INDEX OF UNIQUE PRINCIPAL STRESS
        
        if RFIX < 0.001
            KS = 3;
        else
            KS = 1;
        end
        
        %   FIND ANGLE (COSINE) NEEDED TO ROTATE THE B AXIS TO AN ORIENTATION
        %   PERPENDICULAR TO THE UNIQUE PRINCIPAL STRESS AXIS (DO THIS ONLY
        %   IF THE UNIQUE STRESS IS IN THE PROPER QUADRANT OF THE FOCAL
        %   MECHANISM; OTHERWISE THE CORRECT ROTATION IS THE SUPPLEMENT OF
        %   THE ABOVE ANGLE);
        
        ROT1 = abs(atan(B(2,KS)/B(3,KS)));
        ROT3 = abs(atan(B(2,KS)/B(1,KS)));
        if Q(I)*(RFIX*B(1,2)*B(3,2)+B(1,3)*B(3,3)) > 0.0
            ROT1 = PI-ROT1;
            ROT3 = PI-ROT3;
        end
        if ROT1 > ROT3
            ROTM = ROT3;
        else
            ROTM = ROT1;
        end
    end
    
    
    function [SUMR] = XPROTE(I, JPHI, B, KFPQ, SUMR)
        %  SUBROUTINE XPROTE CALCULATES THE ROTATION MISFITS FOR BOTH NODAL   *
        %  PLANES ABOUT THE AXES OF THE FAULT PLANE GEOMETRY (FPG, OR THE     *
        %  PRIMED AXES)--FOR THE EXACT METHOD                                 *
        
        % LOGICAL KFPQ,SSLP,PASS1
        % DIMENSION B(3,3),ROT(3),ROTM1(21,2),SUMR(21,40),CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),AZ(470,2),DIP(470,2),Q(470);
        % dimension record(7);
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        % global AZ DIP %Q                 %COMMON_DEF THREE
        %global KFP KR RFXS RSTEP record  % COMMON_DEF FIVE
        %global SSLP PASS1       % COMMON_DEF SIX
        
        %   JK = NODAL PLANE INDEX
        %   IK = INDEX OF FPG AXIS WHICH IS THE POLE OF THE NODAL PLANE
        %   LK = INDEX OF FPG AXIS WHICH IS THE SLIP DIRECTION ON THE
        %      NODAL PLANE
        
        JK = 0;
        B222 = B(2,2)*B(2,2);
        B232 = B(2,3)*B(2,3);
        B12B32 = B(1,2)*B(3,2);
        B13B33 = B(1,3)*B(3,3);
        for IK = [1,3]   % DO until line 120
            JK = JK+1;
            if JK == 2 && KFPQ
                continue;
            end
            LK = 4-IK;
            B122 = B(IK,2)*B(IK,2);
            B132 = B(IK,3)*B(IK,3);
            B13B23 = B(IK,3)*B(2,3);
            B12B22 = B(IK,2)*B(2,2);
            B22B32 = B(2,2)*B(LK,2);
            B23B33 = B(2,3)*B(LK,3);
            
            %   FOR EACH SET OF STRESS DIRECTIONS, B(I,J), TEST ALL VALUES OF R (= RFIX);
            
            RFIX = RFXS;
            for K = 1:KR   % DO until line 110
                RFIX = RFIX+RSTEP;
                
                %   FOR AXISYMMETRIC STRESSES FIND ROTATIONS USING SUBROUTINE AXSYME
                
                if RFIX < 0.001 || RFIX > 0.999
                    if JK == 1
                        ROTM = AXSYME(I,B,RFIX);
                    else
                        ROTM = PI2;
                    end
                else
                    %   FOR NON-AXISYMMETRIC STRESSES, FIND ROTATIONS ABOUT FPG AXES
                    
                    BNUM = B13B23+RFIX*B12B22;
                    ROT(IK) = atan(BNUM/(RFIX*B12B32+B13B33));
                    ROT(2) = atan(BNUM/(RFIX*B22B32+B23B33));
                    RK = (RFIX*(B122-B222)+B132-B232)/BNUM;
                    SRK2 = sqrt(0.25-1.0/(4.0+RK*RK));
                    ROT(LK) = acos(sqrt(0.5+SRK2));
                    ROT(LK) = -SIGN(ROT(LK),RK);
                    
                    %   IF THE SENSE OF SLIP ON THE OBSERVED FAULT PLANE IS "CORRECT"
                    %   FOR THE STRESS MODEL IN QUESTION, THEN SET PASS1 = true--IN
                    %   WHICH CASE THE SENSE OF SLIP WILL NOT BE CHECKED UNTIL THE SMALL-
                    %   EST ROTATION IS FOUND (IF IT IS THEN INCORRECT, RETURN TO THIS
                    %   POINT AND REPEAT, THIS TIME CHECKING SENSE OF SLIP AS SUCCESSIVE
                    %   ROTATIONS ARE CALCULATED, AND ADMITTING ONLY CORRECT ONES).  IF
                    %   THE SENSE OF SLIP ON THE OBSERVED FAULT PLANE IS "INCORRECT", THEN
                    %   SET PASS1 = false AND CHECK THE SENSE OF SLIP ALL ALONG THE PATH
                    %   TO THE SMALLEST ROTATION.  IN A SENSE, THIS APPROACH IS GAMBLING
                    %   THAT THE OBSERVED CONDITION PREDICTS THE SENSE OF SLIP ON THE
                    %   CLOSEST SOLUTION, THEREBY SAVING COMPUTATIONS WHERE POSSIBLE.
                    
                    PASS1 = Q(I)*(RFIX*B12B32+B13B33) <= 0.0;
                    if ~PASS1
                        [~] = XPCHKA(I,IK,LK,JK,B,ROT,RFIX,Q);
                    end
                    
                    %   FIND THE SMALLEST OF THE ROTATIONS ABOUT THE 3 FPG AXES
                    while true
                        MX = 1;
                        ROTM = abs(ROT(1));
                        for L = 2:3   % DO until line 100
                            if abs(ROT(L)) < ROTM
                                MX = L;
                                ROTM = abs(ROT(L));
                            end
                        end % line 100
                        if JK == 2 , MX = 4-MX; end
                        if MX == 3
                            AZI = rem(data.AZ(I,3-JK)+270.0,360.0)*RAD;
                            PL=(90.0-data.DIP(I,3-JK))*RAD;
                        elseif MX == 2
                            AZI = rem(atan2(CE2(I),CN2(I))+PI2,PI2);
                            PL = asin(CD2(I));
                        else
                            AZI = rem(data.AZ(I,JK)+270.0,360.0)*RAD;
                            PL=(90.0-data.DIP(I,JK))*RAD;
                        end
                        
                        %   FIND THE SMALLEST ROTATION ABOUT ALL AXES (OF GENERAL ORIENTATION);
                        %
                        [ROTM] = AXRFN(I,JK,JPHI,B,RFIX,AZI,PL,ROTM, data);
                        
                        %   IF THE SMALLEST ROTATION FOUND IN THE FIRST PASS YIELDS THE
                        %   WRONG SENSE OF SLIP ON THE ROTATED FAULT PLANE, START OVER,
                        %   THIS TIME KEEPING TRACK OF THE SENSE OF SLIP (AND NOT ADMIT-
                        %   TING SOLUTIONS YIELDING THE INCORRECT SENSE OF SLIP)--HOPE-
                        %   FULLY, THIS PATH IS TAKEN INFREQUENTLY
                        
                        if ~SSLP && PASS1
                            [~] = XPCHKA(I,IK,LK,JK,B,ROT,RFIX,Q);
                            PASS1 = false;
                            continue
                        else
                            break
                        end
                    end
                end
                
                % >> **** 105 TAG HERE *** <<
                ROTM1(K,JK) = ROTM;
                if KFPQ || JK == 2
                    ROTM = ROTM1(K,1);
                    if ~KFPQ && ROTM1(K,2) < ROTM
                        ROTM = ROTM1(K,2);
                    end
                    
                    %   SUM MISFITS FOR ALL DATA IN ARRAY SUMR(J,K)--APPLY RELATIVE
                    %   WEIGHTS (abs(Q(I)) HERE
                    
                    SUMR(K,JPHI) = SUMR(K,JPHI) + ROTM * abs(Q(I));
                end
            end % line 110 [K loop]
        end % line 120 [IK loop]
    end
    
    function [ROTM] = AXSYME(I,B,RFIX)
        %  SUBROUTINE AXSYME CALCULATES THE ROTATION MISFITS BETWEEN OBSER-   *
        %  VATIONS AND AXISYMMETRIC STRESS MODELS--FOR THE EXACT METHOD       *
        
        % DIMENSION B(3,3),AZ(470,2),DIP(470,2),Q(470);
        % global AZ DIP Q                 %COMMON_DEF THREE
        
        %   KS = INDEX OF UNIQUE PRINCIPAL STRESS
        
        if RFIX < 0.001
            KS = 3;
        else
            KS = 1;
        end
        
        %   FIND ANGLE (COSINE) NEEDED TO ROTATE THE B AXIS TO AN ORIENTATION
        %   PERPENDICULAR TO THE UNIQUE PRINCIPAL STRESS AXIS (DO THIS ONLY
        %   IF THE UNIQUE STRESS IS IN THE PROPER QUADRANT OF THE FOCAL
        %   MECHANISM; OTHERWISE ROTATE THE POLE OR SLIP DIRECTION TO ALIGN-
        %   MENT WITH THE UNIQUE STRESS);
        
        if Q(I)*(RFIX*B(1,2)*B(3,2)+B(1,3)*B(3,3)) <= 0.0
            ZZ22 = 1.0-B(2,KS)*B(2,KS);
            if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
            ROTM = sqrt(ZZ22);
        else
            ROTM = abs(B(1,KS));
            if abs(B(3,KS)) > ROTM
                ROTM = abs(B(3,KS));
            end
        end
        if ROTM > 1.0 , ROTM = SIGN(1.0,ROTM); end
        ROTM = acos(ROTM);
    end
    
    function [RAX] = AXRFN(I,KJ,JPHI,B,RFIX,AZAX,PLAX,RAX, data)
        %  SUBROUTINE AXRFN LOCATES THE AXIS OF THE SMALLEST ROTATION THAT    *
        %  ACHIEVES A MATCH BETWEEN THE SHEAR STRESS AND SLIP DIRECTIONS ON   *
        %  ONE NODAL PLANE                                                    *
        
        %DIMENSION B(3,3),PHI(2),PHIA(2),DZZ(2);
        %LOGICAL SRF,SSLP,PASS1
        global A1 A2 A3 A4 A5 A6        % COMMON_DEF FOUR
        %global SSLP PASS1       % COMMON_DEF SIX
        PINC1 = 0.08726646;  % data section
        PINC2 = 0.21816615; % data section
        
        %   KJ = NODAL PLANE INDEX
        %   K = INDEX OF THE POLE TO THE NODAL PLANE (FAULT PLANE COORD'S);
        %   L = INDEX OF THE SLIP DIRECTION, OR THE POLE TO THE AUX. PLANE
        
        K = 1;
        if KJ == 2 , K = 3; end
        L = 4-K;
        RF=(RFIX-1.0)/RFIX;
        
        %   SRF = true ON THE FINAL PASS, WHEN THE SIGN OF THE ROTATION
        %   MUST BE FOUND (SO THAT THE SENSE OF SLIP ON THE ROTATED FAULT
        %   PLANE CAN BE CHECKED); SRF = false ON SOME INITIAL PASSES,
        %   WHEN ONLY THE MAGNITUDE OF THE ROTATION MUST BE FOUND
        
        SRF = ~PASS1;
        
        %   FIND COEFFICIENTS
        
        A1 = B(K,1)*B(K,1)+RF*B(K,3)*B(K,3);
        A2 = B(2,1)*B(2,1)+RF*B(2,3)*B(2,3);
        A3 = B(L,1)*B(L,1)+RF*B(L,3)*B(L,3);
        A4 = B(2,1)*B(L,1)+RF*B(2,3)*B(L,3);
        A5 = B(K,1)*B(L,1)+RF*B(K,3)*B(L,3);
        A6 = B(K,1)*B(2,1)+RF*B(K,3)*B(2,3);
        
        %   TEST "OCTAHEDRAL" AXIS (EQUIANGULAR FROM THE THREE PRIMED
        %   COORDINATE AXES--OF THE FAULT PLANE GEOMETRY), TO SEE IF
        %   ROTATIONS ABOUT ANY OF THESE ARE SMALLER THAN THOSE ABOUT
        %   THE FPG (SUBROUTINE XPROTE)--AND SO OFFER A BETTER STARTING
        %   POSITION FOR FINDING THE BEST AXIS
        
        [BAZ,BPL,BR] = octrot(I,KJ,B,SRF, data);
        
        %   TAKE THE SMALLEST OF ALL AXES TESTED SO FAR (IN SUBROUTINES
        %   XPROTE AND OCTROT);
        
        if BR <= RAX
            AZAX = BAZ;
            PLAX = BPL;
            RAX = BR;
        end
        CR = cos(RAX);
        PHI(1) = AZAX;
        PHI(2) = PLAX;
        PINC = PINC1;
        NV = 0;
        
        %   REFINE ROTATION AXIS BY MOVING DOWN THE PATH OF STEEPEST
        %   DESCENT IN SUCCESSIVE STEPS
        
        for II = 1:100   % DO until line 105
            PHIA(1) = PHI(1);
            PHIA(2) = PHI(2);
            CRA = CR;
            
            %   CONSIDER 2 NEW AXES IN THE NEIGHBORHOOD OF THE CURRENT ONE--
            %   FIND THE SMALLEST ROTATION ABOUT EACH
            
            for JI = 1:2   % labeled 90, DO until line 95
                KI = 3-JI;
                PHI(KI) = PHIA(KI);
                PHI(JI) = PHIA(JI)+PINC;
                [C1,C2,C3] = INVEUL(I,PHI(1),PHI(2),KJ);
                CRZ = gernrot(I,KJ,B,RFIX,C1,C2,C3,SRF);
                DZZ(JI) = CRZ-CRA;
            end % line 95    [JI loop]
            
            %   IF A LOCAL SLOPE CANNOT BE FOUND, TRY A BIGGER STEP; IF TOO
            %   BIG A STEP, GET OUT OF LOOP
            
            if DZZ(1) == 0.0 && DZZ(2) == 0.0
                if PINC < PINC2
                    PINC = 1.2*PINC;
                    continue
                else
                    PHI(1) = PHIA(1);
                    PHI(2) = PHIA(2);
                    CR = CRA;
                    break
                end
            else
                
                %   FIND A NEW AXIS DOWN-SLOPE FROM THE CURRENT ONE
                
                PSI = atan2(DZZ(2),DZZ(1));
                PHI(1) = PHIA(1)+cos(PSI)*PINC;
                if PHI(1) < 0.0 || PHI(1) >= PI2
                    PHI(1) = rem(PHI(1)+PI2,PI2);
                end
                PHI(2) = PHIA(2)+sin(PSI)*PINC;
                if PHI(2) < 0.0 || PHI(2) > HPI
                    PHI(2) = -PHI(2);
                    if PHI(2) < 0.0
                        PHI(2) = PI+PHI(2);
                    end
                    PHI(1) = rem(PHI(1)+PI,PI2);
                end
                [C1, C2, C3] = INVEUL(I,PHI(1),PHI(2),KJ);
                CR = gernrot(I,KJ,B,RFIX,C1,C2,C3,SRF);
                
                %   IF THE MAGNITUDE OF ROTATION HAS INCREASED FROM THE PREVIOUS
                %   STEP, REDUCE THE SIZE OF THE STEP AND TRY AGAIN--STOP AFTER
                %   4 REDUCTIONS
                
                if CR <= CRA
                    NV = NV+1;
                    if NV == 4
                        PHI(1) = PHIA(1);
                        PHI(2) = PHIA(2);
                        CR = CRA;
                        break
                    else
                        PINC = 0.5*PINC;
                        continue
                    end
                end
            end
        end % line 105 [II loop]
        
        %   SET SRF = true AND CHECK TO ENSURE PROPER SENSE OF SLIP ON
        %   THE FINAL SOLUTION
        
        SRF = true;
        [C1, C2, C3] = INVEUL(I,PHI(1),PHI(2),KJ, data);
        CR = gernrot(I,KJ,B,RFIX,C1,C2,C3,SRF,Q);
        
        %   AT THE END, COMPARE THE BEST ROTATION TO THE ANGLE NEEDED TO
        %   SUPERIMPOSE THE POLE TO THE NODAL PLANE AND EACH PRINCIPAL
        %   STRESS AXIS (ADMISSIBLE SOLUTIONS); SELECT THE SMALLEST OF
        %   THESE.  THIS IS NECESSARY ONLY FOR VERY ERRATIC DATA FOR
        %   WHICH IT IS DIFFICULT TO FIND THE OPTIMUM AXIS OWING TO THE
        %   SENSE-OF-SLIP CONSTRAINT
        
        if ~PASS1
            K = 1;
            if KJ == 2 , K = 3; end
            for L = 1:3   % DO until line 110
                if abs(B(K,L)) > CR
                    CR = abs(B(K,L));
                end
            end % line 110
        end
        if CR > 1.0 , CR = SIGN(1.0,CR); end
        RAX = acos(CR);
    end
    
    
    function [PLNG, AZIM, RBD] = octrot(I,J,B, SRF, data)
        %  SUBROUTINE OCTROT DETERMINES THE SMALLEST ROTATION ABOUT THE FOUR  *
        %  "OCTAHEDRAL" AXES (RELATIVE TO THE FAULT PLANE COORDINATES) NEEDED *
        %  TO MATCH THE SHEAR STRESS AND SLIP DIRECTIONS ON A FAULT PLANE;    *
        %  THE SMALLEST AMONG THESE FOUR OR THE THREE AXES TESTED IN SUBROU-  *
        %  TINE XPROTE IS TAKEN THE INITIAL GUESS OF THE OPTIMUM ROTATION     *
        %  AXIS (THE STARTING MODEL IN SUBROUTINE AXRFN)                      *
        
        % DIMENSION CN1(470,2),CE1(470,2),CD1(470,2),CN2(470),CE2(470),CD2(470),BDCR(4),B(3,3);
        % LOGICAL SRF
        % global CN1 CE1 CD1 CN2 CE2 CD2  %COMMON_DEF ONE
        SQ3I = 0.5773503; % data section
        K = 3-J;
        
        %   FIND THE ROTATIONS ABOUT THE 4 "OCTAHEDRAL" AXES (EQUALLY SPACED
        %   BETWEEN THE AXIS OF THE FAULT PLANE GEOMETRY);
        
        BDCR(1) = gernrot(I,J,B,RFIX,SQ3I,SQ3I,SQ3I,SRF);
        BDCR(2) = gernrot(I,J,B,RFIX,SQ3I,SQ3I,-SQ3I,SRF);
        BDCR(3) = gernrot(I,J,B,RFIX,SQ3I,-SQ3I,SQ3I,SRF);
        BDCR(4) = gernrot(I,J,B,RFIX,SQ3I,-SQ3I,-SQ3I,SRF);
        %
        %   SELECT THE SMALLEST OF THESE AND FIND ITS AXIS
        %
        LBD = 1;
        for L = 2 : 4  % DO until line 10
            if BDCR(L) > BDCR(LBD)
                LBD = L;
            end
        end % line 10
        F1 = 1.0;
        if LBD >= 3 , F1 = -F1; end
        F2 = 1.0;
        if MOD(LBD,2) == 0 , F2 = -F2; end
        CN = CN1(I,J) + F1*CN2(I) + F2*CN1(I,K);
        CE = CE1(I,J) + F1*CE2(I) + F2*CE1(I,K);
        CD = (CD1(I,J) + F1*CD2(I) + F2*CD1(I,K))*SQ3I;
        if CD < 0.0
            CN = -CN;
            CE = -CE;
            CD = -CD;
        end
        PLNG = asin(CD);
        AZIM = rem(atan2(CE,CN)+PI2,PI2);
        if BDCR(LBD) > 1.0
            BDCR(LBD) = SIGN(1.0,BDCR(LBD));
        end
        RBD = acos(BDCR(LBD));
    end
    
    
    
    function [YY, ZZ] = gernrot(I,KJ,B,RFIX,C1,C2,C3,SRF,Q)
        %  SUBROUTINE GENROT FINDS THE MAGNITUDE OF THE SMALLEST ROTATION     *
        %  ABOUT A SINGLE AXIS (OF GENERAL ORIENTATION) NEEDED TO MATCH A     *
        %  STRESS MODEL AND A FAULT PLANE GEOMETRY;  THIS IS ACCOMPLISHED     *
        %  BY CONSTRUCTING AND SOLVING A FOURTH-ORDER POLYNOMIAL EQUATION     *
        %  (SUBROUTINE POLY4)                                                 *
        
        %LOGICAL SRF
        %DIMENSION D(5),B(3,3),Y(4),Z(4);
        global A1 A2 A3 A4 A5 A6        % COMMON_DEF FOUR
        DEG20 = 0.00087266 ; % data section
        DELTA = DEG20;
        %
        %   SET UP COEFFICIENTS
        %
        while true  %  line 10
            C1C2 = C1*C2;
            C1C3 = C1*C3;
            C2C3 = C2*C3;
            C1C1 = C1*C1;
            C2C2 = C2*C2;
            C3C3 = C3*C3;
            B1 = C1C2*(A1*C1C1+A2*C2C2+A3*(C3C3-1.0)+2.0*(A6*C1C2+A5*C1C3+A4*C2C3))+A4*C1C3+A5*C2C3-A6*C3C3;
            B2 = C3*(C1C1*(A1-A3)+C2C2*(A3-A2))+A4*C2*(C2C2+C2C2-1.0)+A5*C1*(1.0-C1C1-C1C1);
            B3 = C1C2*(A1+A2-2.0*((A1*C1C1+A2*C2C2+A3*C3C3)+2.0*(A4*C2C3+A5*C1C3+A6*C1C2)))+A4*C1C3+A5*C2C3+A6*(1.0-C3C3);
            B4 = 2.0*(A4*C2*(1.0-C2C2)+A5*C1*(C1C1-1.0))+C3*(A1*(1.0-C1C1)-A2*(1.0-C2C2)+A3*(C1C1-C2C2));
            B5 = C1C2*(A1*(C1C1-1.0)+A2*(C2C2-1.0)+A3*(C3C3+1.0)+2.0*(A6*C1C2+A5*C1C3+A4*C2C3))+2.0*(A6*C3C3-A5*C2C3-A4*C1C3);
            B6 = B2*B4;
            B7 = B2*B2;
            B8 = B4*B4;
            D(1) = B5*B5+B8;
            %
            %   IF THE MAGNITUDE OF D(1) IS TOO SMALL, THE RESULTS OF THE FOLLOWING
            %   CALCULATIONS MAY BE IMPRECISE; MAKE SMALL ADJUSTMENTS IN THE AXIS
            %   ORIENTATION TO AVOID THIS CONDITION
            %
            if abs(D(1)) >= 1.0E-08
                break
            end
            DELTA = 1.1*DELTA;
            if abs(C1) > abs(C2)
                if abs(C1) > abs(C3)
                    if C1 > 1.0 , C1 = SIGN(1.0,C1); end
                    C1 = cos(acos(C1)+DELTA);
                    ZZ22 = 1.0-C1*C1-C3*C3;
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    C2 = sqrt(ZZ22);
                else
                    if C3 > 1.0 , C3 = SIGN(1.0,C3); end
                    C3 = cos(acos(C3)+DELTA);
                    ZZ22 = 1.0-C1*C1-C3*C3;
                    if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                    C2 = sqrt(ZZ22);
                end
            elseif abs(C2) > abs(C3)
                if C2 > 1.0 , C2 = SIGN(1.0,C2); end
                C2 = cos(acos(C2)+DELTA);
                ZZ22 = 1.0-C2*C2-C3*C3;
                if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                C1 = sqrt(ZZ22);
            else
                if C3 > 1.0 , C3 = SIGN(1.0,C3); end
                C3 = cos(acos(C3)+DELTA);
                ZZ22 = 1.0-C2*C2-C3*C3;
                if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
                C1 = sqrt(ZZ22);
            end
        end % while
        D(2) = 2.0*(B3*B5+B6);
        D(3) = 2.0*B1*B5+B3*B3+B7-B8;
        D(4) = 2.0*(B1*B3-B6);
        D(5) = B1*B1-B7;
        
        %   SOLVE 4TH ORDER POLYNOMIAL EQUATION FOR cos
        
        [Y] = POLY4(D);
        
        %   IF THE SIGN OF THE ROTATION IS NEEDED, SOLVE 4TH ORDER POLYNOMIAL
        %   EQUATION FOR sin ALSO
        
        if SRF
            B1 = B1+B5;
            D(2) = 2.0*(B3*B4-B2*B5);
            D(3) = B7-2.0*B1*B5+B3*B3-B8;
            D(4) = 2.0*(B1*B2-B3*B4);
            D(5) = B1*B1-B3*B3;
            [Z] = POLY4(D);
        end
        
        %   ARRANGE THE ROTATION SOLUTIONS IN ORDER OF INCREASING MAGNITUDES
        
        [YY, ZZ] = COSORT(1,Y,Z,SRF);
        
        %   IF NECESSARY, CHECK TO ENSURE THE PROPER SENSE OF SLIP ON THE
        %   ROTATED FAULT PLANE
        
        if SRF
            [YY,ZZ] = SSCHK(I,KJ,B,RFIX,[C1,C2,C3],Y,Z,YY,ZZ,Q);  %not entirely sure about SSCHK outputs
        end
    end
    
    function [YY, ZZ] = COSORT(J,Y,Z,SRF)
        %  SUBROUTINE COSORT ARRANGES THE SOLUTIONS FROM SUBROUTINE GENROT    *
        %  IN ORDER OF INCREASING MAGNITUDES                                  *
        
        % LOGICAL SRF
        % DIMENSION Y(4),Z(4);
        
        %   FIND THE JTH SMALLEST ROTATION (JTH LARGEST ANGLE COSINE), BY
        %   SORTING Y(I)--ARRAY OF UP TO 4 ROTATION ANGLE COSINES
        
        for K = 1:J   % DO until line 120
            if K ~= 4
                K1 = K+1;
                for L = K1 : 4  % DO until line 115
                    if Y(K) < Y(L) && Y(L) <= 1.0
                        YA = Y(K);
                        Y(K) = Y(L);
                        Y(L) = YA;
                    end
                end % line 115 for L
            end
        end % line 120 for K
        YY = Y(J);
        if abs(YY) > 1.0
            YY = SIGN(1.0,YY);
        end
        if ~SRF
            return
        end
        
        %   IF CHECKING SENSE OF SLIP, ASSOCIATE THE SOLUTIONS OF THE
        %   COSINE EQUATION, Y(I), WITH THE CORRESPONDING SOLUTIONS OF
        %   THE SINE EQUATION, Z(I);
        
        ZZ22 = 1.0-YY*YY;
        if ZZ22 < 0.0 , ZZ22 = 1.0E-30; end
        ZC = sqrt(ZZ22);
        for K = 1 : 4  % DO until line 125
            if abs(ZC-abs(Z(K))) <= 0.0001
                ZA = Z(J);
                Z(J) = Z(K);
                Z(K) = ZA;
            end
        end % line 125 K-loop
        for K = 1 : 4  % DO until line 130
            if K ~= J
                if abs(ZC-abs(Z(K))) < abs(ZC-abs(Z(J)))
                    ZA = Z(K);
                    Z(K) = Z(J);
                    Z(J) = ZA;
                end
            end
        end % line 130 K-loop
        if YY == 1.0
            YA = 1.0-Z(J)*Z(J);
            if YA < 0.0 , YA = 0.0; end
            YY = SIGN(sqrt(YA),YY);
        end
        ZZ = Z(J);
        return
    end
    
    function [Y] = POLY4(D)
        %  SUBROUTINE POLY4 (DOUBLE PRECISION) DETERMINES UP TO FOUR REAL     *
        %  ROOTS OF A FOURTH ORDER POLYNOMIAL EQUATION WITH COEFFICIENTS      *
        %  FOUND IN SUBROUTINE GENROT                                         *
        
        % IMPLICIT DOUBLE PRECISION (A-C,E-H,O-X,Z);
        % DIMENSION D(5),E(5),C(4),Y(4);
        for I = 2 : 5  % DO until line 10
            E(I) = DBLE(D(I)/D(1));
        end % line 10
        E(1) = 1.0D0;
        C_(4) = 1.0D0;
        C_(3) = -E(3);
        C_(2) = E(4)*E(2)-4.0*E(5);
        C_(1) = -E(4)*E(4)-E(5)*E(2)*E(2)+4.0*E(5)*E(3);
        [X] = POLY3(C_);
        RAUX = 0.25*E(2)*E(2)-E(3)+X;
        if RAUX < 0.0D0 , RAUX = 0.0D0; end
        R = DSQRT(RAUX);
        if R ~= 0.0D0
            F1 = 0.75*E(2)*E(2)-R*R-E(3)-E(3);
            F2=(E(2)*E(3)-E(4)-E(4)-0.25*E(2)*E(2)*E(2))/R;
        else
            F1 = 0.75*E(2)*E(2)-E(3)-E(3);
            FAUX = X*X-4.0*E(5);
            if FAUX < 0.0D0 , FAUX = 0.0D0; end
            F2 = 2.0*DSQRT(FAUX);
        end
        G = F1+F2;
        if G < 0.0D0
            Y(1) = -1.0;
            Y(2) = -1.0;
        else
            if G < 0.0 , G = 1.0E-30; end
            G = DSQRT(G);
            Y(1) = SNGL(0.5*(R-0.5*E(2)+G));
            Y(2) = SNGL(0.5*(R-0.5*E(2)-G));
        end
        H = F1-F2;
        if H < 0.0D0
            Y(3) = -1.0;
            Y(4) = -1.0;
        else
            if H < 0.0 , H = 1.0E-30; end
            H = DSQRT(H);
            Y(3) = SNGL(-0.5*(R+0.5*E(2)-H));
            Y(4) = SNGL(-0.5*(R+0.5*E(2)+H));
        end
    end
    
    function [X] = POLY3(C_)
        %  SUBROUTINE POLY3 (DOUBLE PRECISION) DETERMINES ONE REAL ROOT OF    *
        %  OF A THIRD ORDER POLYNOMIAL EQUATION, AS NEEDED IN SUBROUTINE      *
        %  POLY4                                                              *
        %                                                                     *
        %  NOTE:  VARIABLES IN THIS SUBROUTINE MAY ATTAIN EXTREME VALUES;     *
        %  E.G., ON VAX-11 COMPUTERS USE THE /G_FLOATING COMPILER OPTION      *
        
        % IMPLICIT DOUBLE PRECISION (A-H,O-Z);
        % DIMENSION C(4);
        OT = 0.3333333333333333D0; % data section
        TT = 0.6666666666666667D0; % data section
        SQRT2 = 1.414213562D0; % data section
        Q = C_(2)/3.0-C_(3)*C_(3)/9.0;
        R=(C_(2)*C_(3)-3.0*C_(1))/6.0-C_(3)*C_(3)*C_(3)/27.0;
        QA = DABS(Q);
        RA = DABS(R);
        DIV = QA;
        if RA > QA , DIV = RA; end
        S=(Q/DIV)*(Q/DIV)*Q+(R/DIV)*(R/DIV);
        if S >= 0.0D0
            if S < 0.0 , S = 1.0E-35; end
            S = DIV*DSQRT(S);
            R1 = R+S;
            S1=(DABS(R1)).^OT;
            S1 = DSIGN(S1,R1);
            R2 = R-S;
            S2=(DABS(R2)).^OT;
            S2 = DSIGN(S2,R2);
            X = S1+S2-C_(3)*OT;
        else
            C_(1) = -C_(1);
            C_(3) = -C_(3);
            C3 = C_(3)*OT;
            H1 = C_(3)*C3-C_(2);
            H2 = C_(1)-C_(2)*C3+2.0*C3*C3*C3;
            ZZ22 = TT*H1;
            if ZZ22 < 0.0D0 , ZZ22 = 1.0D-30; end
            H = DSQRT(ZZ22);
            H4 = H2*SQRT2/(H*H*H);
            if H4 > 1.0 , H4 = DSIGN(1.0D0,H4); end
            ALPHA=(DACOS(H4))*OT;
            if ALPHA > 1.0D0 , ALPHA = DSIGN(1.0D0,ALPHA); end
            X = H*SQRT2*DCOS(ALPHA)+C3;
        end
    end
    
    
    function [CRA, SR] = SSCHK(I,KJ,B,RFIX,CA,Y,Z,CRA,SR, Q)
        %  SUBROUTINE SSCHK TESTS TO ENSURE THAT THE ROTATIONS FOUND IN SUB-  *
        %  ROUTINE GENROT RESULT IN THE CORRECT SENSE OF SLIP ON THE FAULT    *
        %  PLANE                                                              *
        
        % DIMENSION CA(3),A(3,3),B(3,3),B1(3,3),Y(4),Z(4),AZ(470,2),DIP(470,2),Q(470);
        % LOGICAL SSLP,PASS1
        % global Q                 %COMMON_DEF THREE
        % global SSLP PASS1       % COMMON_DEF SIX
        
        %   INDICES AS IN SUBROUTNE AXRFN
        
        K = KJ;
        if KJ == 2 , K = 3; end
        L = 4-K;
        
        %   ROTATION AXIS COORDINATES: CA(I), ROTATION ANGLE COSINE =
        %   CRA, SINE = SR
        
        JF = 1;
        
        while true  % line 140
            if abs(CRA) > 1.0
                CRA = 1.0 * sign(CRA); %fortran: SIGN(1.0,CRA)
            end
            CCRA = 1.0-CRA;
            
            %   CALCULATE ROTATION MATRIX, A(I,J);
            
            for M = 1 : 3  % DO until line 150
                for N = M : 3  % DO until line 145
                    A(M,N) = CCRA*CA(M)*CA(N);
                    if M ~= N
                        A(N,M) = A(M,N);
                    end
                end % line 145
                A(M,M) = A(M,M)+CRA;
            end % line 150
            Q1 = 1.0;
            for M = 1 :2:3   % DO until line 160
                for N = 1 : 3  % DO until line 160
                    if M ~= N
                        A(M,N) = A(M,N)-Q1*SR*CA(6-M-N);
                        Q1 = -Q1;
                    end
                end % N 160
            end % M line 160
            
            %   FIND ROTATED FAULT PLANE GEOMETRY, B1(I,J);
            
            for M = [1,3]
                for N = [2,3]
                    B1(M,N) = A(M,1)*B(K,N) + A(M,2)*B(2,N) + A(M,3)*B(L,N);
                end
            end
            
            %   CHECK SENSE OF SLIP
            
            SSLP = Q(I)*(RFIX*B1(1,2)*B1(3,2)+B1(1,3)*B1(3,3)) < 0.0;
            
            %   IF THE SENSE OF SLIP IS INCORRECT AND THIS IS THE FINAL PASS,
            %   FIND THE NEXT SMALLEST ROTATION AND CHECK IT
            
            if ~(SSLP || PASS1)
                if JF ~= 4
                    JF = JF+1;
                    [CRA, SR] = COSORT(JF,Y,Z,true);
                    continue
                else
                    CRA = -1.0;
                    break
                end
            end
        end % while
        return
    end
    
    function value = SIGN(x,y)
        %fortran's sign function
        value = abs(x) * sign(y);
    end
    
    
    function params = read_params(filename)
        fid = fopen(filename);
        params.INFILE = fgetl(fid);         % INFILE
        params.OUTFILE = fgetl(fid);        % OUTFILE
        primary_stress_index = fgetl(fid);  % ISIG
        primary_pl_az_var = fgetl(fid);     % PLPRI, AZPRI, APPRI
        skip_directions_from_beginning = fgetl(fid); %DSKIP (y or n)
        if startsWith(skip_directions_from_beginning,'y', 'IgnoreCase',true)
            skip_how_many = fgetl(fid);  % NPS0
        else
            skip_how_many = "0";
        end
        secondary_pl_az_var = fgetl(fid);     % PLSEC, AZSEC, APSEC
        which_grid = fgetl(fid); % IGC,1 = 5-deg, 2 = 10-deg [default]
        rvals_lo_hi_step = fgetl(fid);
        meth = fgetl(fid); %METHOD, 1:POLE ROTATION, 2:APPROXIMATE',3:EXACT [DEFAULT]
        fclose(fid);
        
        % -- file has been read.
        %    now, interpret the values that we read
        
        params.ISIG = str2double(primary_stress_index);
        assert(params.ISIG == 1 || params.ISIG == 3)
        
        [primary_pl_az_var,cnt] = sscanf(primary_pl_az_var, '%f');
        assert(cnt == 3);
        params.PLPRI = primary_pl_az_var(1);
        params.AZPRI = primary_pl_az_var(2);
        params.APPRI = primary_pl_az_var(3);
        
        params.NPS0 = str2double(skip_how_many);
        
        [secondary_pl_az_var, cnt] = sscanf(secondary_pl_az_var, '%f');
        assert(cnt == 3);
        params.PLSEC = secondary_pl_az_var(1);
        params.AZSEC = secondary_pl_az_var(2);
        params.APSEC = secondary_pl_az_var(3);
        
        params.IGC = str2double(which_grid);
        params.GRD = params.IGC == 1;
        
        
        % convert in two steps to be more resilient/specific
        [rvals_lo_hi_step, cnt] = sscanf(rvals_lo_hi_step, '%f');
        assert(cnt == 3);
        params.RLOW = rvals_lo_hi_step(1);
        params.RHIGH = rvals_lo_hi_step(2);
        params.RSTEP = rvals_lo_hi_step(3);
        
        if params.RSTEP == 0
            params.KR = 1;
        else
            params.KR = fix((params.RHIGH-params.RLOW+0.001) / params.RSTEP) + 1;
        end
        assert(ismember(meth, '123'));
        params.METHOD = str2double(meth);
    end
    
    function [NFM, KFP, tb] = read_input(filename)
        % retrieves
        fid = fopen(filename,'r');
        NFM = fscanf(fid, '%f', 1); % # of data
        KFP = fscanf(fid, '%f', 1); % # of known fault planes [must be first]
        fclose(fid);
        tb = readtable(filename,'HeaderLines',1,'FileType','text','Format','%f %f %f %f %d');
        tb.Properties.VariableNames = {'AZ', 'DIP', 'AZ_B', 'DIP_B', 'Q'};
        tb.AZ = [tb.AZ tb.AZ_B];
        tb.AZ_B=[];
        tb.DIP = [tb.DIP, tb.DIP_B];
        tb.DIP_B=[];
    end
    
    function params = get_interactively()
        
        INFILE = input( ' ENTER NAME OF INPUT FILE: ','s');
        OUTFILE = input( ' ENTER NAME OF OUTPUT FILE: ','s');
        
        %   ENTER DATA FOR DETERMINING PRINCIPAL STRESS DIRECTIONS TO BE TESTED
        
        ISIG = input(' ENTER INDEX OF THE PRIMARY PRINCIPAL STRESS: (1 OR 3) :');
        assert(ISIG == 1 || ISIG == 3);
        JSIG = 4-ISIG;
        stuff = input("ENTER PLUNGE, AZIMUTH, AND VARIANCE <as '[pl, az, var]> OF 1ST  PRINCIPAL STRESS AXIS  --SIGMA "+ ISIG);
        assert(len(stuff)==3, 'Enter values as a 3-element vector (with brackets) [Plunge ,Azimuth, Variance]');
        PLPRI = stuff(1);
        AZPRI = stuff(2);
        APPRI = stuff(3);
        DSKIP = input('Skip any directions at the beginning? (Y/N) :','s'); %1s
        if startsWith(DSKIP, {'y','Y'})
            NPS0 = input(' skip how many? : ');
        else
            NPS0 = 0;
        end
        
        stuff = input("ENTER PLUNGE, AZIMUTH, AND VARIANCE <as '[pl, az, var]> OF 2nd  PRINCIPAL STRESS AXIS  --SIGMA " + JSIG);
        assert(len(stuff)==3, 'Enter values as a 3-element vector (with brackets) [Plunge ,Azimuth, Variance]');
        PLSEC = stuff(1);
        AZSEC = stuff(2);
        APSEC = stuff(3);
        IGC = input('WHICH GRID? (1)  5-DEGREE ,(2) 10-DEGREE [DEFAULT] :'); % as %1d
        GRD = IGC == 1;
        %
        %   ENTER DATA FOR DETERMINING VALUES OF R TO BE TESTED
        %
        %     disp( 'ENTER R VALUES (0-1):  LOWEST, HIGHEST, INCREMENT');
        stuff = input('ENTER R VALUES (0-1):  [LOWEST, HIGHEST, INCREMENT]');
        assert(len(stuff)==3, 'Enter values as a 3-element vector (with brackets) [lowest ,highest, increment]');
        RLOW = stuff(1);
        RHIGH = stuff(2);
        RSTEP = stuff(3);
        if RSTEP == 0.0
            KR = 1;
        else
            KR = fix((RHIGH-RLOW+0.001) / RSTEP) + 1;
        end
        
        %   SELECT A METHOD
        
        disp( 'WHICH METHOD?  (1) POLE ROTATION');
        disp( '               (2) APPROXIMATE');
        disp( '               (3) EXACT [DEFAULT]');
        METHOD = input();
        assert(ismember(METHOD,1:3), 'Method should be a value between 1 and 3');
        
        %   INPUT # OF DATA (NFM) AND # FOR WHICH FAULT PLANE IS KNOWN FROM
        %   THE 2 NODAL PLANES (KFP)--THESE MUST BE ENTERED BEFORE THOSE WITH
        %   UNKNOWN FAULT PLANES.
        
        fread(unit1, NFM, KFP); % FORMAT(2(1X,I3));
        RFXS = RLOW-RSTEP;
        RSMIN = 9999.0;
        WT = XPSET(NFM);
        PRISTR(ISIG,NPS0,GRD,WT,AZPRI,PLPRI,APPRI,AZSEC,PLSEC,APSEC);
        fprintf(fid_out_tmp3, ' Best Model (Weighted Averages in degrees) - %7.3f (%3d %3d %3d',RSMIN,NTAB,NR,NPHI);
        fprintf(' Best Model (Weighted Averages in degrees) - %7.3f (%3d %3d %3d',RSMIN,NTAB,NR,NPHI);
    end
    
end % main program
