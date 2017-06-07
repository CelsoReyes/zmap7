/* a program to run the bootstrap operation for slicks */
#include <stdio.h>
main(argc,argv)
int argc; 
char **argv;
{
	char headline[100];
	char data[800][100];
	char dataf[800][100];
	double seed(),myrand(),rand;
	int nobs;
	int ntries;
	int n;
	int i,j,k;
	FILE *fpin,*fpout;
	char name[20];
	float dip1,ddir1,rake1;
	float dip2,ddir2,rake2;
	float frac;

	rand=seed();

	/* read in data */
	if(argc!=4){
		fprintf(stderr,"usage: bootslickw file ntries frac\n");
		return;
	}

	++argv;
	sscanf(*argv,"%s",name);
	++argv;
	sscanf(*argv,"%d",&ntries);
	++argv;
	sscanf(*argv,"%f",&frac);

	fpin=fopen(name,"r");
	if(fpin==NULL){
		fprintf(stderr,"unable to open %s.\n",name);
		return;
	}

	fgets(headline,100,fpin);
	nobs=0;
	while(fgets(&data[nobs][0],100,fpin)!=NULL){
		sscanf(&data[nobs][0],"%f %f %f",&ddir1,&dip1,&rake1);
		switcher(ddir1,dip1,rake1,&ddir2,&dip2,&rake2);
		sprintf(&dataf[nobs][0],"%g %g %g\n",ddir2,dip2,rake2);
		nobs++;
	}

	for(i=0;i<ntries;++i){
		fpout=fopen("Xtemp","w");
		if(fpout==NULL){
			fprintf(stderr,"unable to open Xtemp\n");
			return;
		}
		fputs(headline,fpout);
		for(n=0;n<nobs;++n){
			rand=myrand(&rand);
			j=rand*nobs;
			if(j==nobs)j=nobs-1;
			if(myrand(&rand)>=frac)fputs(&data[j][0],fpout);
			else fputs(&dataf[j][0],fpout);
		}
		fclose(fpout);
		slfast("Xtemp");
	}
}
