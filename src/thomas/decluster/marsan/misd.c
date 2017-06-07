#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>

#define R 6370.
#define PI 3.14159
#define GETL getline(&line,&len,in);
#define PRINTL printf("%s",line);
#define BGD_IMPOSED 1
#define BGD_POISSON 2
#define BGD_POISSON_PERIODIC 3
#define BGD_CLUSTER 4

float seuil,*mbin=NULL,*tbin=NULL,*rbin=NULL,**w,*w0,**lambda_t,**lambda_r,*lambda0,**keep_t,**keep_r,*keep0_r,*corr,surface;
int nmbin,ntbin,nrbin,N,col[4],sav[8],is_correction,is_latlon,bgd;
char name_data[100],name_correction[100],suffix[100];


void read_input(filename)
char filename[];
{
	char *line=NULL;
     size_t len=0;
	FILE *in;
	int i,j,n;
	float tmp;

	in=fopen(filename,"r");
	// DATA
	GETL GETL PRINTL
	GETL sscanf(line,"%s",name_data); printf("%s\n",name_data);
	GETL PRINTL
	GETL sscanf(line,"%d %d %d %d",&col[0],&col[1],&col[2],&col[3]); printf("%d %d %d %d\n",col[0],col[1],col[2],col[3]);
	GETL PRINTL
	GETL sscanf(line,"%d",&is_latlon); printf("%d\n",is_latlon);
	GETL PRINTL
	GETL sscanf(line,"%d",&is_correction); 
	if(is_correction) { sscanf(line,"%*d %s",name_correction); printf("1\t%s\n",name_correction); } else printf("0\n"); 
	// DISCRETIZATION
	GETL GETL PRINTL 
	i=0; while(fscanf(in,"%f",&tmp)) { i++; mbin=(float *)realloc(mbin,i*sizeof(float)); mbin[i-1]=tmp; } nmbin=i; 
	for(i=0;i<nmbin;i++) printf("%g\t",mbin[i]); printf("\n");
	GETL PRINTL
	i=0; while(fscanf(in,"%f",&tmp)) { i++; tbin=(float *)realloc(tbin,i*sizeof(float)); tbin[i-1]=tmp; } ntbin=i; 
	for(i=0;i<ntbin;i++) printf("%g\t",tbin[i]); printf("\n");
	GETL PRINTL
	i=0; while(fscanf(in,"%f",&tmp)) { i++; rbin=(float *)realloc(rbin,i*sizeof(float)); rbin[i-1]=tmp; } nrbin=i; 
	for(i=0;i<nrbin;i++) printf("%g\t",rbin[i]); printf("\n");
	// BACKGROUND
	GETL GETL PRINTL GETL PRINTL
	GETL sscanf(line,"%d",&bgd); if(bgd==BGD_IMPOSED) { lambda0=(float *)calloc(1,sizeof(float)); sscanf(line,"%*d %f",lambda0); }
	if(bgd==BGD_POISSON | bgd==BGD_POISSON_PERIODIC) sscanf(line,"%*d %f",&surface); printf("%d\n",bgd);
	// CONVERGENCE
	GETL GETL PRINTL
	GETL sscanf(line,"%f",&seuil); printf("%f\n",seuil);
	// OUTPUT
	GETL GETL PRINTL
	GETL sscanf(line,"%s",suffix); printf("%s\n",suffix);
	GETL PRINTL
	for(i=0;i<8;i++) { fscanf(in,"%d",&sav[i]); printf("%d ",sav[i]); } printf("\n");
	fclose(in);
	free(line);
}

void compute_r_latlon(lat,lon,r)
float *lat,*lon;
int **r;
{
	int i,j;
	float x,y,z,rr;

	for(i=0;i<N;i++) 
		for(j=i+1;j<N;j++)
		{
			x=R*(cos(lat[i]*PI/180.)*cos(lon[i]*PI/180.)-cos(lat[j]*PI/180.)*cos(lon[j]*PI/180.));
			y=R*(cos(lat[i]*PI/180.)*sin(lon[i]*PI/180.)-cos(lat[j]*PI/180.)*sin(lon[j]*PI/180.));
			z=R*(sin(lat[i]*PI/180.)-sin(lat[j]*PI/180.));
			rr=sqrt(x*x+y*y+z*z);
			r[i][j]=sort_r(rr);
			r[j][i]=r[i][j];
		}
}

void compute_r_xy(x,y,r)
float *x,*y;
int **r;
{
	int i,j;
	float s,rr;

	for(i=0;i<N;i++) 
		for(j=i;j<N;j++)
		{
			rr=sqrt((x[i]-x[j])*(x[i]-x[j])+(y[i]-y[j])*(y[i]-y[j])); 
			if(bgd==BGD_POISSON_PERIODIC) {
				s=sqrt((x[i]-x[j]-sqrt(surface))*(x[i]-x[j]-sqrt(surface))+(y[i]-y[j])*(y[i]-y[j])); if(s<rr) rr=s;
				s=sqrt((x[i]-x[j]+sqrt(surface))*(x[i]-x[j]+sqrt(surface))+(y[i]-y[j])*(y[i]-y[j])); if(s<rr) rr=s;
				s=sqrt((x[i]-x[j])*(x[i]-x[j])+(y[i]-y[j]-sqrt(surface))*(y[i]-y[j]-sqrt(surface))); if(s<rr) rr=s;
				s=sqrt((x[i]-x[j])*(x[i]-x[j])+(y[i]-y[j]+sqrt(surface))*(y[i]-y[j]+sqrt(surface))); if(s<rr) rr=s;
			}
			r[i][j]=sort_r(rr);
			r[j][i]=r[i][j];
		}
}

int sort_r(r)
float r;
{
	int s;

	if(r<rbin[0]) s=-1; 
	if(r>rbin[nrbin-1]) s=nrbin;
	if(r>=rbin[0] & r<=rbin[nrbin-1])
	{
		for(s=1;s<nrbin;s++) { if(r<=rbin[s]) break; } 
		s--;
	}
	return(s);
}

int sort_m(m)
float m;
{
	int z;

	if(m<mbin[0]) z=-1;
	if(m>=mbin[nmbin-1]) z=nmbin;
	if(m>=mbin[0] & m<mbin[nmbin-1]) { z=0; while(mbin[z]<=m) z++; z--; }
	return(z);
}		

		
void initialization_weights(m,r)
int *m,**r;
{
	int i,j;

	w=(float **)calloc(N,sizeof(float *));
	for(i=0;i<N;i++) w[i]=(float *)calloc(N,sizeof(float));
	
	for(i=0;i<N;i++)
		if(m[i]>=0 & m[i]<nmbin)
			for(j=i+1;j<N;j++)	
				if(r[i][j]>=0 & r[i][j]<nrbin)	
					w[i][j]=1;

	w0=(float *)calloc(N,sizeof(float));
	for(i=0;i<N;i++) w0[i]=1; 
}


void normalization_weights()
{
	int i,j;
	float tot;

	for(i=0;i<N;i++) 
	{
		tot=w0[i];
		for(j=0;j<i;j++) tot+=w[j][i];
		w0[i]/=tot;
		for(j=0;j<i;j++) w[j][i]/=tot;
	}
}

void step1(t,m,r)
float *t;
int *m,**r;
// compute weights w from lambda
{
	int i,j,k;
	float *ww;

	if(bgd==BGD_CLUSTER) ww=(float *)calloc(N,sizeof(float));

	for(i=0;i<N;i++) 
	{
		if(m[i]>=0 & m[i]<nmbin)
		{
			for(j=i+1;j<N;j++)
				if(t[j]-t[i]>tbin[0] & t[j]-t[i]<tbin[ntbin-1] & r[i][j]>=0 & r[i][j]<nrbin)
				{
					for(k=1;k<ntbin;k++) { if(t[j]-t[i]<tbin[k]) break; } k--;
					w[i][j]=lambda_t[m[i]][k]*lambda_r[m[i]][r[i][j]];
				}
				else w[i][j]=0;
		}
		else for(j=i+1;j<N;j++) w[i][j]=0; 
		if(bgd==BGD_IMPOSED | bgd==BGD_POISSON | bgd==BGD_POISSON_PERIODIC) w0[i]=*lambda0;
		if(bgd==BGD_CLUSTER) 
			for(j=0;j<N;j++)
				if(r[i][j]>=0 & r[i][j]<nrbin)
 					ww[i]+=lambda0[r[i][j]]*w0[j]/t[N-1];
	}
	if(bgd==BGD_CLUSTER) { for(i=0;i<N;i++) w0[i]=ww[i]; free(ww); }
	normalization_weights();
}

void step2(t,m)
float *t;
int *m;
// compute rates lambda_t(m,t) according to the time and magnitude intervals.
{
	int i,j,k,count[nmbin-1][ntbin-1];
	float tmax;

	for(i=0;i<nmbin-1;i++)
		for(j=0;j<ntbin-1;j++)
		{ lambda_t[i][j]=0; count[i][j]=0; }
	for(i=0;i<N-1;i++)
		if(m[i]>=0 & m[i]<nmbin)
		{
			tmax=0; for(k=1;k<ntbin;k++) { if(t[N-1]-t[i]<tbin[k]) break; tmax=tbin[k]; count[m[i]][k-1]++; } 
			for(j=i+1;j<N;j++)
			{ 
				if(t[j]-t[i]>=tmax) break;
				if(t[j]-t[i]>tbin[0])
				{
					for(k=1;k<ntbin;k++) { if(t[j]-t[i]<tbin[k]) break; } k--;
					lambda_t[m[i]][k]+=w[i][j]*corr[j];
				}
			} 
		}
	for(i=0;i<nmbin-1;i++)
		for(j=0;j<ntbin-1;j++)
			if(count[i][j])
				lambda_t[i][j]/=(count[i][j]*(tbin[j+1]-tbin[j]));
	if(bgd==BGD_POISSON | bgd==BGD_POISSON_PERIODIC) {
		*lambda0=0;
		for(i=0;i<N;i++) *lambda0+=w0[i]*corr[i]/(surface*t[N-1]);
	}
}			

void step3(t,m,r)
// compute densities lambda_r(m,r) according to the distance intervals.
float *t;
int *m,**r;
{
	int i,j;
	float tot;

	for(i=0;i<nmbin-1;i++)
		for(j=0;j<nrbin-1;j++) 
			lambda_r[i][j]=0;

	for(i=0;i<N-1;i++)
		if(m[i]>=0 & m[i]<nmbin)
			for(j=i+1;j<N;j++)
				if(r[i][j]>=0 & r[i][j]<nrbin)
					lambda_r[m[i]][r[i][j]]+=w[i][j]*corr[j];

	for(i=0;i<nmbin-1;i++)
	{
		tot=0; for(j=0;j<nrbin-1;j++) tot+=lambda_r[i][j];
		if(tot) for(j=0;j<nrbin-1;j++) lambda_r[i][j]/=(tot*PI*(rbin[j+1]*rbin[j+1]-rbin[j]*rbin[j]));
	}

	if(bgd==BGD_CLUSTER) {
		for(i=0;i<nrbin-1;i++) lambda0[i]=0;
		for(i=0;i<N;i++) 
			for(j=0;j<N;j++)
				if(r[i][j]>=0 & r[i][j]<nrbin) 
					lambda0[r[i][j]]+=w0[i]*w0[j]*corr[j];	
		tot=0; for(i=0;i<nrbin-1;i++) tot+=lambda0[i]; 
		if(tot) for(i=0;i<nrbin-1;i++) lambda0[i]/=(tot*PI*(rbin[i+1]*rbin[i+1]-rbin[i]*rbin[i])); 	
	}
}

void copy_rates()
{
	int i,j;

	for(i=0;i<nmbin-1;i++)
		for(j=0;j<ntbin-1;j++)
			keep_t[i][j]=lambda_t[i][j];
		
	for(i=0;i<nmbin-1;i++)
		for(j=0;j<nrbin-1;j++)
			keep_r[i][j]=lambda_r[i][j];
}

float test_convergence()
{
	float cv=0,tmp;
	int i,j;

	for(i=0;i<nmbin-1;i++) {
		for(j=0;j<ntbin-1;j++)
			if(keep_t[i][j]*lambda_t[i][j])
			{
				tmp=fabs(log(lambda_t[i][j])/log(keep_t[i][j])-1.);
				if(tmp>cv) cv=tmp;
			}
		for(j=0;j<nrbin-1;j++)
			if(keep_r[i][j]*lambda_r[i][j])
			{
				tmp=fabs(log(lambda_r[i][j])/log(keep_r[i][j])-1.);
				if(tmp>cv) cv=tmp;
			}
	}
	printf("** %f\n",cv);
	return(cv);
}


void save()
{
	FILE *out;
	int i,j;
	char name[100];

	// mbin
	if(sav[0]) {
	sprintf(name,"mbin%s",suffix); out=fopen(name,"w");
	for(i=0;i<nmbin;i++) fprintf(out,"%g\n",mbin[i]);
	fclose(out); }

	// tbin
	if(sav[1]) {
	sprintf(name,"tbin%s",suffix); out=fopen(name,"w");
	for(i=0;i<ntbin;i++) fprintf(out,"%g\n",tbin[i]);
	fclose(out); }

	// rbin
	if(sav[2]) {
	sprintf(name,"rbin%s",suffix); out=fopen(name,"w");
	for(i=0;i<nrbin;i++) fprintf(out,"%g\n",rbin[i]);
	fclose(out); }

	// lambda_t
	if(sav[3]) {
	sprintf(name,"lambda_t%s",suffix); out=fopen(name,"w");
	for(i=0;i<nmbin-1;i++)
	{
		for(j=0;j<ntbin-1;j++)
			fprintf(out,"%g\t",lambda_t[i][j]);
		fprintf(out,"\n");
	} fclose(out); }

	// lambda_r
	if(sav[4]) {
	sprintf(name,"lambda_r%s",suffix); out=fopen(name,"w");
	for(i=0;i<nmbin-1;i++)
	{
		for(j=0;j<nrbin-1;j++)
			fprintf(out,"%g\t",lambda_r[i][j]);
		fprintf(out,"\n");
	} fclose(out); }

	// lambda0
	if(sav[5]) {
	sprintf(name,"lambda0%s",suffix); out=fopen(name,"w");
	if(bgd==BGD_IMPOSED | bgd==BGD_POISSON | bgd==BGD_POISSON_PERIODIC) fprintf(out,"%g\n",*lambda0);
	if(bgd==BGD_CLUSTER) {
		for(i=0;i<nrbin-1;i++) 
			fprintf(out,"%g\n",lambda0[i]);
	}
	fclose(out); }

	// w
	if(sav[6]) {
	sprintf(name,"w%s",suffix); out=fopen(name,"w");
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
			fprintf(out,"%g ",w[i][j]);
		fprintf(out,"\n");
	} fclose(out); }

	// w0
	if(sav[7]) {
	sprintf(name,"w0%s",suffix); out=fopen(name,"w");
	for(i=0;i<N;i++)
		fprintf(out,"%g\n",w0[i]);
	fclose(out); }
}



int main(argc,argv)
int argc;
char *argv[];
// COMMAND LINE: misd_v1 input_file_name
{ 
	float a,b,c,*t=NULL,*lat=NULL,*lon=NULL,cv,tmp;
	int i,j,*m=NULL,**r;
	long offset;
	FILE *in;
	char name_input_file[100],*line=NULL;
     size_t len=0;
     ssize_t read;

	sscanf(argv[1],"%s",name_input_file);
	read_input(name_input_file);

	// MEMORY ALLOCATIONS
	lambda_t=(float **)calloc(nmbin-1,sizeof(float *)); for(i=0;i<nmbin-1;i++) lambda_t[i]=(float *)calloc(ntbin-1,sizeof(float));
	lambda_r=(float **)calloc(nmbin-1,sizeof(float *)); for(i=0;i<nmbin-1;i++) lambda_r[i]=(float *)calloc(nrbin-1,sizeof(float));
	if(bgd==BGD_POISSON | bgd==BGD_POISSON_PERIODIC) lambda0=(float *)calloc(1,sizeof(float)); 	
	if(bgd==BGD_CLUSTER) lambda0=(float *)calloc(nrbin-1,sizeof(float)); 
	keep_t=(float **)calloc(nmbin-1,sizeof(float *)); for(i=0;i<nmbin-1;i++) keep_t[i]=(float *)calloc(ntbin-1,sizeof(float));
	keep_r=(float **)calloc(nmbin-1,sizeof(float *)); for(i=0;i<nmbin-1;i++) keep_r[i]=(float *)calloc(nrbin-1,sizeof(float));
	keep0_r=(float *)calloc(nrbin-1,sizeof(float)); 

	// READ EARTHQUAKE DATA
	in=fopen(name_data,"r");
	offset=ftell(in);
	i=0;
	while(1)
	{	
		offset=ftell(in);
		for(j=0;j<col[0];j++) fscanf(in,"%f",&tmp); t=realloc(t,(i+1)*sizeof(float)); t[i]=tmp; fseek(in,offset,SEEK_SET);
		for(j=0;j<col[1];j++) fscanf(in,"%f",&tmp); m=realloc(m,(i+1)*sizeof(int)); m[i]=sort_m(tmp); fseek(in,offset,SEEK_SET);
		for(j=0;j<col[2];j++) fscanf(in,"%f",&tmp); lat=realloc(lat,(i+1)*sizeof(float)); lat[i]=tmp; fseek(in,offset,SEEK_SET);
		for(j=0;j<col[3];j++) fscanf(in,"%f",&tmp); lon=realloc(lon,(i+1)*sizeof(float)); lon[i]=tmp; fseek(in,offset,SEEK_SET);
		if(getline(&line,&len,in)==-1) break;
		i++; } N=i;
	fclose(in);
	printf("* FOUND %d EARTHQUAKES IN %s\n",N,name_data);
	
	r=(int **)calloc(N,sizeof(int *)); for(i=0;i<N;i++) r[i]=(int *)calloc(N,sizeof(int));
	if(is_latlon) compute_r_latlon(lat,lon,r); else compute_r_xy(lat,lon,r);
	corr=(float *)calloc(N,sizeof(float));
	if(is_correction) { in=fopen(name_correction,"r"); for(i=0;i<N;i++) fscanf(in,"%f",&corr[i]); fclose(in); }
	else for(i=0;i<N;i++) corr[i]=1.;

	// INITIALIZATION (WEIGHTS AND RATES)
	initialization_weights(m,r); 
	normalization_weights();
	step2(t,m);
	step3(t,m,r);

	// MAIN LOOP
	cv=seuil+1;
	while(cv>seuil)
	{
		copy_rates();
		step1(t,m,r);
		step2(t,m);
		step3(t,m,r);
		cv=test_convergence();
	}
	save();
	free(t); free(m); free(lat); free(lon); free(w0); for(i=0;i<N;i++) { free(r[i]); free(w[i]); } free(r); free(w); 
}




