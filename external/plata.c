#include <stdio.h>
main(argc,argv)  /* beach ball program */
/* puts output in file named by argv */
int argc; 
char **argv;
{
	float z,z2,z3;
	short i,j,k;
	char name[30];
	char line[80];
	char cap[40];
	FILE *fin,*fplot;

	/* find plotfile name */
	--argc; 
	++argv;
	if(argc){
		fin=fopen(*argv,"r");
		if(fin==NULL){
			printf("Unable to open %s.\n",*argv);
			return;
		}
		sprintf(name,"%s.plodc",*argv);
		fplot=fopen(name,"w");
		if(fplot==NULL){
			printf("Unable to open %s.\n",name);
			return;
		}
	}
	else {
		printf("Usage: a.out slick-file.\n");
		return;
	}
	/* get rid of header line */
	fgets(line,80,fin);
	fprintf(fplot,"title %s data\n",*argv);
	fprintf(fplot,"fatness plane 1\nfatness rake 2\n");
	fprintf(fplot,"r 6.\n");
	while(fscanf(fin,"%f %f %f",&z,&z2,&z3)!=EOF){
		fprintf(fplot,"plane %10.2f %10.2f\n",z,z2);
		fprintf(fplot,"rake %10.2f\n",z3);
	}
}
