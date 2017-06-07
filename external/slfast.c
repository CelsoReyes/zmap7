#include <math.h>
#include <stdio.h>
#define TORADS 57.29577951
#define MAXDATA 1000
#define MAX3 3000
/* COORDINATES ARE EAST,NORTH,UP */

main(argc,argv)  /* slickenside inversion program */
int argc;  /* argument count */
char **argv; /* argument string */
{
	double ddir[MAXDATA];  /* dip direction for data */
	double dip[MAXDATA];   /* dip of data */
	double rake[MAXDATA];  /* rake of data */
	short nobs;  /* number of observations */
	double amat[MAX3][5];  /* coefficient matrix for normal equation */
	double stress[6];  /* stress tensor in vector form, element order is: */
	/* xx,xy,xz,yy,yz,zz */
	double strten[3][3];  /* stress tensor in tensor form */
	double slick[MAX3];    /* slickenside vector elements vector */
	double n1,n2,n3;    /* normal vector elements */
	double norm[MAXDATA][3];  /* storage of n1,n2,n3 */
	short i,j,k;        /* dummy variables */
	double z,z2,z3;     /* more dummy variables */
	char name[20];      /* output file name */
	FILE *fpin;   /* input file pointer */
	FILE *fpout;  /* output file pointer */
	FILE *fplot;  /* plot file pointer */
	double a2[5][5],cc[5],sigma;  /* for use with leasq subr */
	double a2i[5][5];  /* to get covariance mtrix */
	double lam[3];  /* eigenvalues */
	double vecs[3][3];  /* eigenvectors */
	char line[80];  /* character line */
	double t[3];  /* shear stress vector */
	double iso;  /* isotropic stress mag */
	double angavg,angstd;  /* average and standard deviation of fit angle */
	double isoavg,isostd;  /* same for isotropic stress size */
	double magavg,magstd;  /* same for tangential stress size */
	double tf[3],tnorm;  /* full traction vector  */
	/* and normal traction */
	float phi;

	/* get file pointers */
	-- argc;  
	++argv;
	if(argc == 0){
		printf("usage: slfast data_file\n");
		return;
	}
	fpin=fopen(*argv,"r");
	if(fpin==NULL){
		printf("unable to open %s.\n",*argv);
		return;
	}
	sprintf(name,"%s.slboot",*argv);
	fpout=fopen(name,"a");
	if(fpout==NULL){
		printf("unable to open %s.\n",name);
		return;
	}

	/* read and write comment line from data file to output file */
	fgets(line,80,fpin);

	/* loop to get data and make up equation */
	nobs=0;
	while(fscanf(fpin,"%lf%lf%lf",&ddir[nobs],&dip[nobs],&rake[nobs])
	    != EOF )
	{
		i=nobs;
		j=3*nobs;
		++nobs;
		z=ddir[i]/TORADS;
		z2=dip[i]/TORADS;
		z3=rake[i]/TORADS;

		n1=sin(z)*sin(z2);  /* normal vector to fault plane */
		n2=cos(z)*sin(z2);
		n3=cos(z2);

		norm[i][0]=n1;
		norm[i][1]=n2;
		norm[i][2]=n3;

		/* slickenside vector calculation */
		slick[j]= -cos(z3)*cos(z)-sin(z3)*sin(z)*cos(z2);
		slick[j+1]= cos(z3)*sin(z)-sin(z3)*cos(z)*cos(z2);
		slick[j+2]= sin(z3)*sin(z2);

		/* find the matrix elements */
		amat[j][0]= n1-n1*n1*n1+n1*n3*n3;
		amat[j][1]= n2-2.*n1*n1*n2;
		amat[j][2]= n3-2.*n1*n1*n3;
		amat[j][3]= -n1*n2*n2+n1*n3*n3;
		amat[j][4]= -2.*n1*n2*n3;

		amat[j+1][0]= -n2*n1*n1+n2*n3*n3;
		amat[j+1][1]= n1-2.*n1*n2*n2;
		amat[j+1][2]= -2.*n1*n2*n3;
		amat[j+1][3]= n2-n2*n2*n2+n2*n3*n3;
		amat[j+1][4]= n3-2.*n2*n2*n3;

		amat[j+2][0]= -n3*n1*n1-n3+n3*n3*n3;
		amat[j+2][1]= -2.*n1*n2*n3;
		amat[j+2][2]= n1-2.*n1*n3*n3;
		amat[j+2][3]= -n3*n2*n2-n3+n3*n3*n3;
		amat[j+2][4]= n2-2.*n2*n3*n3;

		/* check to see if all possible data has been read */
		if(nobs==MAXDATA){
			fprintf(fpout,"NOT ALL DATA COULD BE READ.\n");
			break;
		}
	}  /* end of data read loop */

	/* solve equations via linear least squares */
	i=5;
	j= 3*nobs;
	leasq(amat,i,j,stress,slick,a2,cc,&sigma);
	fprintf(fpout,"%g ",sigma);
	/* fix zz element by using trace = 0 */
	stress[5]= -(stress[0]+stress[3]);

	/* put stress tensor into tensor form */
	strten[0][0]= stress[0];
	strten[0][1]= stress[1];
	strten[1][0]= stress[1];
	strten[0][2]= stress[2];
	strten[2][0]= stress[2];
	strten[1][1]= stress[3];
	strten[1][2]= stress[4];
	strten[2][1]= stress[4];
	strten[2][2]= stress[5];

	fprintf(fpout,"%g %g %g %g %g %g\n",stress[0],stress[1],stress[2],stress[3],
	stress[4],stress[5]);
	/* find  eigenvalues and eigenvectors */
	eigen(strten,lam,vecs);
	/* order eigenvalues and vectors and compute phi */
	i=1;
	while(i){
		i=0;
		for(j=0;j<2;++j){
			if(lam[j]>lam[j+1]){
				z=lam[j];
				lam[j]=lam[j+1];
				lam[j+1]=z;
				z=vecs[0][j];
				vecs[0][j]=vecs[0][j+1];
				vecs[0][j+1]=z;
				z=vecs[1][j];
				vecs[1][j]=vecs[1][j+1];
				vecs[1][j+1]=z;
				z=vecs[2][j];
				vecs[2][j]=vecs[2][j+1];
				vecs[2][j+1]=z;
				i=1;
			}
		}
	}
	if(lam[0] != lam[2]){
		phi=(lam[1]-lam[2])/(lam[0]-lam[2]);
		fprintf(fpout,"%g ",phi);
	}
	else fprintf(fpout,"2. "); /* error flag */
	for(i=0;i<3;++i){
		dirplg(vecs[0][i],vecs[1][i],vecs[2][i],&z,&z2);
		fprintf(fpout,"%5.1f  %5.1f  ",z,z2);
	}
	fprintf(fpout,"\n");
}
