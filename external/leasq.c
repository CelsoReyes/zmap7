leasq(a,m,n,x,b,a2,c,psis) /* finds the least squares solution of ax=b */

double a[]; /* the coefficients matrix with n rows and m columns */
double x[]; /* the solution vector of length m */
double b[]; /* the constant vector of length n */
double a2[]; /* a square matrix of size m for internal use */
double c[]; /* vector of length m for internal use */
short m,n; /* see above */
double *psis; /*pointer to the variance */

/* steps 1 a2= a transpose a */
/*       2 c= a transpose b */
/*       3 solve a2x=c by gaussian elimination */

{
	short i,j;
	atransa(a,m,n,a2);
	atransb(a,m,n,b,c);
	gaus(a2,m,x,c);
	sigsq(a,m,n,x,b,psis);
	return;
}


gaus(a,m,x,b) /* solves ax=b for x by gaussian elimination */


#define sub(I,J) (J+I*m)
short m;
double a[];  /* a square matrix of size m */
double b[];  /* a vector of length m */
double x[];  /* a vector of length m */
{
	short i,i2,i3;
	double d,hold,fact;
	double abs();

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
			if(abs(a[sub(i2,i)])>abs(a[sub(i,i)])){
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

	/* solve the equations */
	x[m-1]=b[m-1]/a[m*m-1];
	for(i=m-2;i> -1;--i){
		d=b[i];
		for(i2=i+1;i2<m;++i2)d=d-x[i2]*a[sub(i,i2)];
		x[i]=d/a[sub(i,i)];
	}
	return;
}


double abs(cc)
double cc;
{  
	double dd;
	dd=cc;  
	if(dd<0)dd= -dd; 
	return (dd); 
}



atransa(a,m,n,b) /* computes b=a transpose*a  */


#define sub(I,J) (J+I*m)
double a[];   /* a matrix of m columns and n rows */
double b[];    /* a square matrix of size m */
short m,n;

{
	short i,j,k;
	double bb;

	for(i=0;i<m;++i){
		for(j=i;j<m;++j){
			bb=0;
			for(k=0;k<n;++k) bb=bb+a[sub(k,i)]*a[sub(k,j)];
			b[sub(i,j)]=bb;
			b[sub(j,i)]=bb;
		}
	}
	return;
}



atransb(a,m,n,b,c) /* computes c= atranspose * b */
double a[];  /* a matrix of n rows and m columns  */
double b[];  /* vector of length n */
double c[];  /* vector of length m */
short m,n;   /* see above */

{   
	short i,i2;

	for(i=0;i<m;++i){ 
		c[i]=0.;
		for(i2=0;i2<n;++i2)c[i]=c[i]+a[sub(i2,i)]*b[i2];
	}
	return;
}

sigsq(a,m,n,x,b,psis) /* computes the variance of a */
/* single observation */
double a[];    /* matrix of n rows and m columns */
double b[];    /* data vector length n*/
double x[];    /* solution vector length m */
double *psis;  /* where to put answer */
short m,n;     /* see above */
{ 
	short i,j;    /* loop variables */
	double y,z,z2;     /* sum variables */

	z=0;
	for(i=0;i<n;++i){  /* loop over rows */
		y=0;
		for(j=0;j<m;++j)y+= a[sub(i,j)]*x[j];
		z+= (b[i]-y)*(b[i]-y);
	}

	if(n!=m){
		z2=(double)n-m;
		z=z/z2;
	}
	*psis=z;
}
