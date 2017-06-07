/* --- The following code comes from c:\tmpsoft\lcc\lib\wizard\textmode.tpl. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void Usage(char *programName)
{
	fprintf(stderr,"%s usage:\n",programName);
	/* Modify here to add your usage message when the program is
	 * called without arguments */
}	

/* returns the index of the first argument that is not an option; i.e.
   does not start with a dash or a slash
*/
int HandleOptions(int argc,char *argv[])
{
	int i,firstnonoption=0;

	for (i=1; i< argc;i++) {
		if (argv[i][0] == '/' || argv[i][0] == '-') {
			switch (argv[i][1]) {
				/* An argument -? means help is requested */
				case '?':
					Usage(argv[0]);
					break;
				case 'h':
				case 'H':
					if (!stricmp(argv[i]+1,"help")) {
						Usage(argv[0]);
						break;
					}
					/* If the option -h means anything else
					 * in your application add code here 
					 * Note: this falls through to the default
					 * to print an "unknow option" message
					*/
				/* add your option switches here */
				default:
					fprintf(stderr,"unknown option %s\n",argv[i]);
					break;
			}
		}
		else {
			firstnonoption = i;
			break;
		}
	}
	return firstnonoption;
}

int main(int argc,char *argv[])
{
	if (argc == 1) {
		/* If no arguments we call the Usage routine and exit */
		Usage(argv[0]);
		return 1;
	}
	/* handle the program options */
	HandleOptions(argc,argv);
	/* The code of your application goes here */
	return 0;
}
