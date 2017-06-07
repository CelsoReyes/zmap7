function [fDipDir, fDip, fRake] = ex_pt2fm(fPTrend, fPDip, fTTrend, fTDip)

TORADS = 57.29577951;

% /* COORDINATES ARE EAST,NORTH,UP */
%
% main(argc,argv)  /* converts from P and T trend and plunge to dip dir, dip ,
% rake */
% /* acts as a filter */
% int argc;  /* argument count */
% char **argv; /* argument string */
% {
% 	double ddir;  /* dip direction for data */
% 	double dip;   /* dip of data */
% 	double rake;  /* rake of data */
% 	double n[3],s[3],m[3];
% 	double p[3],t[3];
% 	double strike[3], updip[3];
% 	double paz,pplg,taz,tplg;
% 	short ii,i,j,k;        /* dummy variables */
% 	double z,z2,z3;     /* more dummy variables */
% 	char name[20];      /* output file name */
% 	FILE *fpin;   /* input file pointer */
% 	FILE *fpout;  /* output file pointer */
% 	FILE *fplot;  /* plot file pointer */
% 	char line[80];  /* character line */
%
% 	/* read and write comment line from data file to output file */
% 	fgets(line,80,stdin);
% 	fputs(line,stdout);
%
% 	while(scanf("%lf%lf%lf%lf",&paz,&pplg,&taz,&tplg)!= EOF){

		%/* compute p and t axes as vectors */
		fZ = fPTrend/TORADS;
		fZ2 = fPDip/TORADS;
		vP(1) = sin(fZ) * cos(fZ2);
		vP(2) = cos(fZ) * cos(fZ2);
		vP(3) = -1 * sin(fZ2);

		fZ = fTTrend/TORADS;
		fZ2 = fTDip/TORADS;
		vT(1) = sin(fZ) * cos(fZ2);
		vT(2) = cos(fZ) * cos(fZ2);
		vT(3) = -1 * sin(fZ2);

		%/* compute n and s vectors */
%		for(i=0;i<3;++i)s[i]=p[i]+t[i];
%   for(i=0;i<3;++i)n[i]=t[i]-p[i];
		vS = vP + vT;
    vN = vT - vP;

		%/* normal vector should point up out of hanging wall, if not reverse both */
% 		if(n[2]<0){
% 			for(i=0;i<3;++i)n[i]= -1*n[i];
% 			for(i=0;i<3;++i)s[i]= -1*s[i];
% 		}
    if vN(3) < 0
      vN = -1 * vN;
      vS = -1 * vS;
    end

		%/* get dip direction and dip */
		%stridip(n[1],n[0],n[2],&ddir,&dip);
    [fDipDir, fDip] = getStrikeDip(vN);

    % ddir+= 90; /* convert from strike to dip direction */
    fDipDir = fDipDir + 90;

		% while(ddir>360)ddir-=360;
    while (fDipDir > 360)
      fDipDir = fDipDir - 360;
    end

% 		/* compute rake */
% 		/* first need a coordinate system in the plane that is strike */
% 		/* direction and updip direction, these are both perpendicular to n */
% 		/* and in plane with s */

		fZ = fDipDir - 90; %/* this is the aziumth of strike */
		fZ = fZ / TORADS;

    vStrike(1) = sin(fZ);
    vStrike(2) = cos(fZ);
		vStrike(3) = 0;

		fZ = fDipDir / TORADS;
		fZ2 = fDip / TORADS;

		% /* updip points opposite horizontal direction horizontal of normal */
		vUpdip(1) = -1 * sin(fZ) * cos(fZ2);
		vUpdip(2) = -1 * cos(fZ) * cos(fZ2);
		vUpdip(3) = sin(fZ2);

		%/* project slip vector onto these coordinates */
		fZ = 0;
		%for(i=0;i<3;++i)z+=s[i]*strike[i];
    for i = 1:3
      fZ = fZ + vS(i) * vStrike(i);
    end

		fZ2=0;
		%for(i=0;i<3;++i)z2+=s[i]*updip[i];
    for i = 1:3
      fZ2 = fZ2 + vS(i) * vUpdip(i);
    end

    fRake = atan2(fZ2, fZ) * TORADS;
		%rake=atan2(z2,z)*TORADS;

		%printf("%f %f %f\n",ddir,dip,rake);


    [fDipDir, fDip] = getStrikeDip(vN);


%#include <math.h>

function [fDipDir, fDip] = getStrikeDip(vN)

% stridip(n,e,u,strike,dip)
% /* finds the strike and dip of a plane given its normal */
% /* vector, output is in degrees north of east and then  */
% /* uses a right hand rule for the dip of the plane */

TORAD = 57.29577951;

if vN(3) < 0
  vN = -vN;
end

fDipDir = atan2(vN(2), vN(1)) * TORAD;
fDipDir = fDipDir - 90;

if (fDipDir < 0)
  fDipDir = fDipDir + 360;
end
if (fDipDir > 360)
  fDipDir = fDipDir - 360;
end
fX = sqrt(vN(1)*vN(1) + vN(2)*vN(2));  % /* x is the horizontal magnitude */
fDip = atan2(fX, vN(3)) * TORAD;
