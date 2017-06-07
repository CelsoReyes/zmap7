/* a program to run the bootstrap operation for slicks */
#include <stdio.h>
main(argc,argv)
int argc; 
char **argv;
{
	char headline[100];
	char data[100][100];
	char data2[100][100];
	double seed(),myrand(),rand;
	int nobs;
	int ntries;
	int n;
	int i,j,k;
	FILE *fpin,*fpout;
	char name[20];

	rand=seed();

	/* read in data */
	if(argc!=3){
		fprintf(stderr,"usage: bootboth file ntries\n");
		return;
	}

	++argv;
	sscanf(*argv,"%s",name);
	++argv;
	sscanf(*argv,"%d",&ntries);

	fpin=fopen(name,"r");
	if(fpin==NULL){
		fprintf(stderr,"unable to open %s.\n",name);
		return;
	}

	fgets(headline,100,fpin);
	nobs=0;
	while(fgets(&data[nobs][0],100,fpin)!=NULL)
		fgets(&data2[nobs++][0],100,fpin);

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
			fputs(&data[j][0],fpout);
			fputs(&data2[j][0],fpout);
		}
		fclose(fpout);
		system("./slfast Xtemp");
	}
}
