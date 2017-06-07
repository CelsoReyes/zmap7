#include <stdio.h>
#include <math.h>
main(argc,argv)
int argc; 
char **argv;
{
	char line[100];
	double tr1[2000],tr2[2000],tr3[2000];
	double pl1[2000],pl2[2000],pl3[2000];
	double t1,t2,t3,d1,d2,d3;
	int flag;
	FILE *fpin,*fpout;
	char namein[20],nameout[20];
	float best[3][3],bestmag;
	float stress[3][3],mag;
	float dot[2000];
	float z;
	int i,j,k;
	float level,level95;
	float conf;
	float phi,phimin,phimax;

	phimin=1;
	phimax=0;

	if(argc!=4){
		printf("usage: plotboots *.slboot output_file confidence_level\n");
		return;
	}

	++argv;
	sscanf(*argv,"%s",namein);
	fpin=fopen(namein,"r");
	if(fpin==NULL){
		printf("unable to open %s\n",namein);
		return;
	}
	++argv;
	sscanf(*argv,"%s",nameout);
	fpout=fopen(nameout,"w");
	if(fpout==NULL){
		printf("unable to open %s\n",nameout);
		return;
	}
	++argv;
	sscanf(*argv,"%f",&conf);
	/* first go through file to find confidence level */
	fprintf(fpout,"title %s %g %% \nr 8.\nsize line 6\n",namein,conf);
	fgets(line,100,fpin);
	sscanf(line,"%f %f %f %f %f %f %f",&z,&best[0][0],&best[0][1],
	&best[0][2],&best[1][1],&best[1][2],&best[2][2]);
	best[1][0]=best[0][1];
	best[2][0]=best[0][2];
	best[2][1]=best[1][2];
	fgets(line,100,fpin);
	sscanf(line,"%f %lf %lf %lf %lf %lf %lf",&phi,&t1,&d1,&t2,&d2,&t3,&d3);
	fprintf(fpout,"symbol line 3 3\nl %5.1f %5.1f\n",t3,d3);
	fprintf(fpout,"symbol line 2 2\nl %5.1f %5.1f\n",t2,d2);
	fprintf(fpout,"symbol line 1 1\nl %5.1f %5.1f\n",t1,d1);
	tenmag(best,&bestmag);
	fprintf(fpout,"size line 3\n");
	i=0;
	while(fgets(line,100,fpin)!=NULL){
		sscanf(line,"%f %f %f %f %f %f %f",&z,&stress[0][0],&stress[0][1],
		&stress[0][2],&stress[1][1],&stress[1][2],&stress[2][2]);
		stress[1][0]=stress[0][1];
		stress[2][0]=stress[0][2];
		stress[2][1]=stress[1][2];
		fgets(line,100,fpin);
		tenmag(stress,&mag);
		tendot(best,stress,bestmag,mag,&dot[i]);
		i++;
	}
	sort(dot,i);
	j=i*((100.-conf)/100.);
	level95=dot[j];
	fclose(fpin);
	fpin=fopen(namein,"r");
	fgets(line,100,fpin);
	fgets(line,100,fpin);

	k=0;
	for(j=0;j<i;++j){
		fgets(line,100,fpin);
		sscanf(line,"%f %f %f %f %f %f %f",&z,&stress[0][0],&stress[0][1],
		&stress[0][2],&stress[1][1],&stress[1][2],&stress[2][2]);
		stress[1][0]=stress[0][1];
		stress[2][0]=stress[0][2];
		stress[2][1]=stress[1][2];
		fgets(line,100,fpin);
		sscanf(line,"%f %lf %lf %lf %lf %lf %lf",&phi,&tr1[k],&pl1[k],&tr2[k],&pl2[k],
		&tr3[k],&pl3[k]);
		tenmag(stress,&mag);
		tendot(best,stress,bestmag,mag,&level);
		if(level>=level95){
			k++;
			if(phi<phimin)phimin=phi;
			if(phi>phimax)phimax=phi;
		}
	}
	fprintf(fpout,"# phirange = %g %g\n",phimin,phimax);
	fprintf(fpout,"symbol line 1 1\n");
	for(i=0;i<k;++i)fprintf(fpout,"l %5.1f %5.1f\n",tr1[i],pl1[i]);
	fprintf(fpout,"symbol line 2 2\n");
	for(i=0;i<k;++i)fprintf(fpout,"l %5.1f %5.1f\n",tr2[i],pl2[i]);
	fprintf(fpout,"symbol line 3 3\n");
	for(i=0;i<k;++i)fprintf(fpout,"l %5.1f %5.1f\n",tr3[i],pl3[i]);
}

tendot(ten1,ten2,mag1,mag2,pdot)
float ten1[3][3];
float ten2[3][3];
float mag1,mag2;
float *pdot;
{
	int i,j;

	*pdot=0;
	for(i=0;i<3;++i)for(j=0;j<3;++j)*pdot+=ten1[i][j]*ten2[i][j];
	*pdot/=mag1*mag2;
	return;
}

tenmag(ten,pmag)
float ten[3][3];
float *pmag;
{
	int i,j;
	double z;

	z=0;
	for(i=0;i<3;++i)for(j=0;j<3;++j)z+=ten[i][j]*ten[i][j];
	z=sqrt(z);
	*pmag=z;
	return;
}
