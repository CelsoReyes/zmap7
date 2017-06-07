/* to find ddir, dip, rake of other plane given same of first */
#include <math.h>
#define TORADS 57.29577951
switcher(ddir1,dip1,rake1,ddir2,dip2,rake2)
float ddir1,dip1,rake1;
float *ddir2,*dip2,*rake2;
{
	double z,z2,z3,s1,s2,s3,lam0,lam1;
	double n1,n2,n3,h1,h2;
	int j;

	z=ddir1/TORADS;
	if(dip1==90)dip1=89.99999;
	z2=dip1/TORADS;
	z3=rake1/TORADS;
	/* slick vector in plane 1 */
	s1= -cos(z3)*cos(z)-sin(z3)*sin(z)*cos(z2);
	s2= cos(z3)*sin(z)-sin(z3)*cos(z)*cos(z2);
	s3= sin(z3)*sin(z2);
	n1=sin(z)*sin(z2);  /* normal vector to plane 1 */
	n2=cos(z)*sin(z2);
	n3=cos(z2);
	h1= -s2; /* strike vector of plane 2 */
	h2= s1;
	/* note h3=0 always so we leave it out */
	stridip(s2,s1,s3,&z,&z2);
	z+= 90.;
	*ddir2=z;
	ranger(ddir2);
	*dip2=z2;
	z= h1*n1 + h2*n2;
	z/= sqrt(h1*h1 + h2*h2);
	z=acos(z);
	if(s3>=0)*rake2= z*TORADS;
	else *rake2= -z*TORADS;
}

ranger(z)
float *z;
/* makes z in 0 to 360 */
{
	while(*z>=360) *z-=360;
	while(*z<0) *z+=360;
}
