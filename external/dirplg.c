#include <math.h>
#define TORADS 57.2577951
dirplg(e,n,u,pdir,pplg) /* to find direction and plunge of a vector */
double e,n,u; /* the vector in east,north,up coordinates */
double *pdir,*pplg;  /* pointers to the direction in east of north */
/* and the plunge down the direction */
{
	double z;  /* dummy variable */
	z=e*e+n*n;
	z=sqrt(z);
	*pplg=atan2(-u,z)*TORADS;
	if(*pplg<0){
		*pplg= -*pplg;
		e= -e;
		n= -n;
	}
	*pdir=atan2(e,n)*TORADS;
}
