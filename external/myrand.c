/* I hate the unix random number generator it makes no sense */
/* this one is stolen from the HP-25 Application Program book */
#define PI 3.14159265358979323846
double myrand(px)
double *px; /* either the seed or the last number */
{
	double z;
	int i;

	z= *px+PI;
	z=z*z*z*z*z;
	i=z;
	*px=z-i;
	return(*px);
}


double seed()  /* gets a seed for myrand */
{
	int i;
	int tim;
	double z;

	tim=time(0);
	z=tim/100000.;
	i=z;
	z=z-i;
	return(z);
}
