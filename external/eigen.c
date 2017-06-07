#include <math.h>
eigen(a,lam,q)    /* subroutine to find eigen values and */
/* and eigenvectors of a 3 by 3 matrix */
/* at end eigenvalues are in lam and   */
/* the corresponding eigenvector is in */
/* q[i,*]                              */
/* does not destroy the matrix a       */


double a[3][3];  /* the matrix */
double lam[3];  /* the eigen values */
double q[3][3]; /* used to hold eigen vectors at end */
{
	double a2[3][3];  /* the matrix again */
	double r[3][3];  /* the decomposition matrices */
	/* q also used to hold eigenvectors at end */
	short i,j,k;   /* various indices */
	double x,y,z;   /* various holders */
	double shift;   /* shift value for shifted QR */
	double xx[3],b[3];

	/* set a2 for later use */
	for(i=0;i<3;++i){
		for(j=0;j<3;++j){
			a2[i][j]=a[i][j];
			r[i][j]=0.;
		}
	}

	/* do the QR */
	/* do the shift */
omt:  
	shift=a2[2][2];
	shift=shift*.999;
	for(i=0;i<3;++i)a2[i][i]=a2[i][i]-shift;
	for(j=0;j<3;++j){
		/* find v sub j */
		for(i=0;i<3;++i)q[i][j]=a2[i][j];
		r[j][j]=1.;
		if(j!=0){
			/* must subtract from q */
			for(k=0;k<j;++k){
				/* find coefficient */
				x=0;
				y=0;
				for(i=0;i<3;++i){
					x=x+q[i][k]*a2[i][j];
					y=y+q[i][k]*q[i][k];
				}
				z=x/y;
				r[k][j]=z;
				for(i=0;i<3;++i)q[i][j]=q[i][j]-z*q[i][k];
			}
		}
	}
	/* now normalize Q and R */
	for(j=0;j<3;++j){
		z=0;
		for(i=0;i<3;++i)z=z+q[i][j]*q[i][j];
		z=sqrt(z);
		for(i=0;i<3;++i){
			q[i][j]=q[i][j]/z;
			r[j][i]=r[j][i]*z;
		}
	}

	/* form a= RQ */
	for(i=0;i<3;++i){
		for(j=0;j<3;++j){
			x=0;
			for(k=0;k<3;++k)x=x+r[i][k]*q[k][j];
			a2[i][j]=x;
		}
	}
	for(i=0;i<3;++i)a2[i][i]=a2[i][i]+shift;
	/* check to see if new iteration needed */
	if(fabs(a2[2][1]) > fabs(.001*a2[2][2]))goto omt;
	if(fabs(a2[1][0]) > fabs(.001*a2[1][1]))goto omt;
	/* store eigen values */
	for(i=0;i<3;++i)lam[i]=a2[i][i];
	/* find eigen vectors now */
	for(k=0;k<3;++k){
		for(i=0;i<3;++i){
			for(j=0;j<3;++j){
				a2[i][j]=a[i][j];
				if(i==j)a2[i][j]=a2[i][j]-lam[k];
			}
			b[i]=0;
		}
		eigvec(a2,3,xx,b);
		for(i=0;i<3;++i)q[i][k]=xx[i];
	}

}
#include <math.h>
eigvec(a,m,x,b) /* solves ax=b for x by gaussian elimination */
/* set up expecially for eigenvectors (i.e.  */
/* for singular matrices)                    */

#define sub(I,J) (J+I*m)
short m;
double a[];  /* a square matrix of size m */
double b[];  /* a vector of length m */
double x[];  /* a vector of length m */
{
	short i,i2,i3;
	double d,hold,fact;
	double mag;

	/* take care of special cases */
	if(m<2){
		x[1]=0.;
		if(m==1) x[1]=b[1]/a[1];
		return ;
	}

	for(i=0;i<m;++i){     /* loop for each pivot */
		for(i2=i+1;i2<m;++i2){   /* loop for each row below a pivot */

			/* see if element below pivot is 0 */
			if(a[sub(i2,i)]==0.) continue;

			/* if element below pivot > pivot flop rows  */
			if(fabs(a[sub(i2,i)])>fabs(a[sub(i,i)])){
				hold=b[i];
				b[i]=b[i2];
				b[i2]=hold;
				for(i3=i;i3<m;++i3){
					hold=a[sub(i,i3)];
					a[sub(i,i3)]=a[sub(i2,i3)];
					a[sub(i2,i3)]=hold;
				}
			}

			/* do the elimination */ 
			fact=a[sub(i2,i)]/a[sub(i,i)];
			a[sub(i2,i)]=0.;
			for(i3=i+1;i3<m;++i3)a[sub(i2,i3)]=a[sub(i2,i3)]-fact*a[sub(i,i3)];
			b[i2]=b[i2]-fact*b[i];


		}
	}

	/* set small values to zero */
	mag=0.;
	for(i=0;i<m;++i){
		for(i2=0;i2<m;++i2)mag=mag+a[sub(i,i2)]*a[sub(i,i2)];
	}
	mag=sqrt(mag)/sqrt(2.);
	for(i=0;i<m;++i){
		for(i2=0;i2<m;++i2) 
			if(mag*.001 > fabs(a[sub(i,i2)]) ) a[sub(i,i2)]=0.;
	}

	/* solve the equations */
	if( a[m*m-1]==0.)x[m-1]=1.;
	else x[m-1]=b[m-1]/a[m*m-1];
	for(i=m-2;i> -1;--i){
		d=b[i];
		for(i2=i+1;i2<m;++i2)d=d-x[i2]*a[sub(i,i2)];
		if( a[sub(i,i)]==0.)x[i]=1.;
		else x[i]=d/a[sub(i,i)];
	}

	/* normalize the eigenvector */
	mag=0.;
	for(i=0;i<m;++i)mag=mag+x[i]*x[i];
	mag=sqrt(mag);
	if(mag == 0.)return;
	for(i=0;i<m;++i)x[i]=x[i]/mag;

	return ;
}
