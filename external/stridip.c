#include <math.h>
stridip(n,e,u,strike,dip)
/* finds the strike and dip of a plane given its normal */
/* vector, output is in degrees north of east and then  */
/* uses a right hand rule for the dip of the plane */
#define TORAD  57.29577951
double n,e,u;
double *strike,*dip;
{
	double x;
	if(u <0.) {
		n= -n;
		e= -e;
		u= -u;
	}
	*strike=atan2(e,n)*TORAD;
	*strike= *strike-90.;
	if(*strike < 0.)*strike+= 360.;
	if(*strike > 360.)*strike-= 360.;
	x=sqrt(n*n+e*e);   /* x is the horizontal magnitude */
	*dip=atan2(x,u)*TORAD;
	return;
}
